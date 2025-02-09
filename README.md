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
irm https://bit.ly/nhattVim_window | iex
```

- Set up Wsl (ubuntu & arch):

```bash
bash <(curl -sSL https://bit.ly/nhattVim_wsl)
```

## Ubuntu _(gnome)_

```bash
# script to install dependencies and setup gnome
sudo apt install curl -y
bash <(curl -sSL https://bit.ly/nhattVim_ubuntu)
```

![](https://github.com/nhattVim/assets/blob/master/dotfiles/ubuntu1.png?raw=true)
![](https://github.com/nhattVim/assets/blob/master/dotfiles/ubuntu2.png?raw=true)

## Arch _(hyprland)_

> The majority of this script comes from [JaKooLit](https://github.com/JaKooLit), that's the beauty of open-source :wink:

```bash
# script to install and setup hyprland
bash <(curl -sSL https://bit.ly/nhattVim_arch)
```

![](https://github.com/nhattVim/assets/blob/master/dotfiles/rice4.png?raw=true)
![](https://github.com/nhattVim/assets/blob/master/dotfiles/rice5.png?raw=true)

### Keybindings

<div align="left">

| Keys                                                                                   | Action                                            |
| :------------------------------------------------------------------------------------- | :------------------------------------------------ |
| <kbd>Super</kbd> + <kbd>W</kbd>                                                        | Select wallpaper                                  |
| <kbd>Super</kbd> + <kbd>D</kbd>                                                        | Rofi launcher                                     |
| <kbd>Super</kbd> + <kbd>Q</kbd>                                                        | Close focused window                              |
| <kbd>Super</kbd> + <kbd>T</kbd>                                                        | Launch terminal emulator (kitty)                  |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>T</kbd>                                     | Toggle drop terminal emulator (pyprland)          |
| <kbd>Super</kbd> + <kbd>F</kbd>                                                        | Launch file manager (thunar)                      |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>F</kbd>                                     | Toggle floating window                            |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>F</kbd>                                       | Toggle all float                                  |
| <kbd>Super</kbd> + <kbd>Z</kbd>                                                        | Toggle zoom mode (pyprland)                       |
| <kbd>Super</kbd> + <kbd>Y</kbd>                                                        | Small help file                                   |
| <kbd>Super</kbd> + <kbd>E</kbd>                                                        | Quick edit Hyprland settings                      |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>E</kbd>                                       | Emoji menu                                        |
| <kbd>Super</kbd> + <kbd>S</kbd>                                                        | Online music                                      |
| <kbd>Super</kbd> + <kbd>V</kbd>                                                        | Clipboard                                         |
| <kbd>Super</kbd> + <kbd>M</kbd>                                                        | Maximize window                                   |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>M</kbd>                                     | Fullscreen                                        |
| <kbd>Super</kbd> + <kbd>R</kbd>                                                        | Refresh                                           |
| <kbd>Super</kbd> + <kbd>ESC</kbd>                                                      | Launch logout menu (wlogout)                      |
| <kbd>Super</kbd> + <kbd>B</kbd>                                                        | Toggle topbar (waybar)                            |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>B</kbd>                                     | Toggle blur                                       |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>G</kbd>                                     | Toggle game mode (Animations ON/OFF)              |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>N</kbd>                                     | Toggle notification (swaync)                      |
| <kbd>Super</kbd> + <kbd>Space</kbd>                                                    | Switch Master / Dwindle Layout                    |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Delete</kbd>                                   | Logout                                            |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>L</kbd>                                        | Lock screen                                       |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>W</kbd>                                        | Random wallpaper                                  |
| <kbd>Alt</kbd> + <kbd>Space</kbd>                                                      | Switch keyboard layout                            |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>W</kbd>                                      | Waybar layout menu                                |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd>                                     | Waybar style menu                                 |
| <kbd>Super</kbd> + <kbd>G</kbd>                                                        | Toggle group                                      |
| <kbd>Alt</kbd> + <kbd>Tab</kbd>                                                        | Change focus to another window                    |
| <kbd>Super</kbd> + <kbd>Print</kbd>                                                    | Take screenshot                                   |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Print</kbd>                                 | Take area of screenshot                           |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>S</kbd>                                     | Take area of screenshot (swappy)                  |
| <kbd>Super</kbd> + <kbd>Tab</kbd>                                                      | Next workspaces                                   |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Tab</kbd>                                   | Previous workspaces                               |
| <kbd>Super</kbd> + <kbd>[0-9]</kbd>                                                    | Switch workspaces                                 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> +<kbd>[0-9]</kbd>                                   | Move active window and follow to workspaces [0-9] |
| <kbd>Super</kbd> + <kbd>Shift</kbd> +<kbd>[0-9]</kbd>                                  | Move active window in silent to workspaces [0-9]  |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>U</kbd>                                     | Move to special workspaces                        |
| <kbd>Super</kbd> + <kbd>U</kbd>                                                        | Toggle special workspaces                         |
| <kbd>Super</kbd> + <kbd>H</kbd><kbd>J</kbd><kbd>K</kbd><kbd>L</kbd>                    | Change focus window                               |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>H</kbd><kbd>J</kbd><kbd>K</kbd><kbd>L</kbd>  | Resize window                                     |
| <kbd>Super</kbd> + <kbd>RightClick</kbd>                                               | Resize window (in floating mode)                  |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>H</kbd><kbd>J</kbd><kbd>K</kbd><kbd>L</kbd> | Move window                                       |
| <kbd>Super</kbd> + <kbd>LeftClick</kbd>                                                | Move windows                                      |

</div>

> **Congratulations!** at this point have successfully configured your linux distribution.
>
> # (￣ y▽ ￣)╭ Ohohoho.....
