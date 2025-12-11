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

class MarkdownViewerWindow : public QMainWindow {
    Q_OBJECT

public:
    explicit MarkdownViewerWindow(const QString& initialFile = QString(),
        QWidget* parent = nullptr)
        : QMainWindow(parent)
    {
        setWindowTitle("Markdown Viewer (Qt)");

        m_textBrowser = new QTextBrowser(this);
        m_textBrowser->setOpenLinks(false);         // wir handeln Links selbst
        m_textBrowser->setOpenExternalLinks(false);

        connect(m_textBrowser, &QTextBrowser::anchorClicked,
            this, &MarkdownViewerWindow::onAnchorClicked);

        auto* central = new QWidget(this);
        auto* layout = new QVBoxLayout(central);
        layout->setContentsMargins(0, 0, 0, 0);
        layout->addWidget(m_textBrowser);
        setCentralWidget(central);

        // Toolbar (Open, Reload)
        auto* tb = addToolBar("Main");
        auto* actOpen = tb->addAction("Open");
        auto* actReload = tb->addAction("Reload");

        connect(actOpen, &QAction::triggered, this, &MarkdownViewerWindow::openFileDialog);
        connect(actReload, &QAction::triggered, this, &MarkdownViewerWindow::reloadFile);

        if (!initialFile.isEmpty())
            loadMarkdownFile(initialFile);
    }

public slots:
    void openFileDialog() {
        QString file = QFileDialog::getOpenFileName(
            this,
            "Open Markdown",
            m_currentDir.isEmpty() ? QDir::currentPath() : m_currentDir,
            "Markdown Files (*.md *.markdown);;All Files (*.*)");
        if (!file.isEmpty()) {
            loadMarkdownFile(file);
        }
    }

    void reloadFile() {
        if (!m_currentFile.isEmpty())
            loadMarkdownFile(m_currentFile);
    }

    void onAnchorClicked(const QUrl& url) {
        // 1) Absolute oder relative URL?
        QUrl resolved = url;
        if (resolved.isRelative())
            resolved = QUrl::fromLocalFile(m_currentDir + "/" + url.toString());

        // 2) Anker innerhalb derselben Datei?
        if (!resolved.isEmpty() && resolved.isLocalFile()) {
            QString path = resolved.toLocalFile();
            QString fragment = resolved.fragment();

            QFileInfo fi(path);
            QString ext = fi.suffix().toLower();

            if (ext == "md" || ext == "markdown") {
                // andere Markdown-Datei öffnen
                loadMarkdownFile(path, fragment);
                return;
            }
        }

        // 3) HTTP/HTTPS → Standardbrowser
        if (resolved.scheme() == "http" || resolved.scheme() == "https") {
            QDesktopServices::openUrl(resolved);
            return;
        }

        // 4) Sonstige Links dem QTextBrowser überlassen (z. B. Anker)
        m_textBrowser->setSource(resolved);
    }

private:
    void loadMarkdownFile(const QString& filePath, const QString& fragment = QString()) {
        QFileInfo fi(filePath);
        if (!fi.exists() || !fi.isFile())
            return;

        m_currentFile = fi.absoluteFilePath();
        m_currentDir = fi.absolutePath();

        // QTextBrowser kann seit Qt 6 / 5.14 anhand der Endung
        // automatisch entscheiden, ob Markdown oder HTML. 
        QUrl url = QUrl::fromLocalFile(m_currentFile);
        if (!fragment.isEmpty())
            url.setFragment(fragment);

        m_textBrowser->setSource(url);
        setWindowTitle(QString("Markdown Viewer - %1").arg(fi.fileName()));
    }

private:
    QTextBrowser* m_textBrowser = nullptr;
    QString m_currentFile;
    QString m_currentDir;
};

int main(int argc, char* argv[])
{
    QApplication app(argc, argv);

    QString initialFile;
    if (argc > 1) {
        initialFile = QString::fromLocal8Bit(argv[1]);
    }

    MarkdownViewerWindow win(initialFile);
    win.resize(1000, 700);
    win.show();

    return app.exec();
}

#include "main.moc"
