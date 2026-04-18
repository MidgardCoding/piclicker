<div align="center">

```
██████╗ ██╗ ██████╗██╗     ██╗ ██████╗██╗  ██╗███████╗██████╗
██╔══██╗██║██╔════╝██║     ██║██╔════╝██║ ██╔╝██╔════╝██╔══██╗
██████╔╝██║██║     ██║     ██║██║     █████╔╝ █████╗  ██████╔╝
██╔═══╝ ██║██║     ██║     ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
██║     ██║╚██████╗███████╗██║╚██████╗██║  ██╗███████╗██║  ██║
╚═╝     ╚═╝ ╚═════╝╚══════╝╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
```

**PiClicker is a strategic clicker/idle game based on the number Pi and other mathematical values.** 

![Status](https://img.shields.io/badge/status-alpha%20%E2%80%93%20active%20development-orange?style=flat-square)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)


</div>

---

## 📊 Production Status

> **Current phase: Alpha - active development**
> Clicking mechanics, Thresholds (+ XP System), upgrades, robots, batteries, managers, expeditions - they all work. The rest needs work.

| Feature | Status | Progress |
|---|---|---|
| Core clicker loop | ✅ Done | `████████████` 100% |
| Combos (click multiplier) | ✅ Done | `████████████` 100% |
| Thresholds 1–20 | ✅ Done | `████████████` 100% |
| Robots (auto-click) | ✅ Done | `████████████` 100% |
| Managers (offline work) | ✅ Done | `████████████` 100% |
| Batteries (XP modifiers) | ✅ Done | `████████████` 100% |
| Expeditions | 🟡 In progress | `██████░░░░░░` 50% |
| Robots (managing, Robot Market) | 🔵 Started | `███░░░░░░░░░` 25% |
| Store & Customization | ⬜ Planned | `░░░░░░░░░░░░` - |
| Prestige & Ascension | ⬜ Planned | `░░░░░░░░░░░░` - |
| Pi Parade events | ⬜ Planned | `░░░░░░░░░░░░` - |
| The Pi Estate (tower mode) | ⬜ Planned | `░░░░░░░░░░░░` - |
| Weekend Rushes | ⬜ Planned | `░░░░░░░░░░░░` - |
| Daily Brawl | ⬜ Planned | `░░░░░░░░░░░░` - |

---

## ⚙️ Core Mechanics

### Combos *(available from the start)*

Available from the start, Combos act as click multipliers. This mechanic rewards manual clicking rather than automation.

- **Each purchase doubles the multiplier**: ×2 → ×4 → ×8, etc.
- Combos do **not** affect robot clicks.

### 🤖 Robots *(Unlocked at Threshold 3)*

Robots click automatically when you are away. Each robot has:

- **Power** - milliseconds required per click.
- **Cores** - number of clicks performed at once.

### 👔 Managers *(Unlocked at Threshold 6)*

Managers allow robots to work even when the game is closed.

- Maximum of 5 managers.
- Unwanted managers can be fired.
- One new manager offer appears daily.
- Rarity tiers: `Basic`, `Super`, `Epic`, `Legendary`, `Master`.
- Stats: Daily wage (percentage of player’s earned points) and work time - both increase with rarity.

### ⚡ Batteries *(Unlocked at Threshold 9)*

- **Additive** - adds a fixed XP/click value.
- **Multiplicative** - multiplies current XP/click.
- **Exponential** - raises current XP/click to a power.

Batteries can be purchased once a certain number of total clicks is reached. Purchasing does **not** consume clicks.

### 🎨 Interface Customization *(Unlocked at Threshold 12)*

The Store offers:

- **Skins** for the main button.
- **Backgrounds** for the main game screen.
- **Sound Packs** for in-game sounds.
- **Bundles** combining Skins, Backgrounds and Sound Packs.

Settings include an option to select newly purchased or unlocked customizations.

### 🧭 Expeditions *(Unlocked at Threshold 15)*

A passive resource-gathering system. Send an idle manager (not working or already on an expedition) to a randomly generated location (seeded).

- **You can reroll the seed 3 times per day.**
- **Each location has**: name, colors (for UI), resources to obtain, duration and a critical chance for special rewards.
- **Possible rewards**: points, new robots, new managers and other interesting items.

---

## 🎯 Threshold System

Thresholds are the main progression milestones.

```
1 ── 2 ──[3]── 4 ── 5 ──[6]── 7 ── 8 ──[9]── ... ──[20]
          ▲              ▲              ▲              ▲
        MAJOR          MAJOR          MAJOR          MAJOR
       (unlock         (unlock        (unlock      (prestige
       Robots)        Managers)     Batteries)      unlock)
```

- **Major Thresholds** - every 3rd milestone (3, 6, 9, 12, 15, 18, 20) => unlock new systems
- **Minor Thresholds** - between majors => extra XP, points, special robots/managers/customizations

---

## 🔁 Prestige & Ascension

Prestige (rebirth) unlocks after completing all 20 Thresholds. It resets the game for permanent bonuses.

- Each Prestige gives 1 Prestige Point (PP), with the amount increasing per reset. PP can be spent in the Store.

**Ascension** unlocks after **5 resets**:
- Each reset grants **1 Ascension Shard** (+1 per subsequent reset)
- Reset cost: starts at `1 No (nonyllion)`, multiplies by ×1000 each reset
- Shards buy permanent upgrades: `+50% global XP`, `-20% in-game prices`, etc.

---

## 🏰 Prestige Game Modes

### Prestige I - The Pi Estate

A separate game mode featuring a 100-floor Tower.

- Works as an independent save file.
- Each floor gives unique rewards for both the global save and the Tower save.
- Completing the Tower resets all floors and rerolls rewards.
- Each floor requires reaching a point threshold within a set time (hours to days).

### Prestige II - Weekend Rushes

An optional weekend event.

- Defeat a Boss by reaching a point target within a time limit.
- Click the main button and extra buttons that grant more points.
- Uses your global progress, but no upgrades are allowed during the fight.
- Lose: lose 1% of your points.
- Win: receive the displayed loot.

### Prestige III - Daily Brawl

Optional daily challenge: reduce a starting point value to zero by clicking. Robots can be used.

- The target value is based on your current progress (button upgrades, owned robots, etc.).
- Reward: a temporary Golden Pi button that gives (current click value)^π until the end of the day.
- Completing several Daily Brawls in a row unlocks upgraded buttons: Diamond Pi, Ruby Pi, Master Pi, Void Pi - each raises the previous button’s value to the power of π.

---

## π Pi Parade

Every day there is a **1-in-24 chance** for the Pi Parade. One of seven special buttons appears:

| Button | Mechanic |
|---|---|
| 🔴 Red | Works like the main button |
| 🩵 Cyan | Starts like main, each click increases its value by 0.1‰ |
| 🟠 Orange | Only 1/3 of clicks register, but each gives 3× normal value |
| 🔵 Blue | Alternate: main -> Blue -> main -> Blue. Each unbroken sequence +1% click value |
| 🟣 Purple | Hold to gain points at ×4 click value |
| 🟢 Green | Both main button and Green button gain +25% click value |
| 🟡 Yellow | Maintain a random CPS target (±5 CPS). Miss 1 min → value halved. Hold 1 min → value tripled |

---

## 🛡️ Click Rate Inspector (CRI)

The CRI discourages auto-clickers, especially during The Pi Estate and Weekend Rushes.
- Disabled by default; auto-activates in competitive modes
- Player sets a CPS limit (default: **10 CPS**)
- Clicks above the limit are silently ignored
- Provides in-game warnings when the limit is exceeded

---

## 🌐 PiClicker Infinite Subscription

> *"Break the finite. Make it infinite."*

**$3.14 / month** - because of course it is !

- Remove ads
- Free or discounted exclusive Store items

Ads appear when rerolling expedition seeds or daily manager offers beyond the free daily limit.

---

## 🚀 Getting Started

```bash
# 1. Clone the repository
git clone https://github.com/yourname/piclicker
cd piclicker

# 2. Install dependencies
flutter pub get

# 3. Start the emulated launch
flutter run
```
[Learn more about Flutter and app debugging](https://docs.flutter.dev/testing/debugging)

---

## 🤝 Contributing

Contributions, bug reports and feature ideas are welcomed. Please open an issue before submitting large PRs.

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

Apache 2.0 © [MidgardCoding]

---

<img width="1057" height="2352" alt="Screenshot_20260418-170500" src="https://github.com/user-attachments/assets/338e68b5-63ac-4e4e-8611-73b5d8010e3f" />
<img width="1075" height="2393" alt="Screenshot_20260418-170511" src="https://github.com/user-attachments/assets/181bc574-716e-4e15-9a1b-767c593241b7" />
<img width="951" height="2118" alt="Screenshot_20260418-170534" src="https://github.com/user-attachments/assets/cc4a5998-968a-453f-9405-4f39a2375af5" />
<img width="1075" height="2393" alt="Screenshot_20260418-170610" src="https://github.com/user-attachments/assets/85a37d63-575c-401d-93b0-ad8f593b6b22" />
<img width="770" height="1714" alt="Screenshot_20260418-170556" src="https://github.com/user-attachments/assets/641877bd-9307-452f-a85a-e879aa585eab" />
<img width="1075" height="2393" alt="Screenshot_20260418-170610" src="https://github.com/user-attachments/assets/580d433b-d878-4e61-be83-d6722e4a3913" />

<div align="center">
<sub>3.14 is life!</sub>
</div>
