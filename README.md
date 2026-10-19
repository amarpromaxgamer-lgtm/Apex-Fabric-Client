# Apex — Royal Fabric Client for Minecraft 1.21.11

A client-side utility and customization mod built with Fabric Loom and Java 21. Apex focuses on a royal-purple/black ClickGUI, visual HUD modules, local profiles, keybinds, and lightweight interface animation. It does not include combat automation, packet abuse, anti-cheat bypasses, or server-side modifications.

## Features

- **Custom ClickGUI:** royal-purple and obsidian panels, subtle particles, and animated opening transitions.
- **Module search:** search module name, category, and description.
- **HUD:** coordinates, FPS, armor durability, and an optional WASD keystrokes display.
- **Module toggles and custom keybinds:** click a module's `Bind key` button and press the desired key. `ESC` clears a bind.
- **Profiles:** cycle through `Default`, `Streamer`, and `Minimal`. Each profile is stored separately.
- **Main controls:** `Right Shift` opens/closes the ClickGUI; `H` toggles the HUD. These controls can also be changed in Minecraft's Controls menu under Apex Client.
- **Multiplayer-friendly:** the included features are client-side display/UI functionality and need no server-side mod. Server owners may set their own policies for client mods.

## Easiest Windows setup

1. Install a **64-bit Java 21 JDK**. Java 21 is required by Minecraft 1.21.11 modding tools.
2. Extract the Apex ZIP.
3. Double-click **`build.bat`**. It will download a project-local Gradle 8.14.3 distribution if needed, compile the mod and show the result. The first run needs internet access to download Gradle and Minecraft/Fabric dependencies.
4. When prompted, choose `Y` to copy Apex into `%APPDATA%\.minecraft\mods`. If matching Fabric API isn't found, the script can download the pinned API version as well.
5. Launch the **Minecraft Java Edition 1.21.11 Fabric** profile. Press **Right Shift** to open Apex.

The script only prints `BUILD SUCCESS` after Gradle returns successfully and the expected JAR is present. If the build fails, the actual Gradle error is shown and no successful build is claimed.

## Manual build

Use Java 21 and Gradle 8.14.3+ with internet access, then run from this directory:

```powershell
gradle --no-daemon clean build
```

The remapped JAR should be at `build\libs\apex-1.0.0.jar`. Copy it and a compatible Fabric API for Minecraft 1.21.11 into the active Minecraft instance's `mods` folder.

## Project versions

- Minecraft: `1.21.11`
- Java target: `21`
- Fabric Loader: `0.18.1` or newer
- Fabric API: `0.141.6+1.21.11`
- Fabric Loom: `1.14.10`
- Yarn mappings: `1.21.11+build.3`

Versions are pinned in `gradle.properties` and `build.gradle`.

## Configuration

Apex stores configuration locally in `.minecraft/config/apex/`:

- `current-profile.txt`
- `profiles/default.json`
- `profiles/streamer.json`
- `profiles/minimal.json`

No profile data is sent to a multiplayer server.

## Verification note

The project includes its Java sources and build setup. This preparation environment has no outbound network access and no Gradle installation, so I could not run a Gradle compile or launch Minecraft here. The `build.bat` helper is designed to build locally on a Windows PC with Java 21 and internet access. Treat the resulting JAR as verified only if the script prints `BUILD SUCCESS`; an in-game launch test still needs to be performed locally.

## License

MIT. See `LICENSE`.

## Build Apex online (no local Gradle required)

This project includes a GitHub Actions workflow at `.github/workflows/build.yml`.
It builds the project with Java 21 and Gradle 9.2.1 and publishes the installable
JAR as a downloadable artifact when the build succeeds.

1. Sign in at https://github.com and create a new repository.
2. Extract this ZIP on your computer. Upload the **contents** of the `Apex` folder
   to the repository (including `.github/workflows/build.yml`), then commit the files.
   If the upload interface omits the hidden `.github` folder, use **Add file → Create
   new file** and name it `.github/workflows/build.yml`, then copy in the workflow
   from this project.
3. Open the repository's **Actions** tab and select **Build Apex**. A push to `main`
   or `master` starts the workflow automatically. You can also choose **Run workflow**.
4. Open the completed run. Under **Artifacts**, download `Apex-Fabric-1.21.11` and
   extract the downloaded ZIP. It contains `Apex-1.21.11.jar` if the build succeeded.
5. Put that JAR in your `.minecraft/mods` folder along with Fabric API for Minecraft
   1.21.11, then launch the matching Fabric profile.

A successful workflow is the build check; this project has not been represented as
compiled or tested in-game until that workflow completes successfully and you test
it in Minecraft. If the workflow fails, open the failed run and share the first
relevant error from the build log.
