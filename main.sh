#!/bin/bash

#add color for text
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
plain='\033[0m'
NC='\033[0m' # No Color


cur_dir=$(pwd)
# check root
#[[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

install_jq() {
    if ! command -v jq &> /dev/null; then
        # Check if the system is using apt package manager
        if command -v apt-get &> /dev/null; then
            echo -e "${RED}jq is not installed. Installing...${NC}"
            sleep 1
            sudo apt-get update
            sudo apt-get install -y jq
        else
            echo -e "${RED}Error: Unsupported package manager. Please install jq manually.${NC}\n"
            read -p "Press any key to continue..."
            exit 1
        fi
    fi
}


loader(){

    install_jq

    # Get server IP
    SERVER_IP=$(hostname -I | awk '{print $1}')

    # Fetch server country using ip-api.com
    SERVER_COUNTRY=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.country')

    # Fetch server isp using ip-api.com 
    SERVER_ISP=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.isp')

    init

}

init(){

    #clear page .
    clear
    echo "+--------------------------------------------------------------------------------------------------------------+"
    echo "|                                                                                                              |" 
    echo "| __          __        _               __          __        _  _   _______                             _     |" 
    echo "| \ \        / /       | |              \ \        / /       | || | |__   __|                           | |    |" 
    echo "|  \ \  /\  / /   __ _ | |_   ___  _ __  \ \  /\  / /   __ _ | || |    | |    _   _  _ __   _ __    ___ | |    |" 
    echo "|   \ \/  \/ /   / _  || __| / _ \| '__|  \ \/  \/ /   / _  || || |    | |   | | | || '_ \ |  _ \  / _ \| |    |" 
    echo "|    \  /\  /   | (_| || |_ |  __/| |      \  /\  /   | (_| || || |    | |   | |_| || | | || | | ||  __/| |    |" 
    echo "|     \/  \/     \__,_| \__| \___||_|       \/  \/     \__,_||_||_|    |_|    \__,_||_| |_||_| |_| \___||_|    |" 
    echo "|                                                                                                              |" 
    echo "+--------------------------------------------------------------------------------------------------------------+"                                                                                                         
    echo -e "${GREEN}Server Country:${NC} $SERVER_COUNTRY"
    echo -e "${GREEN}Server IP:${NC} $SERVER_IP"
    echo -e "${GREEN}Server ISP:${NC} $SERVER_ISP"
    echo "+---------------------------------------------------------------+"
    echo -e "${GREEN}Please choose an option:${NC}"
    echo "+---------------------------------------------------------------+"
    echo -e "${BLUE}| 1  - INSTALL CORE"
    echo -e "${BLUE}| 2  - Config Tunnel "
    echo -e "${BLUE}| 3  - Unistall"
    echo -e "${BLUE}| 0  - Exit"
    echo "+---------------------------------------------------------------+"
    echo -e "\033[0m"

    read -p "Enter option number: " choice
    case $choice in
    1)
        install_fixer
        ;;
    2)
        echo "simple 2"
        ;;
    0)
        echo -e "${GREEN}Exiting program...${NC}"
        exit 0
        ;;
    *)
        echo "Not valid"
        ;;
    esac
        

}

install_core(){

    wget https://github.com/radkesvat/WaterWall/releases/download/v1.21/Waterwall-linux-64.zip
    apt install unzip && unzip Waterwall-linux-64.zip
    chmod +rwx Waterwall
    

}

loader