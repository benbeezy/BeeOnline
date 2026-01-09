# Input System Overview

This document describes the **input architecture** for BeeOnline.

The goal of the input system is to be:
- **Device-agnostic**
- **Arcade-friendly**
- **Network-safe**
- **Easy to extend and remap**
- **Consistent across Windows, macOS, and Linux**

Input handling is intentionally **decoupled from direct gameplay logic**.

---

## Design Principles

### 1. Input Is Abstracted
Gameplay code never reads raw input directly from Godot (`Input.is_action_pressed`, device IDs, etc.).

Instead:
- Raw input is converted into **high-level input intents**
- Gameplay systems consume **intent/state objects**

This allows:
- Multiple device types (keyboard, gamepad, HID, arcade)
- Clean networking & prediction
- Easy rebinding and theming

---

### 2. Input Does Not Equal Authority
Input represents **player intent**, not game state.

- The simulation decides outcomes
- Input is validated and processed deterministically
- Clients never directly modify authoritative state

This is critical for online multiplayer.

---

## High-Level Architecture

```
[ Physical Device ]
        ↓
[ Godot Input Events ]
        ↓
[ Device Profile ]
        ↓
[ Input Intent ]
        ↓
[ Gameplay / Simulation ]
```

---

## Core Components

### `InputBus` (Autoload)

`InputBus` is a globally available manager responsible for:
- Collecting raw input events
- Routing them to the correct device profile
- Emitting normalized input intents

**Responsibilities**
- Device discovery
- Player ↔ device assignment
- Emitting signals for input updates

**Does NOT**
- Contain gameplay logic
- Decide game outcomes
- Handle rendering or UI directly

---

### Device Profiles

Each physical input type is handled by a **device profile**.

Examples:
```
input/
├─ device_profiles/
│  ├─ keyboard_mouse.gd
│  ├─ gamepad.gd
│  ├─ arcade_hid.gd
│  └─ generic_hid.gd
```

A device profile:
- Knows how to read its device
- Converts raw input into BeeOnline input intents
- Is stateless or minimally stateful

This makes adding new controllers trivial.

---

## Input Intents

Input intents are **engine-agnostic**, gameplay-safe structures.

Examples:
- Move left / right
- Jump / Interact
- Menu navigation

### Example Intent Structure

```gdscript
class_name PlayerInputIntent

var move_axis: float = 0.0
var jump_pressed: bool = false
var interact_pressed: bool = false
```

Gameplay code consumes these intents, not raw inputs.

---

## Player Mapping

Each player is assigned:
- A device profile
- A logical player index

This allows:
- Local multiplayer
- Online multiplayer
- Mixed device types
- Seamless reconnects

Mapping is handled centrally by `InputBus`.

---

## HID & Arcade Devices

BeeOnline treats HID and arcade controllers as **first-class citizens**.

Guidelines:
- Buttons are mapped by intent, not button index
- Axis ranges are normalized to `[-1, 1]`
- No assumptions about physical layout
- Profiles may include calibration (To solve glancing issues)

HID mappings are defined in code or external config files (future).

---

## Input Actions vs Raw Events

Godot input actions may still be used **inside device profiles**, but:

- Actions should be generic
- Gameplay scripts must not reference them
- Actions must not encode game rules

This prevents tight coupling between gameplay and editor configuration.

---

## Networking Considerations

Input is:
- Sampled locally
- Timestamped / tick-aligned
- Serialized for network transport
- Replayed or predicted as needed

Important rules:
- Input is never trusted blindly
- Server or authoritative host validates actions
- Visual responsiveness may use client-side prediction

---

## Determinism Rules

To support rollback, replays, and spectators:

- Input intents must be deterministic
- No time-based logic inside input handling
- Device-specific quirks are resolved before intent creation
- Simulation consumes input on fixed ticks

---

## UI & Menus

Menu navigation uses the **same input pipeline**:
- Device profile → intent → UI handler

This ensures:
- Controllers and arcade devices work everywhere
- No duplicated input logic
- Consistent behavior across game and menus

---

## Common Anti-Patterns (Avoid These)

❌ Reading `Input.is_action_pressed()` inside gameplay scripts  
❌ Hard-coding button indices  
❌ Mixing input logic with physics or rendering  
❌ Device-specific code inside simulation  
❌ Letting input directly move nodes  

---

## Extending the System

To add a new input device:
1. Create a new device profile script
2. Map raw input to intents
3. Register it with `InputBus`
4. Test locally and in multiplayer

No gameplay code changes should be required.

---

## Debugging & Tools (Planned)

- Input visualizer overlay
- Per-player input logging
- Device hot-plug detection
- Intent inspection tools

---

## Summary

- Input is abstracted, normalized, and intent-based
- Devices are interchangeable
- Gameplay remains deterministic and network-safe
- Arcade and HID devices are fully supported
- No rebuilds required for new input hardware

This architecture allows BeeOnline to scale from
**local cabinets → online play → tournaments** cleanly and safely.
