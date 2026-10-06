-- ==================================================================
-- Migratie 2026-10-06 — database-structuur gelijktrekken
-- Voor: intra-culemborg (MAMP: jhcintradb, daarna de database op Versio)
--
-- Uitvoeren in phpMyAdmin: kies de database, tab "SQL", plak dit
-- bestand en klik op "Start". Maak vooraf een export/back-up.
-- ==================================================================

-- keytabel.waarde: char(20) -> varchar(500) (zoals Zoetermeer).
-- Groter maken is veilig: bestaande waarden blijven gewoon staan.
ALTER TABLE `keytabel` MODIFY `waarde` varchar(500) CHARACTER SET utf8 NOT NULL;
