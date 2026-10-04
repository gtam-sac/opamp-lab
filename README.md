# Op-Amp Virtual Lab

An educational Flutter app for exploring ideal op-amp differentiator and
integrator circuits. The application opens directly in the differentiator lab;
use the experiment selector in the top bar to switch to the integrator.

## Run

Install Flutter with web support, then from `frontend/` run:

```powershell
flutter pub get
flutter run -d chrome
```

No account, Node.js server, MySQL database, API URL, or network connection is
needed. The simulation and waveform plotting run locally in Flutter.

## Lab controls and features

- Switch between differentiator and integrator experiments.
- Select sine, square, or triangle input waveforms.
- Adjust resistance, capacitance, input amplitude, and frequency.
- Run or stop the animated waveform display.
- Reset all parameters to their defaults and stop the simulation.
- View overlaid input/output plots, circuit diagrams, calculated results, and
  educational explanations.

The differentiator circuit has an input capacitor and feedback resistor; it
uses `Vout = -RC · dVin/dt` with a periodic backward finite difference. The
integrator has an input resistor and feedback capacitor; it uses
`Vout = -(1/RC) · ∫Vin dt` with trapezoidal numerical integration. The ideal
integrator response is centered to show the periodic steady-state waveform;
its arbitrary DC initial condition does not affect the integration slope.
Both outputs are clipped at ±13.5 V after calculation.

R is adjustable from 1 kΩ to 100 kΩ in 1 kΩ steps; C from 0.1 µF to 1.0 µF
in 0.1 µF steps; amplitude from 0.5 V to 10.0 V in 0.1 V steps; and frequency
from 10 Hz to 2000 Hz in 10 Hz steps. Values update with the controls.

For a sine input, these inverting-circuit equations produce a negative-cosine
differentiator output and a positive-cosine integrator output. Square-wave
edges produce clipped derivative pulses; integrating square waves produces
ramps. A triangle integrates into piecewise parabolic segments. The simulation
samples 240 points per input period over three periods. It is an idealized
educational model, not a SPICE-level simulation of a physical op-amp.

## Build and verify

From `frontend/`:

```powershell
flutter analyze
flutter test
flutter build web --release
```

The static web app is generated under `frontend/build/web/`.

## Legacy backend and database

The `backend/` and `database/` directories contain the previous Express/MySQL
authentication and saved-history implementation. The current Flutter lab does
not call those APIs; they are not needed to run or build the lab. The app no
longer has login, signup, JWT handling, or server-backed experiment history.
