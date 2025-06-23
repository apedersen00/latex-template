#!/bin/bash
set -e

TEMPLATE_TYPE=$1
BASE_TAG=$2

get_next_build_number() {
    local base_tag=$1
    echo "Checking for existing builds for base tag: ${base_tag}"

    git fetch --tags

    latest_patch=$(git tag -l "${base_tag}.*" | grep -oE "[0-9]+$" | sort -nr | head -n 1)

    if [[ -z "$latest_patch" ]]; then
        echo "    - No existing builds found. Starting with build 0."
        next_patch=0
    else
        next_patch=$((latest_patch + 1))
        echo "    - Found latest build: ${latest_patch}. Next build will be ${next_patch}."
    fi

    echo "$next_patch"
}

BUILD_NUMBER=$(get_next_build_number "$BASE_TAG")
FULL_VERSION="${BASE_TAG}.${BUILD_NUMBER}"

# Define the unique branch for this new release
DEPLOY_BRANCH="release/${TEMPLATE_TYPE}"
TEMP_DIR="tmp_deploy_${TEMPLATE_TYPE}"

echo "Starting deployment for template: ${TEMPLATE_TYPE}"
echo "Final Version: ${FULL_VERSION}"
echo "Target Branch: ${DEPLOY_BRANCH}"

# 1. Create a clean temporary directory
rm -rf ${TEMP_DIR}
git clone https://github.com/apedersen00/latex-template ${TEMP_DIR}
git checkout ${DEPLOY_BRANCH}
cd ${TEMP_DIR}
rm -rf ./*
cd ..
mkdir -p ${TEMP_DIR}/{config,content,assets}

# 2. Copy all necessary files into the temp directory
echo "    - Copying template files..."
cp "src/templates/${TEMPLATE_TYPE}.tex" "${TEMP_DIR}/main.tex"
cp "src/config/preamble_${TEMPLATE_TYPE}.tex" "${TEMP_DIR}/config/"
cp "src/config/settings.tex" "${TEMP_DIR}/config/"
cp "src/config/references.bib" "${TEMP_DIR}/config/"
cp -r "src/template/content/${TEMPLATE_TYPE}/." "${TEMP_DIR}/sections/"
cp -r "src/assets/." "${TEMP_DIR}/assets/"
cp "src/build_assets/Makefile.simple" "${TEMP_DIR}/Makefile"

# 3. Go into the temp directory and create a new git history for the release
cd ${TEMP_DIR}
git config user.name "GitHub Actions Bot"
git config user.email "actions@github.com"
git add .
git commit -m "build: ${TEMPLATE_TYPE} ${FULL_VERSION}"

# 4. Force push the new release branch and the new tag to the remote repository
echo "    - Pushing branch and tag to remote..."
git push

# 5. Clean up the temporary directory
cd ..
rm -rf ${TEMP_DIR}

echo "Deployment of ${TEMPLATE_TYPE} at version ${FULL_VERSION} successful!"