##############################################################################
#                                                                            #
#                      Microsoft.PowerShell_profile.ps1                      #
#                                                                            #
##############################################################################

$debug = $true

# Set update interval for PowerShell prompt
if ($debug) {
  $updateInterval = -1
} else {
  $updateInterval = 7 # days
}

if ($debug) {
  Write-Host "#######################################" -ForegroundColor Red
  Write-Host "#           Debug mode enabled        #" -ForegroundColor Red
  Write-Host "#          ONLY FOR DEVELOPMENT       #" -ForegroundColor Red
  Write-Host "#                                     #" -ForegroundColor Red
  Write-Host "#       IF YOU ARE NOT DEVELOPING     #" -ForegroundColor Red
  Write-Host "#       JUST RUN \`Update-Profile\`     #" -ForegroundColor Red
  Write-Host "#        to discard all changes       #" -ForegroundColor Red
  Write-Host "#   and update to the latest profile  #" -ForegroundColor Red
  Write-Host "#               version               #" -ForegroundColor Red
  Write-Host "#######################################" -ForegroundColor Red
}


# Install starship if not installed
$is_installed = Get-Command starship -ErrorAction SilentlyContinue
if (-not $is_installed) {
  Write-Host "Installing Starship Prompt..." -BackgroundColor Magenta
  Invoke-Expression (&winget install --id Starship.Starship --source winget)
}
# Initialize Starship
Invoke-Expression (&starship init powershell)

# Import Modules and External Profiles
# Ensure Terminal-Icons module is installed before importing
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
  Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons


######################################
#                                    #
#          Useful Functions          #
#                                    #
######################################

function Test-CommandExists {
  param($command)
  $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
  return $exists
}

# Nano & Vim from git installation
Set-Alias -Name vim -Value 'C:\Program Files\Git\usr\bin\vim.exe'
Set-Alias -Name nano -Value 'C:\Program Files\Git\usr\bin\nano.exe'

# Editor Configuration
$EDITOR = if (Test-CommandExists nvim) { 'nvim' }
          elseif (Test-CommandExists code) { 'code' }
          elseif (Test-CommandExists pvim) { 'pvim' }
          elseif (Test-CommandExists vim) { 'vim' }
          elseif (Test-CommandExists vi) { 'vi' }
          elseif (Test-CommandExists notepad++) { 'notepad++' }
          elseif (Test-CommandExists sublime_text) { 'sublime_text' }
          else { 'notepad' }
Set-Alias -Name edit -Value $EDITOR

# Create new File
function touch($file) { "" | Out-File $file -Encoding ASCII }

# Find file by name/pattern
function ff($name) {
  Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Output "$($_.FullName)"
  }
}

# Open WinUtil full-release
function winutil {
  Invoke-RestMethod https://christitus.com/win | Invoke-Expression
}

# Open WinUtil pre-release
function winutildev {
  Invoke-RestMethod https://christitus.com/windev | Invoke-Expression
}

# System Utilities
function admin {
  if ($args.Count -gt 0) {
    $argList = $args -join ' '
    Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
  }
  else {
    Start-Process wt -Verb runAs
  }
}

# Set UNIX-like aliases for the admin command, so sudo <command> will run the command with elevated rights.
Set-Alias -Name su -Value admin

function which($name) {
  Get-Command $name | Select-Object -ExpandProperty Definition
}

# Git Shortcuts
function gs { git status }
function ga { git add . }
function gc { param($m) git commit -m "$m" }
function gp { git push }

# Quick Access to System Information
function sysinfo { Get-ComputerInfo }

# Networking Utilities
function flushdns {
  Clear-DnsClientCache
  Write-Host "DNS has been flushed"
}

function Clear-Cache {
  # add clear cache logic here
  Write-Host "Clearing cache..." -ForegroundColor Cyan

  # Clear Windows Prefetch
  Write-Host "Clearing Windows Prefetch..." -ForegroundColor Yellow
  Remove-Item -Path "$env:SystemRoot\Prefetch\*" -Force -ErrorAction SilentlyContinue

  # Clear Windows Temp
  Write-Host "Clearing Windows Temp..." -ForegroundColor Yellow
  Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

  # Clear User Temp
  Write-Host "Clearing User Temp..." -ForegroundColor Yellow
  Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

  # Clear Internet Explorer Cache
  Write-Host "Clearing Internet Explorer Cache..." -ForegroundColor Yellow
  Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*" -Recurse -Force -ErrorAction SilentlyContinue

  Write-Host "Cache clearing completed." -ForegroundColor Green
}

function Update-PowerShell {
  try {
      Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
      $updateNeeded = $false
      $currentVersion = $PSVersionTable.PSVersion.ToString()
      $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
      $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
      $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
      if ($currentVersion -lt $latestVersion) {
          $updateNeeded = $true
      }

      if ($updateNeeded) {
          Write-Host "Updating PowerShell..." -ForegroundColor Yellow
          Start-Process powershell.exe -ArgumentList "-NoProfile -Command winget upgrade Microsoft.PowerShell --accept-source-agreements --accept-package-agreements" -Wait -NoNewWindow
          Write-Host "PowerShell has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
      } else {
          Write-Host "Your PowerShell is up to date." -ForegroundColor Green
      }
  } catch {
      Write-Error "Failed to update PowerShell. Error: $_"
  }
}


######################################
#                                    #
#   Powershell Profile Management    #
#                                    #
######################################

# Quick Access to Editing the Profile
function Edit-Profile {
  edit $PROFILE.CurrentUserAllHosts
}
Set-Alias -Name ep -Value Edit-Profile


