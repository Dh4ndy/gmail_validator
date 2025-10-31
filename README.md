# GMAIL VALIDATOR
## Installation the required tools

Ubuntu/Debian:
```sh
sudo apt install -y openssl netcat-openbsd dnsutils telnet coreutils dos2unix
```

CentOS/RHEL:

```sh
sudo yum install -y openssl nc bind-utils telnet coreutils dos2unix
```

Termux (Android):

```sh
pkg install openssl netcat-openbsd dnsutils telnet coreutils dos2unix
```


## Exec

Grant Executable Permission:

```sh
chmod +x gmail.sh
```

If "bash: ./gmail.sh: cannot execute: required file not found" then:

```sh
dos2unix gmail.sh
```

run:

```sh
./gmail.sh
```

   ## Command Line Arguments

```sh
# Basic usage
./gmail.sh -i emails.txt -r results/

# Dengan custom settings
./gmail.sh -i emails.txt -r results/ -l 10 -t 2 -d

# Full options
./gmail.sh -i emails.txt -r results/ -l 15 -t 1 -d

# With Auto-Delete
./gmail.sh -i temp_emails.txt -r final_results/ -d
```

## Parameter Options
| Parameter | Description | Information |
| ------ | ------ | ------  |
| -i file | Input file email list | required
| -r folder | Folder for results | required
| -l number | Email per batch | max 3
| -t seconds | Delay per seconds | 1 sec
| -d | Delete processed emails | free
| -h | help | -

Contact me dh44ndy@gmail.com
