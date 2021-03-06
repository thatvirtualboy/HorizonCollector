#! /bin/bash
#
# Horizon Collector for Mac by Ryan Klumph
# Please report any issues to Ryan on Twitter (@thatvirtualboy)
# Changelog and source available at https://github.com/thatvirtualboy/horizoncollector
# www.thatvirtualboy.com
#

clear
echo "+--------------------------------------------------------------------+"
echo "| This script will collect VMware Horizon Client logs for macOS      |"
echo "| It can also do the following:                                      |"
echo "|                                                                    |"
echo "| - Enable DEBUG logging                                             |"
echo "| - Upload Log Bundle to VMware Support Request                      |"
echo "| - Collect USB, RTAV, and PCoIP logs                                |"                                             
echo "|                                                                    |"
echo "|   For a full list of changes and optimizations,                    |"
echo "|   visit https://labs.vmware.com/flings/horizon-collector-for-mac   |"
echo "|                                                                    |"
echo "|                                                                    |"
echo "|                       >>> VMware Flings <<<                        |"
echo "+--------------------------------------------------------------------+"
read -p "Press any key to start..." -n1 -s
clear

# Check if ThinPrint logs are needed for default log collection
thinprint(){
echo
echo "Are you troubleshooting a printing issue?"
select ynn in "Yes" "No"; do
case $ynn in
Yes ) 
echo
echo "Enabling print logging..."

if [ -d ~/Library/Caches/vmware-view-thinprint-old ]
then
sudo rm -r ~/Library/Caches/vmware-view-thinprint-old &> /dev/null
fi
#mv ~/Library/Caches/vmware-view-thinprint ~/Library/Caches/vmware-view-thinprint-old &> /dev/null
cupsctl --debug-logging
sleep 2s
echo
read -p "Print logging enabled! Please reproduce the printing issue. Then, come back to this console and hit [ENTER]" $enter;
			
# Create symlink to avoid hidden files
ln -s ~/Library/Caches/vmware-view-thinprint/.thnuclnt-* ~/Library/Caches/vmware-view-thinprint/thnuclnt &> /dev/null

# Grab ThinPrint versions
/Applications/VMware\ Horizon\ Client.app/Contents/Library/thnuclnt/thnuclnt -v > ~/Library/Caches/vmware-view-thinprint/thnuclnt/thinprint_version.txt
/Applications/VMware\ Horizon\ Client.app/Contents/Library/thnuclnt/thnuclnt -V >> ~/Library/Caches/vmware-view-thinprint/thnuclnt/thinprint_version.txt
break;;
No ) break;; 
esac
done
}

# Check if ThinPrint logs are needed for DEBUG log collection. Huge thanks to Rick Heisterhagen.
thinprintdb(){
echo
echo "Are you troubleshooting a printing issue?"
select kn in "Yes" "No"; do
case $kn in
Yes ) 
if [ -d ~/Library/Caches/vmware-view-thinprint-old ]
then
sudo rm -r ~/Library/Caches/vmware-view-thinprint-old &> /dev/null
fi
#mv ~/Library/Caches/vmware-view-thinprint ~/Library/Caches/vmware-view-thinprint-old &> /dev/null
cupsctl --debug-logging
printing=1
read -p "Make sure the Horizon Client is started and that you are connected to a Horizon Session. Then, come back to this console and hit [ENTER]" $enter;
killall thnuclnt
sed -i "" -e $'6 a\\\n'"loglevel = debug" ~/Library/Caches/vmware-view-thinprint/.thnuclnt-*/thnuclnt.conf 
# Start thnuclnt again to make logging settings effective
export THNUCLNT_SVC=private
/Applications/VMware\ Horizon\ Client.app/Contents/Library/thnuclnt/thnuclnt -pdir ~/Library/Caches/vmware-view-thinprint/.thnuclnt-*
echo
read -p "Now reproduce the printing issue. Then come back to this console and hit [ENTER]" $enter;
break;;
No ) printing=0
break;; 
esac
done
}

collectlogs(){
echo
echo "Collecting Horizon Client Logs..."
sleep 2s

# Check if root
if [ "$(whoami)" != "root" ]; then
echo "WARNING: you must run this as sudoer if you need to gather USB related logs!"
sleep 4s
fi 

thinprint

# Set zipfile variable
zipfile=horizon-client-logs-`date +%Y-%m-%d_%I.%M.%S_%p_%Z`.zip
zip -r9 ~/Desktop/$zipfile /var/log/cups/* /.thnuclnt/*.log /var/root/Library/Logs/VMware/*.log ~/Library/Caches/vmware-view-thinprint/thnuclnt ~/Library/Logs/VMware* ~/Library/Preferences/ByHost/com.microsoft.rdc.*.plist ~/Library/Preferences/com.microsoft.rdc.plist /Library/Logs/VMware* --exclude=*fusion -x=*Fusion* &> /dev/null

# Disable debug print logging
cupsctl --no-debug-logging
sleep 1s

echo "Done!"
sleep 2s

# FTP to VMware Support
echo
echo "Upload logs to VMware Support Request?"
select yn in "Yes" "No"; do
case $yn in
Yes ) 
echo
read -p "Please type the SR Number and press [ENTER]:" SR; 
echo "Uploading..." 
curl -#T $zipfile --ftp-create-dirs ftp://ftpsite.vmware.com/$SR/`basename $zipfile` --user inbound:inbound
echo
echo "All done! The bundle is also saved to your desktop: $zipfile"
break;;
No ) 

# Remove Symlink
rm ~/Library/Caches/vmware-view-thinprint/thnuclnt

echo
echo "***************************************************"
echo "***************************************************"
echo "                                                   "
echo "    All done! The log bundle is on your desktop    "
echo "                                                   "
echo "***************************************************"
echo "***************************************************"; exit;;
esac
done
}

collectlogsdb(){
echo "Collecting Horizon Client DEBUG Logs..."
sleep 2s

# Check if root
if [ "$(whoami)" != "root" ]; then
echo "WARNING: you must run this as sudoer if you need to gather USB related logs!"
sleep 4s
fi 

# Set zipfile variable
zipfile=horizon-client-logs-`date +%Y-%m-%d_%I.%M.%S_%p_%Z`.zip

zip -r9 ~/Desktop/$zipfile /var/log/cups/* /.thnuclnt/*.log ~/Library/Caches/vmware-view-thinprint/thnuclnt ~/Library/Logs/VMware* ~/Library/Preferences/ByHost/com.microsoft.rdc.*.plist ~/Library/Preferences/com.microsoft.rdc.plist /Library/Logs/VMware* ~/.pcoip.rc ~/Library/Preferences/VMware\ Horizon\ View --exclude=*fusion -x=*Fusion* &> /dev/null

# Disable debug print logging
cupsctl --no-debug-logging
sleep 1s
echo "Done!"
sleep 2s

# FTP to VMware Support
echo
echo "Upload logs to VMware Support Request?"
select yn in "Yes" "No"; do
case $yn in
Yes ) 
echo
read -p "Please type the SR Number and press [ENTER]:" SR; 
echo "Uploading..." 
curl -#T $zipfile --ftp-create-dirs ftp://ftpsite.vmware.com/$SR/`basename $zipfile` --user inbound:inbound
disableDebug
echo
echo "All done! DEBUG logging has been disabled, and a copy of the bundle has been saved to your desktop: $zipfile"
break;;
No ) disableDebug

# Remove Symlink
rm ~/Library/Caches/vmware-view-thinprint/thnuclnt

echo
echo "***************************************************"
echo "***************************************************"
echo "                                                   "
echo "    All done! DEBUG logging has been disabled.     "
echo "A copy of the bundle has been saved to your desktop"
echo "                                                   "
echo "***************************************************"
echo "***************************************************"; exit;;
esac
done
}

# Big thanks to Le Yu
enableDebug(){
launchctl setenv VMWARE_VIEW_DEBUG_LOGGING "1"
launchctl setenv VMWARE_VIEW_USBD_LOG_OPTIONS "-o log:trace"
launchctl setenv VMWARE_VIEW_USBARBITRATOR_LOG_OPTIONS "--debug 3"
launchctl setenv SC_LOG_DETAIL "1"
defaults write com.vmware.rtav EnableExtraLogs true
defaults write com.vmware.rtav LogLevel trace
launchctl setenv VMW_RDPVC_BRIDGE_LOG_ENABLED "1"

mkdir -p "$HOME/Library/Preferences/VMware Horizon View"
echo "loglevel.user.cui = \"9\"" > "$HOME/Library/Preferences/VMware Horizon View/config"
echo "loglevel.user.syncWaitQ = \"10\"" >> "$HOME/Library/Preferences/VMware Horizon View/config"
echo "loglevel.user.dui = \"10\"" >> "$HOME/Library/Preferences/VMware Horizon View/config"
echo "loglevel.user.duiMKS = \"10\"" >> "$HOME/Library/Preferences/VMware Horizon View/config"
echo "loglevel.user.gui = \"10\"" >> "$HOME/Library/Preferences/VMware Horizon View/config"
echo "loglevel.user.crtbora = \"9\"" >> "$HOME/Library/Preferences/VMware Horizon View/config"
echo "loglevel.user.vmIPC = \"9\"" >> "$HOME/Library/Preferences/VMware Horizon View/config"
echo "loglevel.user.mks = \"9\"" >> "$HOME/Library/Preferences/VMware Horizon View/config"
echo "loglevel.user.tools = \"9\"" >> "$HOME/Library/Preferences/VMware Horizon View/config"
echo "loglevel.user.guest_rpc = \"10\"" >> "$HOME/Library/Preferences/VMware Horizon View/config"
echo "vvc.plugins = \"libvdpservice\"" >> "$HOME/Library/Preferences/VMware Horizon View/config"
echo "vvc.plugins.libvdpservice.filename = \"/Applications/VMware Horizon Client.app/Contents/Library/pcoip/vchan_plugins/libvdpservice.dylib\"" >> "$HOME/Library/Preferences/VMware Horizon View/config"
echo "ViewTsdr-Client.TsdrLogger.logLevel = verbose" >> "$HOME/Library/Preferences/VMware Horizon View/config"
echo "pcoip.event_filter_mode = \"3\"" > "$HOME/.pcoip.rc" 
}

disableDebug(){
launchctl setenv VMWARE_VIEW_DEBUG_LOGGING ""
launchctl setenv VMWARE_VIEW_USBD_LOG_OPTIONS ""
launchctl setenv VMWARE_VIEW_USBARBITRATOR_LOG_OPTIONS ""
launchctl setenv SC_LOG_DETAIL ""
defaults delete com.vmware.rtav EnableExtraLogs
defaults delete com.vmware.rtav LogLevel
launchctl setenv VMW_RDPVC_BRIDGE_LOG_ENABLED ""
rm "$HOME/Library/Preferences/VMware Horizon View/config" &> /dev/null
rm "$HOME/.pcoip.rc" &> /dev/null
}

###
echo "Thanks for using Horizon Collector! Would you like to collect default logs, or DEBUG logs?"
select zn in "Default" "DEBUG"; do
case $zn in
Default ) 
echo
collectlogs
break;;

DEBUG ) 
echo
echo "Horizon Collector will now enable DEBUG logging..."
enableDebug
sleep 2s
echo "DEBUG logging enabled!" 
sleep 2s
echo
read -p "Please restart the Horizon Client. Reproduce the issue (unless it's printing related). Then come back to this console and hit [ENTER]" $enterdb;
thinprintdb
				
# Create symlink to avoid hidden files
if [ $printing -eq 1 ]; then
ln -s ~/Library/Caches/vmware-view-thinprint/.thnuclnt-* ~/Library/Caches/vmware-view-thinprint/thnuclnt &> /dev/null

# Grab ThinPrint versions
/Applications/VMware\ Horizon\ Client.app/Contents/Library/thnuclnt/thnuclnt -v > ~/Library/Caches/vmware-view-thinprint/thnuclnt/thinprint_version.txt 2> /dev/null
/Applications/VMware\ Horizon\ Client.app/Contents/Library/thnuclnt/thnuclnt -V >> ~/Library/Caches/vmware-view-thinprint/thnuclnt/thinprint_version.txt 2> /dev/null	
fi

collectlogsdb				
		
break;; 
esac
done
