# Onderhoudsgids intranetten (Culemborg en Zoetermeer)

Voor Jan. Hoe je na de doorlichting van oktober 2026 zelf pagina's en formulieren
aanpast of toevoegt. Alles wat hier staat, staat in `config.php` (identiek in beide sites).

Je hoeft niet te weten hoe deze functies van binnen werken. Je moet alleen weten
**wanneer** je ze gebruikt, net zoals bij TCPDF of PHPMailer.

---

## De zes regels

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

Waarom: staat er in een naam `<script>` of een `"`, dan wordt dat nu als tekst
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
`config.php`; daar hoef je niets voor te doen.

Formulieren met `method="GET"` (zoeken, filteren) hebben het niet nodig.
AJAX met jQuery (`$.post`, `$.ajax`) gaat vanzelf goed.

### 3. Iets verwijderen? Dan `verwijderknop()`, nooit een link

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

### 4. Wie mag dit? `require_recht()`, `heeft_recht()`, `knop_uit()`

De namen van de rechten staan in `includes/rechten.php` (verschilt per site):
`forum_lezen`, `forum_schrijven`, `redactie`, `was_lezen`, `was_wijzigen`,
`maatjes_wijzigen`, `presentie_anderen`, `beheerder`.

```php
require_recht('was_lezen');            // bovenaan een pagina: anders "geen toegang"

if (heeft_recht('maatjes_wijzigen')) { // iets alleen tonen als iemand het mag
    echo verwijderknop(...);
}

<button type="submit" name="updateMtBut" value="wijzig" <?= knop_uit('maatjes_wijzigen') ?>>Opslaan</button>
                                       // knop wordt grijs als iemand het niet mag
```

`knop_uit()` is alleen gemak voor de gebruiker. Controleer bij het **verwerken**
altijd nog met `require_recht()`.

Wie welk niveau heeft, blijft `user.beheerind`. Een niveau een ander recht geven:
alleen `rechten.php` aanpassen.

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
Nieuwe gebruiker: zoals altijd in phpMyAdmin met een leesbaar tijdelijk wachtwoord
en `password_mod = 'j'`. Bij de eerste keer inloggen wordt het vanzelf versleuteld.

---

## Sjabloon: nieuwe pagina

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

## Sjabloon: formulier met opslaan

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

---

## Andere klussen

**Class aanpassen** (`class/`): altijd in beide sites hetzelfde. Daarna `./vergelijk.sh`.

**Database-structuur aanpassen:** schrijf de SQL in `migraties/JJJJ-MM-DD_omschrijving.sql`,
voer hem uit in beide databases (MAMP en later Versio), daarna `./vergelijk.sh`
(moet twee keer OK geven).

**Nieuwe map** waarin alleen PHP-bestanden komen die nooit direct geopend worden
(zoals `class/`, `includes/`): kopieer de `.htaccess` uit `includes/` erin.

**Nieuwe map met foto's van personen:** niet zomaar aanmaken; die moeten via
`foto.php` lopen (inlogcontrole). Vraag hulp.

**Nieuwe bibliotheek** (zoals TCPDF): map vervangen, de `.htaccess` in die map bewaren.

---

## Als er iets misgaat

| Je ziet | Oorzaak | Oplossing |
|---|---|---|
| "Het formulier kon niet worden verwerkt" | `csrf_veld()` vergeten, of sessie verlopen | regel 2 toevoegen; of opnieuw inloggen |
| "Je hebt geen toegang tot deze pagina" | niveau heeft dat recht niet | `rechten.php` of `beheerind` controleren |
| `&lt;b&gt;` of `<b>` als tekst op het scherm | `h()` op een opmaakveld | `Tools::veiligeHtml()` of `opmaakHtml()` |
| Opmaak verdwijnt (bijv. een plaatje) | `veiligeHtml()` is te streng voor dit veld | `opmaakHtml()` gebruiken |
| Witte pagina | PHP-fout | `/Applications/MAMP/logs/php_error.log` |
| Pagina stopt halverwege een commentaar | `?>` in een `//`-commentaar | die tekens uit het commentaar halen |

## Lijstje voor je een wijziging afrondt

- [ ] Elke waarde op het scherm door `h()` (of veiligeHtml/opmaakHtml)?
- [ ] Elk POST-formulier `csrf_veld()`?
- [ ] Niets wijzigen via een link?
- [ ] Pagina en verwerking afgeschermd met `require_recht()`?
- [ ] Getallen uit `$_GET`/`$_POST` met `(int)`?
- [ ] Zelfde wijziging ook in de andere site (als het geen inhoud is)?
- [ ] `php_error.log` leeg na het testen?
- [ ] Commit in git met een korte uitleg.
