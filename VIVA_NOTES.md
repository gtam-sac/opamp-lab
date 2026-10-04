# Viva Notes — Op-Amp Differentiator and Integrator Virtual Lab

## 1. What is the project?

It is a standalone educational virtual laboratory built with:

```text
Flutter → local numerical simulation → waveform plots
```

The app opens directly in the differentiator lab. Students can switch to the
integrator, select an input waveform, adjust circuit parameters, and observe
the calculated input/output plots. No account, backend, or database is needed.

## 2. Why does a differentiator use `Vout = -RC(dVin/dt)`?

For an ideal op-amp, the inverting input is approximately at virtual ground.

For the differentiator:

```text
Ic = C(dVin/dt)
```

The same current flows through the feedback resistor:

```text
Vout = -IcR
```

Therefore:

```text
Vout = -RC(dVin/dt)
```

The negative sign comes from the inverting configuration.

## 3. What does a differentiator actually do?

It responds to the **rate of change** of the input.

- Slowly changing input → smaller output.
- Rapidly changing input → larger output.
- Constant input → approximately zero output.

Increasing R or C increases the magnitude of the ideal differentiator output.

## 4. Why does a square wave produce spikes?

An ideal square wave changes almost instantaneously at its edges.

Since:

```text
dV/dt
```

becomes extremely large at an ideal edge, the differentiator produces a large, narrow pulse there.

The project limits the simulated output to:

```text
±13.5 V
```

so the graph remains finite and demonstrates op-amp output clipping.

## 5. Why is the ideal differentiator noise-prone?

Differentiation emphasizes rapid changes.

High-frequency noise changes rapidly, so differentiation can amplify it strongly.

A practical differentiator therefore adds frequency-limiting components. This project intentionally uses the simpler ideal equation for education.

## 6. What happens to a sine wave?

The derivative of a sine is a cosine:

```text
d/dt [sin(ωt)] = ω cos(ωt)
```

Therefore the inverting differentiator produces a negative-cosine output,
lagging the sine input by 90°.

Its ideal amplitude is:

```text
Vout_peak = RC × A × ω
```

where:

```text
ω = 2πf
```

## 7. What happens to a triangle wave?

A triangle wave has approximately constant positive or negative slope on each segment.

Differentiation turns those constant slopes into approximately constant positive/negative levels.

So:

```text
triangle → square-like output
```

## 8. Why does an integrator use `Vout = -(1/RC)∫Vin dt`?

For an ideal op-amp integrator:

```text
IR = Vin/R
```

The feedback capacitor stores charge:

```text
Ic = C(dV/dt)
```

Combining the current relation with the inverting configuration gives:

```text
Vout = -(1/RC) ∫Vin dt
```

The capacitor therefore accumulates the input signal over time.

## 9. What happens to a square wave in an integrator?

A constant positive input produces a linear decrease in output.

A constant negative input produces a linear increase.

Therefore the two levels of a square wave create alternating ramps:

```text
square → triangle
```

## 10. What happens to a sine wave in an integrator?

The integral of a sine is a negative cosine; the inverting integrator's
additional negative sign therefore produces a positive-cosine output, leading
the sine input by 90°.

For a sine input, the ideal peak magnitude is:

```text
Vout_peak = A/(RCω)
```

## 11. What happens to a triangle wave in an integrator?

The triangle wave consists of linear segments.

Integrating a linear function produces a quadratic function.

Therefore:

```text
triangle → piecewise-parabolic output
```

## 12. What is the RC time constant?

```text
τ = RC
```

It describes the characteristic time scale set by the resistor and capacitor.

A larger R or C means a larger time constant.

In this project it is displayed in seconds, milliseconds, or microseconds depending on its magnitude.

## 13. What is corner frequency?

The project calculates:

```text
fc = 1/(2πRC)
```

It is a characteristic frequency associated with the RC network.

A larger RC gives a smaller corner frequency.

A smaller RC gives a larger corner frequency.

## 14. Why are R and C important?

For the ideal differentiator:

```text
|Vout| ∝ RC
```

So increasing R or C increases output magnitude for the same input.

For the ideal integrator:

```text
|Vout| ∝ 1/(RC)
```

So increasing R or C decreases output magnitude for the same input.

## 15. Why does the frontend use a finite difference?

A computer cannot directly plot an ideal continuous derivative at every mathematical instant.

The simulation samples the waveform at discrete time points.

It estimates the derivative as:

```text
(Vin[i] - Vin[i-1]) / dt
```

This is a backward finite-difference approximation.

## 16. Why does the integrator use trapezoidal integration?

The waveform is sampled at discrete points.

The area between two adjacent samples is approximated by a trapezoid:

```text
area ≈ (Vin[i] + Vin[i-1])/2 × dt
```

Adding these areas gives a numerical approximation to the integral.

## 17. Why is the output clipped at ±13.5 V?

An ideal mathematical op-amp could produce arbitrarily large values.

A real op-amp has finite supply rails and cannot produce unlimited output.

The project uses ±13.5 V as a simple educational output-swing limit.

It is intentionally fixed rather than modelling a complete real op-amp.

## 18. Does the lab need a backend or database?

No. The current lab calculates and plots the simulation locally in Flutter.
The Node/Express and MySQL files are retained as legacy code from the earlier
account and saved-history version, but the app does not call them.

## 22. Why one ExperimentScreen?

Differentiator and integrator screens have nearly identical controls and layout.

Instead of duplicating the screen:

```text
ExperimentScreen(config: ExperimentConfig.differentiator)
ExperimentScreen(config: ExperimentConfig.integrator)
```

The configuration supplies the title, formula, explanation, and simulation function.

This keeps the UI code smaller and easier to maintain.

## 25. Important project limitations to admit in a viva

Do not claim this is a full circuit simulator.

It is an **idealized educational mathematical simulation**.

Known limitations:

- no SPICE engine
- fixed ±13.5 V saturation limit
- simple numerical derivative
- simple numerical integration
- simplified ideal differentiator
- no practical differentiator compensation components
- no integrator leakage/reset component
- no persisted experiment history

## 26. One-minute explanation

> This is a standalone Flutter virtual lab for studying op-amp differentiators and integrators. It generates sine, square, and triangle inputs, numerically calculates each circuit's response, limits the output to ±13.5 V, and plots the input and output. Students can change resistance, capacitance, amplitude, and frequency, switch experiments, and reset the controls. The simulation runs locally and requires no login, backend, or database.
