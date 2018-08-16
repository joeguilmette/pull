#!/bin/bash

# ===============================
# ===== Begin Customization =====
# ===============================

# an array of all the plugin slugs you want to pull.
# first make sure you can `$ git pull` these plugins without issues.
plugin_slugs=(
	"wpai-toolset-types-addon"
	"wp-all-export-pro"
	"wp-all-import-pro"
	"wp-all-import"
	"wp-all-export"
	"wpai-woocommerce-add-on"
	"wpai-acf-add-on"
	"wpai-user-add-on"
	"woocommerce-xml-csv-product-import"
	"wpai-linkcloak-add-on"
	"sandbox"
	)

# the user or org username used to run remote git commands.
github_user=git@github.com:soflyy

# an array of paths to the local dev installs you use (with trailing slashes).
# note that for VVV you need to use $HOME rather than ~.
local_installs=(
	"/Users/joe/Documents/MAMP PRO/sites/wpai.local/app/public/wp-content/plugins/"
	"/Users/joe/Documents/MAMP PRO/sites/wpai.test/wp-content/"
	# "$HOME/Dev/Sites/wpae/app/public/wp-content/plugins/"
	)

# the directory where you store your git repos. the script will add a directory
# called `= Master =` so the script can dump zips in there. 
# it'll also keep directories of all the plugins listed above up to date.
git_folder=~/Dropbox/Dev/git/

# ===============================
# ====== End Customization ======
# ===============================

# now the fun begins
# let's remember where you were when you ran this script
pwd=`pwd`

# loop through all the slugs
for slug in "${plugin_slugs[@]}"
do
	# check if the current directory matches a slug
	if [[ "${PWD##*/}" == $slug ]]; then
		# if it does, only update that slug
		unset plugin_slugs
		plugin_slugs=$slug
	fi
done


# create a git folder if it doesn't exist
mkdir -p "$git_folder"

# now we'll go to your git folder
cd $git_folder

# and this is a thing we do now
# chmod -R 0755 .

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
	  git clone "$github_user"/"$plugin_slug".git
	fi

	# check if the plugin exists in your git repo
	# create a folder if it doesn't
	mkdir -p "$git_folder$plugin_slug"

	# navigate to the plugin directory where this plugin is
	cd "$git_folder$plugin_slug"

	# magic
	git branch
	echo ""
	git pull --all

	branch=`git symbolic-ref --short -q HEAD`

	# now we're going to move this plugin to each of your local installs
	for local_install in "${local_installs[@]}"
	do
		# more things we do now
		# chmod -R 0755 "$local_install""$plugin_slug"/
		# delete the plugin from wp-content/plugins
		rm -rf "$local_install""$plugin_slug"
		# copy the latest from your local git repos
		cp -a "$git_folder""$plugin_slug"/ "$local_install""$plugin_slug"/
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
	if [[ "$plugin_slug" == "wpai-toolset-types-addon" ]]
		then 
			v=`sed -n 's/Version: //p' $git_folder$plugin_slug/wpai-toolset-types-add-on.php`
		else
			if [ ! -f $git_folder$plugin_slug/$plugin_slug.php ]
				then	
					v=`sed -n 's/Version: //p' $git_folder$plugin_slug/plugin.php`
				else
					v=`sed -n 's/Version: //p' $git_folder$plugin_slug/$plugin_slug.php`
			fi
	fi

	# create a git folder if it doesn't exist
	mkdir -p "$git_folder"\=\ Master\ \=/

	# now we need to remove the other zip archives for this plugin in the `= Master =` folder
	find $git_folder\=\ Master\ \=/ -type f -name "${plugin_slug}_*.zip" -exec rm -f {} \;
	cd ..

	# now let's temporarily hide the /tests folder (it gets huge)
	if [ -d "$plugin_slug/tests/" ]; then
	  mv $plugin_slug/tests $plugin_slug/.tests
	fi

	# finally we'll actually make the zip (without the hidden folders), adding
	# the version number to the file name

	zip -rqD $git_folder\=" Master "\=/$plugin_slug.zip $plugin_slug -x '*/\.*'
	mv $git_folder\=" Master "\=/$plugin_slug.zip $git_folder\=" Master "\=/$plugin_slug\_${v// /_}\-\[$branch\].zip

	# and now let's uhide the /tests folder
	if [ -d "$plugin_slug/.tests/" ]; then
	  mv $plugin_slug/.tests $plugin_slug/tests
	fi
done

# and to be polite, we'll go back to wherever you were when you started
cd $pwd
