# offlinetools
Tools to spend more time offline

## do_the_internet.sh

depends: protonmail-bridge, msmtp, offlineimap, newsboat, mblaze and offpunk

See [Offpunk smolnet browser](https://tildegit.org/ploum/AV-98-offline).

A script that checks:

1. If protonmail-bridge is running
2. Take URLs saved in a urls.txt file  (urls I want to read)
3. Send those URLs by mail to the service forlater.email
4. List then send mail queued through the msmtp example scripts
5. Update RSS in newsboat
6. Get my emails through offlineimap
7. Display number of RSS news and news to read in my "news" mail folder
8. Display mails in my inbox


## TODO :
- reading and archiving emails easily !
- reading gemini offline


## newsboat_config

file to be put in .newsboat/config

with this file, every external link will, instead of being opened in a browser, send to the URLs text file (that will later be sent by email to forlater.email).

## Non-urgent :
- optional : apt update/dist-upgrade
- optional : flatpak upgrade
- optional : update wikipedia zim files  (I’ve yet to find a way to do it)
