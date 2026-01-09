# Networking System Overview

This document describes the **networking architecture** for BeeOnline.

The networking system is designed to support:
- **Online multiplayer**
- **Low-latency, arcade-style gameplay**
- **Deterministic simulation**
- **Spectators and replays (future)**
- **Cross-platform compatibility** (Windows, macOS, Linux)

Networking is treated as a **core system**, not an afterthought.

---

## Design Principles

### 1. Simulation Is Authoritative
BeeOnline separates **simulation** from **transport**.

- One peer (server or host) is authoritative
- Clients send **input intents**, not state
- Game state is derived by simulation, not network packets

This prevents cheating and desynchronization.

---

### 2. Input Is the Network Contract
The only thing players send reliably is **input**.

- Inputs are timestamped or tick-based
- Inputs are validated before application
- State replication is derived, not primary

This enables:
- Rollback
- Replays
- Spectator mode
- Deterministic correction

---

### 3. Determinism First
Gameplay simulation must be:
- Tick-based
- Deterministic
- Independent of frame rate
- Independent of platform timing quirks

Networking exists to **deliver input**, not to drive gameplay.

---

## High-Level Architecture

```
[ Client ]
   │
   │ Input Intents
   ▼
[ Authority / Host ]
   │
   │ State Snapshots / Corrections
   ▼
[ Clients ]
```

Authority may be:
- A dedicated server
- A peer host (P2P-style with authority)

The architecture supports both.

---

## Core Components

### `Net` (Autoload)

The `Net` autoload manages:
- Network session lifecycle
- Peer connections
- Message routing
- Match-level network state

**Responsibilities**
- Hosting / joining sessions
- Disconnect handling
- Network time / tick tracking
- Signal-based event dispatch

**Does NOT**
- Contain gameplay logic
- Directly move or modify entities
- Render UI

---

### Simulation Layer

Located in:
```
core/simulation/
```

Responsibilities:
- Apply input intents
- Advance the match state
- Produce deterministic outcomes

The simulation:
- Never calls networking APIs
- Never queries connection state
- Can run offline, headless, or replayed

This strict separation is intentional.

---

### Replication Layer

Located in:
```
networking/replication/
```

Responsibilities:
- Serialize authoritative state
- Send periodic snapshots
- Apply corrections on clients
- Smooth visual reconciliation

Replication exists to:
- Correct drift
- Update late joiners
- Drive spectator views

It does NOT replace simulation.

---

## Tick Model

BeeOnline uses a **fixed simulation tick**.

Example:
- 60 ticks per second
- All inputs applied per tick
- Network packets reference tick IDs

Benefits:
- Stable rollback
- Consistent behavior across platforms
- Predictable reconciliation

Rendering may run faster or slower than simulation.

---

## Client Responsibilities

Clients:
- Collect local input
- Buffer input by tick
- Predict local outcomes (optional)
- Apply authoritative corrections

Clients must be able to:
- Rewind local state
- Reapply buffered inputs
- Visually smooth corrections

Prediction affects visuals, never authority.

---

## Authority Responsibilities

The authority:
- Receives input from all clients
- Validates timing and legality
- Advances the simulation
- Broadcasts authoritative state

The authority:
- Never trusts client state
- Never accepts movement/position packets
- Can disconnect misbehaving peers

---

## Transport Layer

BeeOnline relies on Godot’s networking APIs as a **transport**, not a gameplay layer.

Transport handles:
- Connection
- Reliability
- Packet delivery

Gameplay rules do not live here.

Exact transport selection (ENet, WebSocket, etc.) is abstracted behind `Net`.

---

## Latency Handling

Strategies may include:
- Client-side prediction
- Input buffering
- Server reconciliation
- Interpolation for remote entities

The exact mix may evolve, but:
- Determinism is never sacrificed
- Corrections must be visually smoothed

---

## Spectators & Replays (Planned)

Because input is the primary network artifact:
- Entire matches can be replayed from input logs
- Spectators can receive snapshots + inputs
- Debugging desyncs becomes feasible

This is a direct benefit of the architecture.

---

## Security Considerations

- All inputs are validated
- Tick drift is monitored
- Rate limits enforced
- Invalid or impossible inputs rejected

The architecture assumes malicious clients exist.

---

## Common Anti-Patterns (Avoid These)

❌ Sending transforms or positions as authority  
❌ Letting clients move entities directly  
❌ Frame-rate-based simulation  
❌ Network-driven game rules  
❌ Platform-dependent timing logic  

---

## Extending the System

Future additions may include:
- Dedicated server builds
- Headless simulation mode
- Match recording tools
- Server-side anti-cheat analysis
- Region-based matchmaking

The architecture is intentionally designed to support this growth.

---

## Summary

- Networking delivers **input**, not authority
- Simulation remains deterministic and isolated
- Clients predict; authority decides
- Replication corrects, never drives
- Designed for online play from day one

This system allows BeeOnline to scale from
**local matches → online play → tournaments → spectators**
without architectural rewrites.
