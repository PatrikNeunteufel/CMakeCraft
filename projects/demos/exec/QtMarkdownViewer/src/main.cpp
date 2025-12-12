#include <QApplication>
#include <QMainWindow>
#include <QTextBrowser>
#include <QFileDialog>
#include <QDesktopServices>
#include <QUrl>
#include <QVBoxLayout>
#include <QToolBar>
#include <QAction>
#include <QFileInfo>
#include <QDir>
#include <QWheelEvent>
#include <QShortcut>
#include <QStyle>
#include <QActionGroup>
#include <QMenuBar>
#include <QScrollBar>
#include <QTimer>

// ============================================================================
// MarkdownTextBrowser – QTextBrowser + Zoom per Ctrl+Wheel + Zoom-Reset
// ============================================================================
class MarkdownTextBrowser : public QTextBrowser {
    Q_OBJECT
public:
    explicit MarkdownTextBrowser(QWidget* parent = nullptr)
        : QTextBrowser(parent)
        , m_zoomSteps(0)
    {
        // Damit Ctrl+Z/Ctrl+Y NICHT vom TextBrowser als Undo/Redo abgefangen wird.
        // (Viewer braucht sowieso kein Undo.)
        setUndoRedoEnabled(false);
    }

public slots:
    void resetZoom() {
        if (m_zoomSteps > 0) {
            for (int i = 0; i < m_zoomSteps; ++i)
                zoomOut(1);
        }
        else if (m_zoomSteps < 0) {
            for (int i = 0; i < -m_zoomSteps; ++i)
                zoomIn(1);
        }
        m_zoomSteps = 0;
    }

protected:
    void wheelEvent(QWheelEvent* event) override {
        // Ctrl + Mausrad → Zoom
        if (event->modifiers() & Qt::ControlModifier) {
            const int steps = event->angleDelta().y() / 120;
            if (steps > 0) {
                for (int i = 0; i < steps; ++i)
                    zoomIn(1);
            }
            else if (steps < 0) {
                for (int i = 0; i < -steps; ++i)
                    zoomOut(1);
            }
            m_zoomSteps += steps;
            event->accept();
            return;
        }

        QTextBrowser::wheelEvent(event);
    }

private:
    int m_zoomSteps;
};

// ============================================================================
// MarkdownViewerWindow – MainWindow
// ============================================================================
class MarkdownViewerWindow : public QMainWindow {
    Q_OBJECT

public:
    enum class ThemeMode {
        System,
        Light,
        Dark
    };

public:
    explicit MarkdownViewerWindow(const QString& initialFile = QString(),
        QWidget* parent = nullptr)
        : QMainWindow(parent)
        , m_themeMode(ThemeMode::System)
        , m_systemPalette(qApp->palette())
    {
        setWindowTitle("Markdown Viewer (Qt)");

        // ------------------------------
        // Viewer
        // ------------------------------
        m_textBrowser = new MarkdownTextBrowser(this);
        m_textBrowser->setOpenLinks(false);
        m_textBrowser->setOpenExternalLinks(false);

        connect(m_textBrowser, &QTextBrowser::anchorClicked,
            this, &MarkdownViewerWindow::onAnchorClicked);

        auto* central = new QWidget(this);
        auto* layout = new QVBoxLayout(central);
        layout->setContentsMargins(0, 0, 0, 0);
        layout->addWidget(m_textBrowser);
        setCentralWidget(central);

        // ------------------------------
        // Toolbar (Icons)
        // ------------------------------
        m_toolbar = addToolBar("Navigation");
        m_toolbar->setMovable(false);
        m_toolbar->setToolButtonStyle(Qt::ToolButtonIconOnly);

        m_actBack = m_toolbar->addAction(style()->standardIcon(QStyle::SP_ArrowBack), "Zurück");
        m_actForward = m_toolbar->addAction(style()->standardIcon(QStyle::SP_ArrowForward), "Vorwärts");
        m_toolbar->addSeparator();

        m_actReload = m_toolbar->addAction(style()->standardIcon(QStyle::SP_BrowserReload), "Neu laden");
        m_actOpen = m_toolbar->addAction(style()->standardIcon(QStyle::SP_DialogOpenButton), "Öffnen");
        m_toolbar->addSeparator();

        m_actZoomReset = m_toolbar->addAction(style()->standardIcon(QStyle::SP_BrowserStop), "Reset Zoom");
        m_toolbar->addSeparator();

        m_actThemeMenu = m_toolbar->addAction(style()->standardIcon(QStyle::SP_TitleBarMenuButton), "Theme");

        // ------------------------------
        // Connect Actions
        // ------------------------------
        connect(m_actBack, &QAction::triggered, this, &MarkdownViewerWindow::goBack);
        connect(m_actForward, &QAction::triggered, this, &MarkdownViewerWindow::goForward);
        connect(m_actOpen, &QAction::triggered, this, &MarkdownViewerWindow::openFileDialog);
        connect(m_actReload, &QAction::triggered, this, &MarkdownViewerWindow::reloadFileFresh);
        connect(m_actZoomReset, &QAction::triggered, this, &MarkdownViewerWindow::resetZoom);
        connect(m_actThemeMenu, &QAction::triggered, this, &MarkdownViewerWindow::showThemeMenu);

        // History Buttons enabled/disabled
        connect(m_textBrowser, &QTextBrowser::backwardAvailable,
            m_actBack, &QAction::setEnabled);
        connect(m_textBrowser, &QTextBrowser::forwardAvailable,
            m_actForward, &QAction::setEnabled);

        m_actBack->setEnabled(false);
        m_actForward->setEnabled(false);

        // ------------------------------
        // Menü (Theme)
        // ------------------------------
        buildMenus();

        // ------------------------------
        // Global Shortcuts (funktionieren auch wenn Fokus im TextBrowser ist)
        // ------------------------------
        installGlobalShortcuts();

        // ------------------------------
        // Startdatei laden
        // ------------------------------
        if (!initialFile.isEmpty())
            loadMarkdownFile(initialFile);

        applyTheme(ThemeMode::System);
    }

public slots:
    void openFileDialog() {
        const QString file = QFileDialog::getOpenFileName(
            this,
            "Markdown öffnen",
            m_currentDir.isEmpty() ? QDir::currentPath() : m_currentDir,
            "Markdown (*.md *.markdown);;Alle Dateien (*.*)");

        if (!file.isEmpty())
            loadMarkdownFile(file);
    }

    void goBack() {
        if (m_textBrowser->isBackwardAvailable())
            m_textBrowser->backward();
    }

    void goForward() {
        if (m_textBrowser->isForwardAvailable())
            m_textBrowser->forward();
    }

    void resetZoom() {
        if (m_textBrowser)
            m_textBrowser->resetZoom();
    }

    // “Echt” neu laden: Quelle neu einlesen (und Scrollposition best-effort behalten)
    void reloadFileFresh() {
        if (m_currentFile.isEmpty())
            return;

        // Scrollposition merken
        const int scrollValue = m_textBrowser->verticalScrollBar()->value();

        // QTextBrowser::reload() lädt die aktuelle Source erneut.
        // Das ist besser als setSource(...) mit gleicher URL.
        m_textBrowser->reload();

        // Best-effort: Scroll nach dem Neuaufbau wieder setzen
        QTimer::singleShot(0, this, [this, scrollValue]() {
            if (m_textBrowser && m_textBrowser->verticalScrollBar())
                m_textBrowser->verticalScrollBar()->setValue(scrollValue);
            });
    }

    void onAnchorClicked(const QUrl& url) {
        QUrl resolved = url;

        // Relative Links → auf aktuellen Pfad beziehen
        if (resolved.isRelative())
            resolved = QUrl::fromLocalFile(m_currentDir + "/" + url.toString());

        // Lokale Markdown-Dateien
        if (resolved.isLocalFile()) {
            const QString path = resolved.toLocalFile();
            const QString fragment = resolved.fragment();

            QFileInfo fi(path);
            const QString ext = fi.suffix().toLower();

            if (ext == "md" || ext == "markdown") {
                loadMarkdownFile(path, fragment);
                return;
            }
        }

        // Externe Links
        if (resolved.scheme() == "http" || resolved.scheme() == "https") {
            QDesktopServices::openUrl(resolved);
            return;
        }

        // Anker oder interne Navigation
        m_textBrowser->setSource(resolved);
    }

    // Theme actions
    void setThemeSystem() { applyTheme(ThemeMode::System); }
    void setThemeLight() { applyTheme(ThemeMode::Light); }
    void setThemeDark() { applyTheme(ThemeMode::Dark); }

private:
    void loadMarkdownFile(const QString& filePath, const QString& fragment = QString()) {
        QFileInfo fi(filePath);
        if (!fi.exists() || !fi.isFile())
            return;

        m_currentFile = fi.absoluteFilePath();
        m_currentDir = fi.absolutePath();

        QUrl url = QUrl::fromLocalFile(m_currentFile);
        if (!fragment.isEmpty())
            url.setFragment(fragment);

        m_textBrowser->setSource(url);
        setWindowTitle(QString("Markdown Viewer - %1").arg(fi.fileName()));
    }

    void installGlobalShortcuts() {
        auto makeGlobalShortcut = [this](const QKeySequence& seq, const char* slot) {
            auto* sc = new QShortcut(seq, this);
            sc->setContext(Qt::ApplicationShortcut); // wichtig!
            connect(sc, SIGNAL(activated()), this, slot);
            return sc;
            };

        // Ctrl+Z / Ctrl+Y als Navigation (Undo ist im TextBrowser deaktiviert)
        makeGlobalShortcut(QKeySequence(Qt::CTRL | Qt::Key_Z), SLOT(goBack()));
        makeGlobalShortcut(QKeySequence(Qt::CTRL | Qt::Key_Y), SLOT(goForward()));

        // Ctrl+0 Zoom Reset
        makeGlobalShortcut(QKeySequence(Qt::CTRL | Qt::Key_0), SLOT(resetZoom()));

        // Optional: Browser-typisch Alt+Left/Right (praktisch)
        makeGlobalShortcut(QKeySequence(Qt::ALT | Qt::Key_Left), SLOT(goBack()));
        makeGlobalShortcut(QKeySequence(Qt::ALT | Qt::Key_Right), SLOT(goForward()));

        // Optional: Ctrl+R neu laden (praktisch)
        makeGlobalShortcut(QKeySequence(Qt::CTRL | Qt::Key_R), SLOT(reloadFileFresh()));
    }

    void buildMenus() {
        // Menüleiste
        auto* menuFile = menuBar()->addMenu("&File");
        menuFile->addAction(m_actOpen);
        menuFile->addAction(m_actReload);

        auto* menuView = menuBar()->addMenu("&View");
        menuView->addAction(m_actBack);
        menuView->addAction(m_actForward);
        menuView->addSeparator();
        menuView->addAction(m_actZoomReset);

        auto* menuTheme = menuBar()->addMenu("&Theme");

        m_themeGroup = new QActionGroup(this);
        m_themeGroup->setExclusive(true);

        m_actThemeSystem = menuTheme->addAction("System");
        m_actThemeSystem->setCheckable(true);
        m_actThemeLight = menuTheme->addAction("Light");
        m_actThemeLight->setCheckable(true);
        m_actThemeDark = menuTheme->addAction("Dark");
        m_actThemeDark->setCheckable(true);

        m_themeGroup->addAction(m_actThemeSystem);
        m_themeGroup->addAction(m_actThemeLight);
        m_themeGroup->addAction(m_actThemeDark);

        m_actThemeSystem->setChecked(true);

        connect(m_actThemeSystem, &QAction::triggered, this, &MarkdownViewerWindow::setThemeSystem);
        connect(m_actThemeLight, &QAction::triggered, this, &MarkdownViewerWindow::setThemeLight);
        connect(m_actThemeDark, &QAction::triggered, this, &MarkdownViewerWindow::setThemeDark);
    }

    void showThemeMenu() {
        if (!menuBar())
            return;

        // Wir nutzen einfach das "Theme"-Menü aus der Menüleiste.
        // Popup an Mausposition anzeigen:
        for (auto* a : menuBar()->actions()) {
            if (a && a->text().contains("Theme")) {
                if (a->menu()) {
                    a->menu()->popup(QCursor::pos());
                }
                break;
            }
        }
    }

    void applyTheme(ThemeMode mode) {
        m_themeMode = mode;

        if (mode == ThemeMode::System) {
            qApp->setPalette(m_systemPalette);
            if (m_actThemeSystem) m_actThemeSystem->setChecked(true);
            return;
        }

        if (mode == ThemeMode::Light) {
            // Qt-Standardpalette (hell)
            QPalette pal = qApp->style()->standardPalette();
            qApp->setPalette(pal);
            if (m_actThemeLight) m_actThemeLight->setChecked(true);
            return;
        }

        // Dark palette (simple & effective)
        QPalette dark;
        dark.setColor(QPalette::Window, QColor(30, 30, 30));
        dark.setColor(QPalette::WindowText, Qt::white);
        dark.setColor(QPalette::Base, QColor(20, 20, 20));
        dark.setColor(QPalette::AlternateBase, QColor(30, 30, 30));
        dark.setColor(QPalette::ToolTipBase, Qt::white);
        dark.setColor(QPalette::ToolTipText, Qt::white);
        dark.setColor(QPalette::Text, Qt::white);
        dark.setColor(QPalette::Button, QColor(45, 45, 45));
        dark.setColor(QPalette::ButtonText, Qt::white);
        dark.setColor(QPalette::BrightText, Qt::red);
        dark.setColor(QPalette::Link, QColor(80, 160, 255));
        dark.setColor(QPalette::Highlight, QColor(60, 120, 200));
        dark.setColor(QPalette::HighlightedText, Qt::white);

        qApp->setPalette(dark);
        if (m_actThemeDark) m_actThemeDark->setChecked(true);
    }

private:
    MarkdownTextBrowser* m_textBrowser = nullptr;

    QString m_currentFile;
    QString m_currentDir;

    QToolBar* m_toolbar = nullptr;

    QAction* m_actBack = nullptr;
    QAction* m_actForward = nullptr;
    QAction* m_actReload = nullptr;
    QAction* m_actOpen = nullptr;
    QAction* m_actZoomReset = nullptr;

    QAction* m_actThemeMenu = nullptr;

    QActionGroup* m_themeGroup = nullptr;
    QAction* m_actThemeSystem = nullptr;
    QAction* m_actThemeLight = nullptr;
    QAction* m_actThemeDark = nullptr;

    ThemeMode m_themeMode;
    QPalette  m_systemPalette;
};

// ============================================================================
// main()
// ============================================================================
int main(int argc, char* argv[])
{
    QApplication app(argc, argv);

    QString initialFile;
    if (argc > 1)
        initialFile = QString::fromLocal8Bit(argv[1]);

    MarkdownViewerWindow win(initialFile);
    win.resize(1000, 700);
    win.show();

    return app.exec();
}

#include "main.moc"
