#!/bin/bash -e
# dependancies : mblaze, msmtp, offlineimap, newsboat
# parameters
rss_refresh_interval=43200
inbox=~/mail/INBOX
news=~/mail/Folders.News
forlater="save@forlater.email"

# Check for protonmail bridge
pid=`pgrep protonmail|wc -l`
if [ $pid -gt 0 ]
then
	echo "Protonmail Bridge running"
else
	echo "Protonmail Bridge not running ! Aborting…"
	exit 45
fi

# Offline mail and RSS command
enqueue=/usr/share/doc/msmtp/examples/msmtpqueue/msmtp-enqueue.sh
listqueue=/usr/share/doc/msmtp/examples/msmtpqueue/msmtp-listqueue.sh
runqueue=/usr/share/doc/msmtp/examples/msmtpqueue/msmtp-runqueue.sh
getmail="offlineimap -o"
notmuch="notmuch new"
getrss="newsboat -x reload"
displayrss="newsboat -x print-unread"
news_cache=~/.newsboat/cache.db

# First part : sending URLs to save@forlater.email
urls=~/inbox/to_read/urls.txt
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

# Second part: sending mails
echo "***** Mails to send *****"
$listqueue
echo "***** mails sent ! *****"
$runqueue

# Third part: getting rss every $rss_refresh_interval (in seconds)
current=`date +%s`
last_modified=`stat -c %Y $news_cache`
echo "****** RSS ******"
if [ $(( $current - $last_modified)) -gt $rss_refresh_interval ]
then
	echo "Fetching RSS… (usually slow)"
	$getrss
else
	echo "No RSS refresh for now"
fi

# Fourth part: getting mail
echo "******* Sync IMAP ******"
$getmail
$notmuch

# Fifth part : shutting down
echo "You can shutdown protonmail-bridge"
echo "Manual checks: Tresorit and Protoncalendar"
echo "******************"

# Sixth part : dashboard
echo "$($displayrss) in RSS newsboat"
nb_news=$(mlist $news|wc -l)
echo "$nb_news article(s) to read in news"
mlist $news|mblaze-sort -d|mscan -f %10d%t%2i%s
echo "*****************"
nb_inbox=$(mlist $inbox|wc -l)
echo "$nb_inbox mail(s) in Inbox"
mlist $inbox|mblaze-sort -d|mscan
echo "************"
echo "TODO : check calendar and URLs"
echo "TODO : list of current projects with next tasks"
