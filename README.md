# RedPen

**Paper checking for coaching centers.** A teacher photographs each student's answer sheet, RedPen checks it against the answer key with Grok, marks anything doubtful in red, and creates a result card for every student. The teacher always gives the final marks.

| Login | Home | Project | Results | Admin |
|---|---|---|---|---|
| ![Login](docs/gate.png) | ![Home](docs/home.png) | ![Project](docs/project.png) | ![Results](docs/results.png) | ![Admin](docs/admin.png) |

## How it works

```
Browser (public/index.html)  ──►  RedPen server (server.js)  ──►  Grok API (xAI)
 teacher's phone or laptop        access codes, per-center data,      the API key lives
                                  usage limits, prompts               ONLY here
```

- Anyone who **uses** your hosted RedPen only needs an access code. The Grok key is a secret on the server (an environment variable), never in the code, the repository or the browser.
- Anyone who wants to **run their own copy** sets their own `XAI_API_KEY` on their own server.
- You create access codes in the admin panel. Each has a sheet limit and an optional expiry date, and can be switched off at any time, so your Grok bill stays under control.

> Never put the API key in the frontend or commit it to GitHub. If a key ever leaks, revoke it in the xAI console and create a new one.

## Start in 2 minutes (on your computer)

Needs **Node 18+** (22 recommended). Nothing to install.

1. Copy `.env.example` and name the copy `.env`, then open it in Notepad and fill in `XAI_API_KEY` (and `ADMIN_PASSWORD` if you like). The server reads this file by itself.
2. Start it: double-click `start-windows.bat` (Windows) or run `sh start-mac-linux.sh` (Mac/Linux). Or run `node server.js`.

3. Open `http://localhost:3000/admin`.
4. Sign in. If you did not set `ADMIN_PASSWORD`, the server generated one: it is printed in the terminal and saved in `data/admin-password.txt`.
5. Create a center and copy its code (shown once).
6. Open `http://localhost:3000`, enter the code and your name, and start.

## Host it (so anyone can use it)

You need a server that runs Node or Docker **and keeps a disk between restarts** (your centers and projects are saved there).

### Option A: Render (easiest)
1. Push this folder to a GitHub repository.
2. On Render choose **New > Blueprint** and select the repo (it reads `render.yaml`).
3. Enter `XAI_API_KEY` and `ADMIN_PASSWORD` when asked. The plan includes a 1 GB disk mounted at `/app/data`.
4. Open `https://your-service.onrender.com/admin`.

### Option B: Railway or Fly.io
Deploy from the repo (it has a `Dockerfile`), add a **volume mounted at `/app/data`**, and set `XAI_API_KEY`, `ADMIN_PASSWORD`, `DATA_DIR=/app/data`.

### Option C: Your own server (VPS)
```bash
docker compose up -d --build        # uses .env and a persistent volume
```
For HTTPS install Caddy and use the included `Caddyfile` (change the domain).

> **Do not use a free host with a temporary disk.** Every restart would erase all centers and projects. If the server cannot write to `DATA_DIR`, it still starts but shows a "Temporary storage" warning in the admin panel.

## Environment variables

| Variable | Required | What it does |
|---|---|---|
| `XAI_API_KEY` | for AI checking | Your Grok API key (server only) |
| `XAI_MODEL` | no | Vision-capable Grok model. Empty = try `grok-4.7`, then `grok-4.3`, then `grok-4-1-fast-non-reasoning`. Check current names at console.x.ai |
| `ADMIN_PASSWORD` | no | Admin password. If empty, one is generated and saved in `DATA_DIR/admin-password.txt` |
| `APP_SECRET` | no | Secret for login tokens (auto-created in `DATA_DIR/secret.txt` if empty) |
| `PORT` | no | Default `3000` (hosts set this for you) |
| `DATA_DIR` | no | Where data is stored. Default `./data`. **Point it at a persistent disk** |

## Using the admin panel (`/admin`)

Create a code per center, set its sheet limit and expiry, switch a center off or on, reset usage, make a new code (the old one stops working), delete a center. **Download a backup regularly** (Backup > Download); you can restore it on any new server.

### "I cannot sign in to /admin"
- Open it from your **website address** (`https://your-site.com/admin`), not from a saved file.
- Passwords are case-sensitive. Spaces at the start or end are ignored.
- 10 wrong attempts lock sign-in for 15 minutes.
- No `ADMIN_PASSWORD` set? Look at the server log or `data/admin-password.txt`.
- Changed `ADMIN_PASSWORD` on the host? Restart the service.

## Features

- Access codes, no sign-up. The device remembers the teacher after the first login.
- Each center's data is separate and saved on the server (same projects on phone and laptop).
- **MCQ bubble sheets:** 1 to 100 questions with an *attempt limit* (for example 25 on the paper, attempt 20). Only the first answers up to the limit count; extra ones show "Over limit". The AI only reads which option was marked; the marks are calculated by the app's own code.
- **Written answers:** model answer per question, partial marks in steps of 0.5, a short reason and a confidence level. Low confidence is flagged for the teacher.
- Review and edit every answer, ranking, class stats, printable A4 result cards, CSV export.
- Installable on a phone (PWA): "Add to Home screen".

## Security notes

- Access codes are stored as keyed hashes and shown only when created.
- Login, admin login and checking are rate limited. Checking is capped by each center's sheet limit.
- Prompts are built on the server, so the API cannot be used as a free general AI.
- Photos are sent to Grok for reading and are **not stored**. Only the results are saved.
- Strict Content-Security-Policy and security headers; HTTPS strict transport when behind an HTTPS proxy.
- Back up `DATA_DIR` or use the admin Backup button.

## Known limits

- Storage is one JSON file: fine for dozens of centers. Move to PostgreSQL before growing much beyond that.
- If two devices edit the same project at the same moment, the newest save wins.
- The code is the key. Treat codes like passwords. There are no user accounts by design.
- AI can misread handwriting: always review the flagged answers.

## Roadmap

PostgreSQL storage, PDF export of result cards, WhatsApp sharing, Urdu interface, per-center logo on result cards, automated tests.

## License

MIT, see `LICENSE`.
