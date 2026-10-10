import subprocess, os, collections
BASE = "fcce9c0"
SITES = [("intra-culemborg", "intra.jobhulpculemborg.nl"), ("intra-jhmz", "intra.jhmz.nl")]
NIET = {"includes/configDB.php"}
VERVANG = ["tcpdf/"]

def git(*a):
    return subprocess.run(["git", *a], capture_output=True, text=True, check=True).stdout

def oude_mappen(site):
    namen = git("ls-tree", "-r", "--name-only", BASE, "--", site).splitlines()
    mappen = set()
    for n in namen:
        p = n.split("/")[1:-1]
        for i in range(1, len(p) + 1):
            mappen.add("/".join(p[:i]) + "/")
    return mappen

out = []
w = out.append
w("# Uploadlijst uitrol naar Versio")
w("")
w(f"Gemaakt op 10 oktober 2026 uit git: verschil tussen {BASE} (uitgangssituatie, gelijk aan de server) en de huidige bestanden, inclusief nog niet gecommitte wijzigingen.")
w("Paden zijn relatief aan de hoofdmap van de site op de server. Opnieuw maken: `python3 maaklijst.py` (vraag Claude).")
w("")
w("**Let op:** dit gaat ervan uit dat de server nog gelijk is aan fcce9c0. Heb je sinds begin oktober iets rechtstreeks op de server gewijzigd, controleer dat dan eerst.")
w("")
for site, host in SITES:
    regels = git("diff", "--name-status", "--no-renames", BASE, "--", site).splitlines()
    status = collections.defaultdict(list)
    for r in regels:
        s, pad = r.split("\t", 1)
        status[s].append(pad[len(site) + 1:])
    # niet-gecommitte nieuwe bestanden
    for pad in git("ls-files", "--others", "--exclude-standard", "--", site).splitlines():
        status["A"].append(pad[len(site) + 1:])
    def buiten(p):
        return p in NIET or any(p.startswith(v) for v in VERVANG)
    nieuw = sorted(p for p in status["A"] if not buiten(p))
    gewijzigd = sorted(p for p in status["M"] if not buiten(p))
    weg = [p for p in status["D"] if not any(p.startswith(v) for v in VERVANG)]
    # hele mappen die verdwenen zijn
    weg_mappen = sorted(m for m in oude_mappen(site) if not os.path.isdir(os.path.join(site, m)))
    weg_mappen = [m for m in weg_mappen if not any(m != o and m.startswith(o) for o in weg_mappen)]
    weg_mappen = [m for m in weg_mappen if not any(m.startswith(v) for v in VERVANG)]
    weg_los = sorted(p for p in weg if not any(p.startswith(m) for m in weg_mappen))

    w(f"## {site} ({host})")
    w("")
    w("### Niet uploaden")
    w("- `includes/configDB.php`: op de server staan de echte wachtwoorden. Daar aanvullen volgens stap 4 van de checklist.")
    w("- Foto's (`fotoos_*`), `logs/`, `.DS_Store`: niet in git, op de server laten zoals ze zijn. Alleen de `.htaccess` in die mappen is nieuw (zie hieronder).")
    w("- `onderhoud.aan`: alleen aanmaken op de server (stap 1), nooit vanuit hier uploaden.")
    w("")
    w("### Map helemaal vervangen")
    w("- `tcpdf/`: oude map op de server weggooien, de nieuwe uploaden (inclusief `tcpdf/.htaccess`).")
    w("")
    w("### Eerst (stap 1 van de checklist)")
    w("- `onderhoud.html` en `.htaccess` in de hoofdmap, nadat `onderhoud.aan` is aangemaakt. In de lijsten hieronder staan ze voor de volledigheid nog een keer.")
    w("")
    w(f"### Nieuwe bestanden uploaden ({len(nieuw)})")
    w("Verborgen bestanden (`.htaccess`) staan erbij: zet in je FTP-programma \"verborgen bestanden tonen\" aan.")
    w("")
    for p in nieuw: w(f"- `{p}`")
    w("")
    w(f"### Gewijzigde bestanden uploaden ({len(gewijzigd)})")
    w("")
    groepen = collections.defaultdict(list)
    for p in gewijzigd:
        groepen[p.rsplit("/", 1)[0] + "/" if "/" in p else "(hoofdmap)"].append(p)
    for g in sorted(groepen):
        w(f"**{g}**")
        for p in groepen[g]: w(f"- `{p}`")
        w("")
    w(f"### Verwijderen van de server")
    w("")
    w("Hele mappen (tcpdf/ valt onder \"map helemaal vervangen\"):")
    for m in weg_mappen: w(f"- `{m}`")
    w("")
    w("- `beheer_oud/` (staat alleen op de server, niet in git)")
    w("- `fotoos_wkz-oud/` met alle oude foto's erin (besluit Jan, 10 okt; lokaal al verwijderd)")
    w("")
    w(f"Losse bestanden ({len(weg_los)}):")
    for p in weg_los: w(f"- `{p}`")
    w("")
open("UPLOADLIJST.md", "w").write("\n".join(out) + "\n")
print("ok")
