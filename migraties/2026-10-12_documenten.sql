-- ==================================================================
-- Migratie 2026-10-12 — documentenfunctie
-- Voor: BEIDE intranetten (de publieke sites gebruiken dezelfde database,
-- maar doen niets met deze tabellen).
--
-- Opzet: de GEGEVENS van mappen en documenten staan in de database,
-- de BESTANDEN zelf in een map buiten public_html (DOC_DIR in configDB.php).
-- Back-up = database ÉN die map; nooit maar één van de twee terugzetten.
--
-- ruimte 'eigen'   : persoonlijke documenten; eigenaar_id = user.id van de eigenaar
-- ruimte 'gedeeld' : gemeenschappelijke map; eigenaar_id = NULL
-- gemaakt_door     : user.id van wie de map/het document heeft gemaakt/geüpload
--                    (bepaalt wie mag verwijderen, en telt mee voor het maximum per persoon)
-- parent_id/map_id : NULL = bovenste niveau van de ruimte
--
-- Geen foreign keys naar user: een gebruiker wordt in phpMyAdmin verwijderd,
-- en zijn documenten moeten dan blijven bestaan (de beheerder ziet ze als
-- "zonder eigenaar" en kan ze naar zichzelf verplaatsen).
-- Mag meer dan één keer gedraaid worden (IF NOT EXISTS / INSERT IGNORE).
-- ==================================================================

CREATE TABLE IF NOT EXISTS `docmap` (
  `id`           int(11)      NOT NULL AUTO_INCREMENT,
  `ruimte`       enum('eigen','gedeeld') NOT NULL,
  `eigenaar_id`  int(11)      DEFAULT NULL,
  `parent_id`    int(11)      DEFAULT NULL,
  `naam`         varchar(100) NOT NULL,
  `gemaakt_door` int(11)      NOT NULL,
  `gemaakt_op`   datetime     NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ruimte_eigenaar_parent` (`ruimte`, `eigenaar_id`, `parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `document` (
  `id`           int(11)      NOT NULL AUTO_INCREMENT,
  `ruimte`       enum('eigen','gedeeld') NOT NULL,
  `eigenaar_id`  int(11)      DEFAULT NULL,
  `map_id`       int(11)      DEFAULT NULL,
  `naam`         varchar(200) NOT NULL,          -- de naam zoals de gebruiker hem ziet
  `opslagnaam`   char(32)     NOT NULL,          -- willekeurige naam van het bestand in DOC_DIR
  `extensie`     varchar(10)  NOT NULL,
  `mime`         varchar(100) NOT NULL,
  `grootte`      int(11)      NOT NULL,          -- in bytes
  `gemaakt_door` int(11)      NOT NULL,
  `gemaakt_op`   datetime     NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `opslagnaam` (`opslagnaam`),
  KEY `ruimte_eigenaar_map` (`ruimte`, `eigenaar_id`, `map_id`),
  KEY `gemaakt_door` (`gemaakt_door`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Instellingen die de beheerder op het intranet kan wijzigen.
CREATE TABLE IF NOT EXISTS `instelling` (
  `sleutel` varchar(50)  NOT NULL,
  `waarde`  varchar(500) NOT NULL,
  PRIMARY KEY (`sleutel`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `instelling` (`sleutel`, `waarde`) VALUES
  ('doc_extensies',  'pdf,doc,docx,xls,xlsx,ppt,pptx,odt,ods,txt,rtf,jpg,jpeg,png'),
  ('doc_max_mb',     '10'),     -- maximale grootte per bestand
  ('doc_quotum_mb',  '200');    -- maximaal totaal per persoon (alles wat iemand heeft geüpload)
