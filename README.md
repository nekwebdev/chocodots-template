# chocodots - cocoa flavoured dot files

Companion repository template for [chocolate-template](https://github.com/nekwebdev/chocolate-template) Arch Linux install script.

## how and what?

Use it as a starter point for your own dots!

Make a new repository by using the template option in github instead of forking it.

Don't forget that this is a bare git repository. So you can't just `git clone` it.

    work_tree="/path/to/folder"
    git_dir="/path/to/folder/.config/dotfiles"
    chocodots="/usr/bin/git --git-dir=$git_dir --work-tree=$work_tree"
    mkdir -p "$git_dir"
    git init --bare "$git_dir"
    $dots config status.showUntrackedFiles no
    $dots remote add origin https://urltoyourrepo.git
    $dots branch -m main
    $dots pull origin main

Create an alias named for example chocodots for `/usr/bin/git --git-dir=/path/to/folder/.config/dotfiles --work-tree=/path/to/folder`

Now always use `chocodots` instead of `git` when working on this bare repository.

These dots only contain the base shell profiles and stratup scripts as well as a zsh config with function helpers to load and manage plugins, no need for oh-my-zsh.

## profile, xprofile, zprofile, zshrc, zshenv, bashrc, bash_profile, inputrc, Xresources, why so damn many?!?

In an effort to clean up the home folder of lone dotfiles I copied Luke Smith's approach of having only two *entry points* into those various files you would expect to see in the home folder:

    `~/.xprofile`  ->  `~/.config/X11/xprofile`
    `~/.zprofile`  ->  `~/.config/shell/profile`

I suggest reading a very nice [blog post](https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/) on the subject.

How these dotfiles set it up:

                  boot loader (grub)
                 /                  \
             tty1                    display manager
              |                             |
       source ~/.zprofile    run the dm session wrapper script  
              |                             |
         startx xinitrc             source ~/.zprofile
              |                             |
    source ~/.xprofile & start the window manager/desktop environment


The shell profile is handled by `~/.config/shell/profile`.

If you want to use bash instead replace `~/.zprofile` by a `~/.profile` symlink to `~/.config/shell/profile`.

This profile is only sourced by interactive login shell, ie when you login in a tty or through ssh.

It is in charge of setting up environment variables. They are all set by conf files in `~/.config/environment.d/` as recommended by the [Arch wiki](https://wiki.archlinux.org/title/environment_variables#Per_user). It allows those variables to also be available to the user systemd services.

`~/.config/shell/profile` also has a little trick which makes your login tty1 prompt sort of a display manager:

    [ "$(tty)" = "/dev/tty1" ] && ! pidof -s Xorg >/dev/null 2>&1 && exec startx "$XINITRC"

As soon as you login startx will run `~/.config/X11/xinitrc` which will simply do part of the job of a display manager: source `~/.config/X11/xprofile` and start your window manager/desktop environment.

`~/.config/X11/xprofile` should contain programs that needs to be auto started when your wm/de starts as well as initial configurations and settings that need to be set at each new x session. Only use the built in wm/de autostart functions for programs specific to it or that needs to be started after the wm/de starts.

A display manager is considered an interactive non-login shell so they use a session wrapper script to source the shell profile, but some like `lightdm` do not source `~/.zprofile`. To solve this `~/.config/X11/xprofile` can also source `~/.config/shell/profile` if it hasn't been done already or change your session wrapper script so that it sources `~/.zprofile`.

All subsequent interactive shells, such as opening your terminal, do not source `~/.config/shell/profile` since they already *have* the environment variables set, but instead source `~/.config/zsh/.zshrc` thanks to the **ZDOTDIR** environment variable.

With this setup you can easily go from using a display manager or not and keep a very clean home directory. If you dont plan to use a display manager, you can delete the `~/.xprofile` symlink to clean up the home folder.

## zsh

Thats the only strong opinion this template has, so a solid configuration is included.

[Powerlevel10k](https://github.com/romkatv/powerlevel10k) is a very customizable prompt and you'll go through a configuration script when you first start it. These dotfiles ship with their customized font based on [Meslo Nerd Font](https://www.nerdfonts.com/font-downloads). The default system `monospace` font has been set to Meslo in `~/.config/fontconfig/fonts.conf`.

[dotbare](https://github.com/kazhala/dotbare) to help manage the dotfiles bare git repository.

`~/.local/bin/zsh/zsh-plugins-update` script to update all cloned plugins in `~/.config/zsh/plugins`.

Various functions to handle plugins, much like a full fledge zsh plugin manager.

Warning: The first time you source `~/.config/zsh/.zshrc` by opening a terminal it will download all plugins and build a fzf tab module for faster completions and suggestions, which can take a while.

## cocoa

[chocolate-template](https://github.com/nekwebdev/chocolate-template) `extra.sh` script will source if present `~/.config/cocoa/cocoa.sh` and run the configuration function inside of it. If present it will also install all packages in `~/.config/cocoa/packages.csv`.

That's how you can get a fully installed and configured system that matches your dotfiles setup. The example in this template will setup a bare bones suckless based environment with dwm, st, dmenu and surf.

## credits

- [Luke Smith's Voidrice](https://github.com/LukeSmithxyz/voidrice)

- [Christian Chiarulli's Machfiles](https://github.com/ChristianChiarulli/Machfiles)
