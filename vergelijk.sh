#!/bin/bash
# ==================================================================
# vergelijk.sh — controleert of beide intranetten gelijk lopen in:
#   1. de map class/      (de PHP-classes moeten 100% gelijk zijn)
#   2. de database-structuur (tabellen, kolommen, indexen)
#
# Gebruik (in Terminal):
#   cd ~/Sites/jobhulp-intra
#   ./vergelijk.sh
#
# Draai dit vóór elke upload naar Versio. MAMP moet aan staan.
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

# --- 1. Classes ----------------------------------------------------
echo "== 1. Classes vergelijken"
# diff -r vergelijkt mappen recursief; -x .DS_Store negeert macOS-rommel
if diff -r -x .DS_Store intra-jhmz/class intra-culemborg/class; then
	echo "   OK: classes zijn gelijk"
else
	echo "   LET OP: classes verschillen (zie hierboven; < = jhmz, > = culemborg)"
	FOUT=1
fi

# --- 2. Database-structuur -----------------------------------------
echo "== 2. Database-structuur vergelijken"
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
