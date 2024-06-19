# 🚧 WIP 🚧

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/IndrekHaav/pac/lint.yml?branch=main&label=lint)](https://github.com/IndrekHaav/pac/actions/workflows/lint.yml)

# What is this?

This script - `pac.sh` - is a simple [pacman](https://wiki.archlinux.org/title/Pacman) helper for [Arch Linux](https://archlinux.org/) that provides syntax similar to [apt](https://wiki.debian.org/AptCLI). For example, `pac install <package>` instead of `pacman -S <package>`. It can be useful to those who, like me, sometimes forget the proper pacman flags to use.

The script implements a subset of apt commands and translates them to [corresponding pacman invocations](https://wiki.archlinux.org/title/Pacman/Rosetta).

## What this is not

This script is **not**:

 - a full-featured pacman wrapper
 - a port of `apt` to Arch
 - a replacement for AUR helpers like yay

# How to install?

Clone the repo and copy or symlink the script to a directory that's in the $PATH:

```shell
$ git clone https://github.com/medicamin/pac
$ ln -s $(realpath pac/pac.sh) ~/.local/bin/pac
```

If you happen to have a binary called `pac` already installed (check with `which pac`), then just use another name for the symlink.

# Requirements:

```
$ sudo pacman -S pacman-contrib reflector fzf pkgfile
```
an AUR Helper
and an admin commander such as sudo or doas

# How to use?

Run `pac` with no arguments to get an overview of the supported commands:

```shell
$ pac
Usage: pac command

Working with Packages
    -s,  search <string>	Search for packages matching <string>
    -f,  find <file>		Find the package owner of the file (path or name) 
    -sh, show <packages>	Returns information about <packages>
    -i,  install <packages>	Install <packages>
    -r,  remove <packages>	Remove <packages>
    -rd, removedep <packages>	Remove <packages> and all their dependencies
    -ro, removeorphan		Remove all orphan packages and their dependencies
    -u,  update			Perform a full system upgrade
    -m,  mirrors		Generate mirrorlist sorted by 10 fastest servers
    -d,  depends <package>	Shows a list of dependencies for <package>
    -do, dependson <package>	Shows a list of packages that depend on <package>
    -v,  view			Display content of a file inside a tar package
    
Browse packages
    -bd, database	  	Browse all available packages
    -bi, installed	  	Browse all installed packages
    -bf, foreign	  	Browse all manually installed packages
    -bn, nodeps	  		Browse packages with no dependency
    -bo, orphans	  	Browse orphan packages
    -bu, updatable	  	Browse upgradable packages
    -l,  list			Create a list of installed packages in the home directory
    
Pacman Database
    -c,  clean			Clear pacman cache, keeps only latest package
    -p,  purge			Clear pacman cache, keeps nothing   
    -db, unlock			Unlock database by removing /var/lib/pacman/db.lck
```
