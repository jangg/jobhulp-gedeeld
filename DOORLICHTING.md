# Doorlichting intranetten en publieke websites JobHulpMaatje Zoetermeer en JobHulp Culemborg (6 oktober 2026)

Kopie van het projectdocument in Claude (project "JobHulpMaatje websites"). Bijgewerkt op 11 oktober 2026, middag (publieke site Culemborg live met de gedeelde classes; git per site; vergelijk.sh voor vier sites; lessen bij het uploaden).

Vier sites in ~/Sites/jobhulp-intra, elk met een eigen git-repository (sinds 11 okt):

| Map | Site |
|---|---|
| intra-jhmz | intranet Zoetermeer, https://intra.jhmz.nl |
| intra-culemborg | intranet Culemborg, https://intra.jobhulpculemborg.nl (leidend) |
| pub-jhmz | publieke site Zoetermeer, https://jobhulpmaatjezoetermeer.nl |
| pub-jhc | publieke site Culemborg, https://jobhulpculemborg.nl |

- In elke site wijst de tag `uitgangssituatie` naar de toestand van vóór de doorlichting.
- De hoofdmap heeft een eigen kleine repository voor het gedeelde deel: migraties/, vergelijk.sh, maaklijst.py en de documentatie.
- Reservekopie van de oude gezamenlijke repository: backup oude websites/jobhulp-intra-git-2026-10-11.git.

## Uitgangspunten (van Jan)
- intra-culemborg loopt voor en is leidend.
- Inhoud mag per site verschillen. DB-structuur en class/ moeten 100% gelijk zijn. Controle: ./vergelijk.sh.
- class/ is in alle vier de sites gelijk, ook in de publieke sites (zelfde database). Een wijziging in class/ commit Claude in elke site apart.
- De statuslijst (includes/statuslijst.php) verschilt per organisatie en staat daarom niet in class/. Binnen een organisatie is hij gelijk (intranet = publieke site).
- Ontwikkelen in MAMP (PHP 8.3), pas daarna uploaden naar Versio. Alle sites op Versio draaien op PHP 8.3.
- Git doet Claude (besluit Jan, 11 okt). Jan bekijkt de status in Nova, met per site een eigen Nova-project (git + publiceren).
- De cronjob voor de verjaardagskaarten draait in DirectAdmin via een php-commando, dagelijks rond 6:15.
- Nieuwe gebruikers maakt Jan aan in phpMyAdmin met een leesbaar tijdelijk wachtwoord en password_mod = 'j'.
- De niveaus in user.beheerind hebben in beide intranetten dezelfde betekenis (besluit Jan, 9 okt). rechten.php is in beide intranetten gelijk.
- Oude bestanden die niet gebruikt worden mogen weg.
- De redactie gebruikt HTML-opmaak in postits (titel/tekst) en nieuwstitels.
- Eén codebasis voor beide organisaties (alle verschillen in configDB/rechten) zou Jan fantastisch vinden, maar is een groot project; later.

## Status
### Intranetten (tot en met 10 okt)
- e00ef11 Noodreparatie: login-controle op onbeveiligde pagina's.
- configDB-constanten, classes gelijk, migraties/, vergelijk.sh, cron-herkenning, beheer/ weg.
- **Stap A: rechten met een naam** (+ knop_uit()).
- **Stap B: wachtwoorden als hash + "wachtwoord vergeten".**
- **Stap C: .htaccess, persoonsfoto's alleen na inloggen, oude bestanden weg.**
- **PHP 8.3/8.4-controle** en reparaties. **TCPDF 6.3.5 → 6.11.4** (eigen instellingen in includes/pdf_instellingen.php; logo op intake-PDF).
- Keuzelijsten met foto's tonen alleen afbeeldingen (Tools::afbeeldingen).
- **Stap D deel 1: XSS.** h() in config.php; ca. 650 plekken ge-escaped; (int) voor id's uit de URL (mut_persoon had een SQL-injectie via ?id=). Postits, forum, nieuws en agenda via Tools::veiligeHtml()/opmaakHtml().
- **Stap D deel 2: CSRF.** session.cookie_samesite=Lax; csrf_token()/csrf_veld()/verwijderknop(); automatische controle bij elk POST; verwijderen via POST.
- Enquête, pubquiz en werkzkdBU verwijderd (besluit Jan), met migraties.
- Rechten gelijkgetrokken; utf8mb4 (migratie + SET NAMES 'utf8mb4').
- Onderhoudsmodus: onderhoud.html en een blok bovenaan de root-.htaccess; aan/uit met onderhoud.aan; vanaf Jans IP-adres (77.168.222.49) werkt de site gewoon.
- fotoos_wkz-oud/ verwijderd (besluit Jan, 10 okt; ook op de server).
- **10 okt: intra.jhmz.nl LIVE op Versio met de nieuwe code.** Migraties, rechten omgezet, 22 wachtwoorden gehasht, getest.

### 11 oktober
- verwijderknop(): kleiner prullenbak-icoon (font-size 0.85rem, line-height 1).
- mut_maatje.php (beide intranetten): de lijst werkzoekenden van een maatje toonde HTML als tekst (dubbele h()). Gemeld door Jan.
- Culemborg: eigen includes/statuslijst.php (41 codes).
- **Publieke site Zoetermeer (pub-jhmz)**: class/ gelijk aan de intranetten, statuslijst, config.php met h() en utf8mb4; coördinator-mail bij aanmelding ging naar 'aanmelding@https://…', nu LOC_DOMAIN_PUB; mailtest.php weg. **Live.**
- **Git per site** (besluit Jan): afgesplitst met de geschiedenis; maaklijst.py en vergelijk.sh daarop aangepast.
- c_sucstor.php en c_sucstor_coll.php (succesverhalen, uit pub-jhc) toegevoegd aan class/ van alle vier de sites.
- **Publieke site Culemborg (pub-jhc)**: in git en gelijkgetrokken (classes, statuslijst, config.php met h() en utf8mb4). Opgeruimd: mailtest.php, index.temp, logo_oud.png, c_tools_oud.php; robot.txt → robots.txt.
  - Workshop-mail: onderwerp 'xxxxxxxxxxxxxxxxxx' en tikfout in het domein hersteld.
  - Partnerbijeenkomst: was gekopieerd van Zoetermeer (mail naar aanmelding@jobhulpmaatjezoetermeer.nl, ondertekend 'JobHulpMaatje Zoetermeer'); nu LOC_NAME en aanmelding@jobhulpculemborg.nl. Datum overal 15 oktober (besluit Jan); 'peronen' → 'personen'.
  - t-aanmelden.php (los aanmeldformulier zonder database; blijft, besluit Jan): t-functies.php definieerde ook h() → 'Cannot redeclare h()'; nu met function_exists. includes/t-config.php (SMTP-wachtwoord) buiten git; voorbeeld in includes/t-config.voorbeeld.php.
  - **Live**, na een storing door het uploaden (zie "Uploaden: lessen"). Alle 23 pagina's gecontroleerd.
- jaarverslag.php, jobgroups.php, maatjes.php (beide publieke sites) laadden config.php niet → fout 500 onder PHP 8.3 (bestond al). pub-jhmz/proces_nbemail.php idem: aanmelding nieuwsbrief Zoetermeer werkte niet. Hersteld; in Culemborg live, in Zoetermeer nog uploaden.
- vergelijk.sh controleert alle vier de sites: class/ (tegen intra-culemborg), rechten.php, statuslijst per organisatie, h() en utf8mb4 in config.php, git-status, database-structuur. `./vergelijk.sh -v` toont de verschillen per regel.

## Uploaden: lessen (11 okt)
- **In Transmit altijd "Samenvoegen" (Merge) kiezen, nooit "Vervangen".** Bij jobhulpculemborg.nl werd includes/ vervangen door een map met 3 bestanden: configDB.php, head.php, header.php, footer.php en alle sect-*.php waren weg, en elke pagina gaf een wit scherm (fout 500). Hersteld met een complete includes/ uit de lokale map.
- Uploadpakketten (upload-*/) bevatten daarom een **complete class/**, en bij de publieke sites een complete includes/. Bij de intranetten zijn de meeste mappen bewust gedeeltelijk (configDB.php van de server mag niet weg): daar is Samenvoegen verplicht.
- Nooit includes/configDB.php uit de lokale map meesturen: lokaal kan die de MAMP-instellingen bevatten.
- Vóór het uploaden op de server class → class_oud en config.php → config_oud.php hernoemen, en controleren dat de _oud-versies er echt staan.
- Fout zoeken zonder de site plat te leggen: de nieuwe code in een testmap op de server, met display_errors aan en een .htaccess die alleen Jans IP-adres toelaat. Zo bleek dat de code goed was en het uploaden niet.
- Het PHP-foutlog van jobhulpculemborg.nl in DirectAdmin bleef leeg bij de fout 500: geen betrouwbare bron voor die site.
- Mail testen zonder dat collega's mail krijgen: tijdelijk in includes/configDB.php van de site
  `define("MAIL_TESTMODUS", ($_SERVER['REMOTE_ADDR'] ?? '') === '77.168.222.49');`
  Mail van Jans IP-adres gaat dan naar het PHP-foutlog i.p.v. de mailbox. Daarna de regel weer weghalen.

## CSRF (stap D deel 2)
- Elk formulier met method="POST" moet `<?= csrf_veld() ?>` bevatten, anders geeft het opslaan "Het formulier kon niet worden verwerkt" (403).
- AJAX met jQuery: gaat vanzelf goed via $.ajaxSetup in head.php. Met fetch() zelf de kop 'X-CSRF-Token' meesturen.
- Verwijderen: verwijderknop($actie, ['del_id' => $id], 'vraag?') geeft een klein POST-formulier met prullenbak en bevestigingsvraag.
- Nooit iets wijzigen via een GET-link. Uitzondering (alleen beheerder): maintenance/hash_wachtwoorden.php?uitvoeren en cleanDB.php?execute.

## Escaping en HTML-filter (Tools)
- h($w): htmlspecialchars(ENT_QUOTES|ENT_SUBSTITUTE, UTF-8, double_encode=false). Voor alle gewone waarden. Staat in config.php van alle vier de sites.
- Tools::veiligeHtml($html, $tags, $attributen): DOMDocument-whitelist voor eenvoudige opmaak. Gebruikt voor postits, nieuwstitels, agenda freefld3.
- Tools::opmaakHtml($html): voor Summernote-teksten. Gebruikt voor forum, nieuws tekst_kort, agenda omschrijving en agendatitel.
- Filter alleen bij het tonen (opgeslagen HTML blijft ongewijzigd, dus omkeerbaar).
- Valkuilen: `?>` in een //-commentaar beëindigt PHP; HTML die de code zelf opbouwt (verjaardagen, postit-blok, lijst werkzoekenden bij een maatje) niet nog eens door h(); onder PHP 8 is een ontbrekende constante (bv. LOC_NAME zonder config.php) een fatale fout.

## PHP 8.3 en bibliotheken
- Alle websites op Versio draaien op PHP 8.3.
- PHPMailer 7.0.2: geschikt. TCPDF 6.11.4 (laatste van de 6-lijn); updaten = map tcpdf/ vervangen, .htaccess bewaren.

## Onderhoudsmodus
- Aan: leeg bestand onderhoud.aan in de hoofdmap. Uit: onderhoud.aan verwijderen. Het blok in de .htaccess mag permanent blijven staan.
- Iedereen krijgt onderhoud.html met status 503, behalve de IP-adressen in het blok.
- IPv6: loopt Jans verbinding via IPv6, dan ziet de server een ander adres dan "wat is mijn ip" (IPv4) toont.
- De cronjob draait via de php-opdrachtregel en loopt tijdens het onderhoud gewoon door.

## Checklist uitrollen naar Versio (intranet)

### Per site
1. **Onderhoud aan:** onderhoud.html uploaden, onderhoud.aan aanmaken, daarna onderhoud-stap1.htaccess als .htaccess. Controleren met de telefoon via 4G (wifi uit).
2. **Back-up** van database en bestanden (naast public_html, niet erin).
3. Migraties 2026-10-06_db-gelijktrekken_<site>.sql, 2026-10-07_wachtwoord-hash.sql, 2026-10-08_enquete-verwijderen.sql, 2026-10-08_pubquiz-verwijderen.sql, 2026-10-09_werkzkdBU-verwijderen.sql, 2026-10-09_utf8mb4.sql in phpMyAdmin (eerst de juiste database kiezen).
4. configDB.php op de server controleren/aanvullen (niet uploaden):
   - LOC_WEBSITE_PUB, LOC_JG_NAAM, LOC_JG_EMAIL toevoegen.
   - LOC_WEBSITE = adres van het intranet, zonder / aan het eind.
   - MAIL_SENDEREMAIL gelijk aan MAIL_USERID.
   - MAIL_NOREPLYEMAIL en MAIL_LOGDIR = __DIR__ . "/../logs/".
   - MAIL_TESTMODUS NIET op de server zetten.
5. beheerind omzetten: 2026-10-09_rechten-gelijk_<site>.sql. Eerst de SELECT uit de kop draaien. Mag maar één keer.
6. PHP-versie in DirectAdmin op 8.3.
7. Code uploaden: inhoud van upload-<site>/. **Mappen SAMENVOEGEN, nooit vervangen.** Verborgen .htaccess-bestanden meenemen. Geen configDB.php, foto's, logs, .sql of onderhoud.aan.
8. Map tcpdf/ op de server eerst weggooien, dan de nieuwe uit het pakket.
9. Op de server verwijderen volgens UPLOADLIJST.md (incl. beheer_oud/, fotoos_wkz-oud/, een eventuele *.sql-dump en README.md).
10. Als beheerder: /maintenance/hash_wachtwoorden.php (tellen), dan ?uitvoeren, dan opnieuw: 0.
11. Testen (eigen account tijdelijk op niveau 9): inloggen, rechten, wachtwoord wijzigen/vergeten, foto's (privévenster: 403), /includes/navbar.php geeft 403, intake-PDF, opslaan met ' & é, postits/nieuws/agenda/forum, verjaardagen, foutlog. Claude kan meekijken via de ingebouwde browser.
12. **Onderhoud uit:** onderhoud.aan verwijderen. De volgende ochtend controleren of de verjaardagskaarten verstuurd zijn.

### Terugweg
- Snel te verhelpen fout: repareren terwijl de onderhoudsmodus aan blijft.
- Anders: database én bestanden samen terugzetten uit de back-up. Nooit maar één van de twee.

## Rechten (intranetten)
| Niveau | Mag | Omgezet uit Zoetermeer | Omgezet uit Culemborg |
|---|---|---|---|
| 0 | inloggen, geen forum | 0 | 0 |
| 1 | forum lezen (buitenstaander) | 1 | 1 |
| 2 | + forum schrijven (maatje) | – | 2, 3 |
| 3 | 2 + redactie | 2 | 4 |
| 4 | 2 + WAS lezen | 3 | – |
| 5 | 2 + WAS lezen en schrijven | 4 | 5 |
| 6 | 5 + maatjes wijzigen + presentie anderen | 7, 8 | 7, 8 |
| 7 | redactie + WAS lezen | 5 | – |
| 8 | redactie + WAS lezen en schrijven | 6 | 6 |
| 9 | alles (beheerder) | 9, 'j' | 9, 'j' |

Rechten: forum_lezen 1-9; forum_schrijven 2-9; redactie 3,7,8,9; was_lezen 4-9; was_wijzigen 5,6,8,9; maatjes_wijzigen 6,9; presentie_anderen 6,9; beheerder 9.

## Publieke websites
- Beide gebruiken Tools::MailRoom (aanmelding, workshop, partnerbijeenkomst, contact, nieuwsbrief), getShortPost, sectOne, ConvertTS en de classes Werkzoekende, Processtap, Newsitem, Agendaitem, Jobgroup, Maatje, Keyrecord. pub-jhc ook Sucstor (succesverhalen).
- pub-jhc: de homepage hangt af van $_SESSION['DOELGROEP'] (keytabel 'doelgroep'). Het losse formulier t-aanmelden.php heeft eigen instellingen in includes/t-config.php.
- Alle formulieren sturen de mail voor de organisatie naar aanmelding@<domein>; dat adres stuurt door naar meerdere personen.
- Lokaal in MAMP: includes/configDB.php van de publieke sites bevat de servergegevens. Pas je die aan voor MAMP, dan mag hij nooit meer mee naar de server.
- Nog niet doorgelicht: de pagina's van de publieke sites zelf (escaping, formulieren, CSRF). pub-jhmz/proces_nbemail.php stuurt ook mail naar het ingevulde adres zonder controle.

## Openstaande bevindingen
MIDDEL
8. Collectieklassen plakken WHERE-waarden als string in de SQL (vandaag veilig; id's uit de URL zijn nu (int)).
15. Adres automatisch invullen (aanmelding_wkz) werkt niet meer: oude PDOK-URL. Later aanpassen (Jan).
16. Bewaartermijn: cleanDB ruimt alleen handmatig gemarkeerde werkzoekenden op; intake-PDF belooft verwijdering 6 maanden na het traject.
17. JavaScript-bibliotheken via CDN in verschillende versies.
18. HTML-entiteiten (&eacute;) in de database; ruimen zich op bij opslaan.
19. agenda.php (publieke sites) gebruikt strftime(): deprecated in PHP 8.1, verdwijnt in PHP 9.
20. www.intra.jobhulpculemborg.nl valt niet onder het SSL-certificaat (waarschuwing in het serverlog; onschuldig zolang niemand die naam gebruikt).

Opgelost: 5 (CSRF), 10 (latin1 → utf8mb4), 11 (cookie_samesite).

## Volgorde
A, B, C, D klaar. Live met de nieuwe code: intra.jhmz.nl (10 okt), jobhulpmaatjezoetermeer.nl en jobhulpculemborg.nl (11 okt).

Volgende:
1. **Uitrol intra.jobhulpculemborg.nl** volgens de checklist: upload-culemborg/ staat klaar (complete class/); migraties _culemborg; configDB.php op de server aanvullen; jhcintradb.sql niet uploaden; SAMENVOEGEN.
2. **Zoetermeer bijwerken:** upload-pub-jhmz/ (class/ + jaarverslag, jobgroups, maatjes, proces_nbemail) en upload-jhmz/ (class/ + beheerwas/mut_maatje.php).
3. Formulieren jobhulpculemborg.nl testen met MAIL_TESTMODUS voor Jans IP-adres.
4. ./vergelijk.sh in Terminal met MAMP aan (databasecheck).
5. Opruimen na een paar dagen: class_oud/ en config_oud.php/proces_aanmelding_oud.php op de servers; lokaal herstel-pub-jhc/.

Later: de pagina's van de publieke sites doorlichten; bevindingen 15-20; E. Documentenfunctie.
