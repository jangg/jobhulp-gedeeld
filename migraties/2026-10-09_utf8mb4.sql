-- ==================================================================
-- Migratie 2026-10-09 — alle tabellen naar utf8mb4
-- Voor: BEIDE intranetten (MAMP: intraDB en jhcintradb, daarna Versio)
--
-- Waarom:
--  - keytabel, maatje, user en wkzstatus stonden in latin1: tekens als
--    ş, ğ, ł of Arabisch schrift werden bij opslaan een '?'.
--  - De andere tabellen stonden in "utf8" (3 bytes): geen emoji en sommige
--    zeldzame tekens.
-- utf8mb4 kan alles. MySQL/MariaDB zet de bestaande tekst zelf om; er gaat
-- niets verloren. TEXT-kolommen kunnen daarbij MEDIUMTEXT worden (zodat er
-- evenveel tekens in passen); dat is normaal en gebeurt in beide databases gelijk.
--
-- Hoort bij: config.php gebruikt nu SET NAMES 'utf8mb4'.
--
-- VOORAF:
--  1. Back-up maken (phpMyAdmin > Exporteren).
--  2. Controle op al verminkte tekst (moet 0 rijen geven; zo niet: eerst melden).
--     COLLATE utf8mb4_bin is nodig: zonder dat vindt LIKE '%Ã%' na de omzetting ook elke gewone 'a'.
--       SELECT id, omschrijving, functie FROM maatje WHERE CONCAT_WS(' ',omschrijving,functie) COLLATE utf8mb4_bin LIKE '%Ã%';
--       SELECT id, username FROM user WHERE username COLLATE utf8mb4_bin LIKE '%Ã%';
--       SELECT id, omschrijving FROM wkzstatus WHERE omschrijving COLLATE utf8mb4_bin LIKE '%Ã%';
--
-- Uitvoeren: database selecteren in phpMyAdmin, tabblad SQL, dit bestand plakken.
-- Daarna: ./vergelijk.sh (moet twee keer OK geven).
-- ==================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- Standaard voor nieuwe tabellen in deze database
ALTER DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `aantekening` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `agendaitem`  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `categories`  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `intakeform`  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `jgsessie`    CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `jobgroup`    CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `keytabel`    CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `locatie`     CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `maatje`      CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `newsitem`    CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `person`      CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `postit`      CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `posts`       CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `processtap`  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `sucstor`     CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `topics`      CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `user`        CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `werkzkd`     CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `wkzstatus`   CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- Controle achteraf (alle rijen moeten utf8mb4_unicode_ci tonen):
--   SELECT TABLE_NAME, TABLE_COLLATION FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE();
