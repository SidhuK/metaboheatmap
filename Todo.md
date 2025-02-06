I'll help you create a native Mac app with a polished GUI using your Shiny app. We'll use R.app and Electron to create a standalone application. Here's the step-by-step process:

1. First, let's modify your app.R to work better as a desktop application:

```r:app.R
# ... existing code ...

# Add these lines at the top after the library imports
options(shiny.port = 3838)
options(browser = function(url) {
  NULL
})

# ... rest of existing code ...

# Modify the titlePanel section to look more native:
titlePanel(
  title = div(
    h3("MetaboHeatMap", style = "font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI';"),
    h5("Metabolomics Data Visualization Tool", style = "font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI';")
  ),
  windowTitle = "MetaboHeatMap"
)

# Add this at the very end after shinyApp(ui, server)
if (Sys.getenv("ELECTRON_RUN") == "1") {
  electron::run()
}
```

2. Create a new CSS file to make the app look more native:

```css:www/styles.css
body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    background-color: #f5f5f7;
}

.sidebar {
    background-color: #ffffff;
    border-radius: 10px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    padding: 20px;
    margin: 10px;
}

.btn-primary {
    background-color: #0071e3;
    border: none;
    border-radius: 20px;
    padding: 10px 20px;
    transition: all 0.2s ease;
}

.btn-primary:hover {
    background-color: #0077ed;
    transform: scale(1.02);
}

.form-control {
    border-radius: 8px;
    border: 1px solid #d2d2d7;
}

.nav-tabs {
    border-bottom: 1px solid #d2d2d7;
}

.nav-tabs > li.active > a {
    border-bottom: 2px solid #0071e3;
    color: #0071e3;
}

.plotOutput {
    background-color: white;
    border-radius: 10px;
    padding: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
```

3. Create the Electron configuration:

```javascript:main.js
const { app, BrowserWindow, dialog } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const isDev = require('electron-is-dev');

let mainWindow;
let rShinyProcess;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1400,
        height: 1000,
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        },
        titleBarStyle: 'hiddenInset',
        backgroundColor: '#f5f5f7'
    });

    // Start R process
    const rscriptPath = isDev
        ? 'Rscript'
        : path.join(process.resourcesPath, 'R', 'bin', 'Rscript');

    const appPath = isDev
        ? path.join(__dirname, 'app.R')
        : path.join(process.resourcesPath, 'app', 'app.R');

    rShinyProcess = spawn(rscriptPath, [appPath]);

    // Wait for Shiny to start
    setTimeout(() => {
        mainWindow.loadURL('http://127.0.0.1:3838');
    }, 2000);

    mainWindow.on('closed', () => {
        mainWindow = null;
        if (rShinyProcess) {
            rShinyProcess.kill();
        }
    });
}

app.on('ready', createWindow);

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
    if (rShinyProcess) {
        rShinyProcess.kill();
    }
});

app.on('activate', () => {
    if (mainWindow === null) {
        createWindow();
    }
});
```

4. Create the package.json configuration:

```json:package.json
{
  "name": "metaboheatmap",
  "version": "1.0.0",
  "description": "Metabolomics Data Visualization Tool",
  "main": "main.js",
  "scripts": {
    "start": "electron .",
    "build": "electron-builder",
    "pack": "electron-builder --dir",
    "dist": "electron-builder"
  },
  "build": {
    "appId": "com.karatsidhu.metaboheatmap",
    "productName": "MetaboHeatMap",
    "mac": {
      "category": "public.app-category.scientific",
      "icon": "build/icon.icns",
      "target": ["dmg"],
      "darkModeSupport": true,
      "extraResources": [
        {
          "from": "R-Portable",
          "to": "R"
        },
        {
          "from": "app.R",
          "to": "app/app.R"
        },
        {
          "from": "www",
          "to": "app/www"
        }
      ]
    }
  },
  "devDependencies": {
    "electron": "^24.3.0",
    "electron-builder": "^24.3.0",
    "electron-is-dev": "^2.0.0"
  }
}
```

To build the application:

1. Install the required tools:

```bash
# Install Node.js and npm
brew install node

# Install electron and dependencies
npm install

# Create R-Portable directory
mkdir R-Portable
```

2. Download the appropriate version of R for macOS and extract it to the R-Portable directory.

3. Install required R packages in the R-Portable directory:

```r
install.packages(c("shiny", "pheatmap", "RColorBrewer", "viridis"), lib = "R-Portable/library")
```

4. Create an application icon (icon.icns) and place it in the build directory.

5. Build the application:

```bash
npm run dist
```

The built application will be available in the `dist` directory. Users can then install it by dragging the .dmg file to their Applications folder.

Key features of this setup:

- Native macOS look and feel with system fonts and styling
- Proper window management and native title bar
- Bundled R runtime and packages
- Automatic startup of the R process
- Clean shutdown handling
- Support for dark mode
- Professional installation process via DMG

The app will run as a native macOS application with all dependencies included, so users won't need to install R or any packages separately.

Would you like me to provide any additional details about specific aspects of the setup?
