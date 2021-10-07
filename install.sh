#!/bin/bash

# ----------------------------- Color definition ----------------------------- #

black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`
bold=`tput bold`
reset=`tput sgr0`

randomColorNumber=$((0 + $RANDOM % 7))
randomColor=`tput setaf ${randomColorNumber}`

emojiCheck='\xE2\x9C\x85'
emojiCross='\xE2\x9D\x8C'

# ------------------------------- Set variables ------------------------------ #

# Shells
bashrc=0
zshrc=0

# Tools
goInstalled=0
gobusterInstalled=0
gowitnessInstalled=0
assetfinderInstalled=0
amassInstalled=0
httprobeInstalled=0
subjackInstalled=0
waybackurlsInstalled=0

# -------------------------------- Check Tools ------------------------------- #

genericError () {
    echo -e "${red}${bold}\nError while running the script! Exiting...${reset}\n"
    exit
}

genericSuccess () {
    echo -e "${green}${bold}\nThe installation was successfull, enjoy Automap!${reset}\n"
    exit
}

checkGo () {
    if command -v go &> /dev/null
    then
        goInstalled=1
        
        echo -e "go\t\t${emojiCheck}"
    else
        echo -e "go\t\t${emojiCross}"
    fi
}

checkGobuster () {
    if command -v gobuster &> /dev/null
    then
        gobusterInstalled=1
        
        echo -e "gobuster\t${emojiCheck}"
    else
        echo -e "gobuster\t${emojiCross}"
    fi
}

checkGowitness () {
    if command -v gowitness &> /dev/null
    then
        gowitnessInstalled=1
        
        echo -e "gowitness\t${emojiCheck}"
    else
        echo -e "gowitness\t${emojiCross}"
    fi
}

checkAssetfinder () {
    if command -v assetfinder &> /dev/null
    then
        assetfinderInstalled=1
        
        echo -e "assetfinder\t${emojiCheck}"
    else
        echo -e "assetfinder\t${emojiCross}"
    fi
}

checkAmass () {
    if command -v amass &> /dev/null
    then
        amassInstalled=1
        
        echo -e "amass\t\t${emojiCheck}"
    else
        echo -e "amass\t\t${emojiCross}"
    fi
}

checkHttprobe () {
    if command -v httprobe &> /dev/null
    then
        httprobeInstalled=1
        
        echo -e "httprobe\t${emojiCheck}"
    else
        echo -e "httprobe\t${emojiCross}"
    fi
}

checkSubjack () {
    if command -v subjack &> /dev/null
    then
        subjackInstalled=1
        
        echo -e "subjack\t\t${emojiCheck}"
    else
        echo -e "subjack\t\t${emojiCross}"
    fi
}

checkWaybackurls () {
    if command -v waybackurls &> /dev/null
    then
        waybackurlsInstalled=1
        
        echo -e "waybackurls\t\t${emojiCheck}"
    else
        echo -e "waybackurls\t\t${emojiCross}"
    fi
}

checkTools () {
    echo -e "${bold}Checking Tools...${reset}"
    
    checkGo
    checkGobuster
    checkGowitness
    checkAssetfinder
    checkAmass
    checkHttprobe
    checkSubjack
    checkWaybackurls

}

checkShell () {

    if test -f "$HOME/.bashrc"; then
        bashrc=1
    fi
    if test -f "$HOME/.zshrc"; then
        zshrc=1
    fi

}

installGo () {
    goBaseUrl="https://golang.org/dl/"

    echo "${bold}Downloading latest version of Go...${reset}"
    wget --quiet --continue "${goBaseUrl}"
    goUrlPath=$(grep ".linux-amd64.tar.gz" index.html | head -n 1 | cut -d ' ' -f4 | sed 's/href="//;s/">//;s/\/dl\///')
    goUrl="$goBaseUrl$goUrlPath"
    wget --quiet --continue "${goUrl}"
    rm index.html

    tput civis    
    tput cuu1
    tput cnorm

    echo "${bold}Installing latest version of Go...${reset}"
    sudo tar -C /usr/local -xzf $goUrlPath
    rm ./$goUrlPath
    
    if [[ $zshrc -eq 1 ]]; then

        sudo echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> $HOME/.zshrc
        source $HOME/.zshrc

    elif [[ $bashrc -eq 1 ]]; then
        
        sudo echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> $HOME/.bashrc
        source $HOME/.bashrc

    fi
    
    echo -e "${green}${bold}Go installed successfully!\n${reset}"
}

installGobuster () {
    echo "${bold}Installing gobuster...${reset}"
    go install github.com/OJ/gobuster/v3@latest

    commandResult=$?

    if [ commandResult ]; then
        echo -e "${green}${bold}Gobuster installed successfully!\n${reset}"
    else
        echo -e "${red}${bold}Gobuster could not be installed!\n${reset}"
        exit
    fi
}

installGowitness () {
    echo "${bold}Installing gowitness...${reset}"
    go get -u github.com/sensepost/gowitness

    commandResult=$?

    if [ commandResult ]; then
        echo -e "${green}${bold}Gowitness installed successfully!\n${reset}"
    else
        echo -e "${red}${bold}Gowitness could not be installed!\n${reset}"
        exit
    fi
}

installAssetfinder () {
    echo "${bold}Installing assetfinder...${reset}"
    go get -u github.com/tomnomnom/assetfinder

    commandResult=$?

    if [ commandResult ]; then
        echo -e "${green}${bold}Assetfinder installed successfully!\n${reset}"
    else
        echo -e "${red}${bold}Assetfinder could not be installed!\n${reset}"
        exit
    fi
}

installAmass () {
    echo "${bold}Installing amass...${reset}"
    go get -v github.com/OWASP/Amass/v3/...

    commandResult=$?

    if [ commandResult ]; then
        echo -e "${green}${bold}Amass installed successfully!\n${reset}"
    else
        echo -e "${red}${bold}Amass could not be installed!\n${reset}"
        exit
    fi
}

installHttprobe () {
    echo "${bold}Installing httprobe...${reset}"
    go get -u github.com/tomnomnom/httprobe

    commandResult=$?

    if [ commandResult ]; then
        echo -e "${green}${bold}Httprobe installed successfully!\n${reset}"
    else
        echo -e "${red}${bold}Httprobe could not be installed!\n${reset}"
        exit
    fi
}

installSubjack () {
    echo "${bold}Installing subjack...${reset}"
    go get github.com/haccer/subjack

    commandResult=$?

    if [ commandResult ]; then
        echo -e "${green}${bold}Subjack installed successfully!\n${reset}"
    else
        echo -e "${red}${bold}Subjack could not be installed!\n${reset}"
        exit
    fi
}

installWaybackurls () {
    echo "${bold}Installing waybackurls...${reset}"
    go get github.com/tomnomnom/waybackurls

    commandResult=$?

    if [ commandResult ]; then
        echo -e "${green}${bold}Waybackurls installed successfully!\n${reset}"
    else
        echo -e "${red}${bold}Waybackurls could not be installed!\n${reset}"
        exit
    fi
}

installTools () {

    echo -e "${bold}\nUpdating...${reset}"
    sudo apt update > /dev/null 2>/dev/null

    if [ $goInstalled -ne 1 ]; then
        installGo
    fi

    if [ $gobusterInstalled -ne 1 ]; then
        installGobuster
    fi

    if [ $gowitnessInstalled -ne 1 ]; then
        installGowitness
    fi

    if [ $assetfinderInstalled -ne 1 ]; then
        installAssetfinder
    fi

    if [ $amassInstalled -ne 1 ]; then
        installAmass
    fi

    if [ $httprobeInstalled -ne 1 ]; then
        installHttprobe
    fi

    if [ $subjackInstalled -ne 1 ]; then
        installSubjack
    fi

    if [ $waybackurlsInstalled -ne 1 ]; then
        installWaybackurls
    fi

}

# ---------------------------------------------------------------------------- #
#                                     Main                                     #
# ---------------------------------------------------------------------------- #

echo -e "${bold}${randomColor}\nAutomap - Requirements Installation:${reset}\n"

checkTools

checkShell

if [ $goInstalled -eq 1 ] && [ $gobusterInstalled -eq 1 ] && [ $gowitnessInstalled -eq 1 ] && [ $assetfinderInstalled -eq 1 ] && [ $amassInstalled -eq 1 ] && [ $httprobeInstalled -eq 1 ] && [ $subjackInstalled -eq 1 ] && [ $waybackInstalled -eq 1 ]; then
    genericSuccess
fi

echo -e "\n${bold}Would you like to install all necessary tools? (yes/no)${reset}"
read response

if [ -z $response ]; then
    echo -e "${red}${bold}\nIncorrect input, please insert 'yes' or 'no'.${reset}\n"
    exit
elif [ $response == "yes" ]; then
    installTools
    commandResult=$?
    if [ commandResult ]; then
        genericSuccess
    else
        echo -e "${red}${bold}There was an error while installing the tools. Exiting...\n${reset}"
        exit
    fi
    
elif [ $response == "no" ]; then
    genericSuccess
else
    echo -e "${red}${bold}\nIncorrect input, please insert 'yes' or 'no'.${reset}\n"
    exit
fi
