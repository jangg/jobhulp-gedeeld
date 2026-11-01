<?php
/* ==================================================================
 * anonimiseer.php — maakt een kopie van de lokale database (MAMP) met
 * fictieve persoonsgegevens, om veilig mee te testen (nov 2026).
 *
 * Gebruik (in Terminal, in ~/Sites/jobhulp-intra, MAMP moet aan staan):
 *   /Applications/MAMP/bin/php/php8.3.x/bin/php anonimiseer.php
 *   /Applications/MAMP/bin/php/php8.3.x/bin/php anonimiseer.php intra-culemborg
 *   (8.3.x: het versienummer dat in /Applications/MAMP/bin/php/ staat)
 *
 * - Leest de databasegegevens uit <site>/includes/configDB.php (standaard intra-jhmz).
 * - Weigert te draaien als die database niet op deze Mac staat (nooit op de server!).
 * - De ORIGINELE database wordt alleen gelezen, nooit gewijzigd.
 * - Maakt een nieuwe database <naam>_anoniem (bijv. intraDB_anoniem); een
 *   bestaande met die naam wordt eerst weggegooid.
 * - Laat aan het eind zien met welke gebruikersnaam je als welk niveau inlogt.
 *
 * Daarna in <site>/includes/configDB.php (lokaal) dbname=... veranderen in
 * de nieuwe naam om met de fictieve gegevens te werken.
 *
 * Wat er gebeurt per tabel: zie $LEEG en de stappen 3 t/m 8 hieronder.
 * ================================================================== */

if (PHP_SAPI !== 'cli') stop("Alleen te gebruiken in Terminal.\n");
error_reporting(E_ALL);
function stop (string $tekst): never { fwrite(STDERR, $tekst); exit(1); }

$site = rtrim($argv[1] ?? 'intra-jhmz', '/');
$config = __DIR__ . "/$site/includes/configDB.php";
if (!is_file($config)) stop("Niet gevonden: $config\n");
require $config;		// geeft DB_DSN, DB_USERNAME, DB_PASSWORD

/* ---------- 1. Verbinden, alleen met de lokale database ---------- */
if (!preg_match('/host=(localhost|127\.0\.0\.1)/', DB_DSN) || !preg_match('/dbname=([A-Za-z0-9_]+)/', DB_DSN, $m)) {
	stop("STOP: DB_DSN in $config wijst niet naar een lokale database:\n  " . DB_DSN . "\n");
}
$bron = $m[1];
$doel = $bron . '_anoniem';
if (str_ends_with($bron, '_anoniem')) stop("STOP: $bron is zelf al een geanonimiseerde kopie.\n");

// MAMP: liefst via het socket-bestand (werkt ook als netwerktoegang in MAMP uit staat)
$socket = '/Applications/MAMP/tmp/mysql/mysql.sock';
$dsn = file_exists($socket)
	? "mysql:unix_socket=$socket;charset=utf8mb4"
	: rtrim(preg_replace('/dbname=[^;]*/', '', DB_DSN), ';') . ';charset=utf8mb4';
try {
	$db = new PDO($dsn, DB_USERNAME, DB_PASSWORD, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
} catch (PDOException $e) {
	stop("Kan niet verbinden met MySQL (staat MAMP aan?): " . $e->getMessage() . "\n");
}
echo "Bron: $bron  ->  kopie: $doel\n";

/* ---------- 2. Kopie maken: zelfde structuur, zelfde inhoud ---------- */
$db->exec("DROP DATABASE IF EXISTS `$doel`");
$db->exec("CREATE DATABASE `$doel` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
$tabellen = $db->query("SHOW FULL TABLES FROM `$bron` WHERE Table_type = 'BASE TABLE'")->fetchAll(PDO::FETCH_COLUMN);
foreach ($tabellen as $t) {
	$db->exec("CREATE TABLE `$doel`.`$t` LIKE `$bron`.`$t`");
	$db->exec("INSERT INTO `$doel`.`$t` SELECT * FROM `$bron`.`$t`");
}
echo count($tabellen) . " tabellen gekopieerd.\n";
$db->exec("USE `$doel`");
$heeft = fn(string $t) => in_array($t, $tabellen, true);

/* Vaste tekst voor vrije tekstvelden die niet leeg zijn. */
function fictief (PDO $db, string $tabel, array $velden, string $tekst): void
{
	foreach ($velden as $v) {
		$stmt = $db->prepare("UPDATE `$tabel` SET `$v` = :t WHERE `$v` IS NOT NULL AND `$v` <> ''");
		$stmt->execute([':t' => $tekst]);
	}
}

/* ---------- 3. Personen: werkzoekenden én maatjes (tabel person) ---------- */
mt_srand(2026);		// vaste startwaarde: elke keer dezelfde fictieve namen
$jongens = ['Daan','Sem','Lucas','Milan','Levi','Bram','Thijs','Ruben','Jesse','Tim','Mohamed','Youssef','Ahmet','Piet','Kees','Henk','Joost','Mark','Erik','Willem'];
$meisjes = ['Emma','Julia','Sophie','Anna','Sara','Fleur','Lotte','Noor','Eva','Lisa','Fatima','Aisha','Elif','Ingrid','Marja','Petra','Anouk','Sanne','Ilse','Yvonne'];
$achter  = ['Jansen','Bakker','Visser','Smit','Meijer','Mulder','Bos','Vos','Peters','Hendriks','Dekker','Brouwer','Dijkstra','Kok','Verhoeven','Postma','Kuiper','Hoekstra','Schouten','Willems','Koster','Prins','Huisman','Peeters','Groot'];
$tussen  = ['', '', '', '', 'de', 'van', 'van der', 'van den'];
$straten = ['Lindelaan','Beukenstraat','Eikenhof','Tulpweg','Rozengracht','Merelpad','Molenweg','Kerkstraat','Schoolstraat','Dorpsstraat','Parklaan','Vijverhof'];
$plaatsen = ['Zoetermeer','Zoetermeer','Zoetermeer','Pijnacker','Benthuizen','Leidschendam','Den Haag'];
$kies = fn(array $a) => $a[mt_rand(0, count($a) - 1)];

$personen = $db->query("SELECT person_id, geslacht, date_geboorte FROM person")->fetchAll(PDO::FETCH_ASSOC);
$upd = $db->prepare("UPDATE person SET voornaam = :vn, tussenvoegsels = :tv, achternaam = :an, straat = :st,
	huisnummer = :hn, postcode = :pc, woonplaats = :wp, emailadres = :em, telefoonnr = :tel,
	picfile = NULL, link_linkedin = '', date_geboorte = :geb WHERE person_id = :id");
foreach ($personen as $p) {
	$id = (int)$p['person_id'];
	$vrouw = in_array(strtolower((string)$p['geslacht']), ['v', 'vrouw', 'f'], true) || ($p['geslacht'] === '' && mt_rand(0, 1));
	$vn = $kies($vrouw ? $meisjes : $jongens);
	$an = $kies($achter);
	// Geboortedatum: tot een half jaar verschoven, zodat leeftijden ongeveer kloppen
	$geb = $p['date_geboorte'] ? date('Y-m-d', strtotime($p['date_geboorte'] . ' ' . mt_rand(-180, 180) . ' days')) : null;
	$upd->execute([
		':vn' => $vn, ':tv' => $kies($tussen), ':an' => $an,
		':st' => $kies($straten), ':hn' => (string)mt_rand(1, 199),
		':pc' => '27' . mt_rand(10, 99) . ' ' . chr(mt_rand(65, 90)) . chr(mt_rand(65, 90)),
		':wp' => $kies($plaatsen),
		// example.com is een gereserveerd domein: mail daarheen komt nooit bij iemand aan
		':em' => strtolower($vn . '.' . $an) . ".$id@example.com",
		':tel' => '06-0000' . sprintf('%04d', $id % 10000),
		':geb' => $geb, ':id' => $id,
	]);
}
echo count($personen) . " personen fictief gemaakt (naam, adres, e-mail, telefoon, foto, LinkedIn, geboortedatum).\n";

/* ---------- 4. Werkzoekenden: vrije teksten ---------- */
if ($heeft('werkzkd')) fictief($db, 'werkzkd', ['situatie', 'opmerkingen', 'toelichting'], 'Fictieve tekst (testgegevens).');

/* ---------- 5. Intakeformulieren ---------- */
if ($heeft('intakeform')) {
	fictief($db, 'intakeform', ['volw_kind','partner_beroep','bron','uitdagingen','beperking','redenen','motivatie','eisen',
		'netwerken','andere_hulp','diploma','studie','werkervaring','werk_gewenst','voorwaarden','reistijd','vervoer',
		'werkbijzh','overige_opm','advnietontv','advopmerkingen'], 'Fictieve tekst (testgegevens).');
	// (nationaliteit en advmaatje zijn korte codes; die blijven zoals ze zijn)
	$db->exec("UPDATE intakeform SET gebplaats = 'Zoetermeer', gebland = 'Nederland',
		akkoord_plaats = 'Zoetermeer', akkoord_handtek = ''");
	// roepnaam en naam bij het akkoord: de nieuwe voornaam en naam van de werkzoekende
	$db->exec("UPDATE intakeform i JOIN werkzkd w ON w.id = i.id_werkzkd JOIN person p ON p.person_id = w.id_person
		SET i.roepnaam = p.voornaam, i.akkoord_naam = TRIM(CONCAT_WS(' ', p.voornaam, p.tussenvoegsels, p.achternaam))");
	$db->exec("UPDATE intakeform SET roepnaam = '', akkoord_naam = '' WHERE id_werkzkd NOT IN (SELECT id FROM werkzkd)");
}

/* ---------- 6. Aantekeningen, processtappen, forum ---------- */
if ($heeft('aantekening')) fictief($db, 'aantekening', ['tekst'], 'Fictieve aantekening (testgegevens).');
if ($heeft('processtap'))  fictief($db, 'processtap', ['toelichting'], 'Fictieve toelichting (testgegevens).');
if ($heeft('posts'))       $db->exec("UPDATE posts SET post_content = CONCAT('<p>Fictief forumbericht ', id, ' (testgegevens).</p>')");
if ($heeft('topics'))      $db->exec("UPDATE topics SET topic_subject = CONCAT('Onderwerp ', id)");
if ($heeft('jobgroup')) {
	// jobgroupleiders: alleen als er een naam staat (geen nummer)
	foreach (['jgleider1', 'jgleider2'] as $v) {
		$db->exec("UPDATE jobgroup SET `$v` = 'Jobgroupleider' WHERE `$v` <> '' AND `$v` NOT REGEXP '^[0-9]+$'");
	}
}

/* ---------- 7. Documenten: leeg beginnen ----------
   De regels wijzen naar echte bestanden (cv's) in DOC_DIR. Daarom geen documenten
   in de kopie; zet voor deze database ook een eigen, lege DOC_DIR in configDB.php. */
if ($heeft('document')) $db->exec("DELETE FROM document");
if ($heeft('docmap'))   $db->exec("DELETE FROM docmap");

/* ---------- 8. Gebruikers: vaste testnamen en één testwachtwoord ---------- */
$wachtwoord = 'Proef1234!';
$stmt = $db->prepare("UPDATE user SET username = CONCAT('gebruiker', id), password = '', password_hash = :h,
	password_mod = 'n', reset_hash = NULL, reset_expires = NULL");
$stmt->execute([':h' => password_hash($wachtwoord, PASSWORD_DEFAULT)]);

echo "\nKlaar. Inloggen in de kopie kan met deze gebruikers, allemaal met wachtwoord $wachtwoord:\n";
$rijen = $db->query("SELECT u.username, u.beheerind, TRIM(CONCAT_WS(' ', p.voornaam, p.tussenvoegsels, p.achternaam)) AS naam,
	(SELECT COUNT(*) FROM maatje m WHERE m.id_person = u.id_person) AS is_maatje
	FROM user u LEFT JOIN person p ON p.person_id = u.id_person ORDER BY u.beheerind DESC, u.id")->fetchAll(PDO::FETCH_ASSOC);
foreach ($rijen as $r) {
	printf("  %-14s niveau %s%s  (%s)\n", $r['username'], $r['beheerind'], $r['is_maatje'] ? ', maatje' : '', $r['naam']);
}
echo "\nNog doen: in $site/includes/configDB.php dbname=$bron veranderen in dbname=$doel,\n"
   . "en DOC_DIR naar een eigen lege map laten wijzen (bijv. .../jobhulp-documenten/zoetermeer-anoniem/).\n";
