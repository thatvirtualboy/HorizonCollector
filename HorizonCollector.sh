#! /bin/bash
#
# Horizon Collector v1.3 for Mac by Ryan Klumph
# Please report any issues to Ryan on Twitter (@thatvirtualboy)
# www.thatvirtualboy.com
#

echo "Collecting Horizon View Logs..."
sleep 2s

# Check if root
if [ "$(whoami)" != "root" ]; then
echo "WARNING: you must run this as sudoer if you need to gather USB related logs!"
sleep 4s
fi 

# Check if ThinPrint logs are needed
echo "Are you troubleshooting a printing issue?"
select ynn in "Yes" "No"; do
	case $ynn in
		Yes ) echo "Enabling print logging..."

if [ -d ~/Library/Caches/vmware-view-thinprint-old ]
then
    sudo rm -r ~/Library/Caches/vmware-view-thinprint-old &> /dev/null
fi
			mv ~/Library/Caches/vmware-view-thinprint ~/Library/Caches/vmware-view-thinprint-old &> /dev/null
			cupsctl --debug-logging
			sleep 2s
			read -p "Print logging enabled! Please restart the Horizon View Client and reproduce the printing issue. Then, come back to this console and hit [ENTER]" $enter;
			
			# Create symlink to avoid hidden files
			ln -s ~/Library/Caches/vmware-view-thinprint/.thnuclnt-* ~/Library/Caches/vmware-view-thinprint/thnuclnt &> /dev/null

			# Grab ThinPrint versions
			/Applications/VMware\ Horizon\ Client.app/Contents/Library/thnuclnt/thnuclnt -v > ~/Library/Caches/vmware-view-thinprint/thnuclnt/thinprint_version.txt
			/Applications/VMware\ Horizon\ Client.app/Contents/Library/thnuclnt/thnuclnt -V >> ~/Library/Caches/vmware-view-thinprint/thnuclnt/thinprint_version.txt
			break;;
		No ) break;; 
	esac
done

# Set zipfile variable
zipfile=vmware-logs-`date +%Y-%m-%d_%I.%M.%S_%p_%Z`.zip

# Bring home the bacon
zip -r9 ~/Desktop/$zipfile /var/log/cups/* /.thnuclnt/*.log ~/Library/Caches/vmware-view-thinprint/thnuclnt ~/Library/Logs/VMware* ~/Library/Preferences/ByHost/com.microsoft.rdc.*.plist ~/Library/Preferences/com.microsoft.rdc.plist /Library/Logs/VMware* --exclude=*fusion -x=*Fusion* &> /dev/null

# Disable debug print logging
cupsctl --no-debug-logging
sleep 1s

echo "Done!"
sleep 2s

# FTP to VMware Support
echo "Upload logs to VMware Support Request?"
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




