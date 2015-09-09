## HorizonCollector for Mac by Ryan Klumph
### Please report any issues to Ryan on Twitter ([@thatvirtualboy](http://twitter.com/thatvirtualboy))


This script gathers Horizon View Client logs and has the ability to upload them to VMware Support. To run the script:

1. Copy HorizonCollector.sh to your desktop
2. Open Terminal (Applications > Terminal)
3. Type   

      ``cd ~/Desktop``
      ``./HorizonCollector.sh``

 NOTE: If you need to gather USB logs for USB related issues, you must run the script as sudoer

 e.g., 

    ``sudo ./HorizonCollector.sh``

### Changelog

v1.2 - Added ThinPrint logging by enabling debug CUPS logging / Better script documentation

v1.1 - Added FTP functionality. Script prompts to upload to VMware Support Request

v1.0 - Gathers logs and zips to directory on desktop

