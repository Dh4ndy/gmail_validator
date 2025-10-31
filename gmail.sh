#!/bin/bash

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
ORANGE='\033[0;33m' 
PINK='\033[1;38;5;200m'
KUNMUD='\033[1;38;5;228m'
PPK='\033[1;38;5;228m'
INI1='\e[34m'
INI2='\e[7m'
INI3='\033[1;38;5;172m' 
INI4='\033[1;38;5;057m'
INI5='\033[1;38;5;160m'
INI6='\033[1;38;5;120m'
BRIGHT_RED='\033[1;31m'
BRIGHT_GREEN='\033[1;32m'
BRIGHT_YELLOW='\033[1;33m'
BRIGHT_BLUE='\033[1;34m'
BRIGHT_MAGENTA='\033[1;35m'
BRIGHT_CYAN='\033[1;36m'
BRIGHT_WHITE='\033[1;37m'

## JANGAN DI UBAH \\ SETTINGAN DEFFAULT // ###
MAX_CONCURRENT=15
BATCH_SIZE=12
TIMEOUT_SMTP=6
CONNECTION_TIMEOUT=2
DELAY_BETWEEN_BATCHES=1
#############################################


ENCRYPT_KEY="LONGENTOT"
encrypt_response() {
    local data="$1"
    echo "$data" | openssl enc -aes-256-cbc -a -salt -pass pass:"$ENCRYPT_KEY" 2>/dev/null
}

decrypt_response() {
    local encrypted_data="$1"
    echo "$encrypted_data" | openssl enc -aes-256-cbc -a -d -salt -pass pass:"$ENCRYPT_KEY" 2>/dev/null
}

validate_encrypted_response() {
    local encrypted_response="$1"
    local decrypted_response
    

    decrypted_response=$(decrypt_response "$encrypted_response")
    

    if echo "$decrypted_response" | grep -q "250.*2.1.5"; then
        return 0
    elif echo "$decrypted_response" | grep -q "550.*5.1.1"; then
        return 1
    fi
    
    return 1
}

print_banner() {
    clear
    echo ""
    printf "${BRIGHT_CYAN}"
    echo "██████╗ ██╗  ██╗██╗  ██╗███╗   ██╗██████╗ ██╗   ██╗"
    echo "██╔══██╗██║  ██║██║  ██║████╗  ██║██╔══██╗╚██╗ ██╔╝"
    echo "██║  ██║███████║███████║██╔██╗ ██║██║  ██║ ╚████╔╝ "
    echo "██║  ██║██╔══██║╚════██║██║╚██╗██║██║  ██║  ╚██╔╝  "
    echo "██████╔╝██║  ██║     ██║██║ ╚████║██████╔╝   ██║   "
    echo "╚═════╝ ╚═╝  ╚═╝     ╚═╝╚═╝  ╚═══╝╚═════╝    ╚═╝   "
    printf "${NC}"
    printf "${BRIGHT_MAGENTA}"
    printf "   ██████  ███    ███  █████  ██ ██      \n"
    printf "  ██       ████  ████ ██   ██ ██ ██      \n"
    printf "  ██   ███ ██ ████ ██ ███████ ██ ██      \n"
    printf "  ██    ██ ██  ██  ██ ██   ██ ██ ██      \n"
    printf "   ██████  ██      ██ ██   ██ ██ ███████ \n"
    printf "${NC}"
    printf "${BRIGHT_BLUE}=================================================${NC}\n"
    printf "${BRIGHT_RED}           GMAIL VALIDATOR DH4NDY           ${NC}\n"
    printf "${BRIGHT_YELLOW}                    2025              ${NC}\n"
    printf "${BRIGHT_BLUE}=================================================${NC}\n\n"
}


inputFile=""
targetFolder=""
sendList=$BATCH_SIZE
perSec=$DELAY_BETWEEN_BATCHES
isDel='n'

usage() { 
    print_banner
    echo ""
    printf "${BRIGHT_WHITE}Usage:${NC} ${BRIGHT_CYAN}$0 -i <list.txt> -r <folder/> [-l <number>] [-t <seconds>] [-d]${NC}\n"
    printf "${BRIGHT_YELLOW}Example:${NC} ${GREEN}$0 -i emails.txt -r results/ -l 12 -t 1${NC}\n\n"
    
    printf "${BRIGHT_WHITE}Performance Options:${NC}\n"
    printf "  ${BRIGHT_CYAN}-i <file>${NC}    Input file containing emails\n"
    printf "  ${BRIGHT_CYAN}-r <folder>${NC}  Result folder\n"
    printf "  ${BRIGHT_CYAN}-l <number>${NC}  Emails per batch ${YELLOW}${NC}\n"
    printf "  ${BRIGHT_CYAN}-t <seconds>${NC} Delay between batches ${YELLOW}${NC}\n"
    printf "  ${BRIGHT_CYAN}-d${NC}           Delete processed emails\n"
    printf "  ${BRIGHT_CYAN}-h${NC}           Show this help\n"
    printf "\n${BRIGHT_YELLOW}Security Features:${NC}\n"
    printf "  ${GREEN}•${NC} Encrypted SMTP response storage\n"
    printf "  ${GREEN}•${NC} AES-256-CBC encryption\n"
    printf "  ${GREEN}•${NC} Secure response validation\n"
    exit 1 
}

while getopts "i:r:l:t:dh" opt; do
    case $opt in
        i) inputFile="$OPTARG" ;;
        r) targetFolder="$OPTARG" ;;
        l) sendList="$OPTARG" ;;
        t) perSec="$OPTARG" ;;
        d) isDel='y' ;;
        h) usage ;;
        *) printf "${RED}Invalid option: -$OPTARG${NC}\n" >&2; usage ;;
    esac
done

if [[ $# -eq 0 ]]; then
    print_banner
    printf "${BRIGHT_CYAN}DH4NDY Gmail Validator${NC}\n"
    printf "${BRIGHT_BLUE}=========================================${NC}\n\n"
    

    while [[ -z "$inputFile" ]]; do
        printf "${BRIGHT_YELLOW}Available .txt files:${NC}\n"
        ls *.txt 2>/dev/null | while read file; do
            printf "  ${CYAN}•${NC} ${GREEN}$file${NC}\n"
        done || printf "  ${YELLOW}No .txt files found in current directory${NC}\n"
        
        printf "\n${BRIGHT_WHITE}Enter email list file: ${NC}"
        read inputFile
        if [[ ! -f "$inputFile" ]]; then
            printf "${RED}File not found: $inputFile${NC}\n"
            inputFile=""
        fi
    done
    
  
    while [[ -z "$targetFolder" ]]; do
        printf "${BRIGHT_WHITE}Enter result folder: ${NC}"
        read targetFolder
        if [[ -z "$targetFolder" ]]; then
            printf "${RED}Result folder is required${NC}\n"
        fi
    done
    
   
    printf "${BRIGHT_WHITE}Emails per batch ${YELLOW}[$BATCH_SIZE]: ${NC}"
    read customSendList
    [[ -n "$customSendList" ]] && sendList="$customSendList"
    
    printf "${BRIGHT_WHITE}Delay between batches (seconds) ${YELLOW}[$DELAY_BETWEEN_BATCHES]: ${NC}"
    read customPerSec
    [[ -n "$customPerSec" ]] && perSec="$customPerSec"
    
    printf "${BRIGHT_WHITE}Delete processed emails? ${YELLOW}[y/N]: ${NC}"
    read deleteChoice
    [[ "$deleteChoice" == "y" || "$deleteChoice" == "Y" ]] && isDel='y'
fi


if [[ -z "$inputFile" || -z "$targetFolder" ]]; then
    printf "${RED}Error: Input file and result folder are required${NC}\n"
    usage
fi

if [[ ! -f "$inputFile" ]]; then
    printf "${RED}Error: Input file '$inputFile' not found${NC}\n"
    exit 1
fi


mkdir -p "$targetFolder"

SECONDS=0


print_banner
print_header

printf "${BRIGHT_YELLOW}Initializing DH4NDY Gmail Validation...${NC}\n"
printf "${BRIGHT_BLUE}╔══════════════════════════════════════════════════════════╗${NC}\n"


printf "${BRIGHT_WHITE}Checking system requirements...${NC}"
if command -v dig &>/dev/null && command -v telnet &>/dev/null && command -v nc &>/dev/null && command -v openssl &>/dev/null; then
    printf " ${GREEN}OK${NC}\n"
else
    printf " ${RED}FAILED${NC}\n"
    printf "${RED}Error: Required tools (dig, telnet, nc, openssl) not found${NC}\n"
    exit 1
fi


printf "${BRIGHT_WHITE}Loading input file...${NC}"
if [[ -f "$inputFile" ]]; then
    file_size=$(wc -l < "$inputFile" 2>/dev/null || echo 0)
    printf " ${GREEN}OK${NC} ${CYAN}($file_size lines)${NC}\n"
else
    printf " ${RED}FAILED${NC}\n"
    exit 1
fi


printf "${BRIGHT_WHITE}Testing Gmail SMTP servers...${NC}\n"
gmail_servers=("gmail-smtp-in.l.google.com" "alt1.gmail-smtp-in.l.google.com")

connected_servers=0
for server in "${gmail_servers[@]}"; do
    printf "  ${BRIGHT_WHITE}$server...${NC}"
    if timeout $CONNECTION_TIMEOUT nc -z -w 1 "$server" 25 2>/dev/null; then
        printf " ${GREEN}CONNECTED${NC}\n"
        ((connected_servers++))
    else
        printf " ${RED}FAILED${NC}\n"
    fi
done

if [[ $connected_servers -eq 0 ]]; then
    printf "${RED}Error: Cannot connect to any Gmail SMTP servers${NC}\n"
    exit 1
else
    printf "${GREEN}Server status: $connected_servers/${#gmail_servers[@]} active${NC}\n"
fi

printf "${BRIGHT_BLUE}╚══════════════════════════════════════════════════════════╝${NC}\n\n"





printf "${BRIGHT_MAGENTA}Filtering Gmail addresses...${NC}\n"


grep -Eio '[a-zA-Z0-9._%+-]+@gmail\.com' "$inputFile" 2>/dev/null | \
tr '[:upper:]' '[:lower:]' | awk '!seen[$0]++' > "$inputFile.gmail_fast"

totalGmails=$(wc -l < "$inputFile.gmail_fast" 2>/dev/null || echo 0)
totalOriginal=$(wc -l < "$inputFile" 2>/dev/null || echo 0)

if [[ $totalGmails -eq 0 ]]; then
    printf "${RED}Error: No Gmail addresses found in input file${NC}\n"
    printf "${YELLOW}Total emails in original file: $totalOriginal${NC}\n"
    exit 1
fi

printf "${GREEN}Filtered $totalGmails Gmail addresses ${YELLOW}(from $totalOriginal total)${NC}\n\n"





validate_gmail_ultra_fast() {
    local email=$1
    local username=$(echo "$email" | cut -d'@' -f1)
    

    [[ ${#username} -lt 6 || ${#username} -gt 30 ]] && return 1
    echo "$username" | grep -Eq '^[a-z0-9\.]+$' || return 1
    [[ "$username" =~ \.\. || "$username" =~ ^\.|\.$ ]] && return 1


    local mx_servers=("gmail-smtp-in.l.google.com" "alt1.gmail-smtp-in.l.google.com")
    
    for server in "${mx_servers[@]}"; do

        timeout $CONNECTION_TIMEOUT nc -z -w 1 "$server" 25 2>/dev/null || continue
        

        local raw_response
        raw_response=$(timeout $TIMEOUT_SMTP bash -c "
            {
                echo 'EHLO google.com'
                sleep 0.5
                echo 'MAIL FROM: <dh4ndy@google.com>'
                sleep 0.5  
                echo 'RCPT TO: <$email>'
                sleep 1
                echo 'QUIT'
            } | telnet '$server' 25 2>&1" 2>&1)
        

        local encrypted_response
        encrypted_response=$(encrypt_response "$raw_response")
        

        if validate_encrypted_response "$encrypted_response"; then
            return 0
        fi
    done
    
    return 1
}




process_single_gmail_fast() {
    local email=$1
    local index=$2
    local total=$3
    local timestamp=$(date +%H:%M:%S)
kirigan="${INI1}D${NC}${INI5}H${NC}${INI3}4${NC}${INI4}N${NC}${INI5}D${NC}${INI6}Y${NC} | ${PPK}V${NC}A${INI6}L${NC}${INI5}I${NC}${INI4}D${NC} ${INI3}E${NC}${INI6}M${NC}${INI1}A${NC}${GREEN}I${NC}${ORANGE}L${NC}"


    if validate_gmail_ultra_fast "$email"; then
        printf "$kirigan | [%d/%d] |${GREEN} GMAIL VALID ${NC}|${YELLOW} $email ${NC}| %s\n" "$index" "$total" "$timestamp"
        echo "$email" >> "$targetFolder/gmail_valid.txt"
    else
        printf "$kirigan | [%d/%d] |${RED} GMAIL INVALID ${NC}|${YELLOW} $email ${NC}| %s\n" "$index" "$total" "$timestamp"
        echo "$email" >> "$targetFolder/gmail_invalid.txt"
    fi
}





printf "${BRIGHT_GREEN}Starting Gmail validation...${NC}\n"
printf "${BRIGHT_BLUE}Performance Configuration:${NC}\n"
printf "  ${BRIGHT_WHITE}• Concurrent processes:${NC} ${CYAN}$MAX_CONCURRENT${NC}\n"
printf "  ${BRIGHT_WHITE}• Emails per batch:${NC} ${CYAN}$sendList${NC}\n"
printf "  ${BRIGHT_WHITE}• Delay between batches:${NC} ${CYAN}$perSec seconds${NC}\n"
printf "  ${BRIGHT_WHITE}• SMTP Timeout:${NC} ${CYAN}${TIMEOUT_SMTP}s${NC}\n"
printf "  ${BRIGHT_WHITE}• Total to process:${NC} ${CYAN}$totalGmails emails${NC}\n"
printf "  ${BRIGHT_WHITE}• Security:${NC} ${GREEN}ENCRYPTED RESPONSE SYSTEM${NC}\n\n"

printf "${BRIGHT_YELLOW}Launching parallel validation engine...${NC}\n"
printf "${BRIGHT_BLUE}════════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}\n"


> "$targetFolder/gmail_valid.txt"
> "$targetFolder/gmail_invalid.txt"


mapfile -t email_array < "$inputFile.gmail_fast"
total_emails=${#email_array[@]}
current_index=0


while [[ $current_index -lt $total_emails ]]; do

    batch_end=$((current_index + sendList))
    [[ $batch_end -gt $total_emails ]] && batch_end=$total_emails
    

    for ((i=current_index; i<batch_end; i++)); do
        email="${email_array[i]}"
        [[ -z "$email" ]] && continue
        
        process_index=$((i + 1))
        process_single_gmail_fast "$email" "$process_index" "$total_emails" &
        

        while [[ $(jobs -r | wc -l) -ge $MAX_CONCURRENT ]]; do
            sleep 0.1
        done
    done
    

    wait
    

    current_index=$batch_end
    

    progress=$((current_index * 100 / total_emails))
    printf "${BRIGHT_CYAN}════════════════════════════════════════> Progress: %d/%d (%d%%) <════════════════════════════════════════${NC}\n" "$current_index" "$total_emails" "$progress"
    

    [[ $current_index -lt $total_emails ]] && sleep "$perSec"
    

    if [[ "$isDel" == 'y' ]]; then
        for ((i=current_index-sendList; i<current_index; i++)); do
            email="${email_array[i]}"
            [[ -n "$email" ]] && sed -i "/^${email}$/d" "$inputFile" 2>/dev/null
        done
    fi
done

printf "${BRIGHT_BLUE}═════════════════════════════════════════════════════════════════════════════════════════════════════════════${NC}\n"






printf "\n${BRIGHT_GREEN}Validation Completed!${NC}\n"
printf "${BRIGHT_BLUE}════════════════════════════════════════════════════════════${NC}\n"

valid_count=0
invalid_count=0

if [[ -f "$targetFolder/gmail_valid.txt" ]]; then
    valid_count=$(wc -l < "$targetFolder/gmail_valid.txt")
    printf "${GREEN}Valid Gmails:${NC} ${CYAN}$targetFolder/gmail_valid.txt${NC}\n"
fi

if [[ -f "$targetFolder/gmail_invalid.txt" ]]; then
    invalid_count=$(wc -l < "$targetFolder/gmail_invalid.txt")
    printf "${RED}Invalid Gmails:${NC} ${CYAN}$targetFolder/gmail_invalid.txt${NC}\n"
fi

total_checked=$((valid_count + invalid_count))

printf "\n${BRIGHT_WHITE}DH4NDY PERFORMANCE REPORT:${NC}\n"
printf "${BRIGHT_BLUE}────────────────────────────────────────────────────────────${NC}\n"
printf "${GREEN}GMAIL VALID:    $valid_count${NC}\n"
printf "${RED}GMAIL INVALID:  $invalid_count${NC}\n"
printf "${BRIGHT_CYAN}TOTAL PROCESSED: $total_checked${NC}\n"
printf "${YELLOW}ORIGINAL COUNT:  $totalOriginal${NC}\n"

if [[ $total_checked -gt 0 ]]; then
    accuracy=$(( (valid_count * 100) / total_checked ))
    printf "${BRIGHT_MAGENTA}SUCCESS RATE:    $accuracy%%${NC}\n"
    
    if [[ $accuracy -gt 90 ]]; then
        printf "${BRIGHT_GREEN}PERFORMANCE: EXCELLENT${NC}\n"
    elif [[ $accuracy -gt 70 ]]; then
        printf "${BRIGHT_YELLOW}PERFORMANCE: GOOD${NC}\n"
    else
        printf "${BRIGHT_RED}PERFORMANCE: NEEDS CHECK${NC}\n"
    fi
fi

duration=$SECONDS
emails_per_second=0
if [[ $duration -gt 0 ]]; then
    emails_per_second=$((total_checked / duration))
fi
printf "\n${BRIGHT_WHITE}SECURITY & SPEED METRICS:${NC}\n"
printf "${BRIGHT_BLUE}────────────────────────────────────────────────────────────${NC}\n"
printf "${CYAN}Total time:      ${duration}s${NC}\n"
printf "${GREEN}Speed:           ${emails_per_second} emails/second${NC}\n"
printf "${YELLOW}Security:        ENCRYPTED RESPONSE SYSTEM${NC}\n"
printf "${MAGENTA}Encryption:     AES-256-CBC ACTIVE${NC}\n"


archive_dir="gmail_checked_$(date +%Y%m%d_%H%M%S)"
mv "$targetFolder" "$archive_dir"
rm -f "$inputFile.gmail_fast"

printf "\n${BRIGHT_GREEN}Results: ${BRIGHT_CYAN}$archive_dir${NC}\n"
printf "${BRIGHT_YELLOW}DH4NDY GMAIL validation completed!${NC}\n\n"


printf "${BRIGHT_BLUE}╔══════════════════════════════════════════════════════════╗${NC}\n"
printf "${BRIGHT_BLUE}║                       DH4NDY - 2025                      ║${NC}\n"
printf "${BRIGHT_BLUE}╚══════════════════════════════════════════════════════════╝${NC}\n"
