# MinimalWindow – Benutzerhandbuch

> **Version:** 0.1.1  
> **Datum:** 2025-12-09  
> **Typ:** Benutzer-Doku  
> **Status:** In Entwicklung

---

## 1. Einführung

`MinimalWindow` ist eine kleine grafische Win32-Demo, die:
- ein Fenster mit Menü erstellt,
- eine eigene Logging-Konsole öffnet,
- Menüaktionen live protokolliert,
- einen "About"-Dialog anzeigt.

Ideal für Tests von WinAPI-Fensterlebenszyklen und Logger‑Integration.

---

## 2. Start / Ausführung

### Voraussetzungen
- Betriebssystem: **Windows**
- Keine zusätzlichen DLLs erforderlich

### Start
Im Explorer Doppelklicken oder über Konsole starten:
```
MinimalWindow.exe
```
Beim Start öffnet sich **zusätzlich eine Konsole** mit Logausgaben.

---

## 3. Bedienung

### Menüstruktur

| Menü | Aktion | Ergebnis |
|------|--------|----------|
| File | Exit | Fenster schließen |
| Action | Action One | Logeintrag "Action One" |
| Action | Action Two | Logeintrag "Action Two" |
| Help | About | Infodialog + Logeintrag |

### About Dialog
Kleines Popup-Fenster mit Titel und Text.

---

## 4. Logging
- Konsole wird automatisch erzeugt
- UTF‑8 fähige Ausgabe
- Alle Menüaktionen werden protokolliert

Optional:
```cpp
BasicLogger::setLogFile("MinimalWindow.log");
```
→ schreibt Logdatei parallel

---

## 5. Troubleshooting

| Problem | Ursache | Lösung |
|--------|--------|--------|
| Fenster startet nicht | RegisterClassW fehlgeschlagen | Logs prüfen |
| Nichts passiert bei Menü | ID nicht ausgewertet | Check WindowProc |
| Konsole zeigt Sonderzeichen falsch | CP nicht auf UTF‑8 | SetConsoleOutputCP prüfen |

---

## 6. Kurzreferenz

| Bereich | Info |
|--------|------|
| Plattform | Windows |
| Technik | WinAPI + BasicLogger |
| GUI | Menü + MessageBox |
| Logging | eigene Konsole |
| Beenden | File → Exit |

---

## 7. Changelog
| Version | Änderungen |
|--------|------------|
| 0.1.1 | Benutzerhandbuch erstellt |

