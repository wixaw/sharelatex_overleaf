#!/bin/bash

# A copier en cron monthly
# cp /local/sharelatex-local/Scripts/clean-logs.sh /etc/cron.monthly/

cd /usr/local/data-sharelatex/data-prod/

echo "" > /usr/local/data-sharelatex/data-prod/chat.log
echo "" > /usr/local/data-sharelatex/data-prod/clsi.log
echo "" > /usr/local/data-sharelatex/data-prod/docstore.log
echo "" > /usr/local/data-sharelatex/data-prod/document-updater.log
echo "" > /usr/local/data-sharelatex/data-prod/filestore.log
echo "" > /usr/local/data-sharelatex/data-prod/notifications.log
echo "" > /usr/local/data-sharelatex/data-prod/real-time.log
echo "" > /usr/local/data-sharelatex/data-prod/spelling.log
echo "" > /usr/local/data-sharelatex/data-prod/tags.log
echo "" > /usr/local/data-sharelatex/data-prod/track-changes.log
echo "" > /usr/local/data-sharelatex/data-prod/web.log

