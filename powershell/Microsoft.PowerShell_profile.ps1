##############################################################################
#                                                                            #
#                      Microsoft.PowerShell_profile.ps1                      #
#                                                                            #
##############################################################################

# Set it to true for debugging purposes
# This will show debug messages and prevent the profile from updating through repository
# This is useful for development and testing of the profile
$debug = $false

# Set the repository URL for the profile
$repo_url = "https://raw.githubusercontent.com/NeuroNexul/configurations/main"

# Define the path to the file that stores the last execution time
$timeFilePath = "$env:USERPROFILE\Documents\PowerShell\LastExecutionTime.txt"

# Set update interval for PowerShell prompt
$updateInterval = 7 # in days

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
elseif (Test-CommandExists nano) { 'nano' }
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

function uptime {
  try {
    # check powershell version
    if ($PSVersionTable.PSVersion.Major -eq 5) {
      $lastBoot = (Get-WmiObject win32_operatingsystem).LastBootUpTime
      $bootTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($lastBoot)
    }
    else {
      $lastBootStr = net statistics workstation | Select-String "since" | ForEach-Object { $_.ToString().Replace('Statistics since ', '') }
      # check date format
      if ($lastBootStr -match '^\d{2}/\d{2}/\d{4}') {
        $dateFormat = 'dd/MM/yyyy'
      }
      elseif ($lastBootStr -match '^\d{2}-\d{2}-\d{4}') {
        $dateFormat = 'dd-MM-yyyy'
      }
      elseif ($lastBootStr -match '^\d{4}/\d{2}/\d{2}') {
        $dateFormat = 'yyyy/MM/dd'
      }
      elseif ($lastBootStr -match '^\d{4}-\d{2}-\d{2}') {
        $dateFormat = 'yyyy-MM-dd'
      }
      elseif ($lastBootStr -match '^\d{2}\.\d{2}\.\d{4}') {
        $dateFormat = 'dd.MM.yyyy'
      }
          
      # check time format
      if ($lastBootStr -match '\bAM\b' -or $lastBootStr -match '\bPM\b') {
        $timeFormat = 'h:mm:ss tt'
      }
      else {
        $timeFormat = 'HH:mm:ss'
      }

      $bootTime = [System.DateTime]::ParseExact($lastBootStr, "$dateFormat $timeFormat", [System.Globalization.CultureInfo]::InvariantCulture)
    }

    # Format the start time
    ### $formattedBootTime = $bootTime.ToString("dddd, MMMM dd, yyyy HH:mm:ss", [System.Globalization.CultureInfo]::InvariantCulture)
    $formattedBootTime = $bootTime.ToString("dddd, MMMM dd, yyyy HH:mm:ss", [System.Globalization.CultureInfo]::InvariantCulture) + " [$lastBootStr]"
    Write-Host "System started on: $formattedBootTime" -ForegroundColor DarkGray

    # calculate uptime
    $uptime = (Get-Date) - $bootTime

    # Uptime in days, hours, minutes, and seconds
    $days = $uptime.Days
    $hours = $uptime.Hours
    $minutes = $uptime.Minutes
    $seconds = $uptime.Seconds

    # Uptime output
    Write-Host ("Uptime: {0} days, {1} hours, {2} minutes, {3} seconds" -f $days, $hours, $minutes, $seconds) -ForegroundColor Blue
      

  }
  catch {
    Write-Error "An error occurred while retrieving system uptime."
  }
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
    }
    else {
      Write-Host "Your PowerShell is up to date." -ForegroundColor Green
    }
  }
  catch {
    Write-Error "Failed to update PowerShell. Error: $_"
  }
}

# Check for Profile Updates
function Update-Profile {
  try {
    $url = "$repo_url/powershell/Microsoft.PowerShell_profile.ps1"
    $oldhash = Get-FileHash $PROFILE
    Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
    $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
    if ($newhash.Hash -ne $oldhash.Hash) {
      Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
      Write-Host "Profile has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
    }
    else {
      Write-Host "Profile is up to date." -ForegroundColor Green
    }
  }
  catch {
    Write-Error "Unable to check for `$profile updates: $_"
  }
  finally {
    Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
  }
}

function Repair-Profile {
  & $PROFILE
}

# Check for starship config updates
function Update-Starship-Config {
  try {
    $url = "$repo_url/starship/starship.toml"
    $oldhash = Get-FileHash "$env:USERPROFILE/.config/starship.toml"
    Invoke-RestMethod $url -OutFile "$env:temp/starship.toml"
    $newhash = Get-FileHash "$env:temp/starship.toml"
    if ($newhash.Hash -ne $oldhash.Hash) {
      Copy-Item -Path "$env:temp/starship.toml" -Destination "$env:USERPROFILE/.config/starship.toml" -Force
      Write-Host "Starship Config has been updated." -ForegroundColor Yellow
    }
    else {
      Write-Host "Starship Config is up to date." -ForegroundColor Green
    }
  }
  catch {
    Write-Error "Unable to check for Starship Config updates: $_"
  }
  finally {
    Remove-Item "$env:temp/starship.toml" -ErrorAction SilentlyContinue
  }
}


######################################
#                                    #
#   Powershell Profile Management    #
#                                    #
######################################

if (-not $debug) {
  Update-Starship-Config
}
else {
  Write-Warning "Skipping Starship Config update in debug mode"
}

# Check for updates and update profile
# skip in debug mode
# Check if not in debug mode AND (updateInterval is -1 OR file doesn't exist OR time difference is greater than the update interval)
if (-not $debug -and `
  ($updateInterval -eq -1 -or `
      -not (Test-Path $timeFilePath) -or `
    ((Get-Date).Date - [datetime]::ParseExact((Get-Content -Path $timeFilePath), 'yyyy-MM-dd', $null).Date).TotalDays -gt $updateInterval)) {

  Update-Profile
  Update-PowerShell
  $currentTime = Get-Date -Format 'yyyy-MM-dd'
  $currentTime | Out-File -FilePath $timeFilePath
}
elseif (-not $debug) {
  Write-Warning "PowerShell update skipped. Last update check was within the last $updateInterval day(s)."
}
else {
  Write-Warning "Skipping PowerShell update in debug mode"
}

# Quick Access to Editing the Profile
function Edit-Profile {
  edit $PROFILE.CurrentUserAllHosts
}
Set-Alias -Name ep -Value Edit-Profile


