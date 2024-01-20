$versions = Get-Content -Path "./versions.txt"
$current_legacy_version = $versions | Where-Object { $_.StartsWith("plb_legacy_version=") } | ForEach-Object { $_.Split('=')[1] }
$current_multiplayer_version = $versions | Where-Object { $_.StartsWith("plb_multiplayer_version=") } | ForEach-Object { $_.Split('=')[1] }
$current_hfu_version = $versions | Where-Object { $_.StartsWith("hfu_version=") } | ForEach-Object { $_.Split('=')[1] }

$plb_mod_id = 327
$hfu_mod_id = 4743
$headers = @{
  "accept" = "application/json"
  "apikey" = "O3OfLglaRfVdjTXk1Zf5mvaTKj0/2vevs7JTrkD3CHvSLVj8--Rj5U86e5fllOe1Mr--P1XI6NxtA+jv6u4KBjjhng=="
}

$plb_mod_files_output = Invoke-RestMethod -Uri "https://api.nexusmods.com/v1/games/baldursgate3/mods/${plb_mod_id}/files.json?category=main,optional" `
  -Headers $headers

$hfu_mod_files_output = Invoke-RestMethod -Uri "https://api.nexusmods.com/v1/games/baldursgate3/mods/${hfu_mod_id}/files.json?category=main" `
  -Headers $headers

$latest_legacy_version = $plb_mod_files_output.files | Where-Object { $_.name -like "*Party Limit Begone Legacy*" } `
  | Select-Object -ExpandProperty version
$latest_multiplayer_version = $plb_mod_files_output.files | Where-Object { $_.name -like "*Party Limit Begone Multiplayer Patch*" } `
  | Select-Object -ExpandProperty version
$latest_hfu_version = $hfu_mod_files_output.files[0].version

if ($current_legacy_version -ne $latest_legacy_version) {
    Write-Host "`nParty Limit Begone Legacy update available." -ForegroundColor Green
    Write-Host "Versions: ${current_legacy_version} | ${latest_legacy_version}" -ForegroundColor Green

    $legacy_mod_file_id = $plb_mod_files_output.files | Where-Object { $_.name -like "*Party Limit Begone Legacy*" } `
      | Select-Object -ExpandProperty file_id
    Write-Host "https://www.nexusmods.com/baldursgate3/mods/${plb_mod_id}?tab=files&file_id=${legacy_mod_file_id}"
}

if ($current_multiplayer_version -ne $latest_multiplayer_version) {
    Write-Host "Party Limit Begone Multiplayer Patch update available." -ForegroundColor Green
    Write-Host "Versions: ${current_multiplayer_version} | ${latest_multiplayer_version}" -ForegroundColor Green

    $multiplayer_mod_file_id = $plb_mod_files_output.files | Where-Object { $_.name -like "*Party Limit Begone Multiplayer Patch*" } `
      | Select-Object -ExpandProperty file_id
    Write-Host "https://www.nexusmods.com/baldursgate3/mods/${plb_mod_id}?tab=files&file_id=${multiplayer_mod_file_id}"
}

if ($current_hfu_version -ne $latest_hfu_version) {
    Write-Host "Honour Features Unlocker update available." -ForegroundColor Green
    Write-Host "Versions: ${current_hfu_version} | ${latest_hfu_version}" -ForegroundColor Green

    $hfu_mod_file_id = $hfu_mod_files_output.files[0].file_id
    Write-Host "https://www.nexusmods.com/baldursgate3/mods/${hfu_mod_id}?tab=files&file_id=${hfu_mod_file_id}"
}


$lines = Get-Content -Path "./versions.txt"

for ($i = 0; $i -lt $lines.Length; $i++) {
  if ($lines[$i] -like "plb_legacy_version=*") {
    $lines[$i] = "plb_legacy_version=$latest_legacy_version"
  }
  elseif ($lines[$i] -like "plb_multiplayer_version=*") {
    $lines[$i] = "plb_multiplayer_version=$latest_multiplayer_version"
  }
  elseif ($lines[$i] -like "hfu_version=*") {
    $lines[$i] = "hfu_version=$latest_hfu_version"
  }
}

$lines | Set-Content -Path "./versions.txt"