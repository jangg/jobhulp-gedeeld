-- ==================================================================
-- Migratie 2026-10-08 — tabel enquete verwijderen (obsolete, besluit Jan)
-- Voor: BEIDE intranetten (MAMP: intraDB en jhcintradb, daarna Versio)
--
-- LET OP: dit verwijdert de tabel met alle antwoorden definitief.
-- Maak vooraf een export/back-up als je de antwoorden nog wilt bewaren.
-- De code die deze tabel gebruikte (enquete.php, includes/chk_enquete.inc)
-- is al verwijderd.
-- ==================================================================

DROP TABLE IF EXISTS `enquete`;
