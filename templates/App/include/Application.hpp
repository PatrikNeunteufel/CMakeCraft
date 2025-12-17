/**
 ****************************************************************************************
 * @file   Application.hpp
 * @brief  Application Interface
 *         CMake Architecture V2 - App-Container Template
 *
 * @author Patrik Neunteufel
 * @date   $MONTHNAME_EN $YEAR
  ****************************************************************************************
 */
// =============================================================================
// Application 
// CMake Architecture V2 - App-Container Template
// =============================================================================
//
// Diese Klasse ist der zentrale Einstiegspunkt für die Anwendungslogik.
// Sie wird vom generischen main.cpp instanziiert und gesteuert.
//
// Für GUI-Anwendungen (Qt):
//   - init(): QApplication erstellen, MainWindow aufbauen
//   - run():  QApplication::exec()
//   - shutdown(): Cleanup
//
// Für Console-Anwendungen:
//   - init(): Konfiguration laden, Services starten
//   - run():  Hauptlogik oder Event-Loop
//   - shutdown(): Cleanup
//
// =============================================================================

#pragma once

#include <memory>
#include <string>
#include <vector>

// Forward Declarations (projektspezifisch erweitern)
// class QApplication;
// class MainWindow;

class Application {
public:
    Application();
    ~Application();
    
    // Nicht kopierbar, nicht verschiebbar (Singleton-artig)
    Application(const Application&) = delete;
    Application& operator=(const Application&) = delete;
    Application(Application&&) = delete;
    Application& operator=(Application&&) = delete;
    
    // =========================================================================
    // Lifecycle
    // =========================================================================
    
    /// Initialisiert die Anwendung
    /// @param argc Anzahl der Kommandozeilenargumente
    /// @param argv Kommandozeilenargumente
    /// @return true bei Erfolg, false bei Fehler
    [[nodiscard]] bool init(int argc, char* argv[]);
    
    /// Startet die Hauptschleife
    /// @return Exit-Code (0 = Erfolg)
    [[nodiscard]] int run();
    
    /// Beendet die Anwendung und gibt Ressourcen frei
    void shutdown();
    
    // =========================================================================
    // Accessors
    // =========================================================================
    
    /// @return Anwendungsname
    [[nodiscard]] const std::string& name() const noexcept;
    
    /// @return Anwendungsversion
    [[nodiscard]] const std::string& version() const noexcept;
    
    /// @return true wenn initialisiert
    [[nodiscard]] bool isInitialized() const noexcept;
    
    /// @return true wenn die Anwendung läuft
    [[nodiscard]] bool isRunning() const noexcept;

private:
    // =========================================================================
    // Private Implementation
    // =========================================================================
    
    struct Impl;
    std::unique_ptr<Impl> m_impl;
    
    bool m_initialized{false};
    bool m_running{false};
};
