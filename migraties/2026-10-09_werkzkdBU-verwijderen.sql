-- ==================================================================
-- Migratie 2026-10-09 — tabel werkzkdBU verwijderen
-- Voor: BEIDE intranetten. In MAMP al gedaan door Jan (9 okt); nog op Versio.
--
-- werkzkdBU was een oude reservekopie van werkzkd en wordt nergens in de
-- code gebruikt. Maak vooraf een back-up.
-- ==================================================================

DROP TABLE IF EXISTS `werkzkdBU`;
