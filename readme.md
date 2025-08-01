Installation and Usage
----------------------

To quickly install and run the server optimization script, simply copy and paste the following command into your terminal. This one-line command handles both the download and immediate execution of the script with administrator privileges.

<code>curl -fsSL https://raw.githubusercontent.com/diswebir/server-optimizer/main/users.sh</code>

<code>sudo bash [users.sh](http://users.sh) </code>

  <input id="my-text-to-copy" value="This text will be copied.">
  <clipboard-copy for="my-text-to-copy">Copy Text</clipboard-copy>

### Command Breakdown

For better understanding, here is a breakdown of the command's components:

-   curl -fsSL ...: This part downloads the script from the provided URL. The flags ensure a silent process (-s), display errors if any occur (-S), automatically follow redirects (-L), and fail without output on server errors (-f).

-   | (Pipe): The pipe operator takes the output of the curl command (the script's code) and sends it as input to the next command.

-   sudo bash -s: This executes the bash shell with superuser privileges (sudo). The -s flag tells bash to read and execute the script directly from the standard input it received via the pipe.
