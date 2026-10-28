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

### 🎨 Weapon Skin Changer & Tactical Attachments Suite
- **Tactical Attachments (Multi-Select)**: Equip **Suppressor (ปลอกเก็บเสียง)**, **Laser Sight (เลเซอร์แทคติคอลพร้อมแสงบีม)**, and **Tactical Scope (สโคปเล็งพร้อมเป้าเรืองแสง)** simultaneously via multi-select dropdown or quick toggles. Suppressor automatically muffles gunshot audio to tactical whisper!
- **Tactical Military Camo Patterns (ลายพรางปืน)**: High-definition military camo patterns including **Woodland Camo (ลายพรางทหารเขียว)**, **Desert Digital Camo (ลายพรางทะเลทรายดิจิตอล)**, **Arctic Winter Camo (ลายพรางหิมะ)**, **Tigerstripe (ลายเสือ)**, **Night Ops Dark Camo**, **Urban Flecktarn**, **Dragon Magma**, **Carbon Fiber Weave**, **Damascus Steel Wave**, and **Galaxy Nebula**.
- **Weapon Skin Styles**: Gold Deluxe (24K Pure Gold), Holographic Forcefield (Animated Energy Wrap), Cyber Neon Blue, Crimson Dragon, Obsidian Shadow, Emerald Viper, Amethyst Galaxy, Arctic Glaze, and Rainbow Chroma (Dynamic Real-Time RGB Cycle).
- **Official Particle Skins**: Direct integration with Site-76's official `ParticleSkins` library (Galaxy, Lightning 1/2/3, Dragon Embers, Cosmic Stars, Space Dust, Black Smoke, Frost, Flakes, Heart Particles, Halloween 2025, Anniversary 2025, Easter 2026, Red Raid, Blue Raid).
- **Muzzle Fire & Flash FX**: Custom muzzle fire particles (Plasma Burst, Dragon Flame, Electric Arc, Void Dark, Rainbow Sparkles) with dynamic muzzle flash light illumination.
- **Custom Firing Sounds**: Real-time sound replacement with high-caliber audio (Sci-Fi Laser Pulse, Heavy 50 Cal Thunder, Silenced Whisper Tactical, Plasma Railgun Burst, Energy Blaster Hit) with customizable Pitch Slider (0.5x - 2.0x).
- **Auto-Equip Engine**: Automatically detects weapon switches and equips the selected skin, camo, attachments, particles, and sounds instantaneously.

### 🚪 Facility & Security Bypass
- **Ghost Doors**: Automatically sets `CanCollide = false` on all facility doors within 40 studs.
- **Phase Blink (Hotkey `V`)**: Instantly phase 10 studs forward through heavy blast doors and keycard gates.
- **Instant Prompts**: Sets all `ProximityPrompt.HoldDuration = 0` (0-second instant interactions).
- **Persistent O5 Keycard**: Automatically equips and re-steals O5 Keycard if dropped or removed.
- **Fullbright (Night Vision)**: Removes shadows and brightens dark containment corridors.

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

### 🛡️ Moderator & Staff Detector (Anti-Staff & Panic Mode)
- **Metatable Games Group Scanner**: Scans all players in the server against Metatable Games (Group ID: 5479038) roles (Trial Mod, Game Mod, Senior Mod, Head Mod, Developer, PM, Coordinator, Admin).
- **Staff Join Alerts**: Instant on-screen notification and spy chat alert when any staff member enters the server.
- **Auto Disable All Features**: Automatically turns off all cheat functions (Aimbot, Triggerbot, Drawing ESP, Chams, Ghost Doors, Noclip, Speedboost, etc.) immediately upon staff detection.
- **Auto Leave / Disconnect**: Automatically disconnects you from the server with a configurable delay to prevent staff spectating or ban registration.
- **Manual Panic Switch**: One-click button to instantly kill all active visuals, hooks, and modifications.
- **Server Rejoin**: Quick button to safely hop or reconnect.

---

## 🔒 Security & Credits
- Source code is protected with multi-layered ChaCha20 stream cipher & Control Flow Flattening (CFF).
- Developed by **valexcryzer** & **MintraZERX**.
- Telegram: **@MintraZERX**
