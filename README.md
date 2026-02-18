# Kingdom - Ada 83 Recreation

A modern recreation of the classic CP/M strategy game **Kingdom** (also known as *Hamurabi*), implemented in **Ada 83**.

## Overview

This project is a faithful implementation of the Sumerian city management simulation. As the ruler (Hamurabi), you must manage your city's resources—land, citizens, and grain—over a 10-year term. Your goal is to maximize the population and land holdings while preventing starvation and managing random events like plagues and rat infestations.

## Features

- **Strict Ada 83 Compatibility**: The source code follows the Ada 83 standard, using period-accurate syntax and library structures.
- **Custom RNG**: Since the Ada 83 standard didn't include a standard library for random number generation, this version implements a custom **Linear Congruential Generator (LCG)**.
- **Modular Design**: The project is split into separate modules to demonstrate proper Ada encapsulation across different directories.
- **Classic Gameplay**: Includes all the original mechanics:
  - Land trade (buying/selling).
  - Population management (feeding/starvation/immigration).
  - Agriculture (planting/harvesting/yield variance).
  - Random events (plague, rat damage).

## Project Structure

### [kingdom_83/](./kingdom_83)
Contains the original single-file implementation.
- `kingdom_original.adb`: A standalone Ada 83 version, ideal for compilers that prefer a single-source file without complex package dependencies.

### [kingdom_83_plus/](./kingdom_83_plus)
Contains a modular implementation in Ada 83 style.
- `kingdom.adb`: Main program loop and user interaction.
- `kingdom_logic.ads / .adb`: Core game logic, state management, and RNG implementation.

### [kingdom_modern/](./kingdom_modern)
Contains a version of the game utilizing more modern Ada conventions and GNAT-style naming.
- `kingdom-main.adb`: Entry point for the modern version.
- `kingdom-logic.ads / .adb`: Modern implementation of the core logic.

### Using GPRbuild (Recommended)

To compile any of the versions, navigate to its directory and use `gprbuild`:

```bash
# Example for the modern version
cd kingdom_modern
gprbuild -P kingdom_modern.gpr
```

### Manual Compilation with GNAT

Alternatively, you can use `gnatmake` within the `src` directories:

```bash
cd kingdom_83/src
gnatmake kingdom_original.adb
```

To run the game after building with `gprbuild`:

```bash
./dest/kingdom-main
```

## Historical Context

*Hamurabi* was one of the earliest "city-building" games, originally developed in FOCAL by Doug Dyment in 1968 and later popularized in BASIC by David H. Ahl. The CP/M version, often titled *Kingdom*, was a staple of early personal computing.
