#!/bin/zsh

SOURCE_BRANCH_NAME=source
TARGET_BRANCH_NAME=gh-pages
SITE_FOLDER=_site

function die() {
	echo $*
	exit 1
}

if [ -e $SITE_FOLDER ]
then
	echo -n "Deleting $SITE_FOLDER..."
	rm -rf $SITE_FOLDER
	mkdir $SITE_FOLDER
	echo "done"
fi

git checkout $SOURCE_BRANCH_NAME || die "$SOURCE_BRANCH_NAME checkout failed"

# create local repository to update site branch
echo -n "Creating local repository..."
pushd $SITE_FOLDER > /dev/null

git clone --recursive .. .  || die "Local clone failed"
git checkout $TARGET_BRANCH_NAME || die "$TARGET_BRANCH_NAME checkout failed"

# TODO: fetch last commit date

popd > /dev/null
echo "done"

# TODO: get list of commits to integrate

# generate site
jekyll build || die "Build failed"

# commit and push site updates to parent repository
echo -n "Commiting and pushing changes to branch $TARGET_BRANCH_NAME..."
pushd $SITE_FOLDER > /dev/null

# FIXME: delete local files (except .git folder) to commit deletions
git add .
# TODO: set commit message with integrated commits
git commit -a -m "Site update" || die "Commit failed"
git push || die "Push failed"

popd > /dev/null
echo "done"
