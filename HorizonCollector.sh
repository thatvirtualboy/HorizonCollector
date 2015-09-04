#! /bin/bash
#
# HorizonCollector for Mac by Ryan Klumph
# Please report any issues to Ryan on Twitter (@thatvirtualboy)
#

echo "Collecting Horizon View Logs..."
sleep 2s
echo "WARNING: you must run this as sudoer if you need to gather USB related logs"
sleep 2s

zipfile=vmware-logs-`date +%Y-%m-%d_%I.%M.%S_%p_%Z`.zip

zip -r9 ~/Desktop/$zipfile ~/Library/Logs/VMware* ~/Library/Preferences/ByHost/com.microsoft.rdc.*.plist ~/Library/Preferences/com.microsoft.rdc.plist /Library/Logs/VMware* --exclude=*fusion -x=*Fusion* &> /dev/null

echo "Upload logs to existing VMware Support Request?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) read -p "Please type the SR Number and press [ENTER]:" SR; 
			  echo "Uploading..." 
              curl -#T $zipfile --ftp-create-dirs ftp://ftpsite.vmware.com/$SR/`basename $zipfile` --user inbound:inbound
              echo "All done! The bundle is also saved to your desktop: $zipfile"
				break;;
        No ) 
echo "***************************************************"
echo "***************************************************"
echo "                                                   "
echo "    All done! The log bundle is on your desktop    "
echo "                                                   "
echo "***************************************************"
echo "***************************************************"; exit;;
    esac
done





