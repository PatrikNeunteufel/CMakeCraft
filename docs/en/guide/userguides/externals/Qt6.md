# Qt6 — UserGuide

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Guide  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Qt6.md](../../../../de/guide/userguides/externals/Qt6.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Installation](#2-installation)
3. [Solution.json Configuration](#3-solutionjson-configuration)
4. [C++ Usage](#4-c-usage)
5. [Qt Widgets](#5-qt-widgets)
6. [Signals & Slots](#6-signals--slots)
7. [Qt Quick / QML](#7-qt-quick--qml)
8. [Advanced Techniques](#8-advanced-techniques)
9. [Troubleshooting](#9-troubleshooting)
10. [Further Information](#10-further-information)
11. [Changelog](#changelog)

---

## 1. Overview

**Qt6** is a comprehensive C++ framework for desktop, mobile and embedded applications.

| Aspect | Value |
|--------|-------|
| **Type** | System External |
| **Version** | 6.x (recommended: 6.6+) |
| **License** | LGPL / Commercial |
| **Website** | [qt.io](https://www.qt.io/) |

### Why Qt6?

| Advantage | Description |
|-----------|-------------|
| 🖥️ **Cross-Platform** | Windows, Linux, macOS, mobile |
| 🎨 **Widgets & QML** | Classic and modern UI |
| 📡 **Networking** | HTTP, WebSocket, Bluetooth |
| 💾 **Databases** | SQL, SQLite, PostgreSQL |

### Qt6 Modules

| Module | Description |
|--------|-------------|
| **Core** | Base functionality |
| **Gui** | GUI fundamentals |
| **Widgets** | Desktop widgets |
| **Quick** | QML/JavaScript UI |
| **Network** | Network functions |
| **Sql** | Database access |
| **Multimedia** | Audio/video |

---

## 2. Installation

### 2.1 Qt Online Installer

1. Download from [qt.io/download](https://www.qt.io/download)
2. Run the Qt Online Installer
3. Select Qt 6.x and the required modules
4. Select a compiler kit (MSVC, MinGW, GCC, Clang)

### 2.2 Package Manager (Linux)

```bash
# Ubuntu/Debian
sudo apt install qt6-base-dev qt6-declarative-dev

# Fedora
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel

# Arch
sudo pacman -S qt6-base qt6-declarative
```

### 2.3 Homebrew (macOS)

```bash
brew install qt@6
```

### 2.4 Installation Paths

| Platform | Typical Path |
|----------|--------------|
| **Windows** | `C:\Qt\6.6.0\msvc2019_64` |
| **Linux** | `/usr/lib/qt6` or `~/Qt/6.6.0/gcc_64` |
| **macOS** | `/usr/local/opt/qt@6` or `~/Qt/6.6.0/macos` |

---

## 3. Solution.json Configuration

### 3.1 Minimal (Widgets)

```json
{
    "externals": {
        "qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Widgets"]
        }
    },
    "executables": [
        {
            "name": "QtApp",
            "type": "GUI",
            "externals": ["qt6"]
        }
    ]
}
```

### 3.2 With Multiple Components

```json
{
    "externals": {
        "qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Widgets", "Network", "Sql"]
        }
    },
    "executables": [
        {
            "name": "QtApp",
            "type": "GUI",
            "externals": ["qt6"]
        }
    ]
}
```

### 3.3 QML/Quick Application

```json
{
    "externals": {
        "qt6": {
            "system": true,
            "package": "Qt6",
            "components": ["Quick", "QuickControls2", "Qml"]
        }
    },
    "executables": [
        {
            "name": "QmlApp",
            "type": "GUI",
            "externals": ["qt6"]
        }
    ]
}
```

### 3.4 CMake Integration

Qt6 needs `CMAKE_PREFIX_PATH`:

```bash
# Configure CMake
cmake -DCMAKE_PREFIX_PATH=/path/to/Qt/6.6.0/gcc_64 ..

# Or in CMakeUserPresets.json
{
    "configurePresets": [
        {
            "name": "qt6",
            "cacheVariables": {
                "CMAKE_PREFIX_PATH": "/path/to/Qt/6.6.0/gcc_64"
            }
        }
    ]
}
```

---

## 4. C++ Usage

### 4.1 Minimal Qt Application

```cpp
#include <QApplication>
#include <QLabel>

int main(int argc, char* argv[]) {
    QApplication app(argc, argv);
    
    QLabel label("Hello, Qt6!");
    label.setWindowTitle("My First Qt App");
    label.resize(200, 100);
    label.show();
    
    return app.exec();
}
```

### 4.2 With MainWindow

```cpp
#include <QApplication>
#include <QMainWindow>
#include <QLabel>
#include <QVBoxLayout>
#include <QPushButton>

int main(int argc, char* argv[]) {
    QApplication app(argc, argv);
    
    QMainWindow window;
    window.setWindowTitle("Qt MainWindow");
    window.resize(400, 300);
    
    QWidget* central = new QWidget();
    QVBoxLayout* layout = new QVBoxLayout(central);
    
    QLabel* label = new QLabel("Hello, Qt6!");
    QPushButton* button = new QPushButton("Click me");
    
    layout->addWidget(label);
    layout->addWidget(button);
    
    window.setCentralWidget(central);
    window.show();
    
    return app.exec();
}
```

### 4.3 Custom Widget Class

**mainwindow.h:**
```cpp
#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

class QPushButton;
class QLabel;

class MainWindow : public QMainWindow {
    Q_OBJECT
    
public:
    explicit MainWindow(QWidget* parent = nullptr);
    ~MainWindow() override = default;
    
private slots:
    void onButtonClicked();
    
private:
    QLabel* label;
    QPushButton* button;
    int clickCount = 0;
};

#endif
```

**mainwindow.cpp:**
```cpp
#include "mainwindow.h"
#include <QVBoxLayout>
#include <QLabel>
#include <QPushButton>

MainWindow::MainWindow(QWidget* parent)
    : QMainWindow(parent) {
    
    setWindowTitle("My Application");
    resize(400, 300);
    
    QWidget* central = new QWidget();
    QVBoxLayout* layout = new QVBoxLayout(central);
    
    label = new QLabel("Click count: 0");
    button = new QPushButton("Click me");
    
    layout->addWidget(label);
    layout->addWidget(button);
    
    setCentralWidget(central);
    
    connect(button, &QPushButton::clicked, this, &MainWindow::onButtonClicked);
}

void MainWindow::onButtonClicked() {
    clickCount++;
    label->setText(QString("Click count: %1").arg(clickCount));
}
```

**main.cpp:**
```cpp
#include <QApplication>
#include "mainwindow.h"

int main(int argc, char* argv[]) {
    QApplication app(argc, argv);
    
    MainWindow window;
    window.show();
    
    return app.exec();
}
```

---

## 5. Qt Widgets

### 5.1 Common Widgets

| Widget | Description |
|--------|-------------|
| `QLabel` | Display text/image |
| `QPushButton` | Button |
| `QLineEdit` | Single-line text input |
| `QTextEdit` | Multi-line text input |
| `QCheckBox` | Checkbox |
| `QRadioButton` | Radio button |
| `QComboBox` | Dropdown |
| `QSlider` | Slider |
| `QSpinBox` | Number input |
| `QProgressBar` | Progress bar |
| `QListWidget` | List |
| `QTableWidget` | Table |
| `QTreeWidget` | Tree view |

### 5.2 Layouts

```cpp
// Vertical
QVBoxLayout* vbox = new QVBoxLayout();
vbox->addWidget(widget1);
vbox->addWidget(widget2);

// Horizontal
QHBoxLayout* hbox = new QHBoxLayout();
hbox->addWidget(widget1);
hbox->addWidget(widget2);

// Grid
QGridLayout* grid = new QGridLayout();
grid->addWidget(widget1, 0, 0);  // Row 0, column 0
grid->addWidget(widget2, 0, 1);  // Row 0, column 1
grid->addWidget(widget3, 1, 0, 1, 2);  // Row 1, 2 columns wide

// Form
QFormLayout* form = new QFormLayout();
form->addRow("Name:", nameEdit);
form->addRow("Email:", emailEdit);
```

### 5.3 Dialogs

```cpp
#include <QMessageBox>
#include <QFileDialog>
#include <QInputDialog>
#include <QColorDialog>

// Message box
QMessageBox::information(this, "Info", "Operation completed");
QMessageBox::warning(this, "Warning", "Something went wrong");

int result = QMessageBox::question(this, "Confirm", "Are you sure?",
    QMessageBox::Yes | QMessageBox::No);
if (result == QMessageBox::Yes) {
    // Yes clicked
}

// File dialog
QString filename = QFileDialog::getOpenFileName(this,
    "Open File", "", "Text Files (*.txt);;All Files (*)");

QString saveFile = QFileDialog::getSaveFileName(this,
    "Save File", "", "Text Files (*.txt)");

// Input dialog
QString text = QInputDialog::getText(this, "Input", "Enter name:");
int number = QInputDialog::getInt(this, "Input", "Enter number:", 0, 0, 100);

// Color dialog
QColor color = QColorDialog::getColor(Qt::white, this, "Select Color");
```

### 5.4 Menus and Toolbars

```cpp
// Menu bar
QMenuBar* menuBar = this->menuBar();

QMenu* fileMenu = menuBar->addMenu("&File");
QAction* newAction = fileMenu->addAction("&New", QKeySequence::New);
QAction* openAction = fileMenu->addAction("&Open", QKeySequence::Open);
fileMenu->addSeparator();
QAction* exitAction = fileMenu->addAction("E&xit", QKeySequence::Quit);

connect(exitAction, &QAction::triggered, this, &QWidget::close);

// Toolbar
QToolBar* toolbar = addToolBar("Main");
toolbar->addAction(newAction);
toolbar->addAction(openAction);

// Status bar
statusBar()->showMessage("Ready");
```

---

## 6. Signals & Slots

### 6.1 Basics

```cpp
// Establish a connection
connect(sender, &SenderClass::signalName, receiver, &ReceiverClass::slotName);

// Example
connect(button, &QPushButton::clicked, this, &MainWindow::onButtonClicked);
```

### 6.2 Lambda as Slot

```cpp
connect(button, &QPushButton::clicked, [this]() {
    label->setText("Button clicked!");
});

// With parameter
connect(slider, &QSlider::valueChanged, [this](int value) {
    label->setText(QString("Value: %1").arg(value));
});
```

### 6.3 Custom Signals & Slots

```cpp
class Counter : public QObject {
    Q_OBJECT
    
public:
    Counter() : count(0) {}
    
    int value() const { return count; }
    
public slots:
    void increment() {
        count++;
        emit valueChanged(count);
    }
    
    void decrement() {
        count--;
        emit valueChanged(count);
    }
    
    void setValue(int value) {
        if (count != value) {
            count = value;
            emit valueChanged(count);
        }
    }
    
signals:
    void valueChanged(int newValue);
    
private:
    int count;
};

// Usage
Counter counter;
connect(&counter, &Counter::valueChanged, [](int value) {
    qDebug() << "Value changed to:" << value;
});

counter.increment();  // Output: "Value changed to: 1"
```

---

## 7. Qt Quick / QML

### 7.1 QML Basics

**main.qml:**
```qml
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "QML App"
    
    Column {
        anchors.centerIn: parent
        spacing: 10
        
        Label {
            text: "Hello, QML!"
            font.pixelSize: 24
        }
        
        Button {
            text: "Click me"
            onClicked: {
                console.log("Button clicked!")
            }
        }
    }
}
```

**main.cpp:**
```cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    
    if (engine.rootObjects().isEmpty())
        return -1;
    
    return app.exec();
}
```

### 7.2 C++ Backend for QML

**backend.h:**
```cpp
#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QString>

class Backend : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString message READ message WRITE setMessage NOTIFY messageChanged)
    
public:
    explicit Backend(QObject* parent = nullptr);
    
    QString message() const;
    void setMessage(const QString& msg);
    
    Q_INVOKABLE void processData();
    
signals:
    void messageChanged();
    
private:
    QString m_message;
};

#endif
```

**main.cpp:**
```cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "backend.h"

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    
    Backend backend;
    
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    
    return app.exec();
}
```

**main.qml:**
```qml
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true
    
    Column {
        Label {
            text: backend.message
        }
        
        Button {
            text: "Update"
            onClicked: backend.processData()
        }
    }
}
```

---

## 8. Advanced Techniques

### 8.1 Threading

```cpp
#include <QThread>
#include <QObject>

class Worker : public QObject {
    Q_OBJECT
    
public slots:
    void doWork() {
        // Long operation
        for (int i = 0; i < 100; i++) {
            QThread::msleep(50);
            emit progress(i);
        }
        emit finished();
    }
    
signals:
    void progress(int value);
    void finished();
};

// Usage
QThread* thread = new QThread();
Worker* worker = new Worker();
worker->moveToThread(thread);

connect(thread, &QThread::started, worker, &Worker::doWork);
connect(worker, &Worker::finished, thread, &QThread::quit);
connect(worker, &Worker::finished, worker, &QObject::deleteLater);
connect(thread, &QThread::finished, thread, &QObject::deleteLater);

connect(worker, &Worker::progress, [](int value) {
    qDebug() << "Progress:" << value;
});

thread->start();
```

### 8.2 Networking

```cpp
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>

QNetworkAccessManager* manager = new QNetworkAccessManager(this);

connect(manager, &QNetworkAccessManager::finished, [](QNetworkReply* reply) {
    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        qDebug() << "Response:" << data;
    } else {
        qDebug() << "Error:" << reply->errorString();
    }
    reply->deleteLater();
});

// GET request
manager->get(QNetworkRequest(QUrl("https://api.example.com/data")));

// POST request
QNetworkRequest request(QUrl("https://api.example.com/data"));
request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
manager->post(request, "{\"key\": \"value\"}");
```

### 8.3 Database

```cpp
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>

// Connection
QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
db.setDatabaseName("mydb.sqlite");

if (!db.open()) {
    qDebug() << "Error:" << db.lastError().text();
    return;
}

// Create table
QSqlQuery query;
query.exec("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)");

// Insert
query.prepare("INSERT INTO users (name) VALUES (:name)");
query.bindValue(":name", "John");
query.exec();

// Query
query.exec("SELECT * FROM users");
while (query.next()) {
    int id = query.value(0).toInt();
    QString name = query.value(1).toString();
    qDebug() << id << name;
}

db.close();
```

### 8.4 Resource System

**resources.qrc:**
```xml
<!DOCTYPE RCC>
<RCC version="1.0">
    <qresource prefix="/">
        <file>images/logo.png</file>
        <file>qml/main.qml</file>
        <file>styles/app.css</file>
    </qresource>
</RCC>
```

```cpp
// Access
QPixmap pixmap(":/images/logo.png");
QFile file(":/styles/app.css");
```

---

## 9. Troubleshooting

### 9.1 "Qt6 not found"

**Problem:** CMake does not find Qt6. Configuring aborts with
`[E503] System external 'qt6': find_package(Qt6) failed.`; if only a module from `components`
is missing, with E504; if the version does not match `version`, with E505
(`cmake/externals/system/Handler.cmake:91`, `:109`, `:128`; messages and fixes:
[ErrorCodes.md](../../references/ErrorCodes.md)).

**Solution:** Set `CMAKE_PREFIX_PATH`:
```bash
cmake -DCMAKE_PREFIX_PATH=/path/to/Qt/6.6.0/gcc_64 ..
```

### 9.2 MOC Not Run

**Problem:** Signals/slots do not work

**Solution:** 
- `Q_OBJECT` macro in the class
- List headers in CMakeLists.txt
- `AUTOMOC ON` in CMake

### 9.3 "undefined reference to vtable"

**Problem:** Link error with Q_OBJECT classes

**Solution:** Reconfigure CMake (MOC must run).

### 9.4 QML Files Not Found

**Problem:** QML files are not loaded

**Solution:** 
- Include them in the .qrc
- Use the `qrc:/` prefix

---

## 10. Further Information

### Official Resources

| Resource | Link |
|----------|------|
| **Website** | [qt.io](https://www.qt.io/) |
| **Documentation** | [doc.qt.io](https://doc.qt.io/) |
| **Qt6 Docs** | [doc.qt.io/qt-6](https://doc.qt.io/qt-6/) |
| **Tutorials** | [doc.qt.io/qt-6/qtexamplesandtutorials.html](https://doc.qt.io/qt-6/qtexamplesandtutorials.html) |
| **Qt Forum** | [forum.qt.io](https://forum.qt.io/) |
| **GitHub** | [github.com/qt](https://github.com/qt) |

### Books & Courses

| Resource | Description |
|----------|-------------|
| **Qt Wiki** | [wiki.qt.io](https://wiki.qt.io/) |
| **Qt Examples** | Bundled examples |

### See Also

- [Externals.md](../Externals.md) — Externals combinations
- [Git_Externals_GUI.md](../../references/externals/Git_Externals_GUI.md) — Alternative: GLFW + ImGui

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.1 | 2026-11-09 | Aligned with the code: examples §3.1–3.3 with the required field `"package": "Qt6"` (otherwise E502, `cmake/externals/system/Handler.cmake`); §9.1 with E503/E504/E505 (CMakeCraft v0.14.1) |
| 1.0.0 | 2025-12-26 | Release 1 (carried over from newCMake, `2e00db7`) |
| **0.5.2** | **2025-12-15** | **Initial: detailed UserGuide for Qt6** |
