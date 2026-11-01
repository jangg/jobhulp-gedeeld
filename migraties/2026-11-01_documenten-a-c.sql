-- ==================================================================
-- Migratie 2026-11-01 — documentenfunctie volgens de keuze van de
-- organisaties: A (gedeelde map) + C (documenten per werkzoekende).
-- Eerst alleen voor ZOETERMEER (lokaal testen in MAMP); Culemborg volgt.
-- Vereist: 2026-10-12_documenten.sql is al gedraaid.
--
-- ruimte 'werkzoekende' : documenten van één werkzoekende; eigenaar_id = werkzkd.id
--                         (worden verwijderd door maintenance/cleanDB.php samen met de werkzoekende)
-- ruimte 'eigen'        : optie B, niet gekozen. Blijft in de lijst staan voor
--                         documenten uit de testperiode; de pagina toont ze niet meer.
--
-- Mag meer dan één keer gedraaid worden.
-- ==================================================================

ALTER TABLE `docmap`   MODIFY `ruimte` enum('eigen','gedeeld','werkzoekende') NOT NULL;
ALTER TABLE `document` MODIFY `ruimte` enum('eigen','gedeeld','werkzoekende') NOT NULL;

-- Maximum voor de gedeelde map: 4 GB (in te stellen in Documenten > Instellingen)
INSERT IGNORE INTO `instelling` (`sleutel`, `waarde`) VALUES ('doc_gedeeld_mb', '4096');

-- Maximum per persoon: 100 MB (was 200). Alleen als het nog op de oude standaard staat,
-- zodat een waarde die de beheerder zelf heeft ingesteld niet wordt overschreven.
UPDATE `instelling` SET `waarde` = '100' WHERE `sleutel` = 'doc_quotum_mb' AND `waarde` = '200';

-- Controle achteraf: zijn er nog testdocumenten in de oude ruimte 'eigen'?
-- SELECT ruimte, COUNT(*) FROM document GROUP BY ruimte;
-- Die zijn op de pagina niet meer te zien. Opruimen kan (bestanden blijven dan als
-- "bestand zonder regel" in DOC_DIR staan; die mag je daar met de hand weggooien):
-- DELETE FROM document WHERE ruimte = 'eigen';
-- DELETE FROM docmap   WHERE ruimte = 'eigen';
