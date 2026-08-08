# Sicherheitsrichtlinie

## Unterstützte Versionen

Sicherheitsrelevante Korrekturen fließen in den `master`-Branch und werden mit
dem nächsten Tag veröffentlicht. Ältere Tags werden nicht rückwirkend gepflegt —
Projekte ziehen ihren `cmakecraft.pin` hoch.

| Stand | Unterstützt |
|---|---|
| `master` und der jeweils neueste Tag | ✅ ja |
| ältere Tags | ❌ nein — bitte Pin hochziehen |

## Schwachstelle melden

**Bitte kein öffentliches Issue eröffnen.** Melde die Schwachstelle privat:

📧 **patrik.neunteufel@gmail.com**

Nützlich sind:

- eine Beschreibung der Schwachstelle
- Schritte zum Nachvollziehen — gern mit einer minimalen `Solution.json`, die
  das Verhalten auslöst
- die mögliche Auswirkung
- deine Kontaktdaten, falls du genannt werden oder eine Rückmeldung willst

Ich bestätige den Eingang innerhalb weniger Tage. Das ist ein Freizeitprojekt
eines Einzelnen — feste Reaktionszeiten kann ich nicht zusagen, aber ich melde
mich.

## Das Angriffsmodell: Code, der beim Konfigurieren läuft

Ein Build-System ist keine Anwendung mit Ein- und Ausgaben. Es ist **Code, der
auf dem Rechner des Entwicklers ausgeführt wird** — mit dessen Rechten, meist
ohne dass jemand hinschaut. Das ist die Stelle, an der sicherheitsrelevante
Fehler sitzen.

Konkret führt CMakeCraft beim `cmake --preset …` aus:

- **CMake-Script-Code** aus `cmake/**` dieses Repositorys
- **`git clone`** auf URLs, die in der `Solution.json` des Projekts stehen
- **fremden CMake-Code**: geholte Externals werden über `FetchContent` verfügbar
  gemacht — ihre eigene `CMakeLists.txt` wird ausgewertet und ausgeführt
- **Hooks** aus `cmake/externals/hooks/` — sie stammen aus CMakeCraft selbst,
  nicht aus dem konsumierenden Projekt

### Was ein Befund ist

- **Ausbruch aus der JSON-Auswertung.** Ein Feldwert in `Solution.json`, der
  dazu führt, dass CMakeCraft daraus ausführbaren CMake-Code macht oder einen
  Befehl mit unbeabsichtigten Argumenten aufruft — CMake-Variablenexpansion in
  Werten, die als Daten gemeint sind, Semikolon-Injektion in Listen,
  Argument-Schmuggel in `execute_process`.
- **Pfad-Ausbruch.** Ein `path`, `include`, `hook` oder Target-Name, der
  Schreib- oder Lesezugriffe außerhalb des Projekt- und Cache-Verzeichnisses
  bewirkt (`../`, absolute Pfade, symbolische Verknüpfungen).
- **Cache-Vergiftung.** Ein Weg, Inhalte in `.externals/` unter dem Namen einer
  Version zu platzieren, die eine andere Version bezeichnet — oder eine
  Prüfung, die vorhandenen Cache akzeptiert, ohne dass er zur gepinnten Version
  passt.
- **Schwächen im Bootstrap.** `CMakeCraftBootstrap.cmake` entscheidet, welcher
  Code als Build-System geladen wird. Alles, was diese Entscheidung von außen
  beeinflussbar macht, ist ein Befund.

### Bekannte Einschränkung: Git-Tags sind veränderlich

Der Bezugsmechanismus pinnt auf einen **Git-Tag**. Tags lassen sich
verschieben — wer das Upstream-Repository kontrolliert, kann unter demselben
Namen anderen Inhalt ausliefern. Signaturen werden nicht geprüft.

Das ist eine bewusste Abwägung zugunsten lesbarer Versionen, keine übersehene
Lücke. Wer strenger pinnen will, trägt in `cmakecraft.pin` statt des Tags einen
**Commit-Hash** ein; einmal geholt, ist der Cache in `.externals/` ohnehin
maßgeblich und wird nicht erneut geladen. Dieselbe Überlegung gilt für die
Git-Externals in der eigenen `Solution.json`.

Meldungen, die diesen Mechanismus **konkret verbessern**, sind willkommen.

## Was nicht in den Rahmen fällt

- **Schwachstellen in geholten Fremdprojekten** (GLFW, Dear ImGui, GoogleTest,
  Catch2, Qt, BASS) — bitte direkt beim jeweiligen Projekt melden.
- **„Fremder CMake-Code wird ausgeführt".** Das ist die Funktionsweise von
  `FetchContent` und von CMake insgesamt: Wer eine Abhängigkeit in seine
  `Solution.json` schreibt, entscheidet sich dafür, deren Build-Code
  auszuführen. Behandle fremde Abhängigkeiten mit derselben Vorsicht wie jedes
  andere Stück fremden Codes.
- **Eine bösartige `Solution.json` im eigenen Projekt.** Wer die Solution
  schreibt, hat ohnehin die Kontrolle über den Build. Interessant wird es erst,
  wenn eine *fremde* Solution — etwa aus einem geklonten Beispielprojekt —
  mehr bewirkt, als ihre Felder nahelegen. Genau das ist dann ein Befund.
- Fehlermeldungen, die interne Pfade preisgeben.
- Funktionswünsche und Fragen zur Bedienung.

## Grundsätzliche Einordnung

CMakeCraft ist ein Entwicklerwerkzeug ohne Netzwerkdienst und ohne
Rechteausweitung. Der realistische Angriffsweg ist ein **fremdes Projekt, das
man klont und konfiguriert** — dabei läuft Code. Das gilt für jedes
CMake-Projekt und ist nicht auf CMakeCraft beschränkt; ein `cmake --preset` auf
einem unbekannten Repository ist so vertrauensvoll wie das Ausführen eines
Skripts daraus.
