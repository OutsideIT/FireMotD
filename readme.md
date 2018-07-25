# MotD Generator for displaying custom system information

### Idea

This tool displays useful system information after logging into a Linux system (or Windows with FireMotD.ps1), such as version, CPU information, 
memory, disk information, number of updates, and many more useful things. 

### Theme Presentation

![FireMotD Themes](/../screenshots/FireMotD-Presentation-v10.01.gif?raw=true "FireMotD Theme Presentation")

Powershell:

![FireMotD Powershell](/../screenshots/FireMotD-Powershell.png?raw=true "FireMotD Powershell")

### Status

Production ready. Making sysadmins happy since 2014.

### How To

Please check https://outsideit.net/firemotd for more information on how to use this plugin.

### Help

In case you find a bug or have a feature request, please make an issue on GitHub.

### Usage Help

```
Usage:
 FireMotD [-v] -t <Theme Name>
 FireMotD [-v] -C ['String']
 FireMotD [-vhVs]

Options:
   -h  | --help               			Shows this help and exits
   -v  | --verbose            			Verbose mode (shows messages)
   -V  | --version            			Shows version information and exits
   -T  | --theme <Theme Name> 			Shows Motd info on screen, based on the chosen theme
   -D  | --Data                  Data template to use (basic or all)
   -TF | --TemplateFile <Path to template> 	Shows theme based on json templates
   -C  | --colortest          			Prints color test to screen
   -M  | --colormap           			Prints color test to screen, with color numbers in it
   -S  | --save               			Saves data to /var/tmp/FireMotD.json
   -I  | --install				Installs FireMotD
  -HV  | --hideversion        			Hides version number
 -sru  | --skiprepoupdate     			Skip the repository package update (apt only)

256-color themes:
 Digipolis
 Elastic
 Eline
 Gray
 Invader
 Modern
 Orange
 Original

16-color themes:
 Blanco
 Blue
 Red

HTML theme:
 html

Examples:
 sudo FireMotD -I -d
 sudo FireMotD -S -d -D all
 FireMotD -T Modern
 FireMotD -t html > /tmp/motd.html
 FireMotD -TF FireMotD-theme-Elastic.json
 FireMotD --theme Modern
 FireMotD --colortest
 FireMotD -M

Note:
 Some functionalities may require superuser privileges. Eg. check for updates.
 If you have problems, try something like:
 sudo FireMotD -S
```

### Installation

#### Dependencies

##### Using yum
```
sudo yum install bc sysstat jq moreutils
```

##### Using apt-get
```
sudo apt-get install bc sysstat jq moreutils
```

#### Built-in Install function

Run this command from you homefolder:
```bash
curl -s https://raw.githubusercontent.com/OutsideIT/FireMotD/master/FireMotD -o ~/FireMotD && chmod 755 ~/FireMotD && sudo ~/FireMotD -I -d
```

#### Make

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

### Crontab to get system information

Root privilege is required for this operation. Only `/etc/crontab` and the files in `/etc/cron.d/` have a username field.
 
The recommended way to generate /var/tmp/FireMotD.json is by creating a separate cron file for firemotd like this:

```bash
sudo vim /etc/cron.d/FireMotD
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
  "if [ -x /usr/local/bin/FireMotD ]; then echo -n 'Updating FireMotD available updates count ... '; /usr/local/bin/FireMotD -sru -S; echo ''; fi";
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
/usr/local/bin/FireMotD -T Red
```

##### To add FireMotD to all users
You may call FireMotD from a few different locations for running globally.  
Eg.` /etc/bash.bashrc`, `/etc/profile`.  

You may also create a initialization script `init.sh` which will call the `FireMotD` script in `/etc/profile.d` when logging in. You can put whatever you like in this init.sh script. Everything in it will be executed at the moment someone logs in your system. Example:
```bash
#!/bin/bash
 
/usr/local/bin/FireMotD -T Digipolis
```

### On Nagios Exchange

https://exchange.nagios.org/directory/Utilities/FireMotD/details

### Copyright

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public 
License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later 
version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more 
details at <http://www.gnu.org/licenses/>.
