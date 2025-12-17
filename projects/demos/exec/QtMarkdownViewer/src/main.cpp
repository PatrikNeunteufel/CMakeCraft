#include <QApplication>
#include <QMainWindow>
#include <QTextBrowser>
#include <QFileDialog>
#include <QDesktopServices>
#include <QUrl>
#include <QVBoxLayout>
#include <QHBoxLayout>
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
#include <QStatusBar>
#include <QLabel>
#include <QToolButton>
#include <QMenu>
#include <QSettings>
#include <QCloseEvent>
#include <QPainter>
#include <QCheckBox>
#include <QLineEdit>
#include <QRegularExpression>
#include <QTextBlock>
#include <cmath>

// ============================================================================
// Icon helpers (no external resources required)
// ============================================================================
static QIcon createMoonIcon(int sizePx = 16) {
    QPixmap pm(sizePx, sizePx);
    pm.fill(Qt::transparent);

    QPainter p(&pm);
    p.setRenderHint(QPainter::Antialiasing, true);

    QColor fg(230, 230, 230);
    p.setBrush(fg);
    p.setPen(Qt::NoPen);
    p.drawEllipse(1, 1, sizePx - 2, sizePx - 2);

    p.setCompositionMode(QPainter::CompositionMode_Clear);
    p.drawEllipse(sizePx / 3, 1, sizePx - 2, sizePx - 2);

    return QIcon(pm);
}

static QIcon createSunIcon(int sizePx = 16) {
    QPixmap pm(sizePx, sizePx);
    pm.fill(Qt::transparent);

    QPainter p(&pm);
    p.setRenderHint(QPainter::Antialiasing, true);

    QColor fg(255, 215, 0);
    p.setBrush(fg);
    p.setPen(Qt::NoPen);

    const int cx = sizePx / 2;
    const int cy = sizePx / 2;
    const int coreR = sizePx / 4;

    p.drawEllipse(cx - coreR, cy - coreR, coreR * 2, coreR * 2);

    p.setPen(QPen(fg, 2));
    const double rayR1 = sizePx * 0.32;
    const double rayR2 = sizePx * 0.48;

    for (int i = 0; i < 8; ++i) {
        const double a = (2.0 * M_PI) * (double(i) / 8.0);
        const int x1 = cx + int(std::cos(a) * rayR1);
        const int y1 = cy + int(std::sin(a) * rayR1);
        const int x2 = cx + int(std::cos(a) * rayR2);
        const int y2 = cy + int(std::sin(a) * rayR2);
        p.drawLine(x1, y1, x2, y2);
    }

    return QIcon(pm);
}

// ============================================================================
// MarkdownTextBrowser: QTextBrowser + Zoom + robust anchor navigation
// ============================================================================
class MarkdownTextBrowser : public QTextBrowser {
    Q_OBJECT
public:
    explicit MarkdownTextBrowser(QWidget* parent = nullptr)
        : QTextBrowser(parent)
        , m_zoomSteps(0)
    {
        setUndoRedoEnabled(false);
        setOpenLinks(false);
        setOpenExternalLinks(false);
    }

    int zoomSteps() const { return m_zoomSteps; }

    // Navigate to anchor by searching for the heading text
    bool navigateToAnchor(const QString& anchor) {
        if (anchor.isEmpty())
            return false;
        
        // Convert anchor back to search pattern
        // e.g. "1-uebersicht" -> search for "1. " at start of line
        
        // Extract leading number if present
        QRegularExpression numRx("^(\\d+)-");
        QRegularExpressionMatch numMatch = numRx.match(anchor);
        
        QString searchText;
        if (numMatch.hasMatch()) {
            // Numbered heading: search for "N. " (e.g., "1. ", "2. ")
            searchText = numMatch.captured(1) + ". ";
        } else {
            // Non-numbered: convert anchor to approximate text
            searchText = anchor;
            searchText.replace("-", " ");
        }
        
        // Search through document blocks for heading
        QTextDocument* doc = document();
        if (!doc)
            return false;
        
        QTextBlock block = doc->begin();
        while (block.isValid()) {
            QString text = block.text().trimmed();
            
            // Check if this block starts with our search text
            if (text.startsWith(searchText, Qt::CaseInsensitive)) {
                // Found it! Scroll to this block
                QTextCursor cursor(block);
                setTextCursor(cursor);
                
                // Ensure it's visible near the top
                ensureCursorVisible();
                
                // Additional scroll adjustment to put heading at top
                QScrollBar* vbar = verticalScrollBar();
                if (vbar) {
                    QRect rect = cursorRect(cursor);
                    int offset = rect.top() - 20; // 20px from top
                    if (offset > 0) {
                        vbar->setValue(vbar->value() + offset);
                    }
                }
                
                return true;
            }
            
            block = block.next();
        }
        
        // Fallback: try Qt's built-in scrollToAnchor
        scrollToAnchor(anchor);
        return false;
    }

public slots:
    void resetZoom() {
        if (m_zoomSteps > 0) {
            for (int i = 0; i < m_zoomSteps; ++i) zoomOut(1);
        }
        else if (m_zoomSteps < 0) {
            for (int i = 0; i < -m_zoomSteps; ++i) zoomIn(1);
        }
        m_zoomSteps = 0;
        emit zoomPercentChanged(zoomPercent());
    }

    void setZoomSteps(int steps) {
        if (steps == m_zoomSteps) {
            emit zoomPercentChanged(zoomPercent());
            return;
        }

        resetZoom();

        if (steps > 0) {
            for (int i = 0; i < steps; ++i) zoomIn(1);
        }
        else if (steps < 0) {
            for (int i = 0; i < -steps; ++i) zoomOut(1);
        }

        m_zoomSteps = steps;
        emit zoomPercentChanged(zoomPercent());
    }

signals:
    void zoomPercentChanged(int percent);

protected:
    void wheelEvent(QWheelEvent* event) override {
        if (event->modifiers() & Qt::ControlModifier) {
            const int steps = event->angleDelta().y() / 120;

            if (steps > 0) {
                for (int i = 0; i < steps; ++i) zoomIn(1);
            }
            else if (steps < 0) {
                for (int i = 0; i < -steps; ++i) zoomOut(1);
            }

            m_zoomSteps += steps;
            emit zoomPercentChanged(zoomPercent());
            event->accept();
            return;
        }

        QTextBrowser::wheelEvent(event);
    }

private:
    int zoomPercent() const {
        const double factor = std::pow(1.10, double(m_zoomSteps));
        return int(std::round(factor * 100.0));
    }

private:
    int m_zoomSteps;
};

// ============================================================================
// Main Window
// ============================================================================
class MarkdownViewerWindow : public QMainWindow {
    Q_OBJECT

public:
    enum class ThemeMode {
        System = 0,
        Light = 1,
        Dark = 2
    };

public:
    explicit MarkdownViewerWindow(const QString& initialFile = QString(),
        QWidget* parent = nullptr)
        : QMainWindow(parent)
        , m_settings("PatrikNeunteufel", "QtMarkdownViewer")
        , m_themeMode(ThemeMode::System)
        , m_systemPalette(qApp->palette())
        , m_systemStyleName(qApp->style()->objectName())
    {
        setWindowTitle("Markdown Viewer (Qt)");

        // ------------------------------
        // Viewer
        // ------------------------------
        m_textBrowser = new MarkdownTextBrowser(this);

        connect(m_textBrowser, &QTextBrowser::anchorClicked,
            this, &MarkdownViewerWindow::onAnchorClicked);

        // ------------------------------
        // Find bar
        // ------------------------------
        buildFindBar();

        // ------------------------------
        // Central layout
        // ------------------------------
        auto* contentWidget = new QWidget(this);
        auto* contentLayout = new QVBoxLayout(contentWidget);
        contentLayout->setContentsMargins(0, 0, 0, 0);
        contentLayout->setSpacing(0);
        contentLayout->addWidget(m_findBar);
        contentLayout->addWidget(m_textBrowser);
        setCentralWidget(contentWidget);

        // ------------------------------
        // Statusbar
        // ------------------------------
        m_zoomLabel = new QLabel(this);
        m_zoomLabel->setText("100%");
        statusBar()->addPermanentWidget(m_zoomLabel);

        connect(m_textBrowser, &MarkdownTextBrowser::zoomPercentChanged,
            this, &MarkdownViewerWindow::onZoomPercentChanged);

        // ------------------------------
        // Toolbar (icons)
        // ------------------------------
        m_toolbar = addToolBar("Navigation");
        m_toolbar->setMovable(false);
        m_toolbar->setToolButtonStyle(Qt::ToolButtonIconOnly);

        m_actBack = m_toolbar->addAction(style()->standardIcon(QStyle::SP_ArrowBack), "Back");
        m_actForward = m_toolbar->addAction(style()->standardIcon(QStyle::SP_ArrowForward), "Forward");
        m_toolbar->addSeparator();

        m_actReload = m_toolbar->addAction(style()->standardIcon(QStyle::SP_BrowserReload), "Reload");
        m_actOpen = m_toolbar->addAction(style()->standardIcon(QStyle::SP_DialogOpenButton), "Open");
        m_toolbar->addSeparator();

        m_actFind = m_toolbar->addAction(style()->standardIcon(QStyle::SP_FileDialogContentsView), "Find");
        m_toolbar->addSeparator();

        m_actZoomReset = m_toolbar->addAction(style()->standardIcon(QStyle::SP_BrowserStop), "Reset Zoom");
        m_toolbar->addSeparator();

        // Theme toggle
        buildThemeButton();
        m_toolbar->addWidget(m_themeButton);

        // Connections
        connect(m_actBack, &QAction::triggered, this, &MarkdownViewerWindow::goBack);
        connect(m_actForward, &QAction::triggered, this, &MarkdownViewerWindow::goForward);
        connect(m_actReload, &QAction::triggered, this, &MarkdownViewerWindow::reloadFileFresh);
        connect(m_actOpen, &QAction::triggered, this, &MarkdownViewerWindow::openFileDialog);
        connect(m_actFind, &QAction::triggered, this, &MarkdownViewerWindow::showFindBar);
        connect(m_actZoomReset, &QAction::triggered, this, &MarkdownViewerWindow::resetZoom);

        connect(m_textBrowser, &QTextBrowser::backwardAvailable,
            m_actBack, &QAction::setEnabled);
        connect(m_textBrowser, &QTextBrowser::forwardAvailable,
            m_actForward, &QAction::setEnabled);

        m_actBack->setEnabled(false);
        m_actForward->setEnabled(false);

        // Menus
        buildMenus();

        // Global shortcuts
        installGlobalShortcuts();

        // Restore settings
        restoreSettings();

        // Load file
        if (!initialFile.isEmpty()) {
            loadMarkdownFile(initialFile);
        }
        else {
            const QString lastFile = m_settings.value("lastFile", "").toString();
            if (!lastFile.isEmpty())
                loadMarkdownFile(lastFile);
        }
    }

protected:
    void closeEvent(QCloseEvent* event) override {
        saveSettings();
        QMainWindow::closeEvent(event);
    }

private slots:
    void goBack() {
        if (m_textBrowser->isBackwardAvailable())
            m_textBrowser->backward();
    }

    void goForward() {
        if (m_textBrowser->isForwardAvailable())
            m_textBrowser->forward();
    }

    void openFileDialog() {
        const QString file = QFileDialog::getOpenFileName(
            this,
            "Open Markdown",
            m_currentDir.isEmpty() ? QDir::currentPath() : m_currentDir,
            "Markdown (*.md *.markdown);;All Files (*.*)");

        if (!file.isEmpty())
            loadMarkdownFile(file);
    }

    void reloadFileFresh() {
        if (m_currentFile.isEmpty())
            return;

        const int scrollValue = m_textBrowser->verticalScrollBar()->value();
        m_textBrowser->reload();

        QTimer::singleShot(0, this, [this, scrollValue]() {
            if (m_textBrowser && m_textBrowser->verticalScrollBar())
                m_textBrowser->verticalScrollBar()->setValue(scrollValue);
        });
    }

    void resetZoom() {
        if (m_textBrowser)
            m_textBrowser->resetZoom();
    }

    void onZoomPercentChanged(int percent) {
        if (m_zoomLabel)
            m_zoomLabel->setText(QString("%1%").arg(percent));
    }

    // --- Anchor handling
    void onAnchorClicked(const QUrl& url) {
        QString urlStr = url.toString();
        
        // Internal anchor (fragment only)
        if (urlStr.startsWith('#')) {
            QString anchor = urlStr.mid(1);
            m_textBrowser->navigateToAnchor(anchor);
            return;
        }
        
        // Handle relative URLs
        QUrl resolved = url;
        if (resolved.isRelative()) {
            resolved = QUrl::fromLocalFile(m_currentDir + "/" + url.toString());
        }

        // Local markdown file
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

        // External URL
        if (resolved.scheme() == "http" || resolved.scheme() == "https") {
            QDesktopServices::openUrl(resolved);
            return;
        }

        m_textBrowser->setSource(resolved);
    }

    void showFindBar() {
        if (!m_findBar) return;
        m_findBar->setVisible(true);
        m_findEdit->setFocus();
        m_findEdit->selectAll();
        triggerLiveFind();
    }

    void hideFindBar() {
        if (!m_findBar) return;
        m_findBar->setVisible(false);

        if (m_textBrowser) {
            QTextCursor c = m_textBrowser->textCursor();
            c.clearSelection();
            m_textBrowser->setTextCursor(c);
        }
    }

    void triggerLiveFind() {
        if (m_findTimer)
            m_findTimer->start();
    }

    void doLiveFind() {
        findNext(true, false);
    }

    void findNextForward() { findNext(true, true); }
    void findNextBackward() { findNext(false, true); }

    void toggleLightDark() {
        if (m_themeMode == ThemeMode::Dark)
            applyTheme(ThemeMode::Light);
        else
            applyTheme(ThemeMode::Dark);
    }

private:
    void findNext(bool forward, bool wrap) {
        if (!m_textBrowser || !m_findEdit) return;

        const QString needle = m_findEdit->text();
        if (needle.isEmpty()) return;

        QTextDocument::FindFlags flags;
        if (!forward) flags |= QTextDocument::FindBackward;
        if (m_cbCase && m_cbCase->isChecked()) flags |= QTextDocument::FindCaseSensitively;
        if (m_cbWhole && m_cbWhole->isChecked()) flags |= QTextDocument::FindWholeWords;

        bool found = m_textBrowser->find(needle, flags);

        if (!found && wrap) {
            QTextCursor c = m_textBrowser->textCursor();
            c.movePosition(forward ? QTextCursor::Start : QTextCursor::End);
            m_textBrowser->setTextCursor(c);
            m_textBrowser->find(needle, flags);
        }
    }

    void buildFindBar() {
        m_findBar = new QWidget(this);
        auto* l = new QHBoxLayout(m_findBar);
        l->setContentsMargins(6, 4, 6, 4);
        l->setSpacing(8);

        m_findEdit = new QLineEdit(m_findBar);
        m_findEdit->setPlaceholderText("Find…");
        m_findEdit->setClearButtonEnabled(true);

        m_cbCase = new QCheckBox("Case", m_findBar);
        m_cbWhole = new QCheckBox("Whole", m_findBar);

        m_findCloseBtn = new QToolButton(m_findBar);
        m_findCloseBtn->setText("✕");
        m_findCloseBtn->setToolTip("Close (Esc)");

        l->addWidget(m_findEdit, 1);
        l->addWidget(m_cbCase, 0);
        l->addWidget(m_cbWhole, 0);
        l->addWidget(m_findCloseBtn, 0);

        m_findBar->setVisible(false);

        m_findTimer = new QTimer(this);
        m_findTimer->setSingleShot(true);
        m_findTimer->setInterval(150);
        connect(m_findTimer, &QTimer::timeout, this, &MarkdownViewerWindow::doLiveFind);

        connect(m_findEdit, &QLineEdit::textChanged, this, &MarkdownViewerWindow::triggerLiveFind);
        connect(m_cbCase, &QCheckBox::toggled, this, &MarkdownViewerWindow::triggerLiveFind);
        connect(m_cbWhole, &QCheckBox::toggled, this, &MarkdownViewerWindow::triggerLiveFind);

        connect(m_findEdit, &QLineEdit::returnPressed, this, &MarkdownViewerWindow::findNextForward);

        auto* scPrev = new QShortcut(QKeySequence(Qt::SHIFT | Qt::Key_Return), m_findEdit);
        connect(scPrev, &QShortcut::activated, this, &MarkdownViewerWindow::findNextBackward);

        connect(m_findCloseBtn, &QToolButton::clicked, this, &MarkdownViewerWindow::hideFindBar);
    }

    void buildThemeButton() {
        m_themeButton = new QToolButton(this);
        m_themeButton->setToolButtonStyle(Qt::ToolButtonIconOnly);
        m_themeButton->setPopupMode(QToolButton::MenuButtonPopup);

        m_themeMenu = new QMenu(this);
        m_actThemeSystem = m_themeMenu->addAction("System");
        m_actThemeLight = m_themeMenu->addAction("Light");
        m_actThemeDark = m_themeMenu->addAction("Dark");

        m_actThemeSystem->setCheckable(true);
        m_actThemeLight->setCheckable(true);
        m_actThemeDark->setCheckable(true);

        m_themeGroup = new QActionGroup(this);
        m_themeGroup->setExclusive(true);
        m_themeGroup->addAction(m_actThemeSystem);
        m_themeGroup->addAction(m_actThemeLight);
        m_themeGroup->addAction(m_actThemeDark);

        m_themeButton->setMenu(m_themeMenu);

        connect(m_themeButton, &QToolButton::clicked, this, &MarkdownViewerWindow::toggleLightDark);
        connect(m_actThemeSystem, &QAction::triggered, this, [this]() { applyTheme(ThemeMode::System); });
        connect(m_actThemeLight, &QAction::triggered, this, [this]() { applyTheme(ThemeMode::Light);  });
        connect(m_actThemeDark, &QAction::triggered, this, [this]() { applyTheme(ThemeMode::Dark);   });
    }

    void applyTheme(ThemeMode mode) {
        m_themeMode = mode;

        if (mode == ThemeMode::System) {
            qApp->setStyle(m_systemStyleName);
            qApp->setPalette(m_systemPalette);
            qApp->setStyleSheet("");

            if (m_actThemeSystem) m_actThemeSystem->setChecked(true);
            m_themeButton->setIcon(createMoonIcon());
            m_themeButton->setToolTip("Switch to Dark Mode");
            return;
        }

        qApp->setStyle("Fusion");

        if (mode == ThemeMode::Light) {
            QPalette pal = qApp->style()->standardPalette();
            qApp->setPalette(pal);

            qApp->setStyleSheet(
                "QMenuBar { background: palette(window); color: palette(windowText); }"
                "QMenuBar::item { background: transparent; }"
                "QMenu { background: palette(window); color: palette(windowText); }"
            );

            if (m_actThemeLight) m_actThemeLight->setChecked(true);
            m_themeButton->setIcon(createMoonIcon());
            m_themeButton->setToolTip("Switch to Dark Mode");
            return;
        }

        // Dark
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

        qApp->setStyleSheet(
            "QToolTip { color: white; background-color: #303030; border: 1px solid #505050; }"
            "QMenuBar { background: #2b2b2b; color: white; }"
            "QMenuBar::item { background: transparent; }"
            "QMenuBar::item:selected { background: #3a3a3a; }"
            "QMenu { background: #2b2b2b; color: white; }"
            "QMenu::item:selected { background: #3a3a3a; }"
        );

        if (m_actThemeDark) m_actThemeDark->setChecked(true);
        m_themeButton->setIcon(createSunIcon());
        m_themeButton->setToolTip("Switch to Light Mode");
    }

    void buildMenus() {
        auto* menuFile = menuBar()->addMenu("&File");
        menuFile->addAction(m_actOpen);
        menuFile->addAction(m_actReload);

        auto* menuEdit = menuBar()->addMenu("&Edit");
        menuEdit->addAction(m_actFind);

        auto* menuView = menuBar()->addMenu("&View");
        menuView->addAction(m_actBack);
        menuView->addAction(m_actForward);
        menuView->addSeparator();
        menuView->addAction(m_actZoomReset);

        auto* menuTheme = menuBar()->addMenu("&Theme");
        menuTheme->addAction(m_actThemeSystem);
        menuTheme->addAction(m_actThemeLight);
        menuTheme->addAction(m_actThemeDark);
    }

    void installGlobalShortcuts() {
        auto makeGlobalShortcut = [this](const QKeySequence& seq, const char* slot) {
            auto* sc = new QShortcut(seq, this);
            sc->setContext(Qt::ApplicationShortcut);
            connect(sc, SIGNAL(activated()), this, slot);
            return sc;
        };

        makeGlobalShortcut(QKeySequence(Qt::CTRL | Qt::Key_Z), SLOT(goBack()));
        makeGlobalShortcut(QKeySequence(Qt::CTRL | Qt::Key_Y), SLOT(goForward()));
        makeGlobalShortcut(QKeySequence(Qt::CTRL | Qt::Key_0), SLOT(resetZoom()));
        makeGlobalShortcut(QKeySequence(Qt::CTRL | Qt::Key_R), SLOT(reloadFileFresh()));

        makeGlobalShortcut(QKeySequence(Qt::ALT | Qt::Key_Left), SLOT(goBack()));
        makeGlobalShortcut(QKeySequence(Qt::ALT | Qt::Key_Right), SLOT(goForward()));

        auto* scFind = new QShortcut(QKeySequence::Find, this);
        scFind->setContext(Qt::ApplicationShortcut);
        connect(scFind, &QShortcut::activated, this, &MarkdownViewerWindow::showFindBar);

        auto* scEsc = new QShortcut(QKeySequence(Qt::Key_Escape), this);
        scEsc->setContext(Qt::ApplicationShortcut);
        connect(scEsc, &QShortcut::activated, this, &MarkdownViewerWindow::hideFindBar);
    }

    void restoreSettings() {
        const int themeInt = m_settings.value("themeMode", int(ThemeMode::System)).toInt();
        ThemeMode mode = ThemeMode::System;
        if (themeInt == int(ThemeMode::Light)) mode = ThemeMode::Light;
        if (themeInt == int(ThemeMode::Dark))  mode = ThemeMode::Dark;

        const int zoomSteps = m_settings.value("zoomSteps", 0).toInt();
        m_textBrowser->setZoomSteps(zoomSteps);

        const bool findCase = m_settings.value("findCase", false).toBool();
        const bool findWhole = m_settings.value("findWhole", false).toBool();
        if (m_cbCase)  m_cbCase->setChecked(findCase);
        if (m_cbWhole) m_cbWhole->setChecked(findWhole);

        applyTheme(mode);
    }

    void saveSettings() {
        m_settings.setValue("themeMode", int(m_themeMode));
        m_settings.setValue("zoomSteps", m_textBrowser ? m_textBrowser->zoomSteps() : 0);

        if (m_cbCase)  m_settings.setValue("findCase", m_cbCase->isChecked());
        if (m_cbWhole) m_settings.setValue("findWhole", m_cbWhole->isChecked());

        if (!m_currentFile.isEmpty())
            m_settings.setValue("lastFile", m_currentFile);
    }

    void loadMarkdownFile(const QString& filePath, const QString& fragment = QString()) {
        QFileInfo fi(filePath);
        if (!fi.exists() || !fi.isFile())
            return;

        m_currentFile = fi.absoluteFilePath();
        m_currentDir = fi.absolutePath();

        // Use Qt's native markdown rendering via setSource
        QUrl url = QUrl::fromLocalFile(m_currentFile);
        m_textBrowser->setSource(url);
        
        setWindowTitle(QString("Markdown Viewer - %1").arg(fi.fileName()));

        m_settings.setValue("lastFile", m_currentFile);

        // Navigate to fragment after load
        if (!fragment.isEmpty()) {
            QTimer::singleShot(100, this, [this, fragment]() {
                m_textBrowser->navigateToAnchor(fragment);
            });
        }
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
    QAction* m_actFind = nullptr;
    QAction* m_actZoomReset = nullptr;

    QLabel* m_zoomLabel = nullptr;

    QWidget* m_findBar = nullptr;
    QLineEdit* m_findEdit = nullptr;
    QCheckBox* m_cbCase = nullptr;
    QCheckBox* m_cbWhole = nullptr;
    QToolButton* m_findCloseBtn = nullptr;
    QTimer* m_findTimer = nullptr;

    QToolButton* m_themeButton = nullptr;
    QMenu* m_themeMenu = nullptr;
    QActionGroup* m_themeGroup = nullptr;
    QAction* m_actThemeSystem = nullptr;
    QAction* m_actThemeLight = nullptr;
    QAction* m_actThemeDark = nullptr;

    QSettings m_settings;

    ThemeMode m_themeMode;
    QPalette  m_systemPalette;
    QString   m_systemStyleName;
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
