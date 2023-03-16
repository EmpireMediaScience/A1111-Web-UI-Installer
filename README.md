# A1111 WebUI Easy Installer and Launcher

This is an **unofficial** simplified installer for **[Automatic1111's Stable Diffusion WebUI](https://github.com/AUTOMATIC1111/stable-diffusion-webui)**.

For simple installation, download the [**Latest Release (.exe)**](https://github.com/EmpireMediaScience/A1111-Web-UI-Installer/releases) and follow the [**Installation Instructions**](#installation)

If you want to improve the Installer, git clone or Fork & Pull Request (this project mainly uses [**Advanced Installer**](https://www.advancedinstaller.com/) and **Powershell**).

## Table of Contents

- [A1111 WebUI Easy Installer and Launcher](#a1111-webui-easy-installer-and-launcher)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [The Installer](#the-installer)
  - [The Launcher](#the-launcher)
  - [Features](#features)
  - [**`WebUI Maintenance Settings`**](#webui-maintenance-settings)
  - [Launch Options](#launch-options)
  - [Miscellaneous](#miscellaneous)
    - [**`Launcher launch options`**](#launcher-launch-options)

## Installation

> **⚠️ WARNING ⚠️**

- This only works on Windows 10 and 11 x64.
- This has only been tested on **NVIDIA Graphics Cards**. [**So make sure your drivers are up to date!**](https://www.nvidia.com/download/index.aspx)
- This installer installs the original [Automatic1111 Stable Diffusion WebUI](https://github.com/AUTOMATIC1111/stable-diffusion-webui) repository **but is not affiliated with it**. If you encounter questions or errors after seeing `Commit Hash: XXXXXXX` in the command window after clicking **`LAUNCH WEBUI`**, they will be related to the WebUI itself and not this Installer. Please do not ask or report them here, but [**here**](https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/new/choose).
- On the other hand, if you find a glitch before that or have a feature request, please [**fill in an issue**](https://github.com/EmpireMediaScience/A1111-Web-UI-Installer/issues) and, more importantly, **join [the r/StableDiffusion discord](https://discord.gg/vrfEcaBTRC) to discuss the project and get general help about the WebUI**.

> ⚠️ This Installer will always clone the latest bleeding-edge update of the WebUI. Unfortunately, some updates can break it.

## The Installer

1. Download the [**latest release**](https://github.com/EmpireMediaScience/A1111-Web-UI-Installer/releases) and run it.
2. If everything goes right, you'll be greeted with this screen:![Installer](https://chat.openai.com/Media/Readme/Installer.png)
3. **Select where you want to install the WebUI.**

    > The default is fine, but if you want to install things somewhere else, it is highly recommended to do it in a dedicated empty folder; otherwise, it will be pretty messy.

4. **"Clean Install"**: Keep it checked if this is your first install via this Auto Installer. Uncheck it if you only want to update the Launcher and keep your existing WebUI intact (with your settings/models/extensions, etc.)

    > **Note** (for experienced users only): It _**may**_ be possible to add the Launcher to an existing WebUI folder you had previously manually git cloned, as long as you move the WebUI folder into a dedicated folder and choose said folder as the Install Path during the install. **But you might encounter errors, and you should delete the venv folder inside the stable-diffusion-webui folder for it to work well.**
5. Click <kbd>Install</kbd> and **remember, this can take a while**
6. Once installed, a folder will open with a shortcut called **_A1111 WebUI (Pin to Taskbar)_**
7. You can drag & drop it on your taskbar if you wish; this is the Launcher for the WebUI
8. Launch the shortcut to open the **[Custom Launcher](#the-launcher)**
9. It should install all the dependencies and ask you if you want to download the base SD model to generate images
   > ⚠️Click "No" only if you already have one or more models somewhere, and if so, don't forget to select their parent folders in the Launcher
10. Once you've set the Launcher according to your preferences, click **`LAUNCH WEBUI`**; this will quit the Launcher and proceed in the terminal window, logging what it's doing

    > ⚠️**Be patient** this will take a while at first; when it's ready, it will open the web UI in your browser

    > ⚠️**Read the WARN message**

11. When you're done using the WebUI, close the browser tab & close the terminal window

## The Launcher

When double clicking **_A1111 WebUI (Pin to Taskbar)_** You should be greeted with the launcher

![Launcher](./Media/Readme/Launcher.png)

## Features

## **`WebUI Maintenance Settings`**

- **<kbd>Browse</kbd>**: This will browse to the _stable-diffusion-webui_ folder
- **<kbd>Reset</kbd>**: This will wipe the _stable-diffusion-webui_ folder and reclone it from GitHub
  > ⚠️ The folder is permanently deleted, so make some backups if needed! A pop-up will ask you for confirmation
- [x] **Auto-Update WebUI**: This will update (git pull) the WebUI every time you launch it
- [x] **Auto-Update Extensions** : Same thing but with the extensions
- [x] **Clear Generated Images**: This will clear all previously generated images from the outputs folder at Launch.
  > ⚠️ The images are permanently deleted! A pop-up will ask you for confirmation.

> The **<kbd>Force</kbd>** buttons next to the above functions will execute the relevant function as soon as you click instead of waiting for Launch

> **Note**: If you have a custom output folder, only the folder specified in the "**_Output directory for images; if empty, defaults to three directories below_**" field in the WebUI settings will be cleared.

## Launch Options

- [x] **Low VRAM**: Allows cards with low VRAM to be able to generate images; this will increase render time but will make things smooth
- [x] **Xformers**: Greatly speeds up RTX 3000 / 4000 cards, can sometimes work with previous gens cards too!
- **`Checkpoint Folder`**: If you don't have a specific checkpoint folder, do not click this, else select it there 💡_click the path to reset_
- **`Default VAE`**: This will allow you to select a default separate for all models VAE file 💡_click the path to reset_
- **Additional Arguments**: If you know what you're doing, add additional launch arguments for the UI here, as you would have done in webui-user.bat. You can also click on the text to see all the arguments available.
  > ⚠️ **_Click SAVE to confirm the additional arguments, else they won't be saved_**

## Miscellaneous

- Launch Options Overview for easy verification & debug
- Launcher Version displayed
- Main GPU & VRAM displayed
- Ability to copy the WebUI Commit Hash (practical for opening GitHub issues)
- Direct link to the Issues section of the Installer/Launcher Github
- Direct link to the Issues section of the WebUI

### **`Launcher launch options`**

> You can add launch options to the Launcher itself by adding them at the end of the "A1111 WebUI (Pin to Taskbar)" shortcut target

- **`skip`**: This goes straight to the Stable Diffusion WebUI with your existing settings without displaying the Launcher UI
- **`no-autolaunch`**: This will launch the WebUI server without opening it when you click **`LAUNCH WEBUI`**, so you can just browse to `http://127.0.0.1:7860/` on your preferred browser
