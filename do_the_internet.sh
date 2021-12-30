#!/bin/bash -e
# dependancies : mblaze, msmtp, offlineimap, newsboat
# parameters
refresh_interval=43200
inbox=~/mail/INBOX
news=~/mail/Folders.News
online_folder=~/mail/Folders.online
forlater="save@forlater.email"
urls=~/inbox/to_read/urls.txt
# Offline mail and RSS command
enqueue=/usr/share/doc/msmtp/examples/msmtpqueue/msmtp-enqueue.sh
listqueue=/usr/share/doc/msmtp/examples/msmtpqueue/msmtp-listqueue.sh
runqueue=/usr/share/doc/msmtp/examples/msmtpqueue/msmtp-runqueue.sh
getmail="offlineimap -o"
notmuch="notmuch new"
getrss="newsboat -x reload"
displayrss="newsboat -x print-unread"
news_cache=~/.newsboat/cache.db
geminisync=~/dev/AV-98-offline/offpunk.py
geminitour=~/.config/offpunk/tour

send_urls () {
	# First part : sending URLs to save@forlater.email
	#number of header lines in urls.txt
	#To: save@forlater.email
	#Subject: Urls
	# blank line
	headers=3
	# number of line in urls (we need only the first char)
	# 3 first lines are mail header
	nb=$(wc -l $urls)
	if [ ${nb::1} -gt $headers ]
	then
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
	current=`date +%s`
	last_modified=`stat -c %Y $news_cache`
	echo "****** RSS and Gemini ******"
	if [ $(( $current - $last_modified)) -gt $refresh_interval ]
	then
		echo "Fetching RSS… (usually slow)"
		$getrss
	else
		echo "No RSS refresh for now"
	fi
}

refresh_gemini() {
	$geminisync --sync --cache-validity $refresh_interval
}

fetch_emails() {
	# Fourth part: getting mail
	echo "******* Sync IMAP ******"
	$getmail
	$notmuch
}


display_dashboard() {
	echo "******************"
	# Sixth part : dashboard
	echo "$($displayrss) in RSS newsboat"
	nb_news=$(mlist $news|wc -l)
	nb_online=$(mlist $online_folder|wc -l)
	nb_gemini=$(cat $geminitour|wc -l)
	echo "$nb_gemini article(s) to read in gemini tour"
	echo "$nb_news article(s) to read in news :"
	echo "- - - - - - - - "
	mlist $news|mblaze-sort -d|mscan -f %10d%t%2i%s
	echo "*****************"
	nb_inbox=$(mlist $inbox|wc -l)
	echo "$nb_inbox mail(s) in Inbox"
	mlist $inbox|mblaze-sort -d|mscan
	echo "************"
	echo "TODO : list of current projects with next tasks"
	echo "$nb_online tasks to do online"
}

shutdown_connection() {
	echo "You can shutdown protonmail-bridge"
	echo "TODO : check calendar, tresorit and URLs"
}


# Check for protonmail bridge
pid=`pgrep protonmail|wc -l`
if [ $pid -gt 0 ]
then
	echo "Protonmail Bridge running"
	send_urls
	list_outbox
	send_emails
	refresh_rss
	refresh_gemini
	fetch_emails
	shutdown_connection
else
	echo " * * * Protonmail Bridge not running ! * * *"
	list_outbox
fi

display_dashboard
