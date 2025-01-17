#!/bin/bash

source <(curl -sSL https://is.gd/nhattVim_lib)

# gum style \
#     --border-foreground 6 --border rounded \
#     --align left --width 104 --margin "1 2" --padding "2 4" \
#     "${YELLOW}WARN:${CYAN} Ensure that you have a stable internet connection ${YELLOW}(Highly Recommended!!!!)      ${RESET}" \
#     "                                                                                                               ${RESET}" \
#     "${YELLOW}WARN:${CYAN} You will be required to answer some questions during the installation!!                  ${RESET}" \
#     "                                                                                                               ${RESET}" \
#     "${YELLOW}WARN:${CYAN} If you are installing on a VM, ensure to enable 3D acceleration else Hyprland wont start!${RESET}"

gum style \
    --border-foreground 6 --border rounded \
    --align left --width 104 --margin "1 2" --padding "2 4" \
    "${YELLOW}WARN:${CYAN} Ensure that you have a stable internet connection ${YELLOW}(Highly Recommended)      ${RESET}" \
    "                                                                                                               ${RESET}" \
    "${YELLOW}WARN:${CYAN} You will be required to answer some questions during the installation                  ${RESET}" \
    "                                                                                                               ${RESET}" \
    "${YELLOW}WARN:${CYAN} If you are installing on a VM, ensure to enable 3D acceleration else Hyprland wont start${RESET}"
