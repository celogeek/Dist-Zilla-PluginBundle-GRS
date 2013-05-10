#!/bin/bash

set -e

source "$HOME/perl5/perlbrew/etc/bashrc"
export PERL_CPANM_OPT="--mirror http://cpan.celogeek.com -v"

perlbrew use 5.16.3
perlbrew install-cpanm -f

cpanm Dist::Zilla

export PERL5LIB=lib
dzil authordeps --missing | cpanm
dzil listdeps --missing | cpanm
dzil clean
AUTHOR_TESTING=1 RELEASE_TESTING=1 dzil cover

echo "Detecting current branch against $CI_BUILD_REF ..."
MASTER=$(git rev-parse origin/master)
DEVEL=$(git rev-parse origin/devel)

case $CI_BUILD_REF in
	$MASTER)
		CURRENT=master
		;;
	$DEVEL)
		CURRENT=devel
		;;
esac

if [ -n "$CURRENT" ]
then
	echo "Current branch : $CURRENT"
	git checkout $CURRENT
	git reset --hard origin/$CURRENT
	git push --mirror git@github.com:celogeek/Dist-Zilla-PluginBundle-GRS.git
fi

