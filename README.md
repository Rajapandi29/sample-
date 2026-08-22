# API Login Lab

A realistic API-learning app without Docker or npm dependencies.

Run `npm start`, then open http://localhost:3000. Register an account first, then log in. The **Live API requests** panel shows every frontend GET, POST, PATCH and DELETE call.

APIs: `POST /api/auth/register`, `POST /api/auth/login`, `GET /api/me`, `POST /api/auth/logout`, and authenticated task CRUD at `/api/tasks`.

This is a learning demo: data is in memory and clears after the server restarts. Passwords are SHA-256 hashed only for demonstration; production systems need a database, HTTPS, and bcrypt/Argon2.
# sample-
