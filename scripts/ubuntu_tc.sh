#!/bin/bash

### Add work stuff to a machine
### Trying to keep it fairly generic for different flavors of Ubuntu
### Updated for Ubuntu 18.04

# TODO: configure and pull down stuff from gitlab.umbctraining.com

echo "Answer 'no' if connected to Training Centers Corporate network. Need to fix support.umbctraining.com from inside."
echo "Would you like to install SimpleHelp? [Y/n]"
read add_simplehelp

# Install SimpleHelp (or not)
if [ "${add_simplehelp,,}" != "n" ] && [ "${add_simplehelp,,}" != "no" ]; then
	echo "Downloading and extracing SimpleHelp archive..."
	wget -O SimpleHelpTechnician.tar "http://support.umbctraining.com/technician/SimpleHelp%20Technician-linux64-online.tar?language=en&hostname=http%3A%2F%2Fsupport.umbctraining.com&ie=ie.exe"
	tar -xvf SimpleHelpTechnician.tar
	echo "Running SimpleHelp installer..."
	~/SimpleHelp\ Technician-linux64-online
	rm  *SimpleHelp*
fi

#chmod go-rwx .tc_config

# TODO: Download and install latest sharp drivers
# http://siica.sharpusa.com/Portals/0/downloads/Drivers/Sharp_1_2_MX_C52_ps.zip
