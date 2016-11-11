#!/bin/bash

# ===============================
# ===== Begin Customization =====
# ===============================

# an array of all the plugin slugs you want to pull.
# first make sure you can `$ git pull` these plugins without issues.
plugin_slugs=(
	"wpai-woocommerce-add-on"
	"wp-all-export-pro"
	"wp-all-import-pro"
	"wp-all-import"
	"wp-all-export"
	"wpai-acf-add-on"
	"wpai-user-add-on"
	"woocommerce-xml-csv-product-import"
	)

# an array of paths to the local dev installs you use (with trailing slashes).
# this is how mine looks for VVV. note that you need to use $HOME rather than ~.
local_installs=(
	"/Applications/MAMP/htdocs/wpai.dev/wp-content/plugins/"
	# "$HOME/Dev/Sites/wpae/app/public/wp-content/plugins/"
	)

# the directory where you store your git repos. you'll need to add a directory
# called `= Master =` so the script can dump zips in there. 
# it'll also keep directories of all the plugins listed above up to date.
git_folder=~/Dropbox/Dev/git/

# this works the same as the git folder.
# dropbox_folder=~/Dropbox/

# ===============================
# ====== End Customization ======
# ===============================

# now the fun begins
# let's remember where you were when you ran this script
pwd=`pwd`

# create a git folder if it doesn't exist
mkdir -p "$git_folder"

# now we'll go to your git folder
cd $git_folder

# and give some breathing room in the terminal
echo ''

# for each plugin slug
for plugin_slug in "${plugin_slugs[@]}"
do	

	# begin formatting bullshit
	# basically we just want to make some equal signs so the terminal output
	# looks pretty and is readable
	eq=\=
	eqs=
	len=${#plugin_slug}
	len=$((len + 14))

	while [ $len -gt 0 ]
	do
		len=$[$len-1]
		eqs=$eqs$eq
	done

	echo $eqs
	echo "====== $plugin_slug ======"
	echo $eqs
	# end formatting bullshit

	# clone the plugin if it doesn't exist
	if [ ! -d "$git_folder$plugin_slug" ]; then
	  # no git repo
	  git clone git@github.com:soflyy/"$plugin_slug".git
	fi

	# check if the plugin exists in your git repo
	# navigate to the plugin directory where you store all your git repos
	cd "$git_folder$plugin_slug"

	# magic
	git branch
	echo ""
	git pull --all

	# now we're going to move this plugin to each of your local installs
	for local_install in "${local_installs[@]}"
	do
		# delete the plugin from wp-content/plugins
		rm -rf $local_install$plugin_slug
		# copy the latest from your local git repos
		cp -a $git_folder$plugin_slug/ $local_install$plugin_slug/
	done
		
	# begin formatting bullshit
	# we want the 'Zipping' display block equal in length
	# to the earlier display block with the plugin slug
	len=${#plugin_slug}
	len=$((len + 5))
	len=$((len / 2))
	eqs=

	while [ $len -gt 0 ]
	do
		len=$[$len-1]
		eqs=$eqs$eq
	done

	echo "$eqs Zipping $eqs"
	echo ''
	# end formatting bullshit

	# this is fun, here we dig into the plugin itself to get the version
	# number so that we can add it to the zip's file name
	if [ ! -f $git_folder$plugin_slug/$plugin_slug.php ]
	then
    	v=`sed -n 's/Version: //p' $git_folder$plugin_slug/plugin.php`
	else
		v=`sed -n 's/Version: //p' $git_folder$plugin_slug/$plugin_slug.php`
	fi


	# now we need to remove the other zip archives for this plugin in the `= Master =` folder
	find $git_folder\=\ Master\ \=/ -type f -name "${plugin_slug}_*.zip" -exec rm -f {} \;

	# finally we'll actually make the zip (without the hidden folders), adding
	# the version number to the file name
	cd ..
	zip -rqD $git_folder/\=\ Master\ \=/$plugin_slug.zip $plugin_slug -x '*/\.*'
	mv $git_folder/\=\ Master\ \=/$plugin_slug.zip $git_folder/\=\ Master\ \=/$plugin_slug\_${v// /_}.zip
done

# dump everything into Dropbox

# echo '==========================='
# echo '==== Adding to Dropbox ===='
# echo '==========================='

# rm -rf $dropbox_folder/\=\ Master\ \=/*
# cp $git_folder/\=\ Master\ \=/* $dropbox_folder/\=\ Master\ \=/

# and to be polite, we'll go back to wherever you were when you started
cd $pwd
