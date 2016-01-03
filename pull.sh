#!/bin/bash

pwd=`pwd`

# an array of all the plugin slugs you want to pull.
# first make sure you can git pull these plugins without issues
plugin_slugs=("wpai-woocommerce-add-on" "wp-all-export-pro" "wp-all-import-pro")

# an array of paths to the local dev installs you use (with trailing slashes)
local_installs=("$HOME/Code/dev/www/wpae/wp-core/wp-content/plugins/" "$HOME/Code/dev/www/wpai/wp-core/wp-content/plugins/" "$HOME/Code/dev/www/wooco/wp-core/wp-content/plugins/")

# the directory where you store your git repos
git_folder=~/git/

# we'll start in your git folder
cd $git_folder

# breathing room
echo ''

# for each plugin slug
for plugin_slug in "${plugin_slugs[@]}"
do	
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

	cd "$git_folder$plugin_slug"
	git pull
	for local_install in "${local_installs[@]}"
	do
	    rm -rf $local_install$plugin_slug
		cp -a $git_folder$plugin_slug/ $local_install$plugin_slug/
	done
	
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
	v=`sed -n 's/Version: //p' $git_folder$plugin_slug/$plugin_slug.php`
	find $git_folder\=\ Master\ \=/ -type f -name "$plugin_slug*.zip" -exec rm -f {} \;
	zip -rq $git_folder/\=\ Master\ \=/$plugin_slug\_${v// /_}.zip * -x '*/\.*'
done

# go back to wherever you were
cd $pwd