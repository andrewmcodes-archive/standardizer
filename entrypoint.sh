#!/bin/bash

set -e

# skip if no /standardize
echo "Checking if contains '/standardize' command..."
(jq -r ".comment.body" "$GITHUB_EVENT_PATH" | grep -E "/standardize") || exit 78

# skip if not a PR
echo "Checking if a PR command..."
(jq -r ".issue.pull_request.url" "$GITHUB_EVENT_PATH") || exit 78

if [[ "$(jq -r ".action" "$GITHUB_EVENT_PATH")" != "created" ]]; then
	echo "This is not a new comment event!"
	exit 78
fi

PR_NUMBER=$(jq -r ".issue.number" "$GITHUB_EVENT_PATH")
REPO_FULLNAME=$(jq -r ".repository.full_name" "$GITHUB_EVENT_PATH")
echo "Collecting information about PR #$PR_NUMBER of $REPO_FULLNAME..."

if [[ -z "$GITHUB_TOKEN" ]]; then
	echo "Set the GITHUB_TOKEN env variable."
	exit 1
fi

URI=https://api.github.com
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"

pr_resp=$(curl -X GET -s -H "${AUTH_HEADER}" -H "${API_HEADER}" \
          "${URI}/repos/$REPO_FULLNAME/pulls/$PR_NUMBER")

HEAD_BRANCH=$(echo "$pr_resp" | jq -r .head.ref)

git remote set-url origin https://x-access-token:$GITHUB_TOKEN@github.com/$REPO_FULLNAME.git
git config --global user.email "standardize@github.com"
git config --global user.name "GitHub Standardize Action"

set -o xtrace

git fetch origin $HEAD_BRANCH
git checkout -b $HEAD_BRANCH origin/$HEAD_BRANCH

gem install bundler:2.0.2
bundle install --path vendor/bundle --jobs 4 --retry 3
yarn install --frozen-lockfile
bin/standardize

git add .
git commit -m "standardize"
git push origin $HEAD_BRANCH
