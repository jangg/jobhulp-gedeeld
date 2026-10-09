# Doorlichting intra.jhmz.nl en intra.jobhulpculemborg.nl (6 oktober 2026)

Kopie van het projectdocument in Claude (project "JobHulpMaatje websites"). Bijgewerkt op 9 oktober 2026 (log opgeschoond, migraties in MAMP gedaan).

Doorgelicht: de lokale kopieën in ~/Sites/jobhulp-intra. De bevindingen gelden voor beide sites, tenzij anders vermeld.
Git: de repository staat in ~/Sites/jobhulp-intra. Commit fcce9c0 is de uitgangssituatie.

## Uitgangspunten (van Jan)
- intra-culemborg loopt voor en is leidend.
- Inhoud mag per site verschillen. DB-structuur en class/ moeten 100% gelijk zijn. Controle: ./vergelijk.sh.
- Ontwikkelen in MAMP (PHP 8.3), pas daarna uploaden naar Versio.
- De cronjob voor de verjaardagskaarten draait in DirectAdmin via een php-commando, dagelijks rond 6:15.
- Nieuwe gebruikers maakt Jan aan in phpMyAdmin met een leesbaar tijdelijk wachtwoord en password_mod = 'j'.
- Adressen: intranet Culemborg = https://intra.jobhulpculemborg.nl, intranet Zoetermeer = https://intra.jhmz.nl.
- De niveaus in user.beheerind blijven zoals ze nu in de databases staan. rechten.php volgt die bestaande betekenis; beheerind hoeft NIET omgezet te worden.
- Oude bestanden die niet gebruikt worden mogen weg.
- De redactie gebruikt HTML-opmaak in postits (titel/tekst) en nieuwstitels.
- Eén codebasis voor beide sites (alle verschillen in configDB/rechten) zou Jan fantastisch vinden, maar is een groot project; later.

## Status (lokaal, nog niet op de servers)
- e00ef11 Noodreparatie: login-controle op onbeveiligde pagina's.
- fb4a789, e9cd7d4, c9d286f, 5666611: configDB-constanten, classes gelijk, migraties/, vergelijk.sh, cron-herkenning, beheer/ weg.
- 2c8e89d … 206b0f0, e02ea05 **Stap A: rechten met een naam** (+ knop_uit()).
- eb1925e vergelijk.sh via MAMP-socket.
- 2d07845, 00d4a7c, 410a4d1, bc8f2c8 **Stap B: wachtwoorden als hash + "wachtwoord vergeten".** Getest in MAMP.
- f31364b **Stap C: .htaccess, persoonsfoto's alleen na inloggen, oude bestanden weg.** Nog testen in MAMP.
- d39da7a **PHP 8.3/8.4-controle** en reparaties.
- 4e47400 **TCPDF 6.3.5 → 6.11.4** (eigen instellingen in includes/pdf_instellingen.php; logo op intake-PDF). Nog testen in MAMP.
- 7cfeb3e Keuzelijsten met foto's tonen alleen afbeeldingen (Tools::afbeeldingen).
- 92d8a6d **Stap D deel 1: XSS.** h() in config.php; ca. 650 plekken ge-escaped; (int) voor id's uit de URL (mut_persoon had een SQL-injectie via ?id=).
- 4bb1366 Postits: $postits-blok werd door de omzetting als tekst getoond (gerepareerd); titel/tekst/linkTekst via Tools::veiligeHtml().
- 3487951 h() met double_encode=false: "Ren&eacute;" uit de database toont weer als René.
- 7a03604 Forum: berichten via Tools::opmaakHtml(); getShortPost() geeft gewone tekst; forummail gefilterd.
- 6168c6e Nieuws (tekst_kort, titel) en agenda (omschrijving, titel, freefld3) gefilterd.
- 51c7031 Agenda: verjaardagsplaatjes weer zichtbaar (titel via opmaakHtml); namen in de verjaardagstitel ge-escaped. Gevonden door Jan bij het testen van intra-jhmz (8 okt).
- cca4ae9 **Stap D deel 2: CSRF.** session.cookie_samesite=Lax; csrf_token()/csrf_veld()/verwijderknop() in config.php; automatische controle bij elk POST (formulierveld of kop X-CSRF-Token); 66 formulieren voorzien; jQuery-AJAX stuurt het token mee (head.php); verwijderen via POST i.p.v. ?del=j / ?delete= (werkzoekenden, maatjes, nieuws, agenda, foto's). Getest: zonder/fout token 403, met token werkt, oude ?del=j-link doet niets meer, inloggen werkt. Nog testen in MAMP.
- Migraties 2026-10-06 en 2026-10-07 + hash_wachtwoorden.php gedraaid in MAMP. ./vergelijk.sh: twee keer OK.
- e9804be Enquête verwijderd (obsolete, besluit Jan): enquete.php, includes/chk_enquete.inc, en de ongebruikte includes/body.inc en pinkster.txt (beide sites). Migratie 2026-10-08_enquete-verwijderen.sql (DROP TABLE enquete): MAMP gedaan (9 okt), Versio nog.
- b1d6f9d Pubquiz verwijderd (eenmalig gebruikt, besluit Jan): pubquiz.php, pubquizantw.php, score.php, pages/pubquizregels.php. Migratie 2026-10-08_pubquiz-verwijderen.sql (DROP TABLE pubquizteams): MAMP gedaan (9 okt), Versio nog.
- 6da5da4 Meldingen uit php_error.log opgelost (substr op NULL in overz_newsitems, overz_werkzoekenden, overz_wkz_vrjrdgn); verjaardagen maatjes in agenda gebruikten vaste jaartallen 2026/2027, nu huidig/volgend jaar. Log in MAMP daarna leeggemaakt; databases gelijk (vergelijk.sh 2x OK).
- 0709a62 Forummail Zoetermeer: CharSet UTF-8 ontbrak.
- utf8mb4: migratie 2026-10-09_utf8mb4.sql en SET NAMES 'utf8mb4' in config.php. Nog uitvoeren in MAMP.

## CSRF (stap D deel 2)
- Elk formulier met method="POST" moet `<?= csrf_veld() ?>` bevatten, anders geeft het opslaan "Het formulier kon niet worden verwerkt" (403).
- AJAX met jQuery: gaat vanzelf goed via $.ajaxSetup in head.php. Met fetch() zelf de kop 'X-CSRF-Token' meesturen.
- Verwijderen: verwijderknop($actie, ['del_id' => $id], 'vraag?') geeft een klein POST-formulier met prullenbak en bevestigingsvraag.
- Nooit iets wijzigen via een GET-link. Uitzondering (alleen beheerder): maintenance/hash_wachtwoorden.php?uitvoeren en cleanDB.php?execute.

## Escaping en HTML-filter (Tools)
- h($w): htmlspecialchars(ENT_QUOTES|ENT_SUBSTITUTE, UTF-8, double_encode=false). Voor alle gewone waarden.
- Tools::veiligeHtml($html, $tags, $attributen): DOMDocument-whitelist. Standaard eenvoudige opmaak (b, strong, i, em, u, br, span, small, mark, sup, sub). Gebruikt voor postits, nieuwstitels, agenda freefld3.
- Tools::opmaakHtml($html): voor Summernote-teksten (p, kopjes, lijsten, tabellen, a, img; style alleen met onschuldige CSS; href/src alleen http(s), mailto, relatief, data:image). Gebruikt voor forum, nieuws tekst_kort, agenda omschrijving en agendatitel.
- Filter alleen bij het tonen (opgeslagen HTML blijft ongewijzigd, dus omkeerbaar).
- Valkuilen onderweg: `?>` in een //-commentaar beëindigt PHP; backslashes in regex dubbel escapen; `echo$x` zonder spatie; HTML die de code zelf opbouwt (verjaardagen, postit-blok) niet escapen.

## PHP 8.3/8.4 en bibliotheken
- Eigen code: geen fouten en geen deprecations meer gevonden. Beperking: rooktest met bijna lege database.
- PHPMailer 7.0.2: geschikt. TCPDF 6.11.4 (laatste van de 6-lijn); updaten = map tcpdf/ vervangen, .htaccess bewaren.

## Checklist uitrollen naar Versio (per site)
1. Back-up van database en bestanden.
2. Migraties 2026-10-06_db-gelijktrekken_<site>.sql, 2026-10-07_wachtwoord-hash.sql, 2026-10-08_enquete-verwijderen.sql, 2026-10-08_pubquiz-verwijderen.sql en 2026-10-09_utf8mb4.sql uitvoeren (utf8mb4 tegelijk met de nieuwe config.php).
3. configDB.php op de server controleren/aanvullen:
   - LOC_WEBSITE_PUB, LOC_JG_NAAM, LOC_JG_EMAIL toevoegen.
   - LOC_WEBSITE = adres van het intranet (Culemborg: https://intra.jobhulpculemborg.nl, zonder / aan het eind). Voor de reset-link.
   - MAIL_SENDEREMAIL gelijk aan MAIL_USERID (anders weigert de SMTP-server).
   - MAIL_NOREPLYEMAIL en MAIL_LOGDIR moeten bestaan; MAIL_LOGDIR = __DIR__ . "/../logs/".
   - Zoetermeer: LOC_LOGO_PDF = "LogoJobHulpMaatjeZoetermeer.jpg".
   - MAIL_TESTMODUS NIET op de server zetten.
4. beheerind: niets omzetten. Wel controleren: SELECT beheerind, COUNT(*) FROM user GROUP BY beheerind; ('j' telt als 9).
5. PHP-versie in DirectAdmin op 8.3 (of hoger) zetten.
6. Nieuwe code uploaden (verborgen .htaccess-bestanden meenemen). Nieuw: includes/rechten.php, includes/pdf_instellingen.php, foto.php, reset.php, maintenance/hash_wachtwoorden.php, de .htaccess-bestanden.
7. Map tcpdf/ op de server helemaal vervangen.
8. Op de server verwijderen: beheer/, beheer_oud/, index_nw.php, wijzwacht_nw.php, maintenance/config.php, includes/newsmsgs*.inc, enquete.php, includes/chk_enquete.inc, includes/body.inc, includes/pinkster.txt, pubquiz.php, pubquizantw.php, score.php, pages/pubquizregels.php, en alles wat in f31364b is verwijderd.
9. Als beheerder: /maintenance/hash_wachtwoorden.php (tellen), dan ?uitvoeren.
10. Testen: inloggen, rechten, wachtwoord wijzigen/vergeten, foto's (privévenster: 403), /includes/navbar.php geeft 403, intake-PDF, nieuwe werkzoekende, namen met ' & é, postits/nieuws/agenda/forum met opmaak, verjaardagen in de agenda.
11. Controleren of mod_rewrite werkt op Versio.

## Stap C, B, A (samenvatting)
- C: .htaccess (root + dichte mappen), foto.php via mod_rewrite (fotoos_person = ingelogd, fotoos_wkz = was_lezen). fotoos_wkz-oud/ dichtgezet, niet verwijderd (Jan beslist).
- B: password_hash/verifyPassword, reset-link 1 uur (sha256 in DB), min. 8 tekens. MAIL_TESTMODUS lokaal.
- A: rechten.php per site; heeft_recht(), require_recht(), knop_uit().

| Recht | Zoetermeer | Culemborg |
|---|---|---|
| forum_lezen | 1-9 | 1-9 |
| forum_schrijven | 2-9 | 2-9 |
| redactie | 2,5,6,7,8,9 | 4,6,7,8,9 |
| was_lezen | 3-9 | 5-9 |
| was_wijzigen | 4,6,7,8,9 | 5-9 |
| maatjes_wijzigen | 7,8,9 | 7,8,9 |
| presentie_anderen | 7,8,9 | 7,8,9 |
| beheerder | 9 | 9 |

Niveaus Zoetermeer: 0 zonder forum; 1 + forum lezen; 2 + redactie; 3 WAS inzien; 4 WAS wijzigen (maatjes alleen inzien); 5 = 2+3; 6 = 2+4; 7/8 = 6 + maatjes; 9 beheerder. Culemborg: 4 redactie; 5 WAS; 6 redactie + WAS; 7/8 = 6 + maatjes; 9 beheerder.

## Openstaande bevindingen
HOOG
5. ~~Geen CSRF-bescherming~~ opgelost in cca4ae9.

MIDDEL
8. Collectieklassen plakken WHERE-waarden als string in de SQL (vandaag veilig; id's uit de URL zijn nu (int)).
10. ~~4 tabellen in latin1~~ migratie 2026-10-09_utf8mb4.sql (alle tabellen utf8mb4) + config.php SET NAMES 'utf8mb4'.
11. ~~session.cookie_samesite ontbreekt~~ opgelost in cca4ae9.
15. Adres automatisch invullen (aanmelding_wkz) werkt niet meer: oude PDOK-URL. Later aanpassen (Jan).
16. Bewaartermijn: cleanDB ruimt alleen handmatig gemarkeerde werkzoekenden op; intake-PDF belooft verwijdering 6 maanden na het traject.
17. JavaScript-bibliotheken via CDN in verschillende versies.
18. HTML-entiteiten (&eacute;) in de database; ruimen zich op bij opslaan; eventueel later een opschoonscript.

## Volgorde
A, B, C, D klaar en door Jan getest in MAMP (9 okt: geen nieuwe fouten, php_error.log leeg). Volgende: uitrol naar Versio.
E. Documentenfunctie, bouwt voort op A/C/D.
