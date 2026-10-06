-- ==================================================================
-- Migratie 2026-10-06 — database-structuur gelijktrekken
-- Voor: intra-jhmz (MAMP: intraDB, daarna de database op Versio)
--
-- Uitvoeren in phpMyAdmin: kies de database, tab "SQL", plak dit
-- bestand en klik op "Start". Maak vooraf een export/back-up.
-- Alle wijzigingen maken kolommen groter of voegen iets toe;
-- er gaan geen gegevens verloren.
-- ==================================================================

-- 1. Tabel voor succesverhalen (bestond al in Culemborg).
--    IF NOT EXISTS: het script kan veilig twee keer draaien.
CREATE TABLE IF NOT EXISTS `sucstor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `delind` varchar(1) DEFAULT NULL,
  `id_user_created` int(11) DEFAULT NULL,
  `datetime_created` datetime DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  `titel` varchar(100) DEFAULT NULL,
  `subtitel` varchar(300) DEFAULT NULL,
  `tekst` mediumtext,
  `tekst_kort` varchar(5000) DEFAULT NULL,
  `tekst_samenvatting` varchar(7000) DEFAULT NULL,
  `tekst_knop` varchar(40) DEFAULT NULL,
  `link_knop` varchar(200) DEFAULT NULL,
  `pubind_intern` varchar(1) DEFAULT NULL,
  `datetime_pub_intern` datetime DEFAULT NULL,
  `pubind_extern` varchar(1) DEFAULT NULL,
  `datetime_pub_extern` datetime DEFAULT NULL,
  `picfile1` varchar(300) DEFAULT NULL,
  `picfile2` varchar(100) DEFAULT NULL,
  `picfile3` varchar(100) DEFAULT NULL,
  `picfile4` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 2. Telefoonnummer: 15 -> 25 tekens (zoals Culemborg).
ALTER TABLE `person` MODIFY `telefoonnr` varchar(25) DEFAULT NULL;
