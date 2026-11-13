# Onderhoudsgids intranetten (Zoetermeer en Culemborg)

Voor Jan, en voor wie het later van Jan overneemt.
Stand: **13 november 2026**.

Deze gids beschrijft hoe de vier websites in elkaar zitten, hoe je ze veilig
aanpast en live zet, en waar je moet kijken als er iets misgaat. Je hoeft niet
te weten hoe elke functie van binnen werkt. Je moet weten **waar** iets staat en
**wanneer** je wat gebruikt.

Inhoud:

1. De sites en de omgeving
2. Werkwijze: git, Nova, publiceren
3. De zes programmeerregels
4. Sjablonen
5. Rechten en het Systeem-scherm
6. Het documentsysteem (DBS)
7. Testen
8. Andere klussen
9. Als er iets misgaat
10. Lijstje voor je een wijziging afrondt
11. Stand van zaken en open punten

---

## 1. De sites en de omgeving

### De vier sites

| Map in `~/Sites/jobhulp-intra` | Site | GitHub (privé, gebruiker `jangg`) |
|---|---|---|
| `intra-jhmz` | intranet Zoetermeer, intra.jhmz.nl | `zoetermeer-intranet` |
| `intra-culemborg` | intranet Culemborg, intra.jobhulpculemborg.nl | `culemborg-intranet` |
| `pub-jhmz` | publieke site Zoetermeer | `zoetermeer-website` |
| `pub-jhc` | publieke site Culemborg, jobhulpculemborg.nl | `culemborg-website` |
| (de hoofdmap zelf) | gedeeld: migraties, scripts, deze gids | `jobhulp-gedeeld` |

Elke site heeft zijn **eigen git-repository** in zijn eigen map. De hoofdmap
`~/Sites/jobhulp-intra` is een vijfde repository voor wat bij alle sites hoort.

De servers staan bij **Versio** (PHP 8.3, beheer via DirectAdmin).
Het intranet Zoetermeer staat op de server in `/domains/jhmz.nl/public_html/intra`.

### Afspraken die altijd gelden

- **Zoetermeer is leidend** (sinds 28 okt 2026). Een wijziging gaat eerst in
  `intra-jhmz`, daarna naar Culemborg.
- **`class/` is in alle vier de sites precies gelijk.** De publieke sites gebruiken
  dezelfde database en dezelfde classes als het intranet van hun organisatie.
  Wijzig je een class, kopieer hem dan naar de andere sites en draai `./vergelijk.sh`.
  (Tijdelijke uitzondering: zie hoofdstuk 11.)
- **De database-structuur is in beide organisaties gelijk.** De inhoud verschilt.
- **Tabellen worden alleen binnen hun eigen class gelezen en geschreven**, nooit
  daarbuiten. `Person` is alleen een basisclass voor `Maatje` en `Werkzoekende`.
- **Inhoud mag per site verschillen** (teksten, logo, `includes/statuslijst.php`).

### Op je Mac

- **MAMP PRO 6.9**, PHP 8.2 standaard; per host kun je PHP 8.3 kiezen.
- Intranet Zoetermeer lokaal: `https://intra-jhmz:8880/`
- Lokale database `intraDB`: een kopie van de Zoetermeer-productiedatabase.
- **Demo-omgeving** voor instructievideo's: map `intra-jhmz-demo`, database
  `jhmz_demo` (fictieve gegevens), adres `http://intra-jhmz-demo.localhost:8888`.
  Staat niet in git.
- Foutmeldingen van PHP: `/Applications/MAMP/logs/php_error.log`
- Instellingen per site (wachtwoorden, databasenaam, documentenmap) staan in
  `includes/configDB.php`. Dat bestand staat **niet** in git en gaat **nooit**
  mee bij publiceren: de server heeft zijn eigen versie met de echte wachtwoorden.
  Een voorbeeld staat in `includes/configDB.voorbeeld.php`.

### Wat er verder in de hoofdmap staat

| Bestand of map | Waarvoor |
|---|---|
| `ONDERHOUD.md` | deze gids |
| `DOORLICHTING.md` | de doorlichting van oktober 2026 en wat daarna is gedaan |
| `migraties/` | SQL-bestanden die de database-structuur veranderen (zie 8) |
| `vergelijk.sh` | controleert of class/, rechten en database gelijk lopen |
| `wissel.sh` | zet alle vier de sites tegelijk op dezelfde branch |
| `wat-uploaden.sh` | welke bestanden zijn veranderd sinds de vorige upload |
| `anonimiseer.php` | maakt een kopie van de database met fictieve gegevens |
| `jobhulp-documenten/` | de lokale documentenmap van het DBS (niet in git) |
| `instructievideos/` | de instructievideo's van het DBS (niet in git) |
| `upload-*` | oude uploadpakketten van de uitrol in oktober/november (niet in git) |

---

## 2. Werkwijze: git, Nova, publiceren

### Git in drie zinnen

- Een **commit** is een vastgelegde stand met een korte uitleg. Daarmee kun je
  altijd zien wat er wanneer en waarom veranderde, en kun je terug.
- Een **branch** is een aparte lijn van commits. **`main` is wat op de server
  staat** (of zo meteen komt te staan).
- **GitHub** is de reservekopie in de cloud. Daar komt alleen iets als je **pusht**.

### De regels

1. **Een verbetering** aan wat er al is (een fout, een tekst, een kleine
   aanpassing) gaat direct op `main` en zo snel mogelijk live.
2. **Een nieuwe functie** krijgt een eigen branch (bijvoorbeeld `intake-pdf-opslaan`).
   Pas als hij helemaal af en getest is, wordt hij samengevoegd met `main` en gaat
   hij live.
3. **Publiceer alleen als Nova op `main` staat.** Nova publiceert wat er op dat
   moment in de map staat. Sta je op een andere branch, dan zet je half werk live.
   Kijk dus altijd eerst bovenin het venster: daar moet `main` staan.
4. **Push na het publiceren** naar GitHub, zodat de reservekopie bijblijft.

Claude doet meestal het committen. Jij bekijkt de stand in Nova.

### Samenvoegen (merge) in Nova

Je staat altijd op de branch die de wijzigingen **ontvangt**. Voor een nieuwe
functie is dat `main`.

1. Zorg dat alles op de feature-branch gecommit is (geen "Changes" meer in het Git-paneel).
2. Zet Nova op `main`: branch-menu bovenaan het Git-paneel, of dubbelklik op
   `main` in de Repository View.
3. Repository View: klik met rechts (of ⌘-klik) op de feature-branch en kies
   de merge-optie.
4. Controleer dat de commits van de feature nu in de geschiedenis van `main` staan.
5. Ruim op: klik met rechts op de feature-branch en verwijder hem.
6. Publiceren en pushen.

Meldt Nova een **merge-conflict** (op beide branches zijn dezelfde regels
veranderd)? Doe niets en vraag hulp.

### Publiceren met Nova

Nova houdt bij welke bestanden zijn veranderd sinds Nova de vorige keer publiceerde.
Het kijkt naar de **wijzigingsdatum**, niet naar de inhoud. Daardoor:

- Na het wisselen van branch staan er bestanden in de lijst die inhoudelijk niet
  veranderd zijn. Git heeft ze opnieuw op schijf gezet. Dat kan geen kwaad: ze
  worden overschreven met dezelfde inhoud.
- Wat met een ander programma is geüpload (vroeger Transmit), weet Nova niet.

**Na het publiceren:** kijk op de live-site of de wijziging werkt.

`includes/configDB.php` mag nooit gepubliceerd worden. Staat hij in de lijst,
vink hem dan uit.

### Lock-bestanden

Als Claude commit, kan git soms zijn eigen tijdelijke bestanden (`.lock`) niet
opruimen. Nova of git geeft dan een melding met *"File exists"* of `index.lock`.
Oplossing: vraag Claude de lock-bestanden op te ruimen, of verwijder in Finder
het genoemde `.lock`-bestand in de verborgen map `.git` van die site (alleen als
er op dat moment niets met git bezig is).

### De scripts (in Terminal, in `~/Sites/jobhulp-intra`)

- **`./vergelijk.sh`**: draai dit voor elke upload. Controleert class/, rechten en
  de database-structuur (MAMP moet aan staan). `./vergelijk.sh -v` toont ook de
  verschillen per regel.
- **`./wissel.sh main`**: alle vier de sites op `main`. `./wissel.sh` zonder naam
  toont op welke branch elke site staat. Werkt alleen als alles gecommit is.
- **`./wat-uploaden.sh`**: verschil tussen de tag `op-server` en `main` per site.
  Na een upload: `./wat-uploaden.sh --klaar <site>` om de tag te verzetten.
  Dit stamt uit de tijd van Transmit; met Nova is het een extra controle.

### Onderhoudsmodus

Bovenaan de `.htaccess` van elk intranet staat een blok voor de onderhoudsmodus.

- **Aan:** zet op de server een leeg bestand `onderhoud.aan` in de hoofdmap van de site.
  Bezoekers zien dan `onderhoud.html`.
- **Uit:** verwijder `onderhoud.aan`.
- Vanaf Jans IP-adressen (IPv4 en IPv6, staan in de `.htaccess`) werkt de site
  gewoon, zodat je kunt testen. Verandert je internetaansluiting, pas die regels aan.
- De cronjob (verjaardagskaarten) loopt door tijdens het onderhoud.

Zoekmachines: de intranetten sturen een `noindex`-kop mee (in `.htaccess`) en
hebben een `robots.txt`, zodat ze niet in Google verschijnen.

---

## 3. De zes programmeerregels

Alles hieronder staat in `config.php` (gelijk in alle sites).

### 1. Waarde op het scherm? Dan `h()`

Alles wat uit de database of uit een formulier komt en in de HTML terechtkomt.

```php
// vroeger
echo '<td>' . $maatje->achternaam . '</td>';
// nu
echo '<td>' . h($maatje->achternaam) . '</td>';
```

```php
<input type="text" name="voornaam" value="<?= h($mtj->voornaam) ?>">
```

Waarom: staat er in een naam `<script>` of een `"`, dan wordt dat als tekst
getoond in plaats van uitgevoerd. "Ren&eacute;" uit de database blijft gewoon René.

**Niet** gebruiken voor HTML die je zelf in de code opbouwt (bijvoorbeeld `'<p>'`,
een `$html`-blok dat al klaar is). Dan zie je de codes op het scherm.

### 2. Formulier met `method="POST"`? Dan `csrf_veld()`

Eén regel, direct na de `<form>`-tag:

```php
<form method="POST" action="mut_maatje.php">
    <?= csrf_veld() ?>
    ...
</form>
```

Vergeet je het, dan krijg je bij opslaan: *"Het formulier kon niet worden verwerkt"*.
Er gaat dus nooit ongemerkt iets mis. De controle zelf gebeurt automatisch onderaan
`config.php`.

Formulieren met `method="GET"` (zoeken, filteren) hebben het niet nodig.
AJAX met jQuery (`$.post`, `$.ajax`) gaat vanzelf goed.

Let op: een `<form>` mag niet binnen een `<p>` staan. Gebruik een `<div>`.
Knoppen op één rij: `<div class="d-flex">` (Bootstrap).

### 3. Iets verwijderen of opslaan? Nooit via een link

```php
// vroeger
'<a href="overz_maatjes.php?del=j&id=' . $maatje->id . '">...</a>'
// nu
verwijderknop('overz_maatjes.php', ['del_id' => $maatje->id], 'Weet je zeker dat je dit maatje wilt verwijderen?')
```

Bovenaan dezelfde pagina verwerk je het:

```php
if (isset($_POST['del_id'])) {
    require_recht('maatjes_wijzigen');
    $item = new Maatje('id', (int)$_POST['del_id']);
    $item->delind = 'j';
    $item->updateToDB();
}
```

Algemene regel: **een link (GET) mag alleen iets tonen, nooit iets wijzigen.**
Wil je eerst een waarschuwing? `onsubmit="return confirm('...')"` op het formulier,
zoals `verwijderknop()` en de knop "PDF opslaan" dat doen.

### 4. Wie mag dit? `require_recht()`, `heeft_recht()`, `knop_uit()`

```php
require_recht('was_lezen');            // bovenaan een pagina: anders "geen toegang"

if (heeft_recht('maatjes_wijzigen')) { // iets alleen tonen als iemand het mag
    echo verwijderknop(...);
}

<button type="submit" name="updateMtBut" value="wijzig" <?= knop_uit('maatjes_wijzigen') ?>>Opslaan</button>
                                       // knop wordt grijs als iemand het niet mag
```

`knop_uit()` is alleen gemak voor de gebruiker. Controleer bij het **verwerken**
altijd nog met `require_recht()`. Welke rechten er zijn: hoofdstuk 5.

### 5. Veld waarin de redactie HTML-opmaak gebruikt? `Tools::veiligeHtml()` of `Tools::opmaakHtml()`

Alleen voor velden waarin bewust opmaak staat. Laat de toegestane opmaak door,
haalt al het andere weg (scripts, onclick, enz.).

| Functie | Voor | Laat toe |
|---|---|---|
| `Tools::veiligeHtml($x)` | korte velden: postit, nieuwstitel, agenda freefld3 | vet, cursief, onderstreept, br, span, small |
| `Tools::opmaakHtml($x)` | Summernote-teksten: forum, nieuws, agenda | ook alinea's, kopjes, lijsten, tabellen, links, plaatjes |

```php
echo '<p>' . Tools::opmaakHtml($newsitem->tekst_kort) . '</p>';
```

Twijfel je? Gebruik `h()`. Zie je dan `<b>` op het scherm, dan was het een opmaakveld.

### 6. Wachtwoorden: niets aan doen

Dat regelt de class `User` zelf (`verifyPassword()`, `setPassword()`).
In Zoetermeer maak je gebruikers en wachtwoorden op het Systeem-scherm (hoofdstuk 5).
In Culemborg nog in phpMyAdmin, met een leesbaar tijdelijk wachtwoord en
`password_mod = 'j'`. Bij de eerste keer inloggen wordt het vanzelf versleuteld.

---

## 4. Sjablonen

### Nieuwe pagina

```php
<?php
include_once('../config.php');          // in de hoofdmap: 'config.php'
include_once('../class/c_user.php');

require_recht('was_lezen');             // doet ook de inlogcontrole

$id = (int)($_GET['id'] ?? 0);          // getal uit de URL altijd met (int)
?>
<!DOCTYPE html>
<html lang="nl">
<head>
<?php include '../includes/head.php'; ?>
</head>
<body>
<?php include '../includes/navbar.php'; ?>

<h1><?= h($titel) ?></h1>

</body>
</html>
```

Kijk voor de precieze kop/navbar naar een bestaande pagina in dezelfde map.

### Formulier met opslaan

```php
<?php
include_once('../config.php');
include_once('../class/c_maatje.php');
require_recht('maatjes_wijzigen');

if (isset($_POST['opslaan'])) {
    $m = new Maatje('id', (int)$_POST['id']);
    $m->voornaam = $_POST['voornaam'];   // opslaan zoals ingetypt
    $m->updateToDB();
}
?>
<form method="POST" action="">
    <?= csrf_veld() ?>
    <input type="hidden" name="id" value="<?= h($m->id) ?>">
    <input type="text" name="voornaam" value="<?= h($m->voornaam) ?>">  <!-- tonen met h() -->
    <button type="submit" name="opslaan" <?= knop_uit('maatjes_wijzigen') ?>>Opslaan</button>
</form>
```

Onthoud: **opslaan zoals ingetypt, ontsnappen bij het tonen.**

### Melding na opslaan

Na het verwerken van een formulier stuur je de gebruiker terug naar de pagina
(`header('location: ...')`), met de melding in de sessie. Zo krijg je bij
"vernieuwen" geen tweede keer opslaan.

```php
// bij het verwerken
$_SESSION['intake_melding'] = ['success', 'Het is opgeslagen.'];   // of 'danger', 'warning'
header('location: intake.php?id=' . urlencode($id));
exit();

// op de pagina: één keer tonen, dan weg
$melding = $_SESSION['intake_melding'] ?? null;
unset($_SESSION['intake_melding']);
```

Voorbeelden: `beheerwas/intake_pdf.php` en `documenten.php`.

---

## 5. Rechten en het Systeem-scherm

### Zoetermeer: rechten per gebruiker (live sinds 8 nov 2026)

Elke gebruiker heeft zijn eigen lijst van rechten in de tabel `user_recht`
(één regel per recht). De beheerder stelt ze in op **Beheer > Systeem**
(`systeem.php`): vinkjes per recht, met profielknoppen.

| Recht | Betekent |
|---|---|
| `forum_lezen`, `forum_schrijven` | forum |
| `redactie` | nieuws, agenda, postits |
| `was_lezen`, `was_wijzigen` | het WAS (werkzoekenden, intakes) |
| `maatjes_wijzigen` | maatjes wijzigen en verwijderen |
| `presentie_anderen` | anderen aanmelden voor maatjesavonden |
| `documenten_gedeeld` | DBS A: de gedeelde map van de coördinatoren |
| `documenten_eigen` | DBS B: documenten van de eigen werkzoekenden (als maatje) |
| `documenten_werkzoekenden` | DBS C: documenten van alle werkzoekenden |
| `beheerder` | mag alles |

Alles staat in `includes/rechten.php`:

- **Nieuw recht:** één regel in `RECHTEN`. Het vinkje verschijnt vanzelf op het
  Systeem-scherm; de database verandert niet.
- **`VEREIST`:** rechten die een ander recht nodig hebben (bijv. `was_wijzigen`
  neemt `was_lezen` mee).
- **`PROFIELEN`:** vaste combinaties voor de profielknoppen (Buitenstaander,
  Maatje, Redactie, Coördinator, Coördinator + maatjes). Alleen de vinkjes worden
  opgeslagen, niet het profiel.

Maatjes mogen het WAS **niet** lezen.

### Regels van het Systeem-scherm

- Een gebruiker moet eerst als **maatje** bestaan.
- Alleen Jan maakt gebruikersnamen aan. Een gebruikersnaam kan daarna niet meer
  veranderen.
- "Verwijderen" is **blokkeren** (`delind = 'j'`). Deblokkeren kan ook.
- Wachtwoord: een tijdelijk wachtwoord (één keer op het scherm) of een mail met
  een link waarmee de gebruiker er zelf een instelt.
- Het **beheerder-account** kan op het Systeem-scherm nooit gewijzigd, geblokkeerd
  of verwijderd worden. Beheerder maken kan alleen in phpMyAdmin (`user_recht`).

`user.beheerind` staat nog in de database maar wordt in Zoetermeer niet meer
gebruikt (behalve als de tabel `user_recht` nog niet bestaat).

### Culemborg: nog niveaus (tot de rechten per gebruiker daar volgen)

In Culemborg geldt nog het niveau in `user.beheerind`:

| Niveau | Mag |
|---|---|
| 0 | inloggen, geen forum |
| 1 | forum lezen (buitenstaander) |
| 2 | + forum schrijven (maatje) |
| 3 | 2 + redactie |
| 4 | 2 + WAS lezen |
| 5 | 2 + WAS lezen en schrijven |
| 6 | 5 + maatjes wijzigen/verwijderen, anderen aanmelden voor maatjesavonden |
| 7 | redactie + WAS lezen |
| 8 | redactie + WAS lezen en schrijven |
| 9 | alles (beheerder) |

De code gebruikt in beide sites dezelfde namen (`require_recht('was_lezen')`).
`includes/rechten.php` vertaalt die in Culemborg naar niveaus.

---

## 6. Het documentsysteem (DBS)

Live in Zoetermeer sinds 8 nov 2026. Vervangt Dropbox. Alles blijft binnen het
intranet; er gaan geen bestanden naar buitenstaande diensten.

### Wat de gebruikers zien

- **A. Gedeelde map** voor de coördinatoren (wie het WAS mag lezen én wijzigen).
  Iedereen met recht A ziet alles; verwijderen kan alleen wie het document heeft
  toegevoegd (en de beheerder). Maximum: 4 GB voor de hele map.
- **C. Map per werkzoekende.** Het maatje ziet de documenten van zijn eigen
  werkzoekenden (recht B), de coördinatoren die van alle werkzoekenden (recht C).
  Maximum: 100 MB per persoon (wat iemand bij werkzoekenden heeft toegevoegd).
- Mappen met submappen, een hele map in één keer uploaden, zoeken op naam.
- Niet-actieve werkzoekenden blijven zichtbaar, met een label.
- De ruimte "eigen" (B als persoonlijke map) is niet gekozen; die staat alleen
  nog in de database voor documenten uit de testperiode.

### Hoe het werkt

- **De gegevens** staan in de database: tabellen `document`, `docmap` (mappen,
  met `parent_id` voor submappen) en `instelling` (de instellingen van de beheerder).
- **De bestanden** staan in `DOC_DIR`, een map **buiten** `public_html`, ingesteld
  in `includes/configDB.php`. Lokaal: `~/Sites/jobhulp-intra/jobhulp-documenten/zoetermeer/`.
- Elk bestand krijgt in `DOC_DIR` een **willekeurige naam van 32 tekens**. De echte
  naam staat alleen in de database. Niemand kan een bestand via een webadres
  opvragen of raden; downloaden gaat altijd via `document.php`, die eerst de
  rechten controleert.
- **Wie wat mag** staat op één plek in `class/c_documenten.php`:
  `Document::magPagina()`, `Document::magRuimte()` en `Document::magWijzigen()`.
  De pagina's vragen het altijd daar na.
- Bij het uploaden wordt gecontroleerd: soort bestand (lijst van de beheerder),
  grootte, het maximum per persoon of van de gedeelde map, en de **inhoud**
  (`finfo`): een programma of webpagina met de naam "brief.pdf" komt er niet in.
  Uitvoerbare soorten (`php`, `exe`, `js`, `html`, enz.) zijn altijd verboden,
  ook als de beheerder ze invult (`Instelling::VERBODEN`).

De classes in `c_documenten.php` (alle methodes zijn `static`, dus `Document::zoek(12)`):

| Class | Voor |
|---|---|
| `Instelling` | instellingen van de beheerder (soorten, max. grootte, maxima) |
| `DocMap` | mappen |
| `Document` | documenten, rechten, uploaden, opslaan, opruimen |

### Voor de beheerder: Beheer > Documenten (`documenten_beheer.php`)

- Toegestane soorten bestanden, maximale grootte per bestand, maximum per persoon,
  maximum voor de gedeelde map.
- **Opslag in gebruik:** aantal documenten en ruimte per ruimte en totaal.
- **Controle:** bestanden zonder regel in de database en andersom.
- **Wezen opruimen:** documenten van werkzoekenden die niet meer bestaan
  (bijvoorbeeld buiten het intranet om verwijderd in phpMyAdmin).

### Intakeformulier opslaan als PDF (live 13 nov 2026)

Op het intakescherm staan drie knoppen: **maak PDF**, **PDF opslaan** en **terug**.

- "PDF opslaan" zet het formulier in de map van de werkzoekende als
  `Intakeformulier Voornaam Achternaam JJJJ-MM-DD.pdf`.
- Bij **alle** werkzoekenden, actief of niet, maar alleen voor wie bij de
  documenten van die werkzoekende mag.
- Al eens vandaag opgeslagen? Dan vraagt de knop eerst of het oude bestand vervangen
  mag worden. Wie vervangt, wordt de nieuwe "eigenaar" van dat document.
- Toestemming van de werkzoekende is niet nodig: de PDF is alleen een andere
  weergave van wat al in de database staat.
- Code: `beheerwas/intake.php` (knop), `beheerwas/intake_pdf.php` (maken en opslaan),
  `Document::intakeNaam()` (de naam) en `Document::bewaarInhoud()` (opslaan).

`Document::bewaarInhoud()` kun je ook gebruiken voor andere bestanden die het
intranet zelf maakt (een export, een overzicht). Gebruik voor bestanden van
gebruikers altijd `Document::upload()`.

### Opruimen en reservekopieën

- `maintenance/cleanDB.php` verwijdert werkzoekenden met `delind = 'j'` en neemt
  hun documenten mee (`Document::verwijderAllesVan()`): de regels in de database
  én de bestanden. Zonder `--execute` doet het alleen een proefronde.
- **Een reservekopie van de database bevat de documenten zelf niet.** Die staan in
  `DOC_DIR`. Voor een volledige reservekopie heb je beide nodig, en ze moeten bij
  elkaar passen (de `opslagnaam` in de database = de bestandsnaam in de map).

### Instructievideo's

Zes korte video's (toevoegen, openen, map maken, naam wijzigen/verwijderen,
gedeelde map, instellingen voor de beheerder) staan in
`~/Sites/jobhulp-intra/instructievideos`. Ze zijn gemaakt in de demo-omgeving
met fictieve gegevens. Culemborg gebruikt dezelfde video's.

Het inbouwen in het intranet (een helppagina en vraagteken-knoppen per scherm)
staat in de branch `instructievideos` van `intra-jhmz` en is nog **niet** live.

---

## 7. Testen

- Test eerst lokaal in MAMP, met een kopie van de productiedatabase.
- Na het testen: `/Applications/MAMP/logs/php_error.log` moet leeg zijn (of geen
  nieuwe regels hebben).
- Lokaal gaat mail niet echt de deur uit (`MAIL_TESTMODUS` in `configDB.php`);
  de mail komt in de error log.
- **Met fictieve gegevens werken** (voor video's, schermafdrukken of als iemand
  meekijkt): `anonimiseer.php` maakt een kopie van de database met verzonnen
  namen. Uitleg staat bovenin dat bestand. Het weigert te draaien op de server.
- Claude kan de code ook controleren met **PHPStan** (zoekt fouten zonder de
  pagina te openen). Dat is in november 2026 voor alle sites gedaan.

---

## 8. Andere klussen

**Class aanpassen** (`class/`): altijd in alle vier de sites hetzelfde. Daarna
`./vergelijk.sh`.

**Database-structuur aanpassen:** schrijf de SQL in
`migraties/JJJJ-MM-DD_omschrijving.sql` (in de hoofdmap), voer hem uit in beide
databases (lokaal in MAMP, later op de server via phpMyAdmin), daarna
`./vergelijk.sh` (moet twee keer OK geven). Een migratie die maar voor één site
is, krijgt `_jhmz` of `_culemborg` in de naam.

**Nieuwe map** waarin alleen PHP-bestanden komen die nooit direct geopend worden
(zoals `class/`, `includes/`): kopieer de `.htaccess` uit `includes/` erin.

**Nieuwe map met foto's van personen:** niet zomaar aanmaken; die moeten via
`foto.php` lopen (inlogcontrole). Vraag hulp.

**Nieuwe bibliotheek** (zoals TCPDF, nu 6.11.4): map vervangen, de `.htaccess`
in die map bewaren.

**PDF maken:** TCPDF met de instellingen uit `includes/pdf_instellingen.php`.
Voorbeeld: `beheerwas/intake_pdf.php` met de class `IntakeformPDF`.
`Output('naam.pdf', 'I')` toont de PDF in de browser, `Output('', 'S')` geeft
hem terug als tekst om op te slaan.

**`pages/presence_list.php` in Culemborg** (presentielijst maatjesavonden): Jan
past die met de hand aan; hij staat bewust niet in git.

---

## 9. Als er iets misgaat

| Je ziet | Oorzaak | Oplossing |
|---|---|---|
| "Het formulier kon niet worden verwerkt" | `csrf_veld()` vergeten, of sessie verlopen | regel 2 toevoegen; of opnieuw inloggen |
| "Je hebt geen toegang tot deze pagina" | gebruiker heeft dat recht niet | Beheer > Systeem (Culemborg: `beheerind`) |
| `&lt;b&gt;` of `<b>` als tekst op het scherm | `h()` op een opmaakveld | `Tools::veiligeHtml()` of `opmaakHtml()` |
| Opmaak verdwijnt (bijv. een plaatje) | `veiligeHtml()` is te streng voor dit veld | `opmaakHtml()` gebruiken |
| Witte pagina | PHP-fout | `/Applications/MAMP/logs/php_error.log` (server: DirectAdmin, error log) |
| Pagina stopt halverwege een commentaar | `?>` in een `//`-commentaar | die tekens uit het commentaar halen |
| Knoppen staan onder elkaar of verspringen | `<form>` binnen een `<p>` | `<div class="d-flex">` gebruiken |
| "De documentenmap op de server is niet ingesteld" | `DOC_DIR` ontbreekt in `configDB.php`, of de map is niet beschrijfbaar | `DOC_DIR` controleren; map aanmaken met schrijfrechten voor PHP |
| Document wel in de lijst, maar downloaden lukt niet | bestand ontbreekt in `DOC_DIR` | Beheer > Documenten, Controle |
| Git/Nova: "File exists" of `index.lock` | lock-bestand van een eerdere git-opdracht | zie hoofdstuk 2, Lock-bestanden |
| Nova toont bestanden die niet veranderd zijn | branch gewisseld (nieuwe datum) | onschuldig; wel eerst controleren dat je op `main` staat |
| Merge-conflict in Nova | op beide branches dezelfde regels veranderd | niets doen, hulp vragen |
| Site toont alleen de onderhoudspagina | `onderhoud.aan` staat nog op de server | dat bestand verwijderen |

---

## 10. Lijstje voor je een wijziging afrondt

- [ ] Elke waarde op het scherm door `h()` (of veiligeHtml/opmaakHtml)?
- [ ] Elk POST-formulier `csrf_veld()`?
- [ ] Niets wijzigen via een link?
- [ ] Pagina en verwerking afgeschermd met `require_recht()`?
- [ ] Getallen uit `$_GET`/`$_POST` met `(int)`?
- [ ] Class gewijzigd? Ook in de andere drie sites, en `./vergelijk.sh`.
- [ ] Database gewijzigd? Migratie in `migraties/`, in beide databases uitgevoerd.
- [ ] Zelfde wijziging ook in Culemborg (als het geen inhoud is)?
- [ ] `php_error.log` leeg na het testen?
- [ ] Commit in git met een korte uitleg.
- [ ] Nieuwe functie? Samengevoegd met `main`.
- [ ] Nova op `main` voor het publiceren; `configDB.php` niet mee.
- [ ] Na het publiceren gekeken op de live-site, en gepusht naar GitHub.
- [ ] Deze gids bijgewerkt als er iets nieuws is bijgekomen.

---

## 11. Stand van zaken en open punten (13 nov 2026)

### Wat waar live staat

| | Zoetermeer | Culemborg |
|---|---|---|
| Doorlichting oktober (stappen A–D, PHP 8.3, TCPDF) | live | live |
| Rechten per gebruiker + Systeem-scherm | live (8 nov) | nog niveaus; in branch `systeem` |
| Documentsysteem (DBS) | live (8 nov) | nog niet; in branch `documenten` |
| Intake-PDF opslaan in DBS | live (13 nov) | nog niet (heeft het DBS nodig) |
| Instructievideo's in het intranet | branch `instructievideos` | volgt met het DBS |

### Tijdelijke uitzondering op "class/ gelijk"

Omdat Zoetermeer eerst is uitgerold, verschilt `class/` nu tussen de organisaties:
Culemborg heeft nog geen `c_documenten.php` en een oudere `c_user.php` en
`c_maatje.php` (zonder rechten per gebruiker). Binnen een organisatie is class/
wel gelijk (intranet en publieke site). Als Culemborg het DBS en de rechten per
gebruiker krijgt, is alles weer gelijk.

### Open punten

- **Culemborg bijwerken:** rechten per gebruiker, Systeem-scherm, DBS, intake-PDF
  en de video's, op dezelfde manier als in Zoetermeer.
- **Instructievideo's** inbouwen (helppagina en vraagteken-knoppen) en live zetten.
- **AVG-opschoning:** periodiek gegevens opruimen van werkzoekenden en maatjes die
  niet meer bij de organisatie horen (ook jobgroup, nieuws, agenda). Uitgangspunten:
  minstens twee jaar bewaren voor analyse en jaarverslag; gegevens van verwijderde
  werkzoekenden als export aan de organisaties geven. **Er wordt niets gebouwd
  voordat beide besturen akkoord zijn.** De opgeslagen documenten (ook de
  intake-PDF's) gaan mee via `Document::verwijderAllesVan()`.
- **MAMP PRO 7:** upgraden als er tijd is.
