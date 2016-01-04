#!/bin/bash
#
## ==============================
# ===== Begin Customization =====
# ===============================

# an array of all the plugin slugs you want to pull.
# first make sure you can `$ git pull` these plugins without issues.
plugin_slugs=(
	"wpai-woocommerce-add-on"
	"wp-all-export-pro"
	"wp-all-import-pro"
	)

# an array of paths to the local dev installs you use (with trailing slashes)
# this is how mine look for VVV.
local_installs=(
	"~/Code/dev/www/add-ons/wp-core/wp-content/plugins/"
	"~/Code/dev/www/wpae/wp-core/wp-content/plugins/"
	"~/Code/dev/www/wpai/wp-core/wp-content/plugins/"
	"~/Code/dev/www/wooco/wp-core/wp-content/plugins/"
	)

# the directory where you store your git repos. the script will add a directory
# called = Master = and dump zips in there. it'll also keep directories of all the
# plugins listed above up to date.
git_folder=~/git/

# ===============================
# ====== End Customization ======
# ===============================

# we'll start in your git folder
cd $git_folder

# let's remember where you were when you started
pwd=`pwd`

# and give some breathing room in the terminanal
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

	# navigate to the plugin directory where you store all your git repos
	cd "$git_folder$plugin_slug"

	# the magic
	git pull

	# now we're going to move this plugin to each different local installs
	for local_install in "${local_installs[@]}"
	do
		# delete the plugin from wp-content/plugins
	    rm -rf $local_install$plugin_slug
	    # copy the latest from your local git repos
		cp -a $git_folder$plugin_slug/ $local_install$plugin_slug/
	done
		
	# begin formatting bullshit
	# this one is so that the 'Zipping' display is equal in length
	# to the earlier one with the plugin slug
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

	# this is fun, here's we're digging into the plugin itself to get the version
	# number so that we can add it to the zip's file name
	v=`sed -n 's/Version: //p' $git_folder$plugin_slug/$plugin_slug.php`
	
	# here we remove the other zip archives for this plugin in the `= Master =` folder
	find $git_folder\=\ Master\ \=/ -type f -name "$plugin_slug*.zip" -exec rm -f {} \;

	# here's where we actually make the zip (without the hidden folders), using
	# the version number in the file name
	zip -rq $git_folder/\=\ Master\ \=/$plugin_slug\_${v// /_}.zip * -x '*/\.*'
done

# go back to wherever you were
cd $pwd