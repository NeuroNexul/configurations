## The Configurations

This repository contains the necessory dev-tools configurations for better development experience. The configurations are based on the following tools:

- [Windows Terminal](https://learn.microsoft.com/en-us/windows/terminal/)
- [Powershell Profile](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.5)
- [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/)
- [Starship](https://starship.rs/)
- Etc...

## Windows Terminal

In the windows terminal, make sure to set the default profile to the latest `Windows PowerShell` version, that we gonna install in the next step. Also, download & install **(for all user)** your preferred [Nerd Fonts](https://www.nerdfonts.com/font-downloads). I prefer the `JetBrains Mono` font, but you can choose any font you like.

Set the font in the settings of the Windows Terminal. Navigate to `Settings > Profiles > Defaults > Additional Settings > Appearance > Font Face` and set the installed font. You can also set the font size and other settings as you like.`

## Windows PowerShell

The pre-installed version of windows powershell may be outdated. So, we need to install the latest version of Windows PowerShell. You can download the latest version from the [PowerShell GitHub releases page](https://github.com/powershell/powershell), [Microsoft Store](https://apps.microsoft.com/detail/9mz1snwt0n5d).

After installing the latest version of Windows PowerShell, you can set it as the default profile in the Windows Terminal. Navigate to `Settings > Startup > Default Profile` and select the latest version of Windows PowerShell. You can also set the default terminal to Windows PowerShell in the settings of Windows Terminal. Navigate to `Settings > Startup > Default Terminal Application` and select `Windows Terminal`.

## Powershell Profile

The PowerShell profile is a script that runs every time you start PowerShell. It is used to customize the PowerShell environment. You can add aliases, functions, and other settings to the profile. The profile is located in the following path: `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` or you can get it by the variable `$PROFILE`. You can learn more [here](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.5#profile-types-and-locations). You can also create a new profile if it does not exist. To create a new profile, run the following command in PowerShell:

```powershell
# Run only if the profile does not exist
if (!(Test-Path -Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force
}
```

After creating the profile, you can open it in your preferred text editor. You can use the following command to open the profile in Visual Studio Code:

```powershell
code $PROFILE
```

or, you can open it in Notepad:

```powershell
notepad $PROFILE
```

Then, paste the code from the `powershell/Microsoft.PowerShell_profile.ps1` file in this repository to the profile. You can also add your own customizations to the profile. The profile is a PowerShell script, so you can use any PowerShell commands in it.

<details>
<summary>
<b>If you want to customize the profile on your own, make sure to replace the repository path with your own path. For that, follow the steps below:</b>
</summary>

1. Create a new repository on GitHub or any other platform you prefer. Make sure the repository is public.
2. Clone the repository to your local machine.
3. Open the `powershell/Microsoft.PowerShell_profile.ps1` file in your preferred text editor.
4. Replace the value of the `$repo_url` variable with the path of the repository you created.

   SCHEMA: `$repo_url = "https://raw.githubusercontent.com/<USERNAME>/<REPO_NAME/<DEFAULT_BRANCH>"`,\
   E.g. `$repo_url = "https://raw.githubusercontent.com/NeuroNexul/configurations/main"`

5. Save the file and push the changes to the repository.
6. Now, you can use the profile in your local machine. The profile will automatically update every time you start PowerShell.
</details>

The given profile is designed to perform the following tasks:

- Checks for the updates of Windows Powershell every 7 days, and if there is an update available, it will automatically update itself. You can also set the update interval to your preferred value by changing the `$updateInterval` variable in the profile.
- Checks for any updates on the repository (Powershell Profile & Starship Config) every 7 days, and if there is an update available, it will automatically update itself. You can also set the update interval to your preferred value by changing the `$updateInterval` variable in the profile.
- Installs the latest version of [Starship](https://starship.rs/) if it is not already installed through the `winget` package manager.
- Sets up the Starship prompt by automatically configuring PowerShell to use Starship for a clean, modern, and highly customizable command-line experience.
- Loads custom aliases, functions, and enhancements to improve daily terminal usage, such as shortcuts for common Git operations, system maintenance commands, and productivity boosters.
- Installs Terminal-Icons for better visualization of files and folders in the terminal.

## Useful Commands

<details>
<summary>
<b>Click to expand for useful commands</b>
</summary>

- To check if a command is available in the system, you can use the following command:

  ```powershell
  Test-CommandExists <command_name>
  ```

  If the command exists, it will return True; otherwise, it will return False.

- To edit a file with the default editor, you can use the following command:

  ```powershell
  edit <file_path>
  ```

  This will open the file in the default editor.\
  ORDER: `nvim > code > nano > pvim > vim > vi > notepad++ > sublime_text`

- To create a new file, you can use the following command:

  ```powershell
  touch <file_path>
  ```

  This will create a new file with the specified path. If the file already exists, it will update the last modified date of the file.

- Find a file by name or pattern in the current directory and its subdirectories:

  ```powershell
  ff <file_name_or_pattern>
  ```

  This will search for the file in the current directory and its subdirectories. You can also use wildcards to search for files with a specific pattern.

- Open `WinUtils` by Cheris Titus:

  ```powershell
  # For full release
  winutils
  # For dev release
  winutildev
  ```

  This will open the `WinUtils` application, which is a collection of useful Windows utilities.

- Open PowerShell as administrator:

  ```powershell
  admin
  # or
  su
  ```

  This will open PowerShell as an administrator.

- Find the location of a command:

  ```powershell
  which <command_name>
  ```

  This will return the location of the command in the system.

- Git shortcuts:

  ```powershell
  gs # git status
  ga # git add .
  gc <message> # git commit -m <message>
  gp # git push
  ```

- Get system information:

  ```powershell
  sysinfo # Get system information
  ```

- Flush DNS cache

  ```powershell
  flushdns # Flush DNS cache
  ```

- Get system uptime:

  ```powershell
  uptime # Get system uptime
  ```

- Clear system cache:

  ```powershell
  Clear-Cache # Clear system cache
  ```

- To manually force an update check for PowerShell, you can use:

  ```powershell
  Update-PowerShell
  ```

  This will immediately check for updates to your PowerShell version and install them if available.

- To manually force an update check for the profile, you can use:

  ```powershell
  Update-Profile
  ```

  This will immediately check for updates to your PowerShell profile and install them if available.

- To manually force an update check for Starship, you can use:

  ```powershell
  Update-Starship-Config
  ```

  This will immediately check for updates to your Starship installation and install them if available.

</details>

If you want to add more commands, you can add them to the profile. You can also create a new file for the commands and import it in the profile. The profile is a PowerShell script, so you can use any PowerShell commands in it.

## Conclusion

This repository contains the configurations that I use in my daily development. You can use the configurations as they are or customize them to your liking. The configurations are designed to improve the development experience and make it easier to work with PowerShell and Windows Terminal. If you have any questions or suggestions, feel free to open an issue or a pull request. Happy coding!

In near future, I will add more configurations for other tools like `Neovim`, `VSCode`, `Windows Terminal`, and other tools. If you have any suggestions for the configurations, feel free to open an issue or a pull request. I will be happy to add them to the repository.
