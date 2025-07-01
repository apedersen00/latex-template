#!/bin/bash
set -e

TEMPLATE_TYPE=$1
BASE_TAG=$2

get_next_build_number() {
    local base_tag=$1
    echo "🔍 Checking for existing builds for base tag: ${base_tag}" >&2
    git fetch --tags --force
    latest_tag=$(git tag -l "${base_tag}.*" | grep -oE "[0-9]+$" | sort -nr | head -n 1)
    latest_build=$(git show --pretty=format:%s -s HEAD)

    if [[ -z "$latest_patch" ]]; then
        echo "    - No existing builds found. Starting with build 0." >&2
        next_patch=0
    else
        next_patch=$((latest_patch + 1))
        echo "    - Found latest build: ${latest_patch}. Next build will be ${next_patch}." >&2
    fi
    echo "$next_patch"
}

BUILD_NUMBER=$(get_next_build_number "$BASE_TAG")
FULL_VERSION="${BASE_TAG}.${BUILD_NUMBER}"
DEPLOY_BRANCH="release/${TEMPLATE_TYPE}"
TEMP_DIR="tmp_deploy_${TEMPLATE_TYPE}"

echo "Starting deployment for template: ${TEMPLATE_TYPE}"
echo "Release Version: ${FULL_VERSION}"
echo "Target Branch: ${DEPLOY_BRANCH}"

echo "    - Cloning repository to prepare release branch..."
rm -rf ${TEMP_DIR}
git clone "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" ${TEMP_DIR}

cd ${TEMP_DIR}
git checkout -B ${DEPLOY_BRANCH} origin/${DEPLOY_BRANCH} || git checkout -B ${DEPLOY_BRANCH}

echo "    - Cleaning old template files from working directory..."
rm -rf ./*

echo "    - Copying new template files..."
mkdir -p ./config ./content ./assets
cp "../src/templates/${TEMPLATE_TYPE}.tex" "./main.tex"
cp "../src/config/preamble_${TEMPLATE_TYPE}.tex" "./config/"
cp "../src/config/settings.tex" "./config/"
cp "../src/config/references.bib" "./config/"
cp -r "../src/templates/content/${TEMPLATE_TYPE}/." "./content/"
cp -r "../src/assets/." "./assets/"
cp "../src/build_assets/Makefile.user" "./Makefile"

echo "    - Committing new version..."
git add .

if git diff --staged --quiet; then
  echo "    - No changes detected compared to the previous release. Nothing to commit."
else
  git config user.name "GitHub Actions Bot"
  git config user.email "actions@github.com"
  git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
  git commit -m "build: ${TEMPLATE_TYPE} ${FULL_VERSION}"
  git push
fi

cd ..
rm -rf ${TEMP_DIR}

echo "Deployment of ${TEMPLATE_TYPE} at version ${FULL_VERSION} successful!"