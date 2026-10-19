$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$GradleVersion = '8.14.3'
$GradleDir = Join-Path $ProjectRoot "tools\gradle-$GradleVersion"
$GradleExe = Join-Path $GradleDir 'bin\gradle.bat'
$ToolsDir = Join-Path $ProjectRoot 'tools'
$MinecraftVersion = '1.21.11'
$FabricApiVersion = '0.141.6+1.21.11'
$JarName = 'apex-1.0.0.jar'
$ScriptExitCode = 0

function Write-Step([string]$Message) {
    Write-Host "`n[Apex] $Message" -ForegroundColor Magenta
}

function Test-UrlDownload([string]$Url, [string]$Destination) {
    Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
    if (!(Test-Path $Destination) -or (Get-Item $Destination).Length -lt 10000) {
        throw "The downloaded file from $Url appears incomplete."
    }
}

try {
    Write-Host '======================================' -ForegroundColor DarkMagenta
    Write-Host '  APEX | Fabric 1.21.11 build helper' -ForegroundColor Magenta
    Write-Host '======================================' -ForegroundColor DarkMagenta

    Write-Step 'Checking Java 21 or newer...'
    $javaCommand = Get-Command java -ErrorAction SilentlyContinue
    if (!$javaCommand) {
        throw 'Java was not found. Install a 64-bit Java 21 JDK, reopen this window, and run this file again.'
    }
    $javaVersionText = (& java -version 2>&1 | Out-String)
    Write-Host ($javaVersionText.Trim())
    $majorMatch = [regex]::Match($javaVersionText, '(?:version\s+"|openjdk\s+)(?<major>\d+)')
    if ($majorMatch.Success -and [int]$majorMatch.Groups['major'].Value -lt 21) {
        throw 'Apex requires Java 21 or newer. Install a 64-bit Java 21 JDK and try again.'
    }

    if (!(Test-Path $GradleExe)) {
        Write-Step "Gradle $GradleVersion was not found; downloading the official Gradle distribution..."
        New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null
        $zipPath = Join-Path $ToolsDir "gradle-$GradleVersion-bin.zip"
        $url = "https://services.gradle.org/distributions/gradle-$GradleVersion-bin.zip"
        Test-UrlDownload $url $zipPath
        Expand-Archive -LiteralPath $zipPath -DestinationPath $ToolsDir -Force
        Remove-Item $zipPath -Force
        if (!(Test-Path $GradleExe)) {
            throw 'Gradle extraction finished, but the Gradle executable was not found.'
        }
    } else {
        Write-Step "Using the project-local Gradle $GradleVersion installation."
    }

    Write-Step 'Compiling Apex. The first build needs internet access to retrieve Fabric/Minecraft dependencies...'
    Push-Location $ProjectRoot
    try {
        & $GradleExe --no-daemon clean build
        if ($LASTEXITCODE -ne 0) {
            throw "Gradle build failed with exit code $LASTEXITCODE. Read the error above; the source did not produce a verified mod JAR."
        }
    } finally {
        Pop-Location
    }

    $JarPath = Join-Path $ProjectRoot "build\libs\$JarName"
    if (!(Test-Path $JarPath) -or (Get-Item $JarPath).Length -lt 10000) {
        throw "Gradle reported success but $JarName was not found in build\libs."
    }
    Write-Host "`nBUILD SUCCESS: $JarPath" -ForegroundColor Green

    $modsDir = Join-Path $env:APPDATA '.minecraft\mods'
    $installChoice = Read-Host "Copy Apex into the default Minecraft mods folder ($modsDir)? [Y/N]"
    if ($installChoice -match '^(Y|YES)$') {
        New-Item -ItemType Directory -Force -Path $modsDir | Out-Null
        Copy-Item -LiteralPath $JarPath -Destination (Join-Path $modsDir $JarName) -Force
        Write-Host "Apex copied to $modsDir" -ForegroundColor Green

        $apiFileName = "fabric-api-$FabricApiVersion.jar"
        $apiPath = Join-Path $modsDir $apiFileName
        $apiAlreadyPresent = Get-ChildItem -LiteralPath $modsDir -Filter 'fabric-api-*.jar' -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like '*1.21.11*' } | Select-Object -First 1
        if (!$apiAlreadyPresent) {
            $apiChoice = Read-Host 'Matching Fabric API for 1.21.11 was not detected. Download it now? [Y/N]'
            if ($apiChoice -match '^(Y|YES)$') {
                try {
                    $encodedVersion = [uri]::EscapeDataString($FabricApiVersion)
                    $apiUrl = "https://maven.fabricmc.net/net/fabricmc/fabric-api/fabric-api/$encodedVersion/fabric-api-$encodedVersion.jar"
                    Test-UrlDownload $apiUrl $apiPath
                    Write-Host 'Matching Fabric API downloaded.' -ForegroundColor Green
                } catch {
                    Write-Warning "Could not download Fabric API automatically: $($_.Exception.Message)"
                    Write-Warning 'Install Fabric API for Minecraft 1.21.11 manually; Apex depends on it.'
                }
            } else {
                Write-Warning 'Remember to install Fabric API for Minecraft 1.21.11, or Apex will not load.'
            }
        } else {
            Write-Host "Found matching Fabric API: $($apiAlreadyPresent.Name)" -ForegroundColor Green
        }
    } else {
        Write-Host 'No game files were changed. Copy the JAR above into your Minecraft 1.21.11 Fabric mods folder when ready.'
    }

    Write-Host "`nDone. Start the Minecraft Java Edition Fabric profile for version $MinecraftVersion." -ForegroundColor Green
    Write-Host 'In-game: press Right Shift to open the Apex ClickGUI.' -ForegroundColor Magenta
} catch {
    $ScriptExitCode = 1
    Write-Host "`nAPEX SETUP FAILED: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host 'No successful mod build is claimed unless the script prints BUILD SUCCESS.' -ForegroundColor Yellow
} finally {
    Write-Host ''
    Read-Host 'Press Enter to close this window' | Out-Null
}

if ($ScriptExitCode -ne 0) { exit $ScriptExitCode }
