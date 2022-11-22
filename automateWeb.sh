#!/bin/bash

aliveSubsFilename="aliveSubs.txt"

# ------------------------------- Print banner ------------------------------- #

printBanner () {
    echo -e "\n${randomColor}${bold}"

    echo -e "               __                         __         __      __      ___.    "
    echo -e "_____   __ ___/  |_  ____   _____ _____ _/  |_  ____/  \    /  \ ____\_ |__  "
    echo -e "\__  \ |  |  \   __\/  _ \ /     \\__  \\   __\/ __ \   \/\/   // __ \| __ \ "
    echo -e "/ __ \|  |  /|  | (  <_> )  Y Y  \/ __ \|  | \  ___/\        /\  ___/| \_\ \ "
    echo -e "(____  /____/ |__|  \____/|__|_|  (____  /__|  \___  >\__/\  /  \___  >___  / "
    echo -e "     \/                         \/     \/          \/      \/       \/    \/ "
}

# -------------------------------- Print help -------------------------------- #

printHelp () {
    
    echo -e "${bold}Usage: ${reset}./automateWeb.sh <SUBS_FILE> [SCAN_TYPE]"
	echo -e "${bold}Example: ${reset}./automateWeb.sh subs.txt enum"
    echo -e "\n"

    echo -e "\n${bold}Available Options: ${reset}"
    echo -e "enum:\tJust enumerates the URLs"
    echo -e "screenshot:\tJust takes screenshots from a file named \"filteredUrls.txt\" inside the subdomain specified in \"aliveSubs.txt\" "
    echo -e "\nIf no SCAN_TYPE is specified, the script runs both of them!"

    echo -e "\n"
}

checkTools () {
    if ! command -v httpx &> /dev/null
    then
        echo -e "${bold}Httpx was not found in the system!\nExiting...${reset}\n"
        exit
    elif ! command -v go &> /dev/null
    then
        echo -e "${bold}Go was not found in the system!\nExiting...${reset}\n"
        exit
	elif ! command -v katana &> /dev/null
    then
        echo -e "${bold}Katana was not found in the system!\nExiting...${reset}\n"
        exit
	elif ! command -v waybackurls &> /dev/null
    then
        echo -e "${bold}Waybackurls was not found in the system!\nExiting...${reset}\n"
        exit
    elif ! command -v anew &> /dev/null
    then
        echo -e "${bold}Anew was not found in the system!\nExiting...${reset}\n"
        exit
	elif ! command -v gowitness &> /dev/null
    then
        echo -e "${bold}Gowitness was not found in the system!\nExiting...${reset}\n"
        exit
    fi

}

# Scripts

enum () {
    subsList=$1
    httpx -list $subsList -silent -o $aliveSubsFilename

    for sub in $(cat $aliveSubsFilename);do
        parsedSub=$(echo $sub | cut -d "/" -f3)
        mkdir $parsedSub

        katana -u $sub -kf all -fs fqdn -o $parsedSub/katana-tmp.txt
        waybackurls $sub | grep $sub > $parsedSub/wayback-tmp.txt
        touch $parsedSub/finalUrls.txt

        cat $parsedSub/katana-tmp.txt | anew $parsedSub/finalUrls.txt
        cat $parsedSub/wayback-tmp.txt | anew $parsedSub/finalUrls.txt
        cat $parsedSub/finalUrls.txt | grep -Ev "jpg|jpeg|png|svg|ico|mp4|gif|css" > $parsedSub/filteredUrls.txt
    done
}

screenshot () {
    for sub in $(cat $aliveSubsFilename);do
        parsedSub=$(echo $sub | cut -d "/" -f3)

        gowitness file -f $parsedSub/filteredUrls.txt
    done
}

if [ "$1" == "" ]
then
    printBanner

    printHelp

else
    
    subsList=$1;
	printBanner
    checkTools
    
    if [ "$2" == "enum" ]
    then
        enum $subsList
    elif [ "$2" == "screenshot" ]
    then
        screenshot
    else
        enum $subsList
        screenshot
    fi

fi
