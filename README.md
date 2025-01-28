<div align="center">
    <h1>Overview 💫</h1>
</div>

![](https://github.com/nhattVim/assets/blob/master/dotfiles/rice1.png?raw=true)

## Window

- Necessary fonts:

  - [MesloLGS NF Regular.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)
  - [MesloLGS NF Bold.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf)
  - [MesloLGS NF Italic.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf)
  - [MesloLGS NF Bold Italic.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)

- Then run this command on powershell:

```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://is.gd/nhattVim_window | iex
```

- Set up Wsl (ubuntu & arch):

```bash
bash <(curl -sSL https://is.gd/nhattVim_wsl)
```

## Ubuntu _(gnome)_

```bash
# script to install dependencies and setup gnome
sudo apt install curl -y
bash <(curl -sSL https://is.gd/nhattVim_ubuntu)
```

![](https://github.com/nhattVim/assets/blob/master/dotfiles/ubuntu1.png?raw=true)
![](https://github.com/nhattVim/assets/blob/master/dotfiles/ubuntu2.png?raw=true)

## Arch _(hyprland)_

> The majority of this script comes from [JaKooLit](https://github.com/JaKooLit), that's the beauty of open-source :wink:

```bash
# script to install and setup hyprland
bash <(curl -sSL https://is.gd/nhattVim_arch)
```

![](https://github.com/nhattVim/assets/blob/master/dotfiles/rice4.png?raw=true)
![](https://github.com/nhattVim/assets/blob/master/dotfiles/rice5.png?raw=true)

<!-- <div align="center"> -->
<!---->
<!-- | Keys                                                                                                     | Action                                                            | -->
<!-- | :------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------- | -->
<!-- | <kbd>Super</kbd> + <kbd>Q</kbd>                                                                          | Close focused window                                              | -->
<!-- | <kbd>Super</kbd> + <kbd>Del</kbd>                                                                        | Kill Hyprland session                                             | -->
<!-- | <kbd>Super</kbd> + <kbd>W</kbd>                                                                          | Toggle the window between focus and float                         | -->
<!-- | <kbd>Super</kbd> + <kbd>G</kbd>                                                                          | Toggle the window between focus and group                         | -->
<!-- | <kbd>Super</kbd> + <kbd>slash</kbd>                                                                      | Launch keybinds hint                                              | -->
<!-- | <kbd>Alt</kbd> + <kbd>Enter</kbd>                                                                        | Toggle the window between focus and fullscreen                    | -->
<!-- | <kbd>Super</kbd> + <kbd>L</kbd>                                                                          | Launch lock screen                                                | -->
<!-- | <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>F</kbd>                                                       | Toggle pin on focused window                                      | -->
<!-- | <kbd>Super</kbd> + <kbd>Backspace</kbd>                                                                  | Launch logout menu                                                | -->
<!-- | <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>W</kbd>                                                          | Toggle waybar                                                     | -->
<!-- | <kbd>Super</kbd> + <kbd>T</kbd>                                                                          | Launch terminal emulator (kitty)                                  | -->
<!-- | <kbd>Super</kbd> + <kbd>E</kbd>                                                                          | Launch file manager (dolphin)                                     | -->
<!-- | <kbd>Super</kbd> + <kbd>C</kbd>                                                                          | Launch text editor (vscode)                                       | -->
<!-- | <kbd>Super</kbd> + <kbd>F</kbd>                                                                          | Launch web browser (firefox)                                      | -->
<!-- | <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Esc</kbd>                                                      | Launch system monitor (htop/btop or fallback to top)              | -->
<!-- | <kbd>Super</kbd> + <kbd>A</kbd>                                                                          | Launch application launcher (rofi)                                | -->
<!-- | <kbd>Super</kbd> + <kbd>Tab</kbd>                                                                        | Launch window switcher (rofi)                                     | -->
<!-- | <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd>                                                       | Launch file explorer (rofi)                                       | -->
<!-- | <kbd>F10</kbd>                                                                                           | Toggle audio mute                                                 | -->
<!-- | <kbd>F11</kbd>                                                                                           | Decrease volume                                                   | -->
<!-- | <kbd>F12</kbd>                                                                                           | Increase volume                                                   | -->
<!-- | <kbd>Super</kbd> + <kbd>P</kbd>                                                                          | Partial screenshot capture                                        | -->
<!-- | <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>P</kbd>                                                        | Partial screenshot capture (frozen screen)                        | -->
<!-- | <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>P</kbd>                                                         | Monitor screenshot capture                                        | -->
<!-- | <kbd>PrtScn</kbd>                                                                                        | All monitors screenshot capture                                   | -->
<!-- | <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>G</kbd>                                                         | Disable hypr effects for gamemode                                 | -->
<!-- | <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>→</kbd><kbd>←</kbd>                                             | Cycle wallpaper                                                   | -->
<!-- | <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>↑</kbd><kbd>↓</kbd>                                             | Cycle waybar mode                                                 | -->
<!-- | <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd>                                                       | Launch wallbash mode select menu (rofi)                           | -->
<!-- | <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>T</kbd>                                                       | Launch theme select menu (rofi)                                   | -->
<!-- | <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>A</kbd>                                                       | Launch style select menu (rofi)                                   | -->
<!-- | <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>X</kbd>                                                       | Launch theme style select menu (rofi)                             | -->
<!-- | <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd>                                                       | Launch wallpaper select menu (rofi)                               | -->
<!-- | <kbd>Super</kbd> + <kbd>V</kbd>                                                                          | Launch clipboard (rofi)                                           | -->
<!-- | <kbd>Super</kbd> + <kbd>K</kbd>                                                                          | Switch keyboard layout                                            | -->
<!-- | <kbd>Super</kbd> + <kbd>←</kbd><kbd>→</kbd><kbd>↑</kbd><kbd>↓</kbd>                                      | Move window focus                                                 | -->
<!-- | <kbd>Alt</kbd> + <kbd>Tab</kbd>                                                                          | Change window focus                                               | -->
<!-- | <kbd>Super</kbd> + <kbd>[0-9]</kbd>                                                                      | Switch workspaces                                                 | -->
<!-- | <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>←</kbd><kbd>→</kbd>                                            | Switch workspaces to a relative workspace                         | -->
<!-- | <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>↓</kbd>                                                        | Move to the first empty workspace                                 | -->
<!-- | <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>←</kbd><kbd>→</kbd><kbd>↑</kbd><kbd>↓</kbd>                   | Resize windows                                                    | -->
<!-- | <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>[0-9]</kbd>                                                   | Move focused window to a relative workspace                       | -->
<!-- | <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Ctrl</kbd> + <kbd>←</kbd><kbd>→</kbd><kbd>↑</kbd><kbd>↓</kbd> | Move focused window (tiled/floating) around the current workspace | -->
<!-- | <kbd>Super</kbd> + <kbd>MouseScroll</kbd>                                                                | Scroll through existing workspaces                                | -->
<!-- | <kbd>Super</kbd> + <kbd>LeftClick</kbd><br><kbd>Super</kbd> + <kbd>Z</kbd>                               | Move focused window                                               | -->
<!-- | <kbd>Super</kbd> + <kbd>RightClick</kbd><br><kbd>Super</kbd> + <kbd>X</kbd>                              | Resize focused window                                             | -->
<!-- | <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>S</kbd>                                                         | Move/Switch to special workspace (scratchpad)                     | -->
<!-- | <kbd>Super</kbd> + <kbd>S</kbd>                                                                          | Toggle to special workspace                                       | -->
<!-- | <kbd>Super</kbd> + <kbd>J</kbd>                                                                          | Toggle focused window split                                       | -->
<!-- | <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>[0-9]</kbd>                                                     | Move focused window to a workspace silently                       | -->
<!-- | <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>H</kbd>                                                        | Move between grouped windows backward                             | -->
<!-- | <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>L</kbd>                                                        | Move between grouped windows forward                              | -->
<!---->
<!-- </div> -->

> **Congratulations!** at this point have successfully configured your linux distribution.
>
> # (￣ y▽ ￣)╭ Ohohoho.....
