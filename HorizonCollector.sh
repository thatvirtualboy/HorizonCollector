#! /bin/bash
#
# HorizonCollector for Mac by Ryan Klumph
# Please report any issues to Ryan on Twitter (@thatvirtualboy)
#

echo "Collecting Horizon View Logs..."
sleep 4s
echo "WARNING: you must run this as sudoer if you need to gather USB related logs"
sleep 4s

zip -r9 ~/Desktop/vmware-logs-`date +%Y-%m-%d_%I.%M.%S_%p_%Z`.zip ~/Library/Logs/VMware* ~/Library/Preferences/ByHost/com.microsoft.rdc.*.plist ~/Library/Preferences/com.microsoft.rdc.plist /Library/Logs/VMware* --exclude=*fusion -x=*Fusion* &> /dev/null

echo "***************************************************"
echo "***************************************************"
echo "                                                   "
echo "    All done! The log bundle is on your desktop    "
echo "                                                   "
echo "***************************************************"
echo "***************************************************"
