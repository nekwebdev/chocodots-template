# https://github.com/nekwebdev/chocodots-template
# @nekwebdev
# LICENSE: GPLv3

# no shebang, this is only sourced by chocolate extra.sh in:
# https://github.com/nekwebdev/chocolate-template
# it will fail miserably if ran

###### => files templates ######################################################
# /usr/share/xsessions/dwm.desktop
DWM_DESKTOP="$(cat <<-EOF
[Desktop Entry]
Encoding=UTF-8
Name=dwm
GenericName=Window manager
Comment=This session starts dwm
Exec=dwm
Icon=dwm
NoDisplay=true
Type=Application
EOF
)"

###### => functions ############################################################
# configures the system for the dotfiles
function addCocoa() {
  local packages=/home/${CHOCO_USER}/.config/cocoa/packages.csv
  [[ -f $packages ]] && installPackages "$packages"

  _echo_step "Cocoa system configuration from dotfiles"; echo

  # start building the script that will be run by .zshrc once
  # mostly for systemd user stuff we can not do in chroot...
  _echo_step "  (Create run script for first boot)"
  local run_script=/home/${CHOCO_USER}/run.sh
  echo "#!/usr/bin/env bash" > "$run_script"
  _echo_success

  _echo_step "  (Set $CHOCO_USER default shell to zsh)"
  chsh -s /usr/bin/zsh "$CHOCO_USER" >/dev/null 2>&1
  rm -rf /home/"$CHOCO_USER"/.bashrc /home/"$CHOCO_USER"/.bash_profile \
        /home/"$CHOCO_USER"/.bash_login /home/"$CHOCO_USER"/.profile \
        /home/"$CHOCO_USER"/.bash_logout
  _echo_success

  _echo_step "  (Configure doas)"
  echo "permit persist :wheel as root" > /etc/doas.conf
  _echo_success

  _echo_step "  (Add enable xbanish systemd user service to run script)"
  echo "systemctl enable --user --now xbanish.service" >> "$run_script"
  _echo_success

  _echo_step "  (Enable Ly as default display manager)"
  systemctl enable -f ly.service >/dev/null 2>&1
  echo "$CHOCO_USER" > /etc/ly/save
  _echo_success

  _echo_step "  (Create dwm xsession desktop file)"
  mkdir -p /usr/share/xsessions
  echo "$DWM_DESKTOP" > /usr/share/xsessions/dwm.desktop
  _echo_success

  # finish the run script by having it clean up .zshrc and delete itself
  _echo_step "  (Finalize run script for first boot)"
  echo -e "\n[ -f /home/$CHOCO_USER/run.sh ] && /home/$CHOCO_USER/run.sh # DELETEME" >> /home/"$CHOCO_USER"/.config/zsh/.zshrc
  echo "sed -i '/DELETEME/d' /home/$CHOCO_USER/.config/zsh/.zshrc" >> "$run_script"
  echo "rm -f $run_script" >> "$run_script"
  chmod +x "$run_script"
  chown "$CHOCO_USER":wheel "$run_script"
  _echo_success; echo
}
