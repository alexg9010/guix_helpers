#! /bin/bash
set -o pipefail

## get project variable from path, turn /home/user/project/xyz into __home__user__project__xyz
PROJECT=${PWD////__}
GUIX_EXTRA_PROFILES=$HOME/.guix-extra-profiles

## check if manifest exists
if [[ ! -f "manifest.scm" ]]
then
    echo "No 'manifest.scm' found." 
    exit 
fi

## create new project manifest path if it does not exist yet
mkdir -p "$GUIX_EXTRA_PROFILES/$PROJECT"

## initialize manifest into profile
if [[ ! -f ".manifest.scm.md5" || ! -d "$GUIX_EXTRA_PROFILES"/$PROJECT/.guix-profile ]]
then
    echo "Initializing 'manifest.scm'." 
    ## save guix packages from manifest into project profile
    guix package --manifest=$PWD/manifest.scm --profile="$GUIX_EXTRA_PROFILES"/$PROJECT/.guix-profile

    ## save current state
    md5sum manifest.scm > .manifest.scm.md5
    
    ##enable automatic loading with direnv
    echo 'eval $(guix package --search-paths -p '"$GUIX_EXTRA_PROFILES/$PROJECT/.guix-profile)" >> .envrc
fi

## check current state
if [[ "$(cat .manifest.scm.md5)" != "$(md5sum manifest.scm)" ]]
then
    echo " updated 'manifest.scm'." 
    ## update guix packages from manifest
    guix package --manifest=$PWD/manifest.scm --profile="$GUIX_EXTRA_PROFILES/$PROJECT/.guix-profile"

    ## save current state
    md5sum manifest.scm > .manifest.scm.md5
else 
    echo "Nothing to be done"
fi


