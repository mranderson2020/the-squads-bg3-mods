#!/bin/sh

downloads_folder="D:/Users/Downloads"
github_folder="${downloads_folder}/the-squads-bg3-mods"

plb_legacy_local_version=0
plb_multiplayer_local_version=0
hfu_local_version=0

commitMessage="Updated versions.txt"

cd $github_folder

if [ -f "${github_folder}/versions.txt" ]; then
  plb_legacy_local_version=$(grep -Po '(?<=plb_legacy_local_version=).*' "${github_folder}/versions.txt")
  plb_multiplayer_local_version=$(grep -Po '(?<=plb_multiplayer_local_version=).*' "${github_folder}/versions.txt")
  hfu_local_version=$(grep -Po '(?<=hfu_local_version=).*' "${github_folder}/versions.txt")
fi

if compgen -G "$downloads_folder/Party Limit Begone Legacy*.zip" > /dev/null; then
  ((plb_legacy_local_version++))
  rm ${github_folder}/plb_legacy_v*
  mv "${downloads_folder}/Party Limit Begone Legacy"*.zip ${github_folder}/plb_legacy_v${plb_legacy_local_version}.zip
  commitMessage="${commitMessage}\nUpdated PLB Legacy to v${plb_legacy_local_version}"
  echo -e "\033[0;32mUpdated PLB Legacy to v${plb_legacy_local_version}\033[0m"
fi

if compgen -G "$downloads_folder/Party Limit Begone Multiplayer Patch*.zip" > /dev/null; then
  ((plb_multiplayer_local_version++))
  rm ${github_folder}/plb_multiplayer_patch_v*
  mv "${downloads_folder}/Party Limit Begone Multiplayer Patch"*.zip ${github_folder}/plb_multiplayer_patch_v${plb_multiplayer_local_version}.zip
  commitMessage="${commitMessage}\nUpdated PLB Multiplayer Patch to v${plb_multiplayer_local_version}"
  echo -e "\033[0;32mUpdated PLB Multiplayer Patch to v${plb_multiplayer_local_version}\033[0m"
fi

if compgen -G "$downloads_folder/Honour Features Unlocker*.zip" > /dev/null; then
  ((hfu_local_version++))
  rm ${github_folder}/hfu_v*
  mv "${downloads_folder}/Honour Features Unlocker"*.zip ${github_folder}/hfu_v${hfu_local_version}.zip
  commitMessage="${commitMessage}\nUpdated HFU to v${hfu_local_version}"
  echo -e "\033[0;32mUpdated HFU to v${hfu_local_version}\033[0m"
fi

sed -i "s/plb_legacy_local_version=.*/plb_legacy_local_version=${plb_legacy_local_version}/" "${github_folder}/versions.txt"
sed -i "s/plb_multiplayer_local_version=.*/plb_multiplayer_local_version=${plb_multiplayer_local_version}/" "${github_folder}/versions.txt"
sed -i "s/hfu_local_version=.*/hfu_local_version=${hfu_local_version}/" "${github_folder}/versions.txt"

git add .
git commit -m "$commitMessage"
git push origin master

echo -e "\033[0;32mDone\033[0m"
