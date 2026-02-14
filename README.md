# BindWorks - Blood Pressure PoC

## Info
 - Project uses `fvm` for flutter version management and was developed on Flutter 3.38.8

 ## Funkcni Pozadavky
**Konektivita: Aplikace vyhledá, spáruje a načte data z BLE zařízení.**
- Aplikace nacte vsechny dostupne BLE zarizeni ktere podporuji Blood Pressure service
- Po vybrani zvoleneho zarizeni se aplikace pripoji a pote se jiz automaticky pripojuje k tomuto zarizeni a sbira data

**Background Sync: Navrhněte řešení pro automatický sběr dat bez nutnosti interakce uživatele**
- viz predchozi odpoved

**Otázka k řešení: Jak zajistíte přenos dat, když aplikace není otevřená na popředí? Jak se liší chování na iOS a Androidu?**
- Podle https://pub.dev/packages/flutter_blue_plus#using-ble-in-app-background - android jsem nemel sanci a cas otestovat, ale je k nemu nejspis potreba `FlutterBackgroundService` nebo neco podobneho

**Offline-First: Data se musí uložit lokálně a synchronizovat až ve chvíli, kdy je dostupná síť.**
- Pokud aplikace dostane data a je pripojena k internetu okamzite nahrava, jinak uklada lokalne a po pripojeni k internetu je uploaduje (neaktualizuje se UI ale log jede)

**API: Odesílání dat na "virtuální server". Stačí mockovat**
- mocked pomoci `Flogger` - TalkerFlutter knihovna

## AI
Copilot s Gemini 3 pro a GPT-5.2-Codex

## Hodiny
- 2h boj s BLE nez jsem sehnal android
- ~6-7h vyvoj (cele jsem to prepisoval a dosel mi cas)

