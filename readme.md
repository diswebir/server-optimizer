Installation and Usage
----------------------

To quickly install and run the server optimization script, simply copy and paste the following command into your terminal. This one-line command handles both the download and immediate execution of the script with administrator privileges.

```bash 
curl -fsSL -o users.sh https://raw.githubusercontent.com/diswebir/server-optimizer/main/users.sh
```
```bash
sudo bash users.sh
```




### 🚀 Hey there! Ready to Simplify Your Linux Life?

Running a Linux system is great, but managing users can be a bit of a headache. This script makes it super easy! It's a handy, interactive tool that puts all the important user stuff in one place. You won't have to mess around with a bunch of different commands in the terminal anymore. Instead of juggling multiple tools, this single script guides you through everything with simple prompts and clear choices. It's like having a friendly co-worker who handles all the tedious admin tasks for you! 🛠️

**Here's what you can do:**

-   **User Management Made Simple:** It's a breeze to **add ➕, delete 🗑️, or edit ✍️** users. Adding a new user? No problem! The script walks you through setting up a username, creating a strong password, and even assigning them to the right groups. Need to remove an old one and all their files? Done. This script ensures a clean removal, getting rid of home directories and other data so nothing gets left behind. You can even handle their groups easily, like adding a new user to the `sudo` or `docker` group with just a couple of clicks. This saves you a ton of time and prevents mistakes, making sure your user accounts are exactly how you want them.

-   **Lock Down Your System:** Keep things extra safe! You can lock 🔒 or unlock 🔓 user accounts in a flash. Locking an account is a great way to temporarily block a user from logging in without deleting their account entirely. This is perfect for when someone is on leave or if you need to quickly suspend their access for a security reason. Plus, the script helps you set up strong password rules so no one can guess them. It makes sure every new password is secure, including a minimum length of 8 characters and a mix of uppercase, lowercase, numbers, and special characters! The script even handles the complex PAM configurations for you in the background, so you can be confident your password policies are solid. 🛡️

-   **Keep an Eye on Things:** Want to know what a user is up to? You can quickly check their **CPU 📈, memory 🧠, and disk usage 💾**. This is super useful for spotting any sneaky processes that are slowing down your system or users who are taking up too much space. Maybe a user's script is eating up all the CPU, or their downloads folder has grown out of control! Monitoring these resources helps you diagnose performance issues and maintain a healthy, smooth-running system.

-   **No-Fuss Setup:** No more worrying about missing programs. The script is smart---it checks for anything it needs, like `libpam-pwquality`, and asks if you want to install it for you. This means you can just run it and get to work, without having to dig through manuals or search online forums for what's missing. The script takes care of the technical details so you can focus on the bigger picture. It's a truly a "set it and forget it" solution for getting started. ✅

Basically, it's a simple, all-in-one tool to keep your system safe and organized. You're going to love it! It's designed to be reliable, secure, and incredibly easy to use, so you can manage your system with confidence. 🌟
