## Horizon Collector for Mac by Ryan Klumph
### Please report any issues to Ryan on Twitter ([@thatvirtualboy](http://twitter.com/thatvirtualboy))

<p align="center"><img src="https://cloud.githubusercontent.com/assets/13758243/9935120/1c728dd8-5d12-11e5-920a-ec2c0416481c.png" height="150" width="150"></p>

This script gathers Horizon View Client logs and has the ability to upload them to VMware Support. It was written with end-users in mind and emphasises ease-of-use. To run the script:

1. Copy HorizonCollector.sh to your desktop
2. Open Terminal (Applications > Terminal)
3. Type   

      ``cd ~/Desktop``
      
      ``./HorizonCollector.sh``

 NOTE: If you need to gather USB logs for USB related issues, you must run the script as sudoer

 e.g., 

    ``sudo ./HorizonCollector.sh``

### Changelog

v1.4 - Added ability to enable and collect full DEBUG logging

v1.3 - Cleaned up ThinPrint logic, pulls ThinPrint versioning, and added sudo check 

v1.2 - Added ThinPrint logging by enabling debug CUPS logging / Better script documentation

v1.1 - Added FTP functionality. Script prompts to upload to VMware Support Request

v1.0 - Gathers logs and zips to directory on desktop

