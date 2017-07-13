# Bash tool to display system information after logging into a Linux system

### Idea

This tool displays useful system information after logging into a Linux system, such as version, CPU information, 
memory, disk information, number of updates, ...

### Screenshots

Modern:

![FireMotD Modern](/../screenshots/FireMotD-Theme-Modern-v5.12.png?raw=true "FireMotD Modern")

Blue:

![FireMotD Blue](/../screenshots/FireMotD-Theme-Blue-v5.12.png?raw=true "FireMotD Blue")

Red:

![FireMotD Red](/../screenshots/FireMotD-Theme-Red-v5.12.png?raw=true "FireMotD Red")

Gray:

![FireMotD Gray](/../screenshots/FireMotD-Theme-Gray-v5.12.png?raw=true "FireMotD Gray")

Original:

![FireMotD Original](/../screenshots/FireMotD-Theme-Original-v5.12.png?raw=true "FireMotD Original")


### Status

Production ready.

### How To

Please check https://outsideit.net/FireMotD for more information on how to use this plugin.

### Help

In case you find a bug or have a feature request, please make an issue on GitHub.

### Install Dependencies

##### Using yum
```
sudo yum install openssh-clients bc sysstat jq moreutils
```

##### Using apt-get
```
sudo apt-get install bc sysstat jq moreutils
```
### Usage Help

```
$ FireMotD --help
FireMotD v5.13.160630

Usage: 
 FireMotD [-v] -t <Theme Name> 
 FireMotD [-v] -C ['String']
 FireMotD [-vUhVs]

Options:
  -h | --help               Shows this help and exits
  -v | --verbose            Verbose mode (shows messages)
  -V | --version            Shows version information and exits
  -t | --theme <Theme Name> Shows Motd info on screen, based on the chosen theme
  -C | --colortest          Prints color test to screen
  -M | --colormap           Prints color test to screen, with color numbers in it
  -S | --save               Saves data to /var/tmp/FireMotD.json
 -HV | --hideversion        Hides version number

256-color themes:
 original
 modern
 gray
 orange

16-color themes:
 red
 blue
 clean

HTML theme:
 html

Examples:
 FireMotD -t original
 FireMotD -t html > /tmp/motd.html
 FireMotD --theme Modern
 FireMotD --colortest
 FireMotD -M
 sudo /usr/local/bin/FireMotD --saveupdates

Note:
 Some functionalities may require superuser privileges. For example to check for updates. 
 If you have problems, try something like:
 sudo ./FireMotD -S
```

### System Install

You need to have `make` installed on the system, if you want to use the Makefile.

##### To install to /usr/local/bin/FireMotD
```bash
sudo make install
```
With this you can probably run FireMotD from anywhere in your system. If not, you need to add `/usr/local/bin` to your `$PATH` variable. To adjust the installation path, change the var `IDIR=/usr/local/bin` in the Makefile to the path you want.

##### To install bash autocompletion support
```bash
sudo make bash_completion
```
With this you can use TAB to autocomplete parameters and options with FireMotD.
Does not require the sudo make install above (system install), but requires the `bash-completion` package to be installed and working. Then you should logout-login or source the bash completion file, eg. `$ . /etc/bash_completion.d/FireMotD`  

If you don't have root access, just install everything on your user's folder and source the file from your user's .profile file

### Crontab to get system updates count

This is an example on how to record the system update package count daily.  
This will update the file `/var/tmp/updatecount.txt` for later access.  
Root privilege is required for this operation. 
Only `/etc/crontab` and the files in `/etc/cron.d/` have a username field.
 
The recommended way to generate updatecount.txt is by creating a separate cron file for firemotd like this:

```bash
sudo vim /etc/cron.d/firemotd
# FireMotD system updates check (randomly execute between 0:00:00 and 5:59:59)
0 0 * * * root perl -e 'sleep int(rand(21600))' && /usr/local/bin/FireMotD -S &>/dev/null
```

But you can also put it in root's crontab (without the user field):

```bash
sudo crontab -e
# FireMotD system updates check (randomly execute between 0:00:00 and 5:59:59)
0 0 * * * perl -e 'sleep int(rand(21600))' && /usr/local/bin/FireMotD -S &>/dev/null
```

### Apt configuration to update updates count

On systems with apt (Debian, Ubuntu, ...) add the following configuration lines to refresh the updates count after an apt action (install, remove, ...) was performed.

Create the apt configuration file `/etc/apt/apt.conf.d/15firemotd` containing:
```bash
DPkg::Post-Invoke {
  "if [ -x /usr/local/bin/FireMotD ]; then echo -n 'Updating FireMotD available updates count ... '; /usr/local/bin/FireMotD -S; echo ''; fi";
};
```

### Adding FireMotD to run on login

Choosing where to run your script is kind of situational. Some files will only run on remote logins, other local logins, or even both. You should find out what suits best your needs on each case.

##### To add FireMotD to a single user
Edit the user's `~/.profile` file, `~/.bash_profile` file, or the `~/.bashrc` file
```bash
nano ~/.profile
```

Add the FireMotD call at the end of the file (choose your theme)
```bash
/usr/local/bin/FireMotD -t red
```

##### To add FireMotD to all users
You may call FireMotD from a few different locations for running globally.  
Eg.` /etc/bash.bashrc`, `/etc/profile`.  

You may also create a initialization script `init.sh` which will call the `FireMotD` script in `/etc/profile.d` when logging in. You can put whatever you like in this init.sh script. Everything in it will be executed at the moment someone logs in your system. Example:
```bash
#!/bin/bash
 
/usr/local/bin/FireMotD --Theme Red
```

### On Nagios Exchange

https://exchange.nagios.org/directory/Utilities/FireMotD/details

### Copyright

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public 
License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later 
version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more 
details at <http://www.gnu.org/licenses/>.
