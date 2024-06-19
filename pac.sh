#!/bin/sh
#
# pm or pac or whatever you call it, is a simple script to make working with pacman easier
# Author: Amin medicamin@gmail.com http://linuxvaman.ir 
# Based on https://github.com/IndrekHaav/pac
#

set -eu

RESET="\033[0m"
RED="\033[1;31m"
BOLD="\033[1m"

#Change if you have another AUR helper
#Or replace yay with pacman if you don't use AUR at all.
HELPER=yay

#You may use another super user helper, such as doas
SUSR=sudo

#You can define search options based on your needs
#Change if you use helpers other than yay, or leave it blank
HELPERSEARCH=--topdown

__usage() {

    cat <<EOF
Usage: $(basename "$0") command
$(echo -e "${BOLD}Requirements:${RESET}") pacman-contrib reflector fzf pkgfile yay (or other AUR helpers)

$(echo -e "${BOLD}Working with Packages${RESET}")
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
    
$(echo -e "${BOLD}Browse packages${RESET}")
    -bd, database	  	Browse all available packages
    -bi, installed	  	Browse all installed packages
    -bf, foreign	  	Browse all manually installed packages
    -bn, nodeps	  		Browse packages with no dependency
    -bo, orphans	  	Browse orphan packages
    -bu, updatable	  	Browse upgradable packages
    -l,  list			Create a list of installed packages in the home directory
    
$(echo -e "${BOLD}Pacman Database${RESET}")
    -c,  clean			Clear pacman cache, keeps only latest package
    -p,  purge			Clear pacman cache, keeps nothing   
    -db, unlock			Unlock database by removing /var/lib/pacman/db.lck
    
EOF
    exit
}

__error() {
    printf "${RED}error:${RESET} %s\n" "$1"
}

__fatal() {
    __error "$1"
    exit 1
}

[ "$#" -gt 0 ] || __usage

case "$1" in

    -s|search) #Search for packages matching <string>
        shift
        command -v $HELPER > /dev/null || __fatal "change HELPER in the source or install yay"
        [ "$#" -eq 1 ] || __fatal "enter a search term"
        $HELPER -Ss "$@" $HELPERSEARCH
        ;;
        
    -f|find) #Find the package owner of the file (path or name) 
        shift
        command -v pkgfile > /dev/null || __fatal "install pkgfile to use this functionality"
        [ "$#" -gt 0 ] || __fatal "enter something"
        pkgfile "$@"
        ;;
        
    -sh|show) #Returns information about <packages>
        shift
        [ "$#" -gt 0 ] || __fatal "enter a package name"
        for package in "$@"; do
            pacman -Qi "$package" 2>/dev/null || pacman -Si "$package" 2>/dev/null || __error "package '$package' was not found"
        done
        ;;
        
    -i|install) #Install <packages>
        shift
        [ "$#" -gt 0 ] || __fatal "enter a package name"
        if [ -f "$*" ]; then pacman -U "$*"; else $HELPER -S "$@"; fi
        ;;
        
    -r|remove) #Remove <packages>
        shift
        [ "$#" -gt 0 ] || __fatal "enter a package name"
        $SUSR pacman -R "$@"
        ;;
        
    -rd|removedep) #Remove <packages> and all their dependencies
        shift
        pkgs=${*:-$(pacman -Qdtq)}
        # shellcheck disable=SC2086
        [ -n "$pkgs" ] && $SUSR pacman -Rns $pkgs
        ;;
        
    -ro|removeorphan) #Remove all orphan packages and their dependencies
        pacman -Qdtq | $SUSR pacman -Rns -
        ;;
             
    -u|update) #Perform a full system upgrade
        $HELPER -Syu
        ;;
        
    -m|mirrors) #Generate mirrorlist sorted by 10 fastest servers
        shift
        command -v reflector > /dev/null || __fatal "install reflector to use this functionality"
        $SUSR reflector --age 6 --fastest 10 --latest 10 --sort rate --protocol https --save /etc/pacman.d/mirrorlist
        ;;
        
    -d|depends) #Shows a list of dependencies for <package>
        shift
        command -v pactree > /dev/null || __fatal "install pacman-contrib to use this functionality"
        [ "$#" -gt 0 ] || __fatal "enter a package name"
        pactree -s -d1 -o1 "$@"
        ;;
        
    -do|dependson) #Shows a list of packages that depend on <package>
        shift
        command -v pactree > /dev/null || __fatal "install pacman-contrib to use this functionality"
        [ "$#" -gt 0 ] || __fatal "enter a package name"
        pactree -r -s -d1 -o1 "$@"
        ;;

    -v|view) #Display content of a file inside a tar package
    	shift
    	[ "$#" -gt 1 ] || __fatal "example: pm -v /path/to/package.pkg.tar.zst etc/file.conf "
        bsdtar -xOf $2 $3
        ;;
        
     -bd|database) #Browse all available packages
        shift
        command -v pactree > /dev/null || __fatal "install fzf to use this functionality"
        pacman -Slq | fzf -e --padding=4%,0,0,0 --margin=4%,0,0,0 --no-scrollbar --info=inline-right  --border=top --border-label='╢ Browse all available packages ╟' --border-label-pos=3 --preview 'pacman -Si {}' --layout=reverse-list 
        ;;
        
     -bi|installed) #Browse all installed packages
        shift
        command -v pactree > /dev/null || __fatal "install fzf to use this functionality"
        pacman -Qq | fzf -e --padding=4%,0,0,0 --margin=4%,0,0,0 --no-scrollbar --info=inline-right  --border=top --border-label='╢ Browse all installed packages ╟' --border-label-pos=3 --preview 'pacman -Qil {}' --layout=reverse-list --bind 'enter:execute(pacman -Qil {} | less)' 
        ;;
         
     -bf|foreign) #Browse all manually installed packages
        shift
        command -v pactree > /dev/null || __fatal "install fzf to use this functionality"
        pacman -Qqm | fzf -e --padding=4%,0,0,0 --margin=4%,0,0,0 --no-scrollbar --info=inline-right  --border=top --border-label='╢ Browse all manually installed packages ╟' --border-label-pos=3 --preview 'pacman -Qil {}' --layout=reverse-list --bind 'enter:execute(pacman -Qil {} | less)' 
        ;;
        
     -bn|nodeps) #Browse packages with no dependency
        shift
        command -v pactree > /dev/null || __fatal "install fzf to use this functionality"
        pacman -Qqent | fzf -e --padding=4%,0,0,0 --margin=4%,0,0,0 --no-scrollbar --info=inline-right  --border=top --border-label='╢ Browse installed packages without dependency ╟' --border-label-pos=3 --preview 'pacman -Qil {}' --layout=reverse-list --bind 'enter:execute(pacman -Qil {} | less)' 
        ;;
        
     -bo|orphans) #Browse orphan packages
        shift
        command -v pactree > /dev/null || __fatal "install fzf to use this functionality"
        pacman -Qdtq | fzf -e --padding=4%,0,0,0 --margin=4%,0,0,0 --no-scrollbar --info=inline-right  --border=top --border-label='╢ Browse orphan packages ╟' --border-label-pos=3 --preview 'pacman -Qil {}' --layout=reverse-list --bind 'enter:execute(pacman -Qil {} | less)' 
        ;;
        
     -bu|updatable) #Browse upgradable packages
        shift
        command -v pactree > /dev/null || __fatal "install fzf to use this functionality"
        pacman -Qu | fzf -e --padding=4%,0,0,0 --margin=4%,0,0,0 --no-scrollbar --info=inline-right  --border=top --border-label='╢ Browse upgradable packages ╟' --border-label-pos=3 --layout=reverse-list --preview-window=hidden
        ;;

    -l|list) #Create a list of installed packages in the home directory
    	pacman -Qq >~/pkglist_all.txt;
	echo "packages list sorted by name: $HOME/pkglist_all.txt"
        ;;
      
    -c|clean) #Clear pacman cache, keeps only latest package
    	command -v paccache > /dev/null || __fatal "install pacman-contrib to use this functionality"
        $SUSR paccache -rk1
        ;;  
        
    -p|purge) #Clear pacman cache, keeps nothing
        $SUSR pacman -Sc
        ;;

    -db|unlock) #Unlocks database by removing /var/lib/pacman/db.lck 
        $SUSR rm /var/lib/pacman/db.lck
        ;;
        
    *)
        __usage
        ;;
esac
