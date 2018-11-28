$layout = get-item '{2ABD2E94-98AC-4101-A762-40F9AE2AF13E}'
$linkDatabase = [Sitecore.Globals]::LinkDatabase

Write-Host 'Finding all items with layout:' $layout.Name

$links = $linkDatabase.GetReferrers($layout)
$links | foreach-object { if ($_.GetSourceItem() -and $_.GetSourceItem().Paths.Path.ToLower().StartsWith("/sitecore/content")) { write-host $_.GetSourceItem().Paths.Path } }

Write-Host 'Done'
