param(
  [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")),
  [switch]$VerboseOutput
)

$ErrorActionPreference = "Stop"

function Write-Info([string]$msg) { Write-Host $msg }
function Write-Warn([string]$msg) { Write-Host $msg -ForegroundColor Yellow }
function Write-Err([string]$msg)  { Write-Host $msg -ForegroundColor Red }

$srcDir = Join-Path $ProjectRoot "src"
$cupFile = Join-Path $srcDir "Parser.cup"
$cupJar = Join-Path $ProjectRoot "lib\java-cup-11b.jar"

if (!(Test-Path $cupFile)) { throw "No existe: $cupFile" }
if (!(Test-Path $cupJar)) { throw "No existe: $cupJar" }

function Find-JavaExe {
  $cmd = Get-Command java.exe -ErrorAction SilentlyContinue
  if ($cmd -and $cmd.Source) { return $cmd.Source }

  $roots = @(
    "$env:JAVA_HOME\\bin",
    "C:\\Java",
    "$env:ProgramFiles\\Java",
    "$env:ProgramFiles\\Eclipse Adoptium",
    "$env:ProgramFiles\\Adoptium",
    "$env:ProgramFiles\\Amazon Corretto",
    "$env:ProgramFiles(x86)\\Java",
    "$env:ProgramFiles(x86)\\Eclipse Adoptium",
    "$env:ProgramFiles(x86)\\Adoptium",
    "$env:LocalAppData\\Programs\\Eclipse Adoptium",
    "$env:LocalAppData\\Programs\\Adoptium"
  ) | Where-Object { $_ -and (Test-Path $_) }

  foreach ($root in $roots) {
    if ($root.ToLower().EndsWith("\\bin")) {
      $candidate = Join-Path $root "java.exe"
      if (Test-Path $candidate) { return $candidate }
      continue
    }

    $found = Get-ChildItem -Path $root -Filter java.exe -Recurse -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -match "\\bin\\java\.exe$" } |
      Select-Object -First 1

    if ($found) { return $found.FullName }
  }

  return $null
}

$javaExe = Find-JavaExe
if (-not $javaExe) {
  Write-Err "No se encontró java.exe. Instala un JDK (Temurin/Oracle/Corretto) o configura JAVA_HOME + PATH."
  Write-Info "Luego vuelve a ejecutar este script."
  exit 1
}

if ($VerboseOutput) {
  Write-Info "ProjectRoot: $ProjectRoot"
  Write-Info "java.exe: $javaExe"
  Write-Info "CUP jar: $cupJar"
  Write-Info "CUP file: $cupFile"
}

Push-Location $srcDir
try {
  Write-Info "Regenerando Parser.java y sym.java desde Parser.cup..."
  & $javaExe -jar $cupJar -parser Parser -symbols sym $cupFile
  if ($LASTEXITCODE -ne 0) {
    throw "CUP falló (exit code $LASTEXITCODE). No se generó Parser.java/sym.java."
  }

  $parserOut = Join-Path $srcDir "Parser.java"
  $symOut = Join-Path $srcDir "sym.java"
  if (!(Test-Path $parserOut) -or !(Test-Path $symOut)) {
    throw "CUP terminó sin error pero no se encontraron $parserOut y/o $symOut."
  }

  Write-Info "OK. Archivos generados/actualizados en: $srcDir"
} finally {
  Pop-Location
}
