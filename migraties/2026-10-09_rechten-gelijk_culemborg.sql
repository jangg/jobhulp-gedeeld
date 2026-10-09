-- ==================================================================
-- Migratie 2026-10-09 — beheerind omzetten naar de gezamenlijke indeling
-- Voor: ALLEEN JobHulp Culemborg (jhcintradb / Versio Culemborg)
--
-- Vanaf nu hebben de niveaus in beide intranetten dezelfde betekenis
-- (includes/rechten.php is in beide sites gelijk):
--   0 = inloggen, geen forum        5 = 2 + WAS lezen en schrijven
--   1 = forum lezen (buitenstaander) 6 = 5 + maatjes wijzigen
--   2 = 1 + forum schrijven (maatje) 7 = redactie + WAS lezen
--   3 = 2 + redactie                 8 = redactie + WAS lezen en schrijven
--   4 = 2 + WAS lezen                9 = alles (beheerder)
--
-- Omzetting oud -> nieuw voor JobHulp Culemborg (jhcintradb / Versio Culemborg):
--   0 -> 0, 1 -> 1, 9 of 'j' -> 9
--   2 en 3 (forum schrijven)  -> 2
--   4 (redactie)              -> 3
--   5 (WAS lezen + wijzigen)  -> 5
--   6 (redactie + WAS)        -> 8
--   7 en 8 (6 + maatjes)      -> 6  (geen redactie meer, besluit Jan)
--
-- VOORAF:
--  1. Back-up van de tabel user (phpMyAdmin > user > Exporteren).
--  2. Kijk wat er gaat gebeuren (verandert niets):
--       SELECT u.username, u.beheerind AS oud, CASE u.beheerind
--         WHEN '3' THEN '2'
--         WHEN '4' THEN '3'
--         WHEN '6' THEN '8'
--         WHEN '7' THEN '6'
--         WHEN '8' THEN '6'
--         WHEN 'j' THEN '9'
--         ELSE u.beheerind END AS nieuw FROM user u ORDER BY oud;
--
-- Deze migratie mag maar EEN keer draaien. De eerste regel legt dat vast in
-- keytabel; een tweede keer geeft daar een foutmelding (Duplicate entry) en
-- stopt phpMyAdmin voordat er iets wordt omgezet.
--
-- Uploaden naar Versio: deze migratie en de nieuwe includes/rechten.php
-- TEGELIJK, anders gelden even de verkeerde rechten.
-- ==================================================================

INSERT INTO keytabel (sleutel, waarde) VALUES ('rechten_v2', '2026-10-09');

UPDATE user SET beheerind = CASE beheerind
    WHEN '3' THEN '2'
    WHEN '4' THEN '3'
    WHEN '6' THEN '8'
    WHEN '7' THEN '6'
    WHEN '8' THEN '6'
    WHEN 'j' THEN '9'
    ELSE beheerind END;
