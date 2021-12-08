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

# ------------------------------- Generic error ------------------------------ #

genericError () {
    echo -e "${red}${bold}\nError while running the script! Exiting...${reset}\n"
    exit
}

# ------------------------------- Print banner ------------------------------- #

printBanner () {
    echo -e "\n${randomColor}${bold}"

	echo -e " __      __      ___.                          "
	echo -e "/  \    /  \ ____\_ |__   _____ _____  ______  "
	echo -e "\   \/\/   // __ \| __ \ /     \\__  \ \____ \ "
	echo -e " \        /\  ___/| \_\ \  Y Y  \/ __ \|  |_> >"
	echo -e "  \__/\  /  \___  >___  /__|_|  (____  /   __/ "
	echo -e "       \/       \/    \/      \/     \/|__|    "
    echo -e "\n${reset}"
}

# -------------------------------- Print help -------------------------------- #

printHelp () {
    
    echo -e "${bold}Usage: ${reset}./Webmap.sh <HOST> <WORDLIST> [options]"
	echo -e "${bold}Example: ${reset}./Webmap.sh myserver.com.br ./wordlists/large-directories.txt"
    echo -e "\n"

    echo -e "\n${bold}Available Options: ${reset}"
    echo -e "\tNo options available at the moment!"
	# echo -e "\t-n: specifies number of ports to scan"

    echo -e "\n"
}

# -------------------------------- Check Tools ------------------------------- #

checkTools () {
    if ! command -v nmap &> /dev/null
    then
        echo -e "${bold}Nmap was not found in the system!\nExiting...${reset}\n"
        exit
    elif ! command -v go &> /dev/null
    then
        echo -e "${bold}Go was not found in the system!\nExiting...${reset}\n"
        exit
	elif ! command -v gobuster &> /dev/null
    then
        echo -e "${bold}Gobuster was not found in the system!\nExiting...${reset}\n"
        exit
	elif ! command -v gowitness &> /dev/null
    then
        echo -e "${bold}Gowitness was not found in the system!\nExiting...${reset}\n"
        exit
	elif ! command -v google-chrome &> /dev/null
    then
        echo -e "${bold}Google Chrome was not found in the system!\nExiting...${reset}\n"
        exit
	elif ! command -v assetfinder &> /dev/null
    then
        echo -e "${bold}Assetfinder was not found in the system!\nExiting...${reset}\n"
        exit
	elif ! command -v amass &> /dev/null
    then
        echo -e "${bold}Amass was not found in the system!\nExiting...${reset}\n"
        exit
	elif ! command -v httprobe &> /dev/null
    then
        echo -e "${bold}Httprobe was not found in the system!\nExiting...${reset}\n"
        exit
	elif ! command -v subjack &> /dev/null
    then
        echo -e "${bold}Subjack was not found in the system!\nExiting...${reset}\n"
        exit
	elif ! command -v waybackurls &> /dev/null
    then
        echo -e "${bold}Waybackurls was not found in the system!\nExiting...${reset}\n"
        exit
    fi

}

lineUp () {
    
    numberOfLines=$1

    for ((i=0;i<numberOfLines;i++)); do
        tput cuu1
    done
    
}

createDirectories() {
	if [ ! -d "$url" ];then
		mkdir $url
	fi
	if [ ! -d "$url/recon" ];then
		mkdir $url/recon
	fi
	if [ ! -d '$url/recon/gowitness' ];then
		mkdir $url/recon/gowitness
	fi
	if [ ! -d "$url/recon/scans" ];then
		mkdir $url/recon/scans
	fi
	if [ ! -d "$url/recon/httprobe" ];then
		mkdir $url/recon/httprobe
	fi
	if [ ! -d "$url/recon/potential_takeovers" ];then
		mkdir $url/recon/potential_takeovers
	fi
	if [ ! -d "$url/recon/wayback" ];then
		mkdir $url/recon/wayback
	fi
	if [ ! -d "$url/recon/wayback/params" ];then
		mkdir $url/recon/wayback/params
	fi
	if [ ! -d "$url/recon/wayback/extensions" ];then
		mkdir $url/recon/wayback/extensions
	fi
	if [ ! -f "$url/recon/httprobe/alive.txt" ];then
		touch $url/recon/httprobe/alive.txt
	fi
	if [ ! -f "$url/recon/final.txt" ];then
		touch $url/recon/final.txt
	fi
}

getSubs() {
	echo "[+] Harvesting subdomains with assetfinder..."
	assetfinder $url >> $url/recon/assets.txt
	cat $url/recon/assets.txt | grep $url >> $url/recon/final.txt
	rm $url/recon/assets.txt

	echo "[+] Double checking for subdomains with amass..."
	amass enum -d $url >> $url/recon/f.txt
	sort -u $url/recon/f.txt >> $url/recon/final.txt
	rm $url/recon/f.txt
}


checkSubs() {
	echo "[+] Probing for alive domains..."
	cat $url/recon/final.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' | tee -a $url/recon/httprobe/a.txt
	sort -u $url/recon/httprobe/a.txt > $url/recon/httprobe/alive.txt
	rm $url/recon/httprobe/a.txt

	echo "[+] Checking for possible subdomain takeover..."

	if [ ! -f "$url/recon/potential_takeovers/potential_takeovers.txt" ];then
		touch $url/recon/potential_takeovers/potential_takeovers.txt
	fi

	subjack -w $url/recon/final.txt -t 100 -timeout 30 -ssl -c ~/go/src/github.com/haccer/subjack/fingerprints.json -v 3 -o $url/recon/potential_takeovers/potential_takeovers.txt
}

scanServers() {
	echo "[+] Scanning for open ports..."
	nmap -iL $url/recon/httprobe/alive.txt -T4 -oA $url/recon/scans/scanned.txt
}

subsWayback() {
	echo "[+] Scraping wayback data..."
	cat $url/recon/final.txt | waybackurls >> $url/recon/wayback/wayback_output.txt
	sort -u $url/recon/wayback/wayback_output.txt

	echo "[+] Pulling and compiling all possible params found in wayback data..."
	cat $url/recon/wayback/wayback_output.txt | grep '?*=' | cut -d '=' -f 1 | sort -u >> $url/recon/wayback/params/wayback_params.txt
	for line in $(cat $url/recon/wayback/params/wayback_params.txt);do echo $line'=';done

	echo "[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output..."
	for line in $(cat $url/recon/wayback/wayback_output.txt);do
		ext="${line##*.}"
		if [[ "$ext" == "js" ]]; then
			echo $line >> $url/recon/wayback/extensions/js1.txt
			sort -u $url/recon/wayback/extensions/js1.txt >> $url/recon/wayback/extensions/js.txt
		fi
		if [[ "$ext" == "html" ]];then
			echo $line >> $url/recon/wayback/extensions/jsp1.txt
			sort -u $url/recon/wayback/extensions/jsp1.txt >> $url/recon/wayback/extensions/jsp.txt
		fi
		if [[ "$ext" == "json" ]];then
			echo $line >> $url/recon/wayback/extensions/json1.txt
			sort -u $url/recon/wayback/extensions/json1.txt >> $url/recon/wayback/extensions/json.txt
		fi
		if [[ "$ext" == "php" ]];then
			echo $line >> $url/recon/wayback/extensions/php1.txt
			sort -u $url/recon/wayback/extensions/php1.txt >> $url/recon/wayback/extensions/php.txt
		fi
		if [[ "$ext" == "aspx" ]];then
			echo $line >> $url/recon/wayback/extensions/aspx1.txt
			sort -u $url/recon/wayback/extensions/aspx1.txt >> $url/recon/wayback/extensions/aspx.txt
		fi
	done

	rm $url/recon/wayback/extensions/js1.txt
	rm $url/recon/wayback/extensions/jsp1.txt
	rm $url/recon/wayback/extensions/json1.txt
	rm $url/recon/wayback/extensions/php1.txt
	rm $url/recon/wayback/extensions/aspx1.txt
}

screenshotSubs() {
	echo "[+] Running gowitness against all compiled domains..."

	touch $url/recon/gowitness/alive.txt
	for line in $(cat $url/recon/final.txt);do
		curl --head --silent --location --output /dev/null --write-out "%{url_effective}\n" $line >> $url/recon/gowitness/alive.txt
	done

	gowitness file -f $url/recon/gowitness/alive.txt -P $url/recon/gowitness/
}

sortSubsResult() {
	sort -u $url/recon/final.txt > $url/recon/subs.txt
	sort -u $url/recon/gowitness/alive.txt > $url/recon/urls.txt
}

webmapSetup() {
	checkTools
	createDirectories
}

subsEnumeration() {
	getSubs
	checkSubs
	scanServers
	subsWayback
	screenshotSubs
	sortSubsResult
}

# if [ "$1" == "" -o "$2" == "" -o "$3" == "" ]

if [ "$1" == "" ]
then
    printBanner

    printHelp

else
    
    url=$1;

	printBanner
	
	# shift
    # target=$1; shift
    # wordlistPath=$1; shift

    # while getopts ":n:" opt; do
    #     case ${opt} in
    #         n ) numberOfPorts=$OPTARG
    #         ;;
    #         \? ) printHelp
    #         ;;
    #         : )
    #         echo "Invalid option: $OPTARG requires an argument" 1>&2
    #         ;;
    #     esac
    # done
    # shift $((OPTIND -1))

    # if [ "$mode" == "host" ]
    # then

    #     hostScan $target $wordlistPath $numberOfPorts

    # elif [ "$mode" == "network" ]
    # then

    #     networkScan $target $wordlistPath $numberOfPorts

    # fi

	webmapSetup
	subsEnumeration

fi


