<?php
/***************************************
***** 0 Geeft toegang tot het intranet maar niet tot het Forum.
***** 1 Geeft toegang tot het intranet inclusief mogelijkheid om Forumberichten te lezen en te schrijven.
***** 2 = 1 + Toegang tot Beheer/Redactie. Hiermee kunnen nieuwsberichten (intern en extern), agendapunten (intern en extern) worden gemaakt. Ook kunnen Post-Its worden gemaakt en kan de Tickertekst ***** van de externe website worden gewijzigd.
***** 3 = 1 + Toegang tot Beheer/de WAS. Hiermee kunnen werkzoekenden, jobgroups en maatjes worden bekeken
***** 4 = 1 + Toegang tot Beheer/de WAS. Hiermee kunnen werkzoekende en jobgroups worden bekeken, aangemaakt, gewijzigd en verwijderd. Maatjes kunnen alleen worden bekeken.
***** 5 = 2 + 3
***** 6 = 2 + 4
***** 7 = 6 + Nu kunnen ook Maatjes worden toegevoegd, gewijzigd en verwijderd.
***** 8 = 
***** 9 = Beheerder.
*******************************************/

$level			= isset($curr_user) ? (int)$curr_user->authLevel() : 0;
$canForumRead 	= $level >= 1;
$canForumWrite 	= $level >= 1;
$canRedactie 	= $level === 2 || $level >= 5;
$canWas			= $level >= 3; 
// $canWasRead     = $level === 3 || $level === 5;
// $canWasWrite    = $level === 4 || $level === 6;
// $canWasWriteM   = $level === 7;
// $canWasWrite    = $level >= 5;
// $canAll 		= $level === 9;
?>
<nav class="navbar navbar-expand-xl navbar-dark fixed-top bg-primary">
	<div class="container">
		<a href="/home.php"><span class="navbar-brand"><?php echo LOC_NAME; ?> Intranet</span></a>
		<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarResponsive" aria-controls="navbarResponsive" aria-expanded="false" aria-label="Toggle navigation">
			<span class="navbar-toggler-icon"></span>
		</button>
		<div class="collapse navbar-collapse" id="navbarResponsive">
			<ul class="navbar-nav mr-auto">
				<li class="nav-item <?php if (basename($_SERVER['PHP_SELF']) == 'home.php') echo 'active'; ?>">
					<a class="nav-link" href="/home.php">Home</a>
				</li>
				<li class="nav-item <?php if (basename($_SERVER['PHP_SELF']) == 'agenda.php') echo 'active'; ?>">
					<a class="nav-link" href="/agenda.php">Agenda</a>
				</li>				
				<li class="nav-item dropdown">
					<a class="nav-link dropdown-toggle" href="#" id="navbardrop" data-toggle="dropdown">
						Overige info
					</a>
					<div class="dropdown-menu">
						<a class="dropdown-item" href="/faces.php">Wie is wie?</a>
						<a class="dropdown-item" href="/nieuwsbrief.php">Nieuwsbrieven</a>
						<a class="dropdown-item" target="_new" href="<?php echo LOC_WEBSITE_PUB ?>">Publieke website</a>
					</div>
				</li>

				<li class="nav-item <?php if (basename($_SERVER['PHP_SELF']) == 'overz_forum.php' || basename($_SERVER['PHP_SELF']) == 'overz_cat.php' || basename($_SERVER['PHP_SELF']) == 'overz_topic.php') echo 'active'; ?>">
					<a class="nav-link <?= $canForumRead ? '' : 'disabled' ?>" href="<?= $canForumRead ? '/forum/overz_forum.php' : '#' ?>">Forum</a>
				</li>
				
				
				<li class="nav-item dropdown">
					<a class="nav-link dropdown-toggle" href="#" id="navbardrop" data-toggle="dropdown">Beheer</a>
					<div class="dropdown-menu">
					<a class="dropdown-item <?= $canRedactie ? '' : 'disabled' ?>"
					   href="<?= $canRedactie ? '/beheerred/beheer.php' : '#' ?>"
					   <?= $canRedactie ? '' : 'aria-disabled="true"' ?>>Redactie</a>
					
					<a class="dropdown-item <?= $canWas ? '' : 'disabled' ?>"
					   href="<?= $canWas ? '/beheerwas/beheer.php' : '#' ?>"
					   <?= $canWas ? '' : 'aria-disabled="true"' ?>>de WAS</a>					
				   </div>
				</li>
			</ul>
			<li class="navbar-nav dropdown">
				<a class="nav-link dropdown-toggle text-white" href="#" id="navbardrop" data-toggle="dropdown">
					Ingelogd als: <?php if (isset($curr_user)) echo $curr_user->username; else echo '----';?>
				</a>
				<div class="dropdown-menu">
					<a class="dropdown-item" href="/wijzwacht.php">Wijzig wachtwoord</a>
					<a class="dropdown-item"  href="/logout.php">Log uit</a>
				</div>
			</li>
		</div>
	</div>
</nav>