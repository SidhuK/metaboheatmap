const { app, BrowserWindow, dialog } = require("electron");
const path = require("path");
const { spawn } = require("child_process");
const isDev = require("electron-is-dev");

let mainWindow;
let rShinyProcess;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 1000,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
    },
    titleBarStyle: "hiddenInset",
    backgroundColor: "#f5f5f7",
  });

  // Start R process
  const rscriptPath = isDev
    ? "Rscript"
    : path.join(process.resourcesPath, "R", "bin", "Rscript");

  const appPath = isDev
    ? path.join(__dirname, "app.R")
    : path.join(process.resourcesPath, "app", "app.R");

  rShinyProcess = spawn(rscriptPath, [appPath]);

  // Wait for Shiny to start
  setTimeout(() => {
    mainWindow.loadURL("http://127.0.0.1:3838");
  }, 2000);

  mainWindow.on("closed", () => {
    mainWindow = null;
    if (rShinyProcess) {
      rShinyProcess.kill();
    }
  });
}

app.on("ready", createWindow);

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") {
    app.quit();
  }
  if (rShinyProcess) {
    rShinyProcess.kill();
  }
});

app.on("activate", () => {
  if (mainWindow === null) {
    createWindow();
  }
});
