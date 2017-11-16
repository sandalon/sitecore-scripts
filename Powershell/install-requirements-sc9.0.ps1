Write-Host "Sitecore 9.0 Requirements Check`n" -foregroundcolor green;

function Check-WindowsFeature {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)] [string]$FeatureName 
    )  
  if((Get-WindowsOptionalFeature -FeatureName $FeatureName -Online).State -eq "Enabled") {
        return 'true';
    } else {
        return 'false';
    }
  }

filter ColorWord {
    param(
        [string] $word,
        [string] $color
    )
    $line = $_
    $index = $line.IndexOf($word, [System.StringComparison]::InvariantCultureIgnoreCase)
    while($index -ge 0){
        Write-Host $line.Substring(0,$index) -NoNewline
        Write-Host $line.Substring($index, $word.Length) -NoNewline -ForegroundColor $color
        $used = $word.Length + $index
        $remain = $line.Length - $used
        $line = $line.Substring($used, $remain)
        $index = $line.IndexOf($word, [System.StringComparison]::InvariantCultureIgnoreCase)
    }
    Write-Host $line
}

function validateFeatures{
  param([string[]] $features)

  $table = @()
  foreach($f in $features){
    $out = new-object psobject
    $out | add-member noteproperty 'Windows Feature' $f
    $featureInstalled = Check-WindowsFeature($f);
    if($featureInstalled  -eq 'true'){
      $out | add-member noteproperty 'Success' 'PASS'
    } else{
      $out | add-member noteproperty 'Success' 'FAIL'
    }
    $table += $out
  }

  return $table
}

Write-Host "Windows Install`n" -foregroundcolor green;
# OS Version
$table = @()
$out = new-object psobject
$currentWindowsVersion = [environment]::OSVersion.Version
switch($currentWindowsVersion.Major)
   {
      6 {
          if($currentWindowsVersion.Minor -lt 2)
            {
              #Write-Host "Windows Version`t`t`t[FAIL] - Windows 8.1 or Greater is required" -foregroundcolor red
              $out | add-member noteproperty 'Windows Feature' 'Windows Version'
              $out | add-member noteproperty 'Success' 'FAIL'
            }
        }
      default { 
        $out | add-member noteproperty 'Windows Feature' 'Windows Version'
        $out | add-member noteproperty 'Success' 'PASS'
      }
   }
$table += $out
$out = new-object psobject

# .NET Version
$NetRegKey = Get-Childitem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
$Release = $NetRegKey.GetValue("Release")
if ( $Release -lt 394802 ){
  $out | add-member noteproperty 'Windows Feature' '.NET Version'
  $out | add-member noteproperty 'Success' 'FAIL'
}
else{
  $out | add-member noteproperty 'Windows Feature' '.NET Version'
  $out | add-member noteproperty 'Success' 'PASS'
}

$table += $out
$out = new-object psobject



# Powershell Version
$powershellVersion = $PSVersionTable.PSVersion.Major
if($powershellVersion -lt 5)
{
  $out | add-member noteproperty 'Windows Feature' 'PowerShell Version'
  $out | add-member noteproperty 'Success' 'FAIL'
}
else
{
  $out | add-member noteproperty 'Windows Feature' 'PowerShell Version'
  $out | add-member noteproperty 'Success' 'PASS'
}

$table += $out
$table | Format-Table | Out-String | ColorWord -word "FAIL" -color red

Write-Host "Windows Features" -ForegroundColor Green

$features = @('IIS-WebServerRole',
              'IIS-WebServer',
              'IIS-CommonHttpFeatures',
              'IIS-HttpErrors',
              'IIS-HttpRedirect',
              'IIS-ApplicationDevelopment',
              'IIS-NetFxExtensibility',
              'IIS-NetFxExtensibility45',
              'IIS-HealthAndDiagnostics',
              'IIS-HttpLogging',
              'IIS-LoggingLibraries',
              'IIS-RequestMonitor',
              'IIS-Security',
              'IIS-RequestFiltering',
              'IIS-HttpCompressionDynamic',
              'IIS-Performance',
              'IIS-WebServerManagementTools',
              'IIS-ManagementScriptingTools',
              'IIS-DefaultDocument',
              'IIS-StaticContent',
              'IIS-DirectoryBrowsing',
              'IIS-WebSockets',
              'IIS-ASPNET',
              'IIS-ASPNET45',
              'IIS-ISAPIExtensions',
              'IIS-ISAPIFilter',
              'IIS-BasicAuthentication',
              'IIS-HttpCompressionStatic',
              'IIS-ManagementConsole',
              'IIS-ManagementService',
              'NetFx4-AdvSrvs',
              'NetFx4Extended-ASPNET45');

$t = validateFeatures($features);
$t | Format-Table | Out-String | ColorWord -word "FAIL" -color red

Write-Host "`nInstalled Software`n" -foregroundcolor green;

$table = @()
$out = new-object psobject

# installed software
$solr = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -eq "Bitnami Apache Solr Stack" } | measure
if( $solr.Count -gt 0 )
{
  $out | add-member noteproperty 'Installed Software' 'SOLR Installed'
  $out | add-member noteproperty 'Success' 'PASS'
}
else
{
  $out | add-member noteproperty 'Installed Software' 'SOLR Installed'
  $out | add-member noteproperty 'Success' 'FAIL'
}

$table += $out
$out = new-object psobject

$DacFX = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -eq "Microsoft SQL Server Data-Tier Application Framework (x86)" } | measure
if( $DacFX.Count -gt 0 )
{
  $out | add-member noteproperty 'Installed Software' 'Dac FX Installed'
  $out | add-member noteproperty 'Success' 'PASS'
}
else
{
  $out | add-member noteproperty 'Installed Software' 'Dac FX Installed'
  $out | add-member noteproperty 'Success' 'FAIL'
}

$table += $out
$out = new-object psobject

$installPath = $env:msdeployinstallpath
if(!$installPath){
    $keysToCheck = @('hklm:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy\3')
    foreach($keyToCheck in $keysToCheck) {
        if(Test-Path $keyToCheck){
            $installPath = (Get-itemproperty $keyToCheck -Name InstallPath -ErrorAction SilentlyContinue | select -ExpandProperty InstallPath -ErrorAction SilentlyContinue)
        }
        if($installPath) {
            break;
        }
    }
}

$out | add-member noteproperty 'Installed Software' 'WebDeploy'
if($installPath){
  $out | add-member noteproperty 'Success' 'PASS'
} else {
  $out | add-member noteproperty 'Success' 'FAIL'
}

$table += $out
$out = new-object psobject

$rewriteKey = @('hklm:\SOFTWARE\Microsoft\IIS Extensions\URL Rewrite')
$out | add-member noteproperty 'Installed Software' 'URL Rewrite'
if(Test-Path $rewriteKey){
  $out | add-member noteproperty 'Success' 'PASS'
} else{
  $out | add-member noteproperty 'Success' 'FAIL'
}

$table += $out

$table | Format-Table | Out-String | ColorWord -word "FAIL" -color red