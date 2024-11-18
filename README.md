<div align="center">
    <h1>Overview 💫</h1>

<!-- &ensp;[<kbd> <br>Window<br> </kbd>](#window)&ensp; -->
<!-- &ensp;[<kbd> <br>Ubuntu<br> </kbd>](#ubuntu-gnome)&ensp; -->
<!-- &ensp;[<kbd> <br>Arch<br> </kbd>](#arch-hyprland)&ensp; -->

</div>

![](https://github.com/nhattruongNeoVim/assets/blob/master/dotfiles/rice1.png?raw=true)

## Window

- Necessary fonts:

  - [MesloLGS NF Regular.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)
  - [MesloLGS NF Bold.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf)
  - [MesloLGS NF Italic.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf)
  - [MesloLGS NF Bold Italic.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)

- Then run this command on powershell:

```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://is.gd/nhattruongNeoVim_window | iex
```

- Set up Wsl (ubuntu & arch):

```bash
bash <(curl -sSL https://is.gd/nhattruongNeoVim_wsl)
```

## Ubuntu _(gnome)_

![](https://github.com/nhattruongNeoVim/assets/blob/master/dotfiles/rice2.png?raw=true)

#### Dependencies

```bash
# script to install dependencies and copy config files
sudo apt install curl -y
bash <(curl -sSL https://is.gd/nhattruongNeoVim_ubuntu)
```

#### Gnome config

- GTK Icons: [Candy icons ](https://github.com/EliverLara/candy-icons)

- GRUB Themes (For dual boot user): [Gnome Grub Theme](https://www.gnome-look.org/p/2076542)

- GTK Themes (Base on): [(Modded) Catppuccin-Mocha-Standard-Mauve-Dark](https://github.com/ART3MISTICAL/dotfiles)

- [Gnome Shell Extensions](https://extensions.gnome.org/):

  - [Aylur's Widget](https://extensions.gnome.org/extension/5338/aylurs-widgets/): Beautiful Plugins with customizable bar
  - [Blur My Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/): Blur the gnome shell
  - [Clipboard History](https://extensions.gnome.org//extension/4839/clipboard-history/): Simple clipboard for gnome
  - [Compiz alike magic lamp effect](https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/): Magic lamp effect alike the macOS minimize effect
  - [Compiz windows effect](https://extensions.gnome.org//extension/3210/compiz-windows-effect/): Compiz wobbly windows effect
  - [Coverflow Alt-Tab](https://extensions.gnome.org//extension/3210/compiz-windows-effect/): Replacement of Alt-Tab, iterates through windows in a cover-flow manner.
  - [Logo menu](https://extensions.gnome.org//extension/4451/logo-menu/): Menu similar to Apple's macOS menu for the GNOME Desktop
  - [No activities button](https://extensions.gnome.org//extension/3184/no-activities-button/): Hide the activities button
  - [Remove App Menu](https://extensions.gnome.org//extension/3906/remove-app-menu/): Remove the application menu from the top bar
  - [Rounded Window Corners](https://extensions.gnome.org/extension/5237/rounded-window-corners/): Rounded corners for all windows
  - [Search Light](https://extensions.gnome.org//extension/5489/search-light/): Take the apps search out of overview
  - [Space Bar](https://extensions.gnome.org//extension/5090/space-bar/): Replaces the 'Activities' button with an i3-like workspaces bar
  - [Top Bar Organizer](https://extensions.gnome.org//extension/4356/top-bar-organizer/): Organize the items of the top (menu)bar
  - [User Themes](https://extensions.gnome.org/extension/19/user-themes/): Load shell themes from user directories
  - [Vitals](https://extensions.gnome.org/extension/1460/vitals/): A simple system monitor on the top bar

- Gnome tweaks (for apply themes and icons ) installation:

  ```zsh
  sudo apt update && sudo apt upgrade
  sudo apt install gnome-tweaks
  ```

  > Then open Tweaks:
  >
  > - Go to Appearance -> Applications -> (Modded) Catppuccin-Mocha-Standard-Mauve-Dark
  > - Go to Appearance -> Shell -> (Modded) Catppuccin-Mocha-Standard-Mauve-Dark
  > - Go to Appearance -> Icons -> Candy-icons

## Arch _(hyprland)_

![](https://github.com/nhattruongNeoVim/assets/blob/master/dotfiles/rice5.png?raw=true)

> The majority of this script comes from [JaKooLit](https://github.com/JaKooLit), that's the beauty of open-source :wink:

```bash
# script to install and setup hyprland
bash <(curl -sSL https://is.gd/nhattruongNeoVim_arch)
```

![](https://github.com/nhattruongNeoVim/assets/blob/master/dotfiles/rice4.png?raw=true)

> **Congratulations!** at this point have successfully configured your linux distribution.
>
> # (￣ y▽ ￣)╭ Ohohoho.....

<!-- https://is.gd/nhattruongNeoVim_nvim -->
<!-- https://is.gd/nhattruongNeoVim_hyprland -->
