# Uploadlijst uitrol naar Versio

Gemaakt uit git: verschil tussen de tag `uitgangssituatie` in de repository van elke site (gelijk aan de server voor de doorlichting) en de huidige bestanden, inclusief nog niet gecommitte wijzigingen.
Paden zijn relatief aan de hoofdmap van de site op de server. Opnieuw maken: `python3 maaklijst.py` (vraag Claude).

**Let op:** dit gaat ervan uit dat de server nog gelijk is aan de uitgangssituatie (begin oktober). Voor intra.jhmz.nl klopt dat niet meer: die staat sinds 10 okt live met de nieuwe code.

## intra-culemborg (intra.jobhulpculemborg.nl)

### Niet uploaden
- `includes/configDB.php`: op de server staan de echte wachtwoorden. Daar aanvullen volgens stap 4 van de checklist.
- Foto's (`fotoos_*`), `logs/`, `.DS_Store`: niet in git, op de server laten zoals ze zijn. Alleen de `.htaccess` in die mappen is nieuw (zie hieronder).
- `onderhoud.aan`: alleen aanmaken op de server (stap 1), nooit vanuit hier uploaden.

### Map helemaal vervangen
- `tcpdf/`: oude map op de server weggooien, de nieuwe uploaden (inclusief `tcpdf/.htaccess`).

### Eerst (stap 1 van de checklist)
- `onderhoud.html` en `.htaccess` in de hoofdmap, nadat `onderhoud.aan` is aangemaakt. In de lijsten hieronder staan ze voor de volledigheid nog een keer.

### Nieuwe bestanden uploaden (17)
Verborgen bestanden (`.htaccess`) staan erbij: zet in je FTP-programma "verborgen bestanden tonen" aan.

- `.htaccess`
- `PHPMailer/.htaccess`
- `SQL queries/.htaccess`
- `class/.htaccess`
- `docs/.htaccess`
- `foto.php`
- `fotoos_person/.htaccess`
- `fotoos_wkz/.htaccess`
- `includes/.htaccess`
- `includes/pdf_instellingen.php`
- `includes/rechten.php`
- `includes/statuslijst.php`
- `logs/.htaccess`
- `mail_apps/.htaccess`
- `maintenance/hash_wachtwoorden.php`
- `onderhoud.html`
- `reset.php`

### Gewijzigde bestanden uploaden (52)

**(hoofdmap)**
- `agenda.php`
- `config.php`
- `faces.php`
- `home.php`
- `index.php`
- `mailroom_forum.php`
- `vergeten.php`
- `wijzwacht.php`

**beheerred/**
- `beheerred/beheer.php`
- `beheerred/mut_agendaitem.php`
- `beheerred/mut_newsitem.php`
- `beheerred/mut_postits.php`
- `beheerred/mut_tickertext.php`
- `beheerred/overz_agendaitems.php`
- `beheerred/overz_newsitems.php`
- `beheerred/photolib.php`
- `beheerred/proces_agendaitem.php`
- `beheerred/proces_newsitem.php`

**beheerwas/**
- `beheerwas/aanmelding_mtj.php`
- `beheerwas/aanmelding_wkz.php`
- `beheerwas/beheer.php`
- `beheerwas/intake.php`
- `beheerwas/intake_pdf.php`
- `beheerwas/mut_jobgroup.php`
- `beheerwas/mut_maatje.php`
- `beheerwas/mut_persoon.php`
- `beheerwas/overz_jobgroups.php`
- `beheerwas/overz_maatjes.php`
- `beheerwas/overz_werkzoekenden.php`
- `beheerwas/overz_wkz_vrjrdgn.php`
- `beheerwas/photolib.php`
- `beheerwas/proces_intake.php`
- `beheerwas/proces_jg.php`
- `beheerwas/proces_ps.php`
- `beheerwas/verjaardagskaarten.php`

**class/**
- `class/c_cat.php`
- `class/c_intakeformpdf.php`
- `class/c_jobgroup_coll.php`
- `class/c_maatje_coll.php`
- `class/c_person.php`
- `class/c_post.php`
- `class/c_tools.php`
- `class/c_user.php`

**forum/**
- `forum/overz_cat.php`
- `forum/overz_forum.php`
- `forum/overz_topic.php`

**includes/**
- `includes/head.php`
- `includes/navbar.php`

**maintenance/**
- `maintenance/cleanDB.php`

**pages/**
- `pages/bericht20251202_1.php`
- `pages/presence_list.php`
- `pages/proces_presence.php`

### Verwijderen van de server

Hele mappen (tcpdf/ valt onder "map helemaal vervangen"):
- `PHPMailer_V6.8.1/`
- `beheer/`
- `class/obsolete/`
- `img copy/`
- `stickynotes/`

- `beheer_oud/` (staat alleen op de server, niet in git)
- `fotoos_wkz-oud/` met alle oude foto's erin (besluit Jan, 10 okt; lokaal al verwijderd)

Losse bestanden (39):
- `JHMZforummsg.html`
- `README.md`
- `beheerred/presentielijst.php`
- `beheerwas/check.php`
- `beheerwas/deljg.php`
- `class/c_tools_oud.php`
- `config copy.php`
- `forum/connect.php`
- `forum/create_cat.php`
- `forum/footer.php`
- `forum/header.php`
- `forum/index.php`
- `home_XMAS.php`
- `img/agenda.php`
- `includes/body.inc`
- `includes/chk_enquete.inc`
- `includes/newsmsgs copy 201119.inc`
- `includes/newsmsgs copy 210513.inc`
- `includes/newsmsgs copy 220114.inc`
- `includes/newsmsgs copy 230906.inc`
- `includes/newsmsgs copy.inc`
- `includes/newsmsgs-copy-201119.inc`
- `includes/newsmsgs-copy-210513.inc`
- `includes/newsmsgs-copy-220114.inc`
- `includes/newsmsgs-copy-230906.inc`
- `includes/newsmsgs-copy-250311.inc`
- `includes/newsmsgs-copy-250901.inc`
- `includes/newsmsgs.inc`
- `includes/pinkster.txt`
- `index_nw.php`
- `logos/stichtingjobhulpculemborg4 copy.png`
- `mail_apps/JHMZforummsg copy.html`
- `mailtest.php`
- `maintenance/config.php`
- `nieuwsbrieven/nb2020081_old.html`
- `pages/hercertificering.php`
- `pages/pubquizregels.php`
- `testdirr.php`
- `wijzwacht_nw.php`

## intra-jhmz (intra.jhmz.nl)

### Niet uploaden
- `includes/configDB.php`: op de server staan de echte wachtwoorden. Daar aanvullen volgens stap 4 van de checklist.
- Foto's (`fotoos_*`), `logs/`, `.DS_Store`: niet in git, op de server laten zoals ze zijn. Alleen de `.htaccess` in die mappen is nieuw (zie hieronder).
- `onderhoud.aan`: alleen aanmaken op de server (stap 1), nooit vanuit hier uploaden.

### Map helemaal vervangen
- `tcpdf/`: oude map op de server weggooien, de nieuwe uploaden (inclusief `tcpdf/.htaccess`).

### Eerst (stap 1 van de checklist)
- `onderhoud.html` en `.htaccess` in de hoofdmap, nadat `onderhoud.aan` is aangemaakt. In de lijsten hieronder staan ze voor de volledigheid nog een keer.

### Nieuwe bestanden uploaden (16)
Verborgen bestanden (`.htaccess`) staan erbij: zet in je FTP-programma "verborgen bestanden tonen" aan.

- `.htaccess`
- `PHPMailer/.htaccess`
- `SQL queries/.htaccess`
- `class/.htaccess`
- `docs/.htaccess`
- `foto.php`
- `fotoos_person/.htaccess`
- `fotoos_wkz/.htaccess`
- `includes/.htaccess`
- `includes/pdf_instellingen.php`
- `includes/rechten.php`
- `logs/.htaccess`
- `mail_apps/.htaccess`
- `maintenance/hash_wachtwoorden.php`
- `onderhoud.html`
- `reset.php`

### Gewijzigde bestanden uploaden (52)

**(hoofdmap)**
- `agenda.php`
- `config.php`
- `faces.php`
- `home.php`
- `index.php`
- `mailroom_forum.php`
- `vergeten.php`
- `wijzwacht.php`

**beheerred/**
- `beheerred/beheer.php`
- `beheerred/mut_agendaitem.php`
- `beheerred/mut_newsitem.php`
- `beheerred/mut_postits.php`
- `beheerred/mut_tickertext.php`
- `beheerred/overz_agendaitems.php`
- `beheerred/overz_newsitems.php`
- `beheerred/photolib.php`
- `beheerred/proces_agendaitem.php`
- `beheerred/proces_newsitem.php`

**beheerwas/**
- `beheerwas/aanmelding_mtj.php`
- `beheerwas/aanmelding_wkz.php`
- `beheerwas/beheer.php`
- `beheerwas/intake.php`
- `beheerwas/intake_pdf.php`
- `beheerwas/mut_jobgroup.php`
- `beheerwas/mut_maatje.php`
- `beheerwas/mut_persoon.php`
- `beheerwas/overz_jobgroups.php`
- `beheerwas/overz_maatjes.php`
- `beheerwas/overz_werkzoekenden.php`
- `beheerwas/overz_wkz_vrjrdgn.php`
- `beheerwas/photolib.php`
- `beheerwas/proces_intake.php`
- `beheerwas/proces_jg.php`
- `beheerwas/proces_ps.php`
- `beheerwas/verjaardagskaarten.php`

**class/**
- `class/c_cat.php`
- `class/c_intakeformpdf.php`
- `class/c_jobgroup_coll.php`
- `class/c_maatje_coll.php`
- `class/c_person.php`
- `class/c_post.php`
- `class/c_tools.php`
- `class/c_user.php`

**forum/**
- `forum/overz_cat.php`
- `forum/overz_forum.php`
- `forum/overz_topic.php`

**includes/**
- `includes/head.php`
- `includes/navbar.php`

**maintenance/**
- `maintenance/cleanDB.php`

**pages/**
- `pages/bericht20201204_1.php`
- `pages/presence_list.php`
- `pages/proces_presence.php`

### Verwijderen van de server

Hele mappen (tcpdf/ valt onder "map helemaal vervangen"):
- `beheer/`
- `img copy/`
- `mail_apps/emails/`
- `new/`
- `stickynotes/`

- `beheer_oud/` (staat alleen op de server, niet in git)
- `fotoos_wkz-oud/` met alle oude foto's erin (besluit Jan, 10 okt; lokaal al verwijderd)

Losse bestanden (31):
- `README.md`
- `beheerred/presentielijst.php`
- `beheerwas/check.php`
- `beheerwas/deljg.php`
- `config copy.php`
- `enquete.php`
- `forum/connect.php`
- `forum/create_cat.php`
- `forum/footer.php`
- `forum/header.php`
- `forum/index.php`
- `home_XMAS.php`
- `img/agenda.php`
- `includes/body.inc`
- `includes/chk_enquete.inc`
- `includes/pinkster.txt`
- `includes/test.php`
- `index_nw.php`
- `mail_apps/sendEmail.php`
- `mailroom_test.php`
- `mailtest.php`
- `maintenance/config.php`
- `nieuwsbrieven/nb2020081_old.html`
- `pages/bericht20211003_2 copy.php`
- `pages/hercertificering.php`
- `pages/presence_list231213.php`
- `pages/pubquizregels.php`
- `pubquiz.php`
- `pubquizantw.php`
- `score.php`
- `wijzwacht_nw.php`

