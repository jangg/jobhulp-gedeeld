#!/bin/bash
# ==================================================================
# vergelijk.sh — controleert of de vier websites gelijk lopen:
#
#   intra-jhmz       intranet Zoetermeer      (intra.jhmz.nl)  <- leidend (sinds 28 okt 2026)
#   intra-culemborg  intranet Culemborg       (intra.jobhulpculemborg.nl)
#   pub-jhmz         publieke site Zoetermeer (jobhulpmaatjezoetermeer.nl)
#   pub-jhc          publieke site Culemborg  (jobhulpculemborg.nl)
#
#   1. class/ moet in alle vier de sites 100% gelijk zijn
#   2. gedeelde bestanden:
#        - includes/rechten.php gelijk in beide intranetten
#        - includes/statuslijst.php gelijk binnen een organisatie
#          (verschilt per organisatie, dus NIET tussen Zoetermeer en Culemborg)
#        - config.php van elke site heeft h() en SET NAMES utf8mb4
#   3. git: openstaande wijzigingen per site (alleen ter informatie)
#   4. de database-structuur van beide organisaties (MAMP moet aan staan)
#
# Gebruik (in Terminal):
#   cd ~/Sites/jobhulp-intra
#   ./vergelijk.sh            # kort: welke bestanden verschillen
#   ./vergelijk.sh -v         # uitgebreid: ook de verschillen per regel
#
# Draai dit vóór elke upload naar Versio.
# ==================================================================
# --- Instellingen (pas aan als je databasenamen veranderen) --------
DB_JHMZ="intraDB"
DB_JHC="jhcintradb"
DB_USER="root"
DB_PASS="root"
DB_HOST="127.0.0.1"
DB_PORT="8889"
# MAMP-MySQL is ook bereikbaar via een socket-bestand (zo verbindt PHP met
# "localhost"). Dat werkt ook als netwerktoegang in MAMP uit staat.
DB_SOCKET="/Applications/MAMP/tmp/mysql/mysql.sock"

cd "$(dirname "$0")" || exit 1     # altijd vanuit de map van dit script
FOUT=0

# --- Hulpjes -------------------------------------------------------
SITES="intra-jhmz intra-culemborg pub-jhmz pub-jhc"
LEIDEND="intra-jhmz"
UITGEBREID=0
[ "$1" = "-v" ] && UITGEBREID=1

ok()   { echo "   OK:      $1"; }
fout() { echo "   LET OP:  $1"; FOUT=1; }
info() { echo "   info:    $1"; }

# vergelijk_map A B: geeft 0 als de mappen gelijk zijn.
# -q: alleen de namen van verschillende bestanden; met -v de volledige verschillen.
vergelijk_map() {
	if [ $UITGEBREID = 1 ]; then
		diff -r -x .DS_Store "$1" "$2"
	else
		diff -rq -x .DS_Store "$1" "$2" | sed 's/^/            /'
		[ "${PIPESTATUS[0]}" = 0 ]
	fi
}
vergelijk_bestand() {
	if [ $UITGEBREID = 1 ]; then diff "$1" "$2"; else cmp -s "$1" "$2"; fi
}

# --- 0. Welke sites zijn er? ---------------------------------------
echo "== 0. Sites"
AANWEZIG=""
for S in $SITES; do
	if [ -d "$S/class" ]; then AANWEZIG="$AANWEZIG $S"; info "$S"
	else info "$S ontbreekt (overgeslagen)"; fi
done

# --- 1. Classes ----------------------------------------------------
echo "== 1. class/ (vergeleken met $LEIDEND, dat is leidend)"
for S in $AANWEZIG; do
	[ "$S" = "$LEIDEND" ] && continue
	if vergelijk_map "$LEIDEND/class" "$S/class"; then
		ok "class/ van $S is gelijk"
	else
		fout "class/ van $S verschilt (zie hierboven; links = $LEIDEND)"
	fi
done

# --- 2. Gedeelde bestanden -----------------------------------------
echo "== 2. Gedeelde bestanden"
if vergelijk_bestand intra-jhmz/includes/rechten.php intra-culemborg/includes/rechten.php; then
	ok "includes/rechten.php is gelijk in beide intranetten"
else
	fout "includes/rechten.php verschilt tussen de intranetten"
fi
# Statuslijst: gelijk binnen een organisatie (intranet = publieke site).
for PAAR in "intra-jhmz pub-jhmz" "intra-culemborg pub-jhc"; do
	set -- $PAAR          # $1 = intranet, $2 = publieke site
	[ -d "$2" ] || continue
	if [ ! -f "$2/includes/statuslijst.php" ]; then
		fout "$2/includes/statuslijst.php ontbreekt"
	elif vergelijk_bestand "$1/includes/statuslijst.php" "$2/includes/statuslijst.php"; then
		ok "statuslijst.php van $2 is gelijk aan die van $1"
	else
		fout "statuslijst.php van $2 verschilt van die van $1"
	fi
done
# config.php: de gedeelde classes hebben h() nodig, de database is utf8mb4.
for S in $AANWEZIG; do
	F="$S/config.php"
	grep -q "function h(" "$F"   || fout "$F: function h() ontbreekt"
	grep -q "utf8mb4" "$F"        || fout "$F: SET NAMES utf8mb4 ontbreekt"
	grep -q "function h(" "$F" && grep -q "utf8mb4" "$F" && ok "$F heeft h() en utf8mb4"
done

# --- 3. Git --------------------------------------------------------
echo "== 3. Git (openstaande wijzigingen; ter informatie)"
for S in . $AANWEZIG; do
	NAAM=$S; [ "$S" = "." ] && NAAM="hoofdmap (gedeeld)"
	if [ ! -d "$S/.git" ]; then info "$NAAM: geen git-repository"; continue; fi
	AANTAL=$(git -C "$S" status --short | wc -l | tr -d ' ')
	if [ "$AANTAL" = 0 ]; then info "$NAAM: alles gecommit"
	else info "$NAAM: $AANTAL openstaande wijziging(en)"; fi
done

# --- 4. Database-structuur -----------------------------------------
echo "== 4. Database-structuur (beide organisaties)"
# MAMP levert zijn eigen mysqldump mee; de plek verschilt per MAMP-versie.
DUMP=$(ls /Applications/MAMP/Library/bin/mysqldump /Applications/MAMP/Library/bin/*/bin/mysqldump 2>/dev/null | head -1)
echo "   gebruikt: $DUMP"
if [ -z "$DUMP" ]; then
	echo "   mysqldump van MAMP niet gevonden, stap overgeslagen"
	exit $FOUT
fi

# Verbinding kiezen: socket als die bestaat, anders host + poort.
if [ -S "$DB_SOCKET" ]; then        # -S: bestaat en is een socket
	VERBINDING=(--socket="$DB_SOCKET")
else
	VERBINDING=(-h "$DB_HOST" -P "$DB_PORT")
fi

structuur() {
	# --no-data: alleen de structuur, geen gegevens.
	local uit
	# 2>&1 vangt ook de foutmelding op, zodat we die kunnen laten zien.
	uit=$("$DUMP" "${VERBINDING[@]}" -u "$DB_USER" -p"$DB_PASS" \
		--no-data --skip-comments "$1" 2>&1) || { echo "$uit" | grep -v "Using a password" >&2; return 1; }
	# De waarschuwing over het wachtwoord op de commandoregel is onschuldig; weghalen.
	uit=$(echo "$uit" | grep -v "Using a password")
	# sed haalt de teller AUTO_INCREMENT=123 weg; die verschilt altijd en is geen structuur.
	echo "$uit" | sed -E 's/ AUTO_INCREMENT=[0-9]+//'
}

# "|| { ...; }" wordt alleen uitgevoerd als het commando ervoor mislukt
A=$(structuur "$DB_JHMZ") || { echo "   FOUT: kan database $DB_JHMZ niet lezen (staat MAMP aan?)"; exit 1; }
B=$(structuur "$DB_JHC")  || { echo "   FOUT: kan database $DB_JHC niet lezen (staat MAMP aan?)"; exit 1; }

# <( ... ) geeft tekst door aan diff alsof het een bestand is
if diff <(echo "$A") <(echo "$B"); then
	echo "   OK: database-structuur is gelijk"
else
	echo "   LET OP: database-structuur verschilt (< = $DB_JHMZ, > = $DB_JHC)"
	FOUT=1
fi

exit $FOUT
