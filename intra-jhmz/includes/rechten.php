<?php
/* ------------------------------------------------------------------
 * Rechten voor JobHulpMaatje Zoetermeer
 *
 * Per recht staat hier welke beheerind-niveaus het hebben.
 * range(1, 9) betekent: 1, 2, 3, 4, 5, 6, 7, 8 en 9.
 * Dit bestand verschilt per site; config.php, navbar.php en de pagina's niet.
 * Nieuw recht nodig? Voeg hier een regel toe (in BEIDE sites) en gebruik
 * heeft_recht('naam') of require_recht('naam').
 * ------------------------------------------------------------------ */
/* Niveaus Zoetermeer (zo staan ze in de database, user.beheerind):
 *   0 = intranet zonder forum      1 = + forum lezen       2 = + redactie
 *   3 = WAS inzien                 4 = WAS wijzigen (maatjes alleen inzien)
 *   5 = 2 + 3 (redactie + WAS inzien)                      6 = 2 + 4
 *   7 en 8 = 6 + maatjes wijzigen  9 = beheerder
 */
define('RECHTEN', [
	'forum_lezen'       => range(1, 9),
	'forum_schrijven'   => range(2, 9),
	'redactie'          => [2, 5, 6, 7, 8, 9],
	'was_lezen'         => range(3, 9),
	'was_wijzigen'      => [4, 6, 7, 8, 9],
	'maatjes_wijzigen'  => [7, 8, 9],       // 8 = 7
	'presentie_anderen' => [7, 8, 9],       // aanwezigheid van anderen aan/uit zetten
	'beheerder'         => [9],
]);
