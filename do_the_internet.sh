#!/bin/bash -e
# dependancies : mblaze, msmtp, offlineimap, newsboat
# parameters
refresh_interval=43200
inbox=~/mail/INBOX
news=~/mail/Folders.News
online_folder=~/mail/Folders.online
forlater="save@forlater.email"
urls=~/inbox/to_read/urls.txt
to_fetch=~/.local/share/offpunk/lists/to_fetch.gmi
# Offline mail and RSS command
enqueue=/usr/share/doc/msmtp/examples/msmtpqueue/msmtp-enqueue.sh
listqueue=/usr/share/doc/msmtp/examples/msmtpqueue/msmtp-listqueue.sh
runqueue=/usr/share/doc/msmtp/examples/msmtpqueue/msmtp-runqueue.sh
getmail="offlineimap -o"
notmuch="notmuch new"
getrss="newsboat -x reload"
displayrss="newsboat -x print-unread"
news_cache=~/.newsboat/cache.db
geminisync=~/dev/offpunk/offpunk.py
geminitour=~/.local/share/offpunk/lists/tour.gmi
geminitoread=~/.local/share/offpunk/lists/toread.gmi
#number of header lines in urls.txt
#To: save@forlater.email
#Subject: Urls
# blank line
headers=3

send_urls () {
	# First part : sending URLs to save@forlater.email
	# number of line in urls (we need only the first char)
	# 3 first lines are mail header
	nb=$(cat $urls| wc -l)
	if [ "${nb}" -gt $headers ]
	then
		echo "sending urls"
		$enqueue $forlater < $urls
		# once send, we remove URLS by rewriting the file (-i)
		# with only the three first lines (header)
		sed "1,$headers ! d" ~/inbox/to_read/urls.txt -i
	else
		echo "no URLs to read forlater"
	fi
}

list_outbox() {
	echo "***** Mails to send *****"
	$listqueue
}

send_emails() {
	echo "***** Sending mails ! *****"
	$runqueue
}

refresh_rss() {
	# Third part: getting rss every $refresh_interval (in seconds)
	current=$(date +%s)
	last_modified=$(stat -c %Y $news_cache)
	remaining=$(( refresh_interval - current + last_modified))
	hremaining=$(( remaining/3600 ))
	if [ $(( current - last_modified)) -gt $refresh_interval ]
	then
		echo "Fetching RSS… (usually slow)"
		$getrss
	else
		echo "No RSS refresh for now, next refresh in $hremaining hours"
	fi
}

refresh_gemini() {
	$geminisync --sync --assume-yes --cache-validity $refresh_interval
}

fetch_emails() {
	# Fourth part: getting mail
	echo "******* Sync IMAP ******"
	$getmail
	$notmuch
}


display_dashboard() {
	export MBLAZE_PAGER=""
	echo "******************"
	# Sixth part : dashboard
	echo "$($displayrss) in RSS newsboat"
	nb_news=$(mlist $news|wc -l)
	nb_online=$(mlist $online_folder|wc -l)
	nb_gemini=$(cat $geminitour|wc -l)
	nb_gemini_toread=$(cat $geminitoread|grep "=>"|wc -l)
	echo "$nb_gemini article(s) to read in gemini tour"
	echo "$nb_gemini_toread article(s) to read in offpunk toread"
	echo "$nb_news article(s) to read in news :"
	echo "- - - - - - - - "
	mlist $news|mblaze-sort -d|mscan -f %10d%t%2i%s
	echo "*****************"
	nb_inbox=$(mlist $inbox|wc -l)
	echo "$nb_inbox mail(s) in Inbox"
	mlist $inbox|mblaze-sort -d|mscan
	echo "************"
	echo "TODO : calendar, push git, list of tasks"
	echo "$nb_online tasks to do online"
}

shutdown_connection() {
	echo "You can shutdown protonmail-bridge"
}


# Check for protonmail bridge
pid=$(pgrep protonmail|wc -l)
if [ "$pid" -gt 0 ]
then
	echo "Protonmail Bridge running"
	send_urls
	list_outbox
	send_emails
	echo "****** RSS and Gemini ******"
	refresh_rss
	refresh_gemini
	fetch_emails
	shutdown_connection
else
	echo " * * * Protonmail Bridge not running ! * * *"
	list_outbox
	nb_fetch=$(cat $to_fetch|wc -l)
	tmp=$(cat $urls|wc -l)
	nb_forlater=$(($tmp-$headers))
	echo " * * $nb_fetch in Offpunk fetch list"
	cat $to_fetch
	echo " * * $nb_forlater in Forlater list"
	tail +$(($headers+1)) $urls
fi

display_dashboard
