Installation and Usage
To install and run the server optimization script, follow these two simple steps. This method ensures the script is downloaded locally before being executed with root privileges, which is often a more reliable approach for interactive scripts.

Download the script: This command uses curl to download the script from the specified GitHub URL and saves it to a file named users.sh.

curl -fsSL -o users.sh https://raw.githubusercontent.com/diswebir/server-optimizer/main/users.sh

Run the script with root privileges: This command executes the downloaded users.sh script using sudo bash, which grants the necessary administrator permissions for it to make system changes.

sudo bash users.sh
