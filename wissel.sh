#!/bin/bash
# ------------------------------------------------------------------
# Alle vier de sites tegelijk op dezelfde branch zetten (okt 2026).
#
#   ./wissel.sh main         wat op de servers staat + verbeteringen (uploaden)
#   ./wissel.sh documenten   main + de documentenfunctie in ontwikkeling (testen in MAMP)
#   ./wissel.sh              laat zien op welke branch elke site staat
#
# Alle vier tegelijk, omdat class/ overal gelijk moet zijn (vergelijk.sh).
# Wisselen kan alleen als er niets ongecommit is; anders eerst Claude laten committen.
# ------------------------------------------------------------------
cd "$(dirname "$0")"
SITES="intra-culemborg intra-jhmz pub-jhc pub-jhmz"
if [ -z "$1" ]; then
	for s in $SITES; do echo "$s: $(git -C "$s" branch --show-current)"; done; exit 0
fi
for s in $SITES; do
	if [ -n "$(git -C "$s" status --porcelain)" ]; then
		echo "$s heeft niet-gecommitte wijzigingen. Er is niets gewisseld."; exit 1
	fi
	git -C "$s" rev-parse --verify -q "$1" >/dev/null || { echo "$s heeft geen branch '$1'. Er is niets gewisseld."; exit 1; }
done
for s in $SITES; do git -C "$s" checkout -q "$1" && echo "$s: nu op $1"; done
