# Blueprint-Änderungsvorschlag: Header-Format

## Aktuelles Format (Blockquote)

```markdown
# ModulName.cmake – Dokumentation

> **Version:** 0.1.1 (doc v1)  
> **Datum:** 2025-12-05  
> **Typ:** Modul-Doku  
> **Status:** In Entwicklung (Pre-Release)  
> **Modul:** cmake/core/ModulName.cmake  
> **Modul-Version:** 0.1.1  
> **Basiert auf:** master_concept v0.1, guidelines v0.1
> **Sprache:** Deutsch  
> **English:** [English Version](../../en/Modules/core/ModulName_cmake_v0_1_0.md)
```

## Vorgeschlagenes alternatives Format (Tabelle)

```markdown
# ModulName.cmake – Dokumentation

| Eigenschaft | Wert |
|-------------|------|
| **Version** | 0.1.1 (doc v1) |
| **Datum** | 2025-12-05 |
| **Typ** | Modul-Doku |
| **Status** | In Entwicklung (Pre-Release) |
| **Modul** | `cmake/core/ModulName.cmake` |
| **Modul-Version** | 0.1.1 |
| **Basiert auf** | master_concept v0.1, guidelines v0.1 |
| **Sprache** | Deutsch |
| **English** | [English Version](../../en/Modules/core/ModulName_cmake_v0_1_0.md) |
```

---

## Vergleich

| Aspekt | Blockquote | Tabelle |
|--------|------------|---------|
| Lesbarkeit Markdown-Source | ✅ Gut | ✅ Gut |
| Lesbarkeit Rendered | ⚠️ Fließtext | ✅ Strukturiert |
| Visueller Scan | ⚠️ Schwieriger | ✅ Einfacher |
| Konsistenz mit Rest | ✅ Aktuell | ⚠️ Neu |
| Copy-Paste-Freundlich | ✅ Kompakter | ⚠️ Mehr Zeilen |

---

## Empfehlung

**Beibehalten: Blockquote-Format**

Gründe:
1. Bereits im Documentation_Blueprint definiert und verwendet
2. Alle bestehenden Dokumentationen nutzen dieses Format
3. Kompakter in der Markdown-Source
4. Keine Migration bestehender Dokumente nötig

**Alternative: Beide Formate erlauben**

Wenn Tabellen-Header gewünscht sind, könnte der Blueprint beide Formate als gleichwertig definieren. Dies wäre jedoch eine Konsistenz-Ausnahme.

---

## Entscheidung benötigt

- [ ] Blockquote beibehalten (keine Änderung)
- [ ] Tabelle als Alternative erlauben
- [ ] Tabelle als neuen Standard definieren (Migration nötig)
