#!/bin/bash

# Color definitions
GREEN="\033[38;2;139;191;123m"
CYAN="\033[36m"
YELLOW="\033[33m"
RESET="\033[0m"

# Function to display binary sequences in green
function binary_sequence() {
    echo -e "Generating binary sequences:${RESET}"
    for i in {1..10}; do
        echo -e "${GREEN}$(head /dev/urandom | tr -dc '01' | head -c 32)${RESET}"
        sleep 0.2
    done
}

# Save GitHub usernames
CONFIG_FILE="$HOME/.github_usernames"

# Function to fetch GitHub data
function fetch_github_data() {
    local username=$1
    echo -e "${YELLOW}Fetching GitHub data for ${username}...${RESET}"
    repos=$(curl -s "https://api.github.com/users/${username}/repos" | jq '.[].name' | wc -l)
    stars=$(curl -s "https://api.github.com/users/${username}/repos" | jq '.[].stargazers_count' | awk '{s+=$1} END {print s}')
    avatar=$(curl -s "https://api.github.com/users/${username}" | jq -r '.avatar_url')

    echo -e "${CYAN}GitHub Username: ${RESET}${username}"
    echo -e "${CYAN}Repositories: ${RESET}${repos}"
    echo -e "${CYAN}Stars: ${RESET}${stars}"

    if command -v chafa >/dev/null 2>&1; then
        curl -s ${avatar} | chafa -s 32x16
    else
        echo -e "${YELLOW}Install 'chafa' to display avatar images.${RESET}"
    fi
}

# Check if running for the first time
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}It looks like this is your first time running the script.${RESET}"
    read -p "How many GitHub accounts do you have? (Enter a number): " github_accounts
    
    if [[ "$github_accounts" =~ ^[0-9]+$ ]] && (( github_accounts > 0 )); then
        for i in $(seq 1 $github_accounts); do
            read -p "Enter GitHub username for account $i (or press Enter to skip): " username
            if [ -n "$username" ]; then
                echo "$username" >> "$CONFIG_FILE"
            fi
        done
    else
        echo -e "${YELLOW}Skipping GitHub username setup.${RESET}"
    fi
fi

# Load GitHub usernames
if [ -f "$CONFIG_FILE" ]; then
    echo -e "${CYAN}GitHub usernames loaded from configuration:${RESET}"
    cat "$CONFIG_FILE"
    while IFS= read -r username; do
        fetch_github_data "$username"
    done < "$CONFIG_FILE"
fi

# Additional flags to edit or add usernames
while getopts ":a:e:h" opt; do
    case $opt in
        a)
            echo "$OPTARG" >> "$CONFIG_FILE"
            echo -e "${CYAN}Added GitHub username: $OPTARG${RESET}"
            ;;
        e)
            nano "$CONFIG_FILE"
            echo -e "${CYAN}Edited GitHub usernames.${RESET}"
            ;;
        h)
            echo -e "Usage: $0 [-a username] [-e] [-h]"
            echo -e "-a username: Add a new GitHub username"
            echo -e "-e: Edit the GitHub usernames list"
            echo -e "-h: Display this help message"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Invalid option. Use -h for help.${RESET}"
            ;;
    esac
done

# Main script
echo -e "Initializing system information script...${RESET}"
sleep 1

# Detect OS and kernel version
OS=$(grep "^PRETTY_NAME=" /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
KERNEL=$(uname -r)

# Detect uptime
UPTIME=$(uptime -p)

# Detect package counts
if command -v pacman >/dev/null 2>&1; then
    SYSTEM_PACKAGES=$(pacman -Qq | wc -l)
    FLATPAK_PACKAGES=$(flatpak list 2>/dev/null | wc -l || echo 0)
else
    SYSTEM_PACKAGES="N/A"
    FLATPAK_PACKAGES="N/A"
fi

# Detect shell and terminal
SHELL=$(basename "$SHELL")

# Detect the terminal emulator accurately
if [ -n "$KONSOLE_VERSION" ]; then
    terminal="konsole"
elif [ -n "$GNOME_TERMINAL_SCREEN" ] || [ -n "$GNOME_TERMINAL_SERVICE" ]; then
    terminal="gnome-terminal"
elif [ -n "$ALACRITTY_LOG" ]; then
    terminal="alacritty"
elif [ -n "$KITTY_WINDOW_ID" ]; then
    terminal="kitty"
elif [ -n "$TERM_PROGRAM" ]; then
    terminal="$TERM_PROGRAM"  # Some terminals set TERM_PROGRAM
else
    # Fallback: Get the parent process of the shell
    parent_pid=$(ps -o ppid= -p $$)
    terminal=$(ps -o comm= -p "$parent_pid" | head -n 1)
fi

# Detect displays
DISPLAYS=$(xrandr --listactivemonitors 2>/dev/null | tail -n +2 || echo "No display information available")

# Detect CPU and memory usage
CPU_MODEL=$(lscpu | grep "Model name:" | sed 's/Model name:\s*//')
MEMORY=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')

# Detect GPU
GPU=$(lspci | grep -i vga | cut -d: -f3 | xargs)

# Detect disk usage
DISK_USAGE=$(df -h / | awk '/\// {print $3 "/" $2}')

# Detect IP address
IP_ADDRESS=$(ip addr show | grep -A3 "state UP" | grep "inet " | awk '{print $2}' | cut -d/ -f1 | head -n 1 || echo "No IP address found")

# Detect locale
LOCALE=$(locale | grep LANG= | cut -d= -f2)

# Output system information
echo -e "${CYAN}OS: ${RESET}${OS}"
echo -e "${CYAN}Kernel: ${RESET}${KERNEL}"
echo -e "${CYAN}Uptime: ${RESET}${UPTIME}"
echo -e "${CYAN}Packages: ${RESET}${SYSTEM_PACKAGES} (pacman), ${FLATPAK_PACKAGES} (flatpak)"
echo -e "${CYAN}Shell: ${RESET}${SHELL}"
echo -e "${CYAN}Terminal Emulator: ${RESET}${terminal:-unknown}"
echo -e "${CYAN}Displays: ${RESET}${DISPLAYS}"
echo -e "${CYAN}CPU: ${RESET}${CPU_MODEL}"
echo -e "${CYAN}Memory: ${RESET}${MEMORY}"
echo -e "${CYAN}GPU: ${RESET}${GPU}"
echo -e "${CYAN}Disk (/): ${RESET}${DISK_USAGE}"
echo -e "${CYAN}IP Address: ${RESET}${IP_ADDRESS}"
echo -e "${CYAN}Locale: ${RESET}${LOCALE}"

echo -e "${CYAN}
         .  .  .  .  .  .  .  .               .  .  .  .  .  .  .  .  .            .  .  
                                        :;                                        
                                       ,oo;                                       
                                      .oooo'                                      
                                     .looooo.                                     
                                    .looooool.                                    
                                    cooooooool.                                   
                                   :ooooooooooc.                                  
                                  ,ooooooooooooc.                                 
                                 ,oooooooooooooo:                                 
                                ,oooooooooooooooo:                                
                                .;oooooooooooooooo:.                              
                              'c'. ,loooooooooooooo:                              
                             'ooooc,.,:oooooooooooooc.                             
                            'oooooooooc:cooooooooooooc.                            
                           ,ooooooooooooooooooooooooooc                            
                          ,ooooooooooooooooooooooooooooc.                          
                         ,ooooooooooooooooooooooooooooooc.                         
                        ;ooooooooooooooooooooooooooooooool.                        
                      .:ooooooooooooooooooooooooooooooooool.                       
                      :ooooooooooooooooooooooooooooooooooool.                      
                    .coooooooooooooooo:;.';:loooooooooooooool.                    
                   .looooooooooooool,.       'looooooooooooooo'                   
                  .looooooooooooool.          .cooooooooooooooo'                  
                 .looooooooooooool.             cooooooooooooooo,                 
                ,oooooooooooooooo'              .oooooooooooooooo:                
               ,ooooooooooooooool                :ooooooooolcclooo:               
              ;oooooooooooooooooc                ,oooooooooooc;'.'::              
            .:ooooooooooooooooooc                ,ooooooooooooool;. .             
           .coooooooooooooooooooo.               :oooooooooooooooooc'.            
          .coooooooooooooool:;,...               ..,;:looooooooooooooo;.          
         .looooooooool:;'.                             ...;:looooooooool.         
        'ooooooooc;'.                                        .';coooooooo'        
       'oooooc;.                                                  .;cooooo,       
      ,ooc,..                                                         .;coo,      
     ;:'.                                                                .';;     
    .                                                                        .  
"

binary_sequence

# Completion message
echo -e "All tasks completed successfully!${RESET}"
