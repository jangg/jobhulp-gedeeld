-- ==================================================================
-- Migratie 2026-10-08 — tabel pubquizteams verwijderen (eenmalig gebruikt, besluit Jan)
-- Voor: BEIDE intranetten (MAMP: intraDB en jhcintradb, daarna Versio)
--
-- De code die deze tabel gebruikte (pubquiz.php, pubquizantw.php, score.php,
-- pages/pubquizregels.php) is al verwijderd. Maak vooraf een back-up.
-- ==================================================================

DROP TABLE IF EXISTS `pubquizteams`;
