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

# Welcome message
echo -e "Initializing system information script...${RESET}"
sleep 1

# Fetch and display system information
echo -e "${YELLOW}Fetching system information...${RESET}"
USERNAME=$(whoami)
HOSTNAME=$(hostname)
TOTAL_RAM=$(free -h | grep Mem: | awk '{print $2}')
USED_RAM=$(free -h | grep Mem: | awk '{print $3}')
DISK_SPACE=$(df -h --total | grep total | awk '{print $2}')
DISK_USED=$(df -h --total | grep total | awk '{print $3}')
MOTHERBOARD=$(cat /sys/devices/virtual/dmi/id/board_vendor 2>/dev/null && cat /sys/devices/virtual/dmi/id/board_name 2>/dev/null)
PACKAGE_COUNT=$(pacman -Qq | wc -l)
AUR_PACKAGES=$(pacman -Qqm | wc -l)  # Count AUR packages

# Fetch the IP address of the active interface connected to the internet
IP_ADDRESS=$(ip addr show | grep -A3 "state UP" | grep "inet " | awk '{print $2}' | cut -d/ -f1 | head -n 1)

# Display fetched information
echo -e "${CYAN}Username: ${RESET}${USERNAME}"
echo -e "${CYAN}Hostname: ${RESET}${HOSTNAME}"
echo -e "${CYAN}RAM: ${RESET}${USED_RAM}/${TOTAL_RAM}"
echo -e "${CYAN}Storage: ${RESET}${DISK_USED}/${DISK_SPACE}"
echo -e "${CYAN}Motherboard: ${RESET}${MOTHERBOARD}"
echo -e "${CYAN}Packages Installed (System-wide): ${RESET}${PACKAGE_COUNT}"
echo -e "${CYAN}AUR Packages: ${RESET}${AUR_PACKAGES}"  # Display AUR packages count
echo -e "${CYAN}IP Address: ${RESET}${IP_ADDRESS}"

# Get the Window Manager (WM) information
wm=$(wmctrl -m | grep -oP "Name:\s+\K.*")
echo -e "${CYAN}Window Manager: ${RESET}${wm}"

# Arch ASCII Art
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

# binary sequence
binary_sequence


# Completion message
echo -e "All tasks completed successfully!${RESET}"
