-- ==================================================================
-- Migratie 2026-10-07 — wachtwoorden als hash + "wachtwoord vergeten"-link
-- Voor: BEIDE intranetten (MAMP: intraDB en jhcintradb, daarna Versio)
--
-- Uitvoeren in phpMyAdmin: kies de database, tab "SQL", plak dit
-- bestand en klik op "Start". Maak vooraf een export/back-up.
-- Deze migratie moet draaien VÓÓR de nieuwe code online staat.
-- Daarna eenmalig: maintenance/hash_wachtwoorden.php
-- ==================================================================

ALTER TABLE `user`
  -- Een hash van password_hash() is nu 60 tekens; 255 laat ruimte voor
  -- sterkere methodes in de toekomst (advies uit de PHP-handleiding).
  ADD `password_hash` varchar(255) DEFAULT NULL AFTER `password`,
  -- sha256 van de token uit de reset-link: altijd precies 64 tekens.
  ADD `reset_hash` char(64) DEFAULT NULL AFTER `password_mod`,
  ADD `reset_expires` datetime DEFAULT NULL AFTER `reset_hash`,
  -- De oude kolom mag nu leeg zijn.
  MODIFY `password` varchar(40) NOT NULL DEFAULT '';
