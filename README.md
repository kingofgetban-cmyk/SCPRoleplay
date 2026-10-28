# 🛡️ SCP: Roleplay (Site-76) - Suite (Combat, Modular ESP, Spy Chat & Facility)

![Roblox](https://img.shields.io/badge/Roblox-SCP%3A%20Roleplay%20(Site--76)-blue?style=for-the-badge&logo=roblox)
![Status](https://img.shields.io/badge/Status-Undetected-brightgreen?style=for-the-badge)
![Security](https://img.shields.io/badge/Protection-ChaCha20_CFF_Protected-purple?style=for-the-badge)
![Executors](https://img.shields.io/badge/Executors-Solara%20%7C%20Wave%20%7C%20Codex%20%7C%20Delta%20%7C%20Fluxus-orange?style=for-the-badge)

High-performance, feature-packed client suite for **SCP: Roleplay (Site-76)**. Built with Rayfield UI library, zero-lag native Drawing API routines, smooth aimbot & triggerbot, facility bypasses, real-time spy chat interception, and comprehensive security tools.

---

## ⚡ Quick Execution

Paste the following line into your executor (**Solara, Wave, Codex, Delta, Fluxus, Synapse, etc.**):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kingofgetban-cmyk/SCPRoleplay/main/SCPRoleplay.lua"))()
```

---

## 🚀 Key Features

### 🎯 Combat Suite
- **Smooth Aimbot**: Configurable smoothness slider (1-10) with mouse relative delta interpolation.
- **Target Bones**: Selectable targeting (Head, Torso, HumanoidRootPart).
- **Target Selection Priority**: Closest to Crosshair or Closest in 3D Distance.
- **Wall Check (Line of Sight)**: Raycasts through site geometry so the aimbot never snaps through walls.
- **Team Check**: Automatically ignores teammates and friendly departments.
- **FOV Circle**: Native Drawing circle overlay with customizable radius and toggle.
- **TriggerBot**: Instant automatic firing upon crosshair intersection with optional delay slider and headshot filter.

### 👁️ Modular Visuals / ESP (Native Drawing API)
- **Box ESP**: Crisp 2D bounding boxes with dynamic height and width.
- **Tracer Lines**: Configurable tracer origins (**Bottom Screen**, **Center Screen**, **Top Screen**).
- **Player Names**: Sharp text overlays with outline.
- **Distance Display**: Exact distance meters `[XXm]` calculated from local player.
- **Equipped Weapon Display**: Real-time equipped weapon and item tags `<Weapon>`.
- **Dynamic Health Bar**: Live health percentage indicator with green-to-red color gradient.
- **Team Color Coding**: Automatic department color matching (Class-D, MTF, Chaos, Security, AD, etc.).
- **Chams (3D Highlight)**: Smooth silhouette highlighting through walls.
- **Target Filter**: Toggle between **Everyone** and **Enemies Only**.
- **SCP ESP**: Tracks all SCP entities (SCP-173, SCP-096, SCP-106, SCP-049, SCP-939, SCP-076, SCP-966).
- **Dropped Items ESP**: Outlines and labels dropped guns, keycards, and medical gear.

### 🚪 Facility & Security Bypass
- **Ghost Doors**: Automatically sets `CanCollide = false` on all facility doors within 40 studs.
- **Phase Blink (Hotkey `V`)**: Instantly phase 10 studs forward through heavy blast doors and keycard gates.
- **Noclip (Hotkey `N`)**: Freely walk through walls and obstacles.
- **Instant Prompts**: Sets all `ProximityPrompt.HoldDuration = 0` (0-second instant interactions).
- **Persistent O5 Keycard**: Automatically equips and re-steals O5 Keycard if dropped or removed.
- **Fullbright (Night Vision)**: Removes shadows and brightens dark containment corridors.
- **Speed Boost**: Configurable walkspeed multiplier.

### 📡 Spy Chat & Intelligence Interceptor
- **Roblox Chat Box Restoration**: Overrides Site-76's hidden chat window, restoring the native Roblox chat box.
- **Radio Frequency Sniffer**: Intercepts Chaos Raiders, MTF Tac-Comms, O5 Council, and Security radio frequencies.
- **Team Chat Sniffer**: Captures team-only whispers and coordinates.
- **In-Chat Intelligence Feed**: Prints formatted, color-coded intelligence reports directly into your chat log.

### 🛡️ Anti-SCP Defense
- **Auto Look at SCP-173**: Automatically snaps camera to Peanut when within 65 studs to keep it frozen.
- **Avoid Looking at SCP-096**: Automatically deflects camera downwards when near Shy Guy to prevent triggering rage mode.

### 🔫 Arsenal & Weapons
- **37-Gun Armory Spawner**: Spawn weapons including BR-762, M4, M16A4, Minigun, XM250, Burning Fang, Freeze Gun, ACR, Honey Badger, Spas-12, AA-12, etc.
- **Weapon Stealer**: Steals the equipped weapon directly from the nearest player into your inventory.

### 🎭 Troll Suite
- **Spinbot**: High-velocity rotational spin with configurable speed slider.
- **Spam Crouch (Teabag)**: Fast rhythmic crouching animation.
- **Disco Facility Lights**: Cycles facility ambient lights through RGB rave colors.
- **Levitate / Float**: Smooth anti-gravity hovering.
- **Ragdoll Trip**: Harmlessly stumble and ragdoll on demand.

### 🎥 CCTV Surveillance
- **25+ Live Feeds**: View real-time cameras across Site-76 directly from your screen (`Workspace.Cameras`).

### 🗺️ Teleports
- **SCP Chambers**: Instant teleports to SCP-173, 096, 106, 049, 939, 087, 023, 076, 079, 966.
- **Sectors & Bases**: Instant waypoints to CDC, Sector 1, Sector 2, Heavy Containment, Warhead, Chaos Base, and MTF Spawn.

---

## 🔒 Security & Credits
- Source code is protected with multi-layered ChaCha20 stream cipher & Control Flow Flattening (CFF).
- Developed by **valexcryzer** & **MintraZERX**.
- Telegram: **@MintraZERX**
