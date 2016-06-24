# Bash tool to display system information after logging into a Linux system

### Idea

This tool displays useful system information after logging into a Linux system, such as version, CPU information, 
memory, disk information. 

### Screenshots

Modern:

![MotD Generator Modern Raspbian](/../screenshots/generate-motd-modern-raspbian.png?raw=true "MotD Generator Modern Raspbian")

Blue:

![MotD Generator Blue Raspbian](/../screenshots/generate-motd-blue-raspbian.png?raw=true "MotD Generator Blue Raspbian")

Red:

![MotD Generator Red Raspbian](/../screenshots/generate-motd-red-raspbian.png?raw=true "MotD Generator Red Raspbian")

Original:

![MotD Generator Original Raspbian](/../screenshots/generate-motd-original-raspbian.png?raw=true "MotD Generator Original Raspbian")


### Status

Production ready.

### How To

Please check https://outsideit.net/FireMotD/ for more information on how to use this plugin.

### Help

In case you find a bug or have a feature request, please make an issue on GitHub.

### Usage Help

```
$ FireMotD --help
/usr/local/bin/FireMotD v5.02.160528

Usage: /usr/local/bin/FireMotD <-t theme> [UhCVv]

Options:
  -h | --help        Shows this help and exits
  -v | --verbose     Verbose mode (shows messages)
  -V | --version     Shows version information and exits
  -t | --theme       Shows Motd info on screen, based on the chosen theme
  -C | --colortest   Prints color test to screen
  -U | --updates     Checks updates and prints to stdout
  -s | --saveupdates Check updates and saves to disk
                     (same as /usr/local/bin/FireMotD -U > /var/tmp/updatecount.txt)

Available Themes:
  -t original
  -t modern
  -t red
  -t blue
  -t html
  -t blank

Examples:
  /usr/local/bin/FireMotD -t original
  /usr/local/bin/FireMotD --theme Modern
  /usr/local/bin/FireMotD --colortest
  /usr/local/bin/FireMotD --saveupdates

Note:
  Some functionalities may require superuser priviledges. Eg. check for updates.
  Please try doing sudo /usr/local/bin/FireMotD if you have problems.
```

### System Install

You need to have `make` installed on the system.

Then to install to /usr/local/bin:
```bash
sudo make install
```

To install bash_completion (with TAB):
```bash
sudo make bash_completion
```

### Crontab example 

This is an example on how to update the System Update Info daily.

This will update the /var/tmp/updatecount.txt file for later access.

Root privilege is required for this operation.

To edit root's crontab:
```bash
sudo crontab -e
```

Then add this line (updates everyday at 3:03am)
```bash
3 3 * * * /usr/local/bin/FireMotD -s
```

Or using the old way:
```bash
3 3 * * * /usr/local/bin/FireMotD -U > /var/tmp/updatecount.txt
```

### Adding to an SSH session

To add this to a single user, just call the program from the user's ~/.profile file.

```bash
nano ~/.profile
```

Then add to the end (choose your theme):
```bash
/usr/local/bin/FireMotD -t modern
```

### On Nagios Exchange

https://exchange.nagios.org/directory/Utilities/FireMotD/details

### Copyright

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public 
License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later 
version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more 
details at <http://www.gnu.org/licenses/>.
