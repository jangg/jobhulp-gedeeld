-- ==================================================================
-- Migratie 2026-11-13 — rechten per gebruiker (tabel user_recht)
-- Voor: ALLEEN JobHulp Culemborg (jhcintradb / Versio Culemborg).
-- Zelfde omzetting als in Zoetermeer (2026-11-06_rechten-per-gebruiker_jhmz.sql):
-- de niveaus betekenen in beide intranetten hetzelfde sinds 9 oktober 2026
-- (2026-10-09_rechten-gelijk_culemborg.sql).
-- Vereist: 2026-10-12_documenten.sql en 2026-11-01_documenten-a-c.sql zijn al gedraaid.
--
-- Tot nu toe stond in user.beheerind één niveau (0-9), en elk niveau was
-- een vaste combinatie van rechten. Vanaf nu heeft elke gebruiker zijn eigen
-- lijst van rechten: één regel per recht in de nieuwe tabel user_recht.
-- Welke rechten er zijn, staat in includes/rechten.php.
--
-- Deze migratie zet elk niveau om naar precies dezelfde rechten als vandaag
-- (zie de tabel met niveaus in ONDERHOUD.md, hoofdstuk 5).
-- Niemand mag na de omzetting iets meer of minder dan ervoor, op één
-- ding na: het nieuwe recht documenten_eigen (B, de documenten van de eigen
-- werkzoekenden) krijgt iedereen vanaf niveau 2. Dat mocht een maatje al,
-- het was alleen nog geen apart recht.
--
--   niveau 8           -> houdt in Culemborg ook maatjes_wijzigen en presentie_anderen
--                         (besluit Jan, 18 nov 2026; zo stond het al in includes/rechten.php)
--   niveau 9 (of 'j')  -> beheerder (de beheerder mag automatisch alles)
--   niveau 0           -> geen rechten (wel inloggen)
--
-- De kolom user.beheerind blijft voorlopig staan en wordt niet meer gebruikt.
-- Zo kun je terug naar de vorige versie (branch main van 8 nov) als er iets misgaat.
--
-- VOORAF:
--  1. Back-up van de tabel user (phpMyAdmin > user > Exporteren).
--  2. Kijk hoeveel gebruikers per niveau er zijn (verandert niets):
--       SELECT beheerind, COUNT(*) FROM user GROUP BY beheerind;
--
-- Deze migratie mag maar EEN keer draaien. De regel met keytabel legt dat vast;
-- een tweede keer geeft daar een foutmelding (Duplicate entry) en stopt
-- phpMyAdmin voordat er rechten dubbel worden toegevoegd.
--
-- Uploaden naar Versio: deze migratie en de nieuwe bestanden van de branch
-- gelijk-jhmz TEGELIJK. (Draait de nieuwe code zonder deze tabel, dan valt
-- class/c_user.php terug op beheerind; zie User::rechten().)
--
-- CONTROLE ACHTERAF (verandert niets):
--   SELECT u.username, u.beheerind, GROUP_CONCAT(r.recht ORDER BY r.recht) AS rechten
--     FROM user u LEFT JOIN user_recht r ON r.user_id = u.id
--     GROUP BY u.id ORDER BY u.beheerind, u.username;
-- ==================================================================

CREATE TABLE IF NOT EXISTS `user_recht` (
  `user_id` int(11) NOT NULL,
  `recht`   varchar(40) NOT NULL,
  PRIMARY KEY (`user_id`, `recht`),
  -- Wordt een user-regel ooit echt verwijderd (bijv. in phpMyAdmin),
  -- dan verdwijnen zijn rechten vanzelf mee.
  CONSTRAINT `fk_user_recht_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO keytabel (sleutel, waarde) VALUES ('rechten_v3', '2026-11-06');

INSERT INTO `user_recht` (`user_id`, `recht`)
          SELECT id, 'forum_lezen'              FROM user WHERE beheerind IN ('1','2','3','4','5','6','7','8')
UNION ALL SELECT id, 'forum_schrijven'          FROM user WHERE beheerind IN ('2','3','4','5','6','7','8')
UNION ALL SELECT id, 'redactie'                 FROM user WHERE beheerind IN ('3','7','8')
UNION ALL SELECT id, 'was_lezen'                FROM user WHERE beheerind IN ('4','5','6','7','8')
UNION ALL SELECT id, 'was_wijzigen'             FROM user WHERE beheerind IN ('5','6','8')
UNION ALL SELECT id, 'maatjes_wijzigen'         FROM user WHERE beheerind IN ('6','8')
UNION ALL SELECT id, 'presentie_anderen'        FROM user WHERE beheerind IN ('6','8')
UNION ALL SELECT id, 'documenten_gedeeld'       FROM user WHERE beheerind IN ('5','6','8')
UNION ALL SELECT id, 'documenten_eigen'         FROM user WHERE beheerind IN ('2','3','4','5','6','7','8')
UNION ALL SELECT id, 'documenten_werkzoekenden' FROM user WHERE beheerind IN ('5','6','8')
UNION ALL SELECT id, 'beheerder'                FROM user WHERE beheerind IN ('9','j');
