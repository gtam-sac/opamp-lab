# Op-Amp Virtual Lab

A college full-stack educational virtual lab for an **Op-Amp Differentiator** and **Op-Amp Integrator**.

## 1. Architecture

```text
Flutter Web
    |
    | HTTP/JSON + JWT
    v
Node.js + Express REST API
    |
    | mysql2
    v
MySQL / MariaDB
```

Flutter never connects directly to MySQL. Database credentials remain on the backend.

## 2. Final project structure

```text
opamp-lab/
├── CONTINUATION_STATE.md
├── README.md
├── VIVA_NOTES.md
├── database/
│   └── schema.sql
├── backend/
│   ├── .env.example
│   ├── package.json
│   ├── package-lock.json
│   └── src/
│       ├── server.js
│       ├── app.js
│       ├── config/
│       │   └── db.js
│       ├── middleware/
│       │   ├── authMiddleware.js
│       │   └── errorHandler.js
│       ├── routes/
│       │   ├── authRoutes.js
│       │   └── experimentRoutes.js
│       ├── controllers/
│       │   ├── authController.js
│       │   └── experimentController.js
│       ├── models/
│       │   ├── userModel.js
│       │   └── experimentModel.js
│       └── utils/
│           ├── jwt.js
│           └── validators.js
└── frontend/
    ├── pubspec.yaml
    ├── assets/
    └── lib/
        ├── main.dart
        ├── app.dart
        ├── theme/
        │   └── app_theme.dart
        ├── utils/
        │   └── constants.dart
        ├── models/
        │   ├── user.dart
        │   ├── experiment_session.dart
        │   └── simulation_params.dart
        ├── logic/
        │   ├── waveform_generator.dart
        │   ├── simulation_result.dart
        │   ├── differentiator_simulator.dart
        │   ├── integrator_simulator.dart
        │   └── experiment_config.dart
        ├── services/
        │   ├── api_client.dart
        │   ├── auth_service.dart
        │   ├── auth_provider.dart
        │   └── experiment_service.dart
        ├── widgets/
        │   ├── waveform_chart.dart
        │   ├── circuit_diagrams.dart
        │   ├── control_panel.dart
        │   ├── results_summary.dart
        │   └── info_section.dart
        └── screens/
            ├── login_screen.dart
            ├── signup_screen.dart
            ├── dashboard_screen.dart
            ├── experiment_screen.dart
            └── history_screen.dart
```

## 3. Dependencies

### Backend

Already declared in `backend/package.json`:

- express `^4.19.2`
- mysql2 `^3.11.0`
- bcrypt `^5.1.1`
- jsonwebtoken `^9.0.2`
- cors `^2.8.5`
- dotenv `^16.4.5`
- nodemon `^3.1.4` (development)

Install with:

```bash
cd backend
npm install
```

### Flutter

Declared in `frontend/pubspec.yaml`:

- Flutter SDK
- http `>=1.1.0 <2.0.0`
- provider `>=6.0.0 <7.0.0`
- shared_preferences `>=2.2.0 <3.0.0`
- fl_chart `>=0.66.0 <1.0.0`
- cupertino_icons `^1.0.6`
- flutter_lints `>=3.0.0 <5.0.0` (development)

The Flutter dependency ranges were deliberately left flexible because the original sandbox did not have Flutter/Dart access and therefore could not resolve `pubspec.lock`.

## 4. MySQL / MariaDB setup

Install MySQL or MariaDB locally, start the database server, and run:

```bash
mysql -u root -p < database/schema.sql
```

The schema creates:

- database: `opamp_lab`
- table: `users`
- table: `experiment_sessions`

For normal application use, create a dedicated non-root user rather than connecting the backend as root:

```sql
CREATE USER 'opamp_app'@'localhost' IDENTIFIED BY 'your_strong_password';
GRANT ALL ON opamp_lab.* TO 'opamp_app'@'localhost';
FLUSH PRIVILEGES;
```

The project was previously tested with this dedicated-user pattern.

## 5. Backend setup

From the `backend/` directory:

### Windows PowerShell

```powershell
Copy-Item .env.example .env
```

### macOS / Linux / Git Bash

```bash
cp .env.example .env
```

Edit `.env` and set real values:

```dotenv
PORT=4000
NODE_ENV=development
CORS_ORIGIN=http://localhost:5000

DB_HOST=localhost
DB_PORT=3306
DB_USER=opamp_app
DB_PASSWORD=your_strong_password
DB_NAME=opamp_lab

JWT_SECRET=replace_with_a_long_random_secret
JWT_EXPIRES_IN=7d
```

Then:

```bash
npm install
npm start
```

For development with automatic restart:

```bash
npm run dev
```

Health endpoint:

```text
GET http://localhost:4000/api/health
```

Expected response:

```json
{
  "status": "ok",
  "service": "opamp-lab-backend"
}
```

Do not commit `.env`.

## 6. Flutter setup

Install a current stable Flutter SDK with Chrome/Web support.

Verify:

```bash
flutter doctor
```

Then:

```bash
cd frontend
flutter pub get
flutter analyze
flutter run -d chrome
```

The default frontend API URL is:

```text
http://localhost:4000/api
```

To use another backend without editing source code:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://your-backend.example/api
```

## 7. Run everything locally

1. Start MySQL/MariaDB.
2. Make sure `opamp_lab` exists and `opamp_app` can access it.
3. Start the backend:

   ```bash
   cd backend
   npm start
   ```

4. In another terminal, start Flutter:

   ```bash
   cd frontend
   flutter run -d chrome
   ```

5. In the browser:
   - Sign up.
   - You should land on the dashboard.
   - Open Differentiator or Integrator.
   - Change R, C, amplitude, frequency, and waveform.
   - The graphs update immediately.
   - Press **RUN / UPDATE SIMULATION** for an explicit recalculation.
   - Press **Save This Run**.
   - Open **History** and verify the saved session.
   - Delete the session.
   - Log out and log back in.

## 8. Backend API contract

Base path:

```text
/api
```

Authentication:

```text
Authorization: Bearer <jwt>
```

### Authentication

```text
POST /api/auth/signup
POST /api/auth/login
GET  /api/auth/profile
```

Signup body:

```json
{
  "name": "Student",
  "email": "student@example.com",
  "password": "password123"
}
```

### Experiments

```text
POST   /api/experiments
GET    /api/experiments
DELETE /api/experiments/:id
```

Experiment POST fields use camelCase:

```json
{
  "experimentType": "differentiator",
  "waveformType": "sine",
  "resistanceOhm": 10000,
  "capacitanceF": 1e-7,
  "amplitudeV": 5,
  "frequencyHz": 100,
  "notes": null
}
```

The response fields for saved sessions use the database's snake_case names. The Flutter model intentionally handles this difference.

## 9. Simulation

### Differentiator

The ideal relation used by the frontend is:

```text
Vout(t) = -RC · dVin/dt
```

The waveform is sampled at 240 points per cycle for three cycles. The derivative is calculated with a backward finite difference:

```text
dVin/dt ≈ (Vin[i] - Vin[i-1]) / dt
```

The calculated output is then limited to ±13.5 V so an ideal mathematical square-wave edge does not become an infinite plotted value.

### Integrator

The ideal relation is:

```text
Vout(t) = -(1/RC) · ∫Vin dt
```

The frontend uses cumulative trapezoidal integration:

```text
area ≈ (Vin[i] + Vin[i-1]) / 2 × dt
```

The accumulated value is converted to output voltage and then limited to ±13.5 V.

### Default sanity check

With:

```text
R = 10 kΩ
C = 100 nF
A = 5 V
f = 100 Hz
```

the intended values are approximately:

```text
RC = 1 ms
fc = 159.15 Hz

Differentiator sine peak ≈ 3.14 V
Integrator sine peak ≈ 7.96 V
```

## 10. Build Flutter Web for deployment

After `flutter pub get` and successful analysis:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://your-backend.example/api
```

The deployable static files are generated under:

```text
frontend/build/web/
```

## 11. Free / low-cost deployment options

Free hosting terms change, so verify the provider's current limits before deployment.

### Option A — practical short demo

- **Backend:** Render free Web Service.
- **MySQL:** a temporary free MySQL host such as FreeDB.
- **Frontend:** Render Static Site.

This can work for a short college demonstration, but the database option must be treated as temporary if its current free plan auto-deletes data. Do not use it as a permanent production database.

### Option B — Railway trial

Railway currently provides a free trial with a one-time credit allocation and allows database deployments during the trial. This is useful for a short-lived grading/demo deployment, but it should not be described as permanently free: the trial has a time/credit limit and the subsequent plan has usage charges.

### Important deployment settings

For production, set:

```dotenv
NODE_ENV=production
CORS_ORIGIN=https://your-frontend.example
```

The frontend must be built with the deployed API URL:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://your-backend.example/api
```

Never put MySQL credentials or the JWT signing secret into Flutter source code or `--dart-define` values.

## 12. Test account

There is no seeded demo account.

For grading/testing:

1. Open the app.
2. Select **Sign up**.
3. Create an account using an email you control.
4. Log in with that account.

## 13. Error handling

The frontend converts network failures into a friendly message:

```text
Could not reach the server. Is the backend running?
```

Server-side error messages are surfaced through `ApiException.message`.

The UI should never display raw database errors or stack traces.

Expected useful paths to test:

- wrong password
- duplicate email
- invalid/empty signup fields
- backend stopped
- expired/invalid JWT
- invalid experiment values
- deleting a session that is no longer available

## 14. Security design

- Passwords are hashed with bcrypt on the backend.
- Plain-text passwords are never stored in MySQL.
- JWTs are signed by the backend and verified by backend middleware.
- The frontend only stores the JWT needed for authenticated API requests.
- Flutter never receives MySQL credentials.
- Production CORS should be restricted to the deployed frontend origin.
- `.env` must remain outside source control.

## 15. Verification status

### Verified before frontend work

The continuation state records that the database schema and backend were exercised against a live MariaDB instance, including health, signup, duplicate signup, validation failures, login, profile, save/list/delete, invalid experiment data, and unknown-route behavior.

### Frontend implementation status in this delivery

All frontend Dart files specified in `CONTINUATION_STATE.md` have been created in the requested dependency order.

**Not verified in this environment:**

- `flutter pub get`
- `flutter analyze`
- `flutter build web`
- Chrome browser manual workflow
- narrow-browser overflow testing
- visual verification of all error paths

Reason: the available environment has no Flutter/Dart SDK (`flutter` is not installed), and the previous continuation state records that the sandbox could not fetch the Flutter SDK.

Therefore this README deliberately does **not** claim that the frontend compiles.

## 16. Known limitations

- No automated Flutter unit/widget tests were added.
- No automated end-to-end browser test suite was added.
- Simulation is an idealized educational model, not a SPICE-accurate circuit simulator.
- Output saturation is fixed at ±13.5 V rather than being user-configurable.
- The differentiator uses a simple backward finite difference.
- The integrator is a simple cumulative trapezoidal model.
- The simplified ideal differentiator does not model a real circuit's frequency-compensation/noise-limiting components.
- The simplified integrator does not implement a real leakage/reset resistor for long-term DC stability.
- No password-reset flow is included.
- No OAuth/2FA is included.
- Temporary free database hosting is unsuitable for important long-term data.

## 17. Final manual test checklist

Run these with the real Flutter SDK and the already-tested backend:

- [ ] `flutter pub get`
- [ ] `flutter analyze` with zero errors
- [ ] `flutter build web`
- [ ] Sign up
- [ ] Dashboard appears
- [ ] Differentiator opens
- [ ] Integrator opens
- [ ] All four sliders visibly affect the result
- [ ] Sine/square/triangle selection changes the waveform
- [ ] Square → differentiator produces narrow spikes
- [ ] Triangle → differentiator produces a square-like output
- [ ] Square → integrator produces a triangle-like output
- [ ] Save This Run works
- [ ] History lists the run
- [ ] Delete works
- [ ] Logout works
- [ ] Login works again
- [ ] Narrow ~400 px browser width has no overflow
- [ ] Wrong password shows a friendly error
- [ ] Duplicate signup shows a friendly error
- [ ] Empty/invalid signup is caught
- [ ] Stopped backend shows the friendly connection error
- [ ] Local Chrome run has no CORS error
