# pull
A bash script that makes pulling plugins down from GitHub into local dev installs and packaging them into distributable, version-labeled zips easy as pie.

This script assumes that you will have 1 directory on your computer where you will store all of the git repos for plugins you want to update. It also assumes that you will have an arbitrary number of local WordPress installs where you want these plugins to be kept up to date.

First, fork `pull` and modify `pull.sh` to tell it which slugs you want to update and where your local installs are. The slugs should be the repo name in GitHub. 

Running `pull` will loop through your list of slugs and
- Clone/fetch each one into a separate directory in your git folder
- Copy that folder to each of your local installs
- Create a folder with installable zips for each plugin
