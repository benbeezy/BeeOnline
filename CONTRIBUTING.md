# Contributing to BeeOnline

Thank you for your interest in contributing to **BeeOnline**!  
BeeOnline is a **community-built, open-source, arcade-inspired multiplayer game** focused on originality, accessibility, and modern online play.

This document explains **how to contribute**, **what we accept**, and **important legal and technical rules** that protect both contributors and the project.

---

## Code of Conduct

All contributors are expected to be respectful, constructive, and collaborative.

Harassment, discrimination, or hostile behavior of any kind will not be tolerated.  
If issues arise, maintainers may remove content or restrict participation.

---

## High-Level Principles

Before contributing, please keep these core principles in mind:

- BeeOnline is **inspired by**, but **not a clone of**, any existing arcade game.
- All contributions must be **original**, **from-scratch**, or **properly licensed**.
- The project prioritizes **clarity**, **maintainability**, and **network-friendly design**.
- Legal and IP safety is a **hard requirement**, not optional.

---

## What We Welcome

We happily accept contributions in the following areas:

### Code
- Gameplay systems
- Networking and synchronization
- Input handling (HID, controllers, arcade devices)
- Performance optimizations
- Bug fixes and refactors
- Tooling, debugging utilities, and CI improvements

### Assets
- Original art (sprites, UI, VFX)
- Original audio (music, SFX)
- Fonts with permissive licenses
- Icons, diagrams, and documentation visuals

### Documentation
- Architecture explanations
- Networking design notes
- Setup guides
- Tutorials or contributor notes

---

## What We Do NOT Accept

To protect the project and contributors, **the following are strictly prohibited**:

- Any assets copied, traced, modified, or “recreated from memory” from *Killer Queen*
- ROMs, cabinet dumps, binary files, or proprietary data
- Decompiled, reverse-engineered, or leaked source code
- Trademarked logos, names, fonts, UI layouts, or audio
- “Placeholder” assets ripped from commercial games
- Network behavior copied from packet inspection or disassembly

If you are unsure whether something is acceptable, **open an issue and ask first**.

---

## Asset & IP Safety Rules (Very Important)

All assets and code must be **one of the following**:

1. Created entirely by you for BeeOnline  
2. Released under a license compatible with MIT  
3. Explicitly placed in the public domain  

When submitting assets:
- State the source and license clearly
- Include attribution if required
- Avoid stylistic mimicry that could cause confusion

If an asset’s origin is unclear, it will be rejected.

---

## Development Setup

### Requirements
- Godot (version specified in README)
- Git
- A supported OS (Windows, macOS, Linux)

### Project Structure
Please respect the existing folder structure:

- autoload/ # Global managers only
- core/ # Deterministic, simulation-friendly logic
- input/ # Input abstraction & HID handling
- networking/ # Netcode, replication, prediction
- scenes/ # Godot scenes
- docs/ # Documentation

Avoid placing gameplay logic in autoloads.

---

## Coding Guidelines

### General
- Favor **clarity over cleverness**
- Keep systems modular and testable
- Use signals instead of tight coupling
- Avoid global state unless intentionally managed

### GDScript
- Use 4 spaces for indentation
- Use descriptive names
- Avoid large “god scripts”
- Comment intent, not obvious behavior

### Networking
- Assume latency, packet loss, and desync
- Keep simulation deterministic where possible
- Never trust client input blindly
- Document assumptions clearly

---

## Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make focused, incremental commits
4. Ensure the project loads and runs
5. Open a Pull Request with:
   - What changed
   - Why it changed
   - Any risks or follow-up work

Small, well-scoped PRs are preferred.

---

## Review & Merging

Maintainers will review PRs for:
- Code quality
- Architectural fit
- Legal/IP safety
- Long-term maintainability

Changes may be requested before merging.  
Not all PRs will be accepted, and that’s okay — discussion is encouraged.

---

## Licensing

By contributing to BeeOnline, you agree that:

- Your contributions are licensed under the **MIT License**
- You have the right to submit the content
- You are not contributing proprietary or restricted materials

---

## Reporting Issues

Please use GitHub Issues to report:
- Bugs
- Crashes
- Performance regressions
- Security or networking concerns
- Legal/IP concerns (quietly and respectfully)

For sensitive matters, contact the maintainers directly if possible.

---

## Final Note

BeeOnline exists because of community trust and care.  
Protecting originality, legality, and long-term health matters more than speed.

Thank you for helping build something great.
