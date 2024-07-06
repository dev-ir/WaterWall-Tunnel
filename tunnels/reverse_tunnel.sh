#!/bin/bash

#add color for text
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
plain='\033[0m'
NC='\033[0m' # No Color


cur_dir=$(pwd)
# check root
# [[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

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
gv_menu(){

	install_jq
    run_screen

    clear

    # Get server IP
    SERVER_IP=$(hostname -I | awk '{print $1}')

    # Fetch server country using ip-api.com
    SERVER_COUNTRY=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.country')

    # Fetch server isp using ip-api.com 
    SERVER_ISP=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.isp')
	
    WATER_CORE=$(check_core_status)
    WATER_TUNNEL=$(check_tunnel_status)


    echo "+-----------------------------------------------------------------------------------------------------------------------+"
    echo "| __          __        _               __          __        _  _   _______                             _              |" 
    echo "| \ \        / /       | |              \ \        / /       | || | |__   __|                           | |             |" 
    echo "|  \ \  /\  / /   __ _ | |_   ___  _ __  \ \  /\  / /   __ _ | || |    | |    _   _  _ __   _ __    ___ | |             |" 
    echo "|   \ \/  \/ /   / _  || __| / _ \| '__|  \ \/  \/ /   / _  || || |    | |   | | | || '_ \ |  _ \  / _ \| |             |" 
    echo "|    \  /\  /   | (_| || |_ |  __/| |      \  /\  /   | (_| || || |    | |   | |_| || | | || | | ||  __/| |             |" 
    echo "|     \/  \/     \__,_| \__| \___||_|       \/  \/     \__,_||_||_|    |_|    \__,_||_| |_||_| |_| \___||_| ( 2.0.1 )   |" 
    echo "|                                                                                                                       |" 
    echo "+-----------------------------------------------------------------------------------------------------------------------+"                                                                                                         
    echo -e "|${GREEN}Server Country    |${NC} $SERVER_COUNTRY"
    echo -e "|${GREEN}Server IP         |${NC} $SERVER_IP"
    echo -e "|${GREEN}Server ISP        |${NC} $SERVER_ISP"
    echo -e "|${GREEN}WaterWall CORE    |${NC} $WATER_CORE"
    echo -e "|${GREEN}WaterWall Tunnel  |${NC} $WATER_TUNNEL"
    echo "+--------------------------------------------------------------------------------------------------------------+"
    echo -e "|${YELLOW}Please choose an option:${NC}"
    echo "+--------------------------------------------------------------------------------------------------------------+"
    echo -e $1
    echo "+---------------------------------------------------------------------------------+"
    echo -e "\033[0m"
}



install_tunnel(){
    gv_menu "| 1  - IRAN \n| 2  - Kharej \n| 0  - Exit"

    read -p "Enter option number: " setup

    case $setup in
    1)
        iran_setup
        ;;  
    2)
        kharej_setup
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


iran_setup(){
    
read -p "Enter Kharej IP  : " kharej_ip
    
cat <<EOL > dev-ir.json
{
    "name": "myconf",
    "nodes": [
        {
            "name": "users_inbound",
            "type": "TcpListener",
            "settings": {
                "address": "0.0.0.0",
                "port": [80,65535],
                "nodelay": true
            },
            "next":  "header"
        },

        {
            "name": "header",
            "type": "HeaderClient",
            "settings": {
                "data": "src_context->port"
            },
            "next": "bridge2"
        },

        {
            "name": "bridge2",
            "type": "Bridge",
            "settings": {
                "pair": "bridge1"
            }
        },
        {
            "name": "bridge1",
            "type": "Bridge",
            "settings": {
                "pair": "bridge2"
            }

            
        },
        {
            "name": "reverse_server",
            "type": "ReverseServer",
            "settings": {},
            "next": "bridge1"
        },

   

        {
            "name": "kharej_inbound",
            "type": "TcpListener",
            "settings": {
                "address": "0.0.0.0",
                "port": 443,
                "nodelay": true,
                "whitelist":[
                    "$kharej_ip/32"
                ]
            },
            "next": "reverse_server"
        }
    ]
}
EOL

cat <<EOL > /root/connector.sh
/root/Waterwall
EOL

chmod +x /root/connector.sh
screen -dmS connector_session bash -c '/root/connector.sh'
echo "Your job is greate..."

}

kharej_setup(){
    
read -p "Enter IRAN IP    : " iran_ip
    
cat <<EOL > dev-ir.json
{
    "name": "reverse_simple",
    "nodes": [
       

        {
            "name": "outbound_to_core",
            "type": "TcpConnector",
            "settings": {
                "nodelay": true,
                "address":"127.0.0.1",
                "port":"dest_context->port"
            }

        },

        {
            "name": "header",
            "type": "HeaderServer",
            "settings": {
                "override": "dest_context->port"
            },
            "next": "outbound_to_core"
        },

        {
            "name": "bridge1",
            "type": "Bridge",
            "settings": {
                "pair": "bridge2"
            },
            "next": "header"

        },
        {
            "name": "bridge2",
            "type": "Bridge",
            "settings": {
                "pair": "bridge1"
            },
            "next": "reverse_client"

        },
      
        {
            "name": "reverse_client",
            "type": "ReverseClient",
            "settings": {
                "minimum-unused":16
            },
            "next":  "outbound_to_iran"
        },


        {
            "name": "outbound_to_iran",
            "type": "TcpConnector",
            "settings": {
                "nodelay": true,
                "address":"$iran_ip",
                "port":443
            }
        }

    ]
}

EOL
cat <<EOL > /root/connector.sh
/root/Waterwall
EOL

chmod +x /root/connector.sh
screen -dmS connector_session bash -c '/root/connector.sh'
echo "Your job is greate..."
    
}

run_screen(){
#!/bin/bash

# Check if screen is installed
if ! command -v screen &> /dev/null
then
    echo "Screen is not installed. Installing..."
    
    # Check the Linux distribution to use the correct package manager
    if [ -f /etc/redhat-release ]; then
        # CentOS/RHEL
        sudo yum install screen -y
    elif [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install screen -y
    else
        echo "Unsupported Linux distribution. Please install screen manually."
        exit 1
    fi
    
    # Verify installation
    if ! command -v screen &> /dev/null
    then
        echo "Failed to install screen. Please install manually."
        exit 1
    else
        echo "Screen has been successfully installed."
    fi
else
    echo "Screen is already installed."
fi

}


check_core_status() {
    local file_path="/root/dev-ir.json"
    local status

    if [ -f "$file_path" ]; then
        status="${GREEN}Installed"${NC}
    else
        status=${RED}"Not installed"${NC}
    fi

    echo "$status"
}

check_tunnel_status() {
    local file_path="dev-ir.json"
    local status

    if [ -f "$file_path" ]; then
        status="${GREEN}Enabled"${NC}
    else
        status=${RED}"Disabled"${NC}
    fi

    echo "$status"
}

install_tunnel