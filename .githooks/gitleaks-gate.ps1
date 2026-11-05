# Kapija protiv upisa tajni. Jedna skripta, dva pozivaoca:
#   1. agentov `PreToolUse` hook na `Write|Edit` (lokalno podesavanje, nije u repou)
#      -> bez argumenata, cita JSON dogadjaja sa stdin-a
#   2. `pre-commit` unos na `git commit` (.pre-commit-config.yaml)
#      -> sa `-PreCommit`, skenira samo staged izmene
#
# Fail-closed po konstrukciji: sve sto nije dokazano dobro zavrsava se sa `exit 2`,
# jer `PreToolUse` blokira SAMO izlaznim kodom 2. Kod 1 ne blokira, propusta.
#
# ZASTO NEMA `Write-Error` NI `$ErrorActionPreference = 'Stop'`: prva verzija je
# imala oboje i vracala je 1 umesto 2, jer `Write-Error` uz `Stop` obori skriptu
# pre `exit 2`. Hook bi tiho propustio upis. Poruke zato idu direktno na stderr.
#
# ZASTO SE NE SKENIRA RADNO STABLO (druga verzija, 24.10.2026): `gitleaks detect
# --no-git` nad korenom ne postuje .gitignore. Na dokazu je nasao 13 nalaza, svi u
# ignorisanim fajlovima (.env, .venv, apps/web/.next), pa bi odbio SVAKI upis
# zauvek. Drugo, `PreToolUse` se izvrsava PRE upisa, pa bi skeniranje stabla
# proverilo staro stanje, a tajnu koja se upravo upisuje ne bi videlo. Zato hook
# skenira tacno sadrzaj koji se upisuje, a `pre-commit` tacno ono sto se commituje.
#
# `-ExecutionPolicy Bypass` se NE koristi: `LocalMachine` je `RemoteSigned`, pa se
# lokalna skripta pokrece bez njega.
param([switch]$PreCommit)

function Deny([string]$Message) {
    [Console]::Error.WriteLine($Message)
    exit 2
}

if (-not (Get-Command gitleaks -ErrorAction SilentlyContinue)) {
    Deny "gitleaks nije na PATH-u. Kapija se ne moze izvrsiti, upis odbijen."
}

if ($PreCommit) {
    $repo = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repo)) {
        Deny "Nisam u git repozitorijumu. Kapija se ne moze izvrsiti, commit odbijen."
    }
    gitleaks git --pre-commit --staged --redact --no-banner "$repo"
    if ($LASTEXITCODE -ne 0) {
        Deny "Gitleaks nasao tajnu u staged izmenama. Commit odbijen."
    }
    exit 0
}

# Hook: JSON dogadjaja sa stdin-a. UTF-8 u oba smera, inace PowerShell 5.1 pretvara
# sve van ASCII u '?' pre nego sto sadrzaj stigne do gitleaks-a.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$raw = [Console]::In.ReadToEnd()
try {
    $evt = $raw | ConvertFrom-Json
} catch {
    Deny "Dogadjaj hooka nije ispravan JSON. Upis odbijen."
}
if ($null -eq $evt -or $null -eq $evt.tool_input) {
    Deny "Dogadjaj hooka nema tool_input. Upis odbijen."
}

$ti = $evt.tool_input
$parts = @()
if ($ti.content) { $parts += [string]$ti.content }
if ($ti.new_string) { $parts += [string]$ti.new_string }
foreach ($e in @($ti.edits)) {
    if ($e -and $e.new_string) { $parts += [string]$e.new_string }
}

# Prazan novi sadrzaj (npr. Edit koji samo brise tekst) ne moze da unese tajnu.
if ($parts.Count -eq 0) { exit 0 }

($parts -join "`n") | gitleaks stdin --redact --no-banner -l warn
if ($LASTEXITCODE -ne 0) {
    Deny "Gitleaks nasao tajnu u sadrzaju koji se upisuje. Upis odbijen."
}

exit 0
