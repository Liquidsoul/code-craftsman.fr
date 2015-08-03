#!/bin/zsh

SOURCE_BRANCH_NAME=source
TARGET_BRANCH_NAME=gh-pages
SITE_FOLDER=_site

function die() {
	echo $*
	exit 1
}

# Generate commit message with list of commits from $SOURCE_BRANCH_NAME to integrate
LAST_COMMIT_DATE=`git log -1 --format=%cd $TARGET_BRANCH_NAME`
COMMITS_TO_INTEGRATE=`git log --since="$LAST_COMMIT_DATE" --format=%s $SOURCE_BRANCH_NAME`
if [ -z "$COMMITS_TO_INTEGRATE" ]
then
	echo "Nothing to integrate. Exiting..."
	exit 2
fi

COMMIT_MSG="Site update\n\n$COMMITS_TO_INTEGRATE"


if [ -e $SITE_FOLDER ]
then
	echo -n "'$SITE_FOLDER' exists. Deleting it..."
	rm -rf $SITE_FOLDER || die "Failed to delete '$SITE_FOLDER'"
	echo "done"
fi

git checkout $SOURCE_BRANCH_NAME || die "'$SOURCE_BRANCH_NAME' checkout failed"

# create local repository to update site branch
echo -n "Creating local repository..."

git clone --recursive . $SITE_FOLDER || die "Local clone failed"

pushd $SITE_FOLDER > /dev/null

git checkout $TARGET_BRANCH_NAME || die "'$TARGET_BRANCH_NAME' checkout failed"
# empty repository except for hidden files (like .gitignore)
ls | xargs git rm -r || die "Failed to empty '$SITE_FOLDER' local repository"

popd > /dev/null
echo "done"

# generate site
jekyll build || die "Build failed"

# commit and push site updates to parent repository
echo -n "Commiting and pushing changes to branch $TARGET_BRANCH_NAME..."
pushd $SITE_FOLDER > /dev/null

# Add all modifications
git add . || die "Failed to add modifications in '$SITE_FOLDER' local repository"

# Commit and push
git commit -a -m "$COMMIT_MSG" || die "Commit failed"
git push || die "Push failed"

popd > /dev/null
echo "done"
