# Brojač poseta (visit-counter)

![CI](https://github.com/andjelarogljic12-oss/visit-counter/actions/workflows/ci.yml/badge.svg)

Mala web aplikacija u Python-u (Flask) koja broji posete i čuva brojač u Redis bazi.
Aplikacija je spakovana u Docker kontejner, pokreće se zajedno sa Redis-om preko
Docker Compose-a, a GitHub Actions pipeline na svaki push proverava kod i builduje image.

## Arhitektura

```
Korisnik (curl / browser)
        |
        | port 8080
        v
+------------------+          +------------------+
|  app (Flask)     | -------> |  redis (baza)    |
|  kontejner       |   6379   |  kontejner       |
+------------------+          +--------+---------+
                                       |
                               volume redis-data
```

Spolja je dostupan samo port aplikacije. Redis je dostupan samo aplikaciji,
kroz internu mrežu koju Docker Compose pravi automatski.

## Endpoint-i

| Endpoint | Opis |
|----------|------|
| `GET /` | `{"message": "Hello DevOps", "host": "<ID kontejnera>"}` |
| `GET /visits` | Uvećava brojač za 1 i vraća `{"visits": N}` |
| `GET /health` | `200 {"status": "ok"}` ako Redis radi, inače `503 {"status": "error"}` |

## Preduslovi

- Git
- Docker Desktop (Windows/macOS) ili Docker Engine + Docker Compose (Linux)
- Na Windows-u: WSL2 sa Ubuntu-om (za Bash skriptu)

## Pokretanje

```bash
git clone https://github.com/andjelarogljic12-oss/visit-counter.git
cd visit-counter
cp .env.example .env
docker compose up -d --build
```

Provera:

```bash
curl http://localhost:8080/
curl http://localhost:8080/visits
./scripts/healthcheck.sh http://localhost:8080
```

Gašenje: `docker compose down` (podaci ostaju u volume-u).
Gašenje uz brisanje podataka: `docker compose down -v`.

## Testovi i linter lokalno

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt -r requirements-dev.txt
flake8 app.py test_app.py
pytest
```

## Makefile

`make build`, `make up`, `make test`, `make down`.

## Važnije odluke

- **Python + Flask** – najmanje koda za jednostavan HTTP servis, pa je fokus na DevOps delu.
- **`python:3.12-slim`** – zvanična i mala slika (image aplikacije zauzima oko 200 MB
  na disku, dok pun `python` image ima preko 1 GB). Verzija je tačno navedena,
  a ne `latest`, da bi build uvek davao isti rezultat.
- **`redis:7.4-alpine`** – zvanična Redis slika na Alpine Linux-u, vrlo mala.
- **Redosled u Dockerfile-u** – prvo `requirements.txt` i `pip install`, pa tek onda kod.
  Kad se promeni samo kod, Docker koristi keširan sloj sa bibliotekama i build je brži.
- **Ne-root korisnik (`appuser`)** – aplikacija u kontejneru nema administratorska prava,
  pa bi eventualni napad imao manje posledice.
- **Volume `redis-data` + `--appendonly yes`** – Redis upisuje svaku izmenu na disk u volume,
  pa brojač ostaje sačuvan i posle `docker compose down`.
- **Redis bez `ports`** – baza ne treba da bude dostupna spolja; aplikacija joj pristupa
  preko interne mreže po imenu servisa `redis`.
- **Healthcheck za Redis + `depends_on: condition: service_healthy`** – aplikacija se
  pokreće tek kad Redis zaista odgovara.
- **`restart: unless-stopped`** – ako kontejner padne, Docker ga sam ponovo pokreće.
- **`.env` / `.env.example`** – stvarna konfiguracija se ne čuva u Git-u; u repozitorijumu
  je samo primer.
- **Podrazumevane vrednosti u kodu** – služe samo da test i lokalno pokretanje rade bez
  podešavanja; u Docker-u se vrednosti uvek čitaju iz `.env`.
- **Odvojen `requirements-dev.txt`** – pytest i flake8 trebaju samo za razvoj i CI,
  ne i u image-u aplikacije.

## Problemi na koje sam naišla

- **WSL nije imao instaliran Linux.** `wsl --status` je pokazivao WSL2, ali `wsl -l -v`
  je javio da nema instaliranih distribucija. Rešila sam sa `wsl --install -d Ubuntu`.
- **Docker nije bio instaliran.** Instalirala sam Docker Desktop i u
  Settings → Resources → WSL Integration uključila Ubuntu, da bi Docker radio iz
  Ubuntu terminala.
- **`gh auth login` nije mogao da otvori browser** (u WSL-u nema browser-a). Otvorila sam
  github.com/login/device ručno u Windows browser-u i unela kod.
- **Slučajno sam zatvorila Pull Request** umesto da ga spojim. Ponovo sam ga otvorila
  (Reopen pull request), sačekala da CI prođe i spojila ga u `main`.
- **Posle prelaska na `main` nisam videla folder `scripts`.** Naučila sam da su fajlovi
  sa feature grane u `main` tek kad se PR spoji i uradi `git pull`.

## Korišćeni alati

- Claude (AI asistent) – smernice kroz izradu i objašnjenje komandi; sve komande sam pokretala i proveravala sama.
- Zvanična dokumentacija: Docker, Docker Compose, GitHub Actions, Flask.
