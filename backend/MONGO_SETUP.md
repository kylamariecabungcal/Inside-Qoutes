# MongoDB Setup for Inside Qoutes (local dev)

This project supports optional MongoDB persistence. If `MONGODB_URI` is present in `backend/.env`, the server will connect to MongoDB; otherwise it uses file-based storage (`backend/data/users.json`).

Steps to run a local MongoDB with Docker Compose:

1. Copy the example env file:

```powershell
cd C:\Users\kylam\Inside-Qoutes\backend
copy .env.example .env
notepad .env
```

2. Start MongoDB with Docker Compose:

```powershell
docker compose up -d
```

3. Start backend:

```powershell
npm install
npm run dev
```

Verification:

- On successful connection you will see `✅ Connected to MongoDB` in the server logs.
- If you see `No MONGODB_URI provided; skipping MongoDB connection.` then either `.env` is missing or `MONGODB_URI` is empty.

Notes:

- For Atlas use, replace `MONGODB_URI` with your Atlas connection string and ensure network access is allowed.
- Do not commit `.env` with production credentials.
