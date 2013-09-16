#!/bin/bash


# This bash script name
ME=`basename $0`
# Folder
FOLDER=$1
# GitHub User
USER=$2

if [ -z "$USER" ] || [ -z "$FOLDER" ];
then
    echo
    echo "Usage: sh "$ME" <FOLDER> <USER>"
    echo "example: sh "$ME" /my_folder UserName"
    echo
exit
fi;

# This function sync folders to repositories at GitHub using parameters - FOLDER & USER.
function sync-tree-to-github ()
}
    for SUBFOLDER in $(find $FOLDER -maxdepth 1 -type d)
    do
	if [ ! $SUBFOLDER = $FOLDER ]; then
	    echo Creating $SUBFOLDER repo....
	    REPO=${SUBFOLDER##*/}
	    sync-folder-to-github $SUBFOLDER $USER $REPO
	fi;
    done
}

# This function sync folder to repository at GitHub using parameters - FOLDER & USER & REPO.
function sync-folder-to-github()
{
    #Get vars from function
    FOLDER=$1; USER=$2; REPO=$3

    #Create repo
    echo "Create GitHub repo"
    create-github-repo $USER $REPO

    #Sync to folder
    cd $FOLDER
    if [ -d ".git" ]; then
	echo "Syncing exist git"
	git remote add origin git@github.com:$USER/$REPO.git
	git push origin master
    else
	if [ ! -f "README.md" ]; then
	    echo "no README.md found."
	    # Uncomment to generate README.md for each new repo who don't have README.md file
	    #echo "generating README.md..."
	    #echo "$REPO"  > README.md 
	    #echo "========" >> README.md
	fi;
	if [ ! -f "LICENSE" ]; then
	    echo "no LICENSE found."
	    # Uncomment to download GPL3 LICENSE for each new repo who don't have LICENSE file
	    #echo "download GPL3 LICENSE..."
	    #wget http://www.gnu.org/licenses/gpl.txt
	    #mv gpl.txt LICENSE
	fi;
	echo "Creating new git and syncing"
	git init
	git remote add origin git@github.com:$USER/$REPO.git
	git add .
	git commit -a -m "Initial commit"
	git push origin master
	# uncomment to set tag for all the folders
	#git tag -a 1.0 -m 'verion 1.0'
	#git push origin master --tags
    fi
}


# This script creates a repository at GitHub using parameters - USER & REPO.
function create-github-repo()
{

# GitHub User
USER=$1
# Name of repo to create
REPO=$2

# Json to pass to github api
JSON='{"name":"'$REPO'"}'

# Pass json to github
curl -u $USER https://api.github.com/user/repos -d $JSON
}

# Load settings
if [ -f settings.cfg ] ; then
    echo "Loading settings..."
    source settings.cfg
else
    echo "ERROR: Create settings.cfg (from settings.cfg.example)"
    exit
fi;

sync-tree-to-github $FOLDER $USER
