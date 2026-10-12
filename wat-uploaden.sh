#!/bin/bash
# ------------------------------------------------------------------
# Welke bestanden moeten nog naar de server? (okt 2026)
#
# In elke site wijst de git-tag "op-server" naar de stand die op de server
# staat. Dit script toont per site het verschil tussen die tag en de
# branch main: alleen main gaat naar de server. Nieuwe functies worden
# gebouwd in een eigen branch (nu: documenten) en gaan pas mee als ze
# klaar zijn en in main zijn samengevoegd.
#
# LET OP: Transmit uploadt wat er in de map staat. Upload dus alleen als
# de site op main staat (het script waarschuwt anders). Wisselen: ./wissel.sh
#
#   ./wat-uploaden.sh                 alle vier de sites
#   ./wat-uploaden.sh pub-jhc         één site
#   ./wat-uploaden.sh --klaar pub-jhc na het uploaden: tag verzetten naar nu
#
# Niet in de lijst: configDB.php (wachtwoorden; op de server zelf bijwerken),
# .gitignore en *.voorbeeld.php (horen bij git, niet op de server).
# ------------------------------------------------------------------
cd "$(dirname "$0")"
SITES="intra-culemborg intra-jhmz pub-jhc pub-jhmz"

if [ "$1" = "--klaar" ]; then
	[ -d "$2/.git" ] || { echo "Gebruik: ./wat-uploaden.sh --klaar <site>"; exit 1; }
	if [ -n "$(git -C "$2" status --porcelain)" ]; then
		echo "$2 heeft nog niet-gecommitte wijzigingen. Eerst committen (vraag Claude)."; exit 1
	fi
	git -C "$2" tag -f op-server main >/dev/null && echo "$2: op-server staat nu op $(git -C "$2" log --oneline -1 main)"
	exit 0
fi
[ -n "$1" ] && SITES="$1"

for s in $SITES; do
	echo "=== $s  (op de server: $(git -C "$s" log --oneline -1 op-server 2>/dev/null || echo 'GEEN TAG op-server'))"
	tak=$(git -C "$s" branch --show-current)
	if [ "$tak" != "main" ]; then
		echo "   !! Deze map staat op branch '$tak', niet op main. NIET uploaden; eerst ./wissel.sh main"
	elif [ -n "$(git -C "$s" status --porcelain)" ]; then
		echo "   !! Er zijn nog niet-gecommitte wijzigingen; die staan hieronder niet. Eerst committen (vraag Claude)."
	fi
	{
		git -C "$s" diff --name-status --no-renames op-server main
	} | grep -v -E $'\t(includes/configDB\\.php|\\.gitignore|.*\\.voorbeeld\\.php)$' | sort -u -k2 | awk -F'\t' '
		$1=="D" { weg[++w]=$2; next }
		        { op[++u]=$2 }
		END {
			if (u==0 && w==0) { print "   niets: de server is bij\n"; exit }
			if (u) { print "   Uploaden (" u "):"; for (i=1;i<=u;i++) print "     " op[i] }
			if (w) { print "   Verwijderen op de server (" w "):"; for (i=1;i<=w;i++) print "     " weg[i] }
			print ""
		}'
done
