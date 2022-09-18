#!/bin/bash

platypus=$1

# User welcome message
if [ -z "$platypus" ]; then
    echo -e "\n####################################################################"
    echo '# 👋 Welcome, this is the setup script for the battery CLI tool.'
    echo -e "# Note: this script will ask for your password once or multiple times."
    echo -e "####################################################################\n\n"
fi

# Ask for sudo once, in most systems this will cache the permissions for a bit
sudo echo "🔋 Starting battery installation"

echo -e "\n[ 1/9 ] Superuser permissions acquired."

# Get smc source and build it
tempfolder=~/.battery-tmp
binfolder=/usr/local/bin
mkdir -p $tempfolder

smcfolder="$tempfolder/smc"
echo "[ 2/9 ] Cloning fan control version of smc"
git clone --depth 1 https://github.com/hholtmann/smcFanControl.git $smcfolder &> /dev/null
cd $smcfolder/smc-command
echo "[ 3/9 ] Building smc from source"
make &> /dev/null

# Move built file to bin folder
echo "[ 4/9 ] Move smc to executable folder"
sudo mkdir -p $binfolder
sudo mv $smcfolder/smc-command/smc $binfolder
sudo chmod u+x $binfolder/smc

# Write battery function as executable
bateryfolder="$tempfolder/battery"
echo "[ 5/9 ] Cloning battery repository"
git clone --depth 1 https://github.com/actuallymentor/battery.git $bateryfolder &> /dev/null
echo "[ 6/9 ] Writing script to $binfolder/battery"
sudo cp $bateryfolder/battery.sh $binfolder/battery
sudo chmod 755 $binfolder/battery
sudo chmod u+x $binfolder/battery

# Remove tempfiles
cd ../..
echo "[ 7/9 ] Removing temp folder $tempfolder"
rm -rf $tempfolder
echo "[ 8/9 ] Removed temporary build files"

$binfolder/battery visudo
echo "[ 9/9 ] Set up visudo declarations"

if [ -z "$platypus" ]; then
    echo -e "\n🎉 Battery tool installed. Type \"battery\" for instructions.\n"
fi