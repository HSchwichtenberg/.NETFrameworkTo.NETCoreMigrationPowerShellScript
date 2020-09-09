$ErrorActionPreference = "Inquire"

. "$PSScriptRoot\ITV.util.ps1"
. "$PSScriptRoot\CSProjTemplates.ps1"

Head "A PowerShell Script for the Migration of C#-based .NET Framework projects to .NET Core 3.1 or .NET 5.0"
Head "Dr. Holger Schwichtenberg, www.IT-Visions.de 2019-2020"
Head "Skript-Version: 0.4.0 (2020-09-09)"
Head "Using .NET SDK Version: $(dotnet --version)"
# ******************************************************

$TFM = "net5.0" # "net5.0" or "netcoreapp3.1"
$defaultNugets = @{
  "Microsoft.Windows.Compatibility"="5.0.0-preview.8.20407.11" # or: "Microsoft.Windows.Compatibility"="3.1.1"
}

#region -------------------------- Register "Migrate this C#-Project to .NET Core" command for .csproj
if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ea SilentlyContinue | out-null
$regPath = "HKCR:PROGID\shell\Migrate this C#-Project to .NET Core\"
$progIds = (Get-ItemProperty  HKCR:.csproj\OpenWithProgids | gm | where name -Like "VisualStudio*").Name

foreach($progID in $progIds)
  { 
  $classRoot = $regPath -replace "PROGID", $progID     
  Write-Host "Registering this script in Registry $classRoot ..."   
  md "$classRoot" -Force | Out-Null
  md "$classRoot\command" -Force | Out-Null
  $registryPath = "$classRoot\Command"
  $Name = "(Default)"
  $value = 'powershell.exe -File "'  + $PSScriptRoot +"\" + $MyInvocation.MyCommand.Name + '" "%1"'
  New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null
  }
  success "DONE! Run script as normal user for migrating C# projects to .NET Core!"
  Exit-ReturnKey
}
#endregion

# --------------------------------------------------------------------------------
function Migrate-Project($projectfile, $newParentFolderName, $template, $projects, $libs, $nugets)
{    
<#
  .SYNOPSIS
    convert a .NET Framework project to .NET Core
#>

h1 "Converting .NET Framework project to .NET Core: $projectFile"

#region -------------------------- Paths
h2 "Creating paths..."
$filename = [System.IO.Path]::GetFileNameWithoutExtension($projectfile)
$projectFolder = [System.IO.Path]::GetDirectoryName($projectfile)
$folderObj = (get-item $projectFolder)
$parentfolder = $folderObj.Parent.FullName
$newProjectFolder = [System.IO.Path]::Combine($newParentFolderName, $folderObj.Name)
$newProjectName = [System.IO.Path]::GetFileNameWithoutExtension((get-item $projectfile).Name)
$newProjectFilePath = [System.IO.Path]::Combine($newProjectFolder,"$($newProjectName).csproj")
print "Source path: $projectFolder"
print "Source Project file: $projectfile"
print "Target Solution folder: $newParentFolderName"
print "Target path: $newProjectFolder"
print "Target project: $newProjectFilePath"
print "Template: $template"

# Create target Solution folder, if it does not exists
if (-not (test-path $newParentFolderName)) { md $newParentFolderName }

# Remove target project folder, if it DOES exists
Remove-Item $newProjectFolder/* -Recurse -Force  -ea SilentlyContinue
md $newProjectFolder -ea SilentlyContinue
#region

#region -------------------------- Getting data from existing project file
h2 "Getting data from existing project file..."
if (-not (test-path $projectfile)) { throw "Project file not found!" } 
$rootnamespace = Get-RegExFromFile $projectfile '<RootNamespace>(.*)</RootNamespace>'
if ($rootnamespace -eq $null) { $rootnamespace = $newProjectName }
print "Rootnamespace: $rootnamespace"

if ($projects -eq $null) { 
  $projects = Get-RegExFromFile $projectfile '<ProjectReference Include="(.*)"' 
  if ($project -ne $null) { $projects | foreach { print "Projektreference: $_" } }
}

function Get-PackageReferencesFromFile($path)
    <#
        .SYNOPSIS
          Get a tag oder value from a project file
    #>
{
  [Hashtable] $e = @{ }
  $xml = [xml] (Get-Content $path)
  $prSet = $xml.SelectNodes("//*[local-name()='PackageReference']")
  foreach($pr in $prSet)
  {
      $name = ($pr.Attributes["Include"]).value
      $vers = ($pr.SelectSingleNode("//*[local-name()='Version']")).innerText
      #print "$name = $vers"
      $e.Add($name,  $vers)
  }
  #print $e.Count
  $e
}

$nugetsFromProject += (Get-PackageReferencesFromFile $projectfile ) 
print $nugetsFromProject.Gettype().fullname
$nugets += $nugetsFromProject 
if ($nugets -ne $null) { $nugets.keys | ForEach-Object { print "PackageReference: $_";  } }

$applicationicon =  Get-RegExFromFile $projectfile '<ApplicationIcon>(.*)</ApplicationIcon>' 
print "applicationicon: $applicationicon"
#endregion

#region -------------------------- Remove Destination Folder"
h2 "Clean Destination Folder $newProjectFolder"
if (test-path $newProjectFolder) {
  warning "Removing existing files in $newProjectFolder..."
  rd $newProjectFolder -Force -Recurse
}
#endregion

#region -------------------------- Copy Code
h2 "Copy Code $newProjectName to $newProjectFolder"
Copy-Item $projectFolder  $newProjectFolder -Recurse -Force
dir $newProjectFolder  | out-default

h2 "Make writeable"
Get-ChildItem -Path $newProjectFolder -Recurse -File | ForEach-Object {
  $_.IsReadOnly = $false
}

h2 "Remove unused files in $newProjectName..."
if (Test-Path $newProjectFolder\bin) {rd $newProjectFolder\bin -Recurse  }
if (Test-Path $newProjectFolder\obj) {rd $newProjectFolder\obj -Recurse }
remove-item $newProjectFolder\*.vspscc
remove-item $newProjectFolder\*.sln
remove-item $newProjectFolder\*.csproj
dir $newProjectFolder -Recurse | Set-ItemProperty -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue | out-default 
dir $newProjectFolder | out-default
#endregion

#region -------------------------- Creating new project file
h2 "Creating new project file ($newProjectFilePath )..."
$csproj = $template
$csproj = $csproj.Replace("[DATE]",(get-Date))
$csproj = $csproj.Replace("[rootnamespace]",$rootnamespace)
$csproj = $csproj.Replace("[icon]",$applicationicon)
$csproj = $csproj.Replace("[TFM]",$TFM)
$projRef = ""
foreach($r in $projects)
{
   print "Project: $r"
   $projRef += "    " + $ProjRefTemplate.Replace("TODO",$r) + "`n"
}
$csproj = $csproj.Replace("[ProjectReference]",$projRef.TrimEnd()) 

$assetRef = ""
if (test-path $newProjectFolder\assets)
{
  $assets = dir $newProjectFolder\assets
  foreach($a in $assets)
  {
    print "Asset: $a"
    $assetRef += "    " + $AssetTemplate.Replace("FILE","assets\$($a.name)") + "`n"
  }
}
$csproj = $csproj.Replace("[AssetsRef]",$assetRef.TrimEnd())

$nugetref = ""
foreach($n in $nugets.keys)
{
   print "Nuget: $n $($nugets[$n])"
   $nugetref += "    " + $NugetRefTemplate.Replace("NAME",$n).Replace("VERSION",$nugets[$n]) + "`n"
}
$csproj = $csproj.Replace("[NugetReference]",$nugetref.TrimEnd())

$libref = ""
foreach($l in $libs)
{
   print "DLL: $l"
    $libref += "   " + $LibRefTemplate.Replace("TODO",$l)
}
$csproj = $csproj.Replace("[LibReference]",$libref.TrimEnd())

#print $csproj
$csproj | Set-Content $newProjectFilePath  -Force

#endregion

#region -------------------------- Build
h2 "Build $newProjectName..."
cd $newProjectFolder
#dotnet restore | out-default
dotnet build | out-default
#endregion
return $newProjectFolder
}

#region ############################ Main

$sourceproject = $args[0] # Get path to .csproj from Script arguments
if ($sourceproject -eq $null) { Write-Error "No path! :-("; Read-Host; exit; }

$projectFolder = [System.IO.Path]::GetDirectoryName($sourceproject)
$projektName = [System.IO.Path]::GetFileName(($sourceproject))
$folderObj = (get-item $projectFolder)
$parentfolder = $folderObj.Parent.FullName
$newParentFolderName = $parentfolder + "#" + $TFM.Replace(".","")

print "Selected Source Folder: $projectFolder"
print "Selected Project: $projektName"

if (test-path ([System.IO.Path]::Combine($projectfolder, "packages.config")) )
{
  warning "There is still a packages.config in this project. You should move to <PackageReference>-Tags using Visual Studio. Continue anyway? (Y/N)"
  $c = Read-Host
  if ($c -ine "y" ) { exit }
}

$template = ""
$c = read-host "Template: C=Console, W=WPF/WinForms, L=Library (DLL), U=Unit Tests Other=exit?"
switch($c.toupper())
{
 "w" { $template = $projwpftemplate;  }
 "c" { $template = $projEXETemplate; }
 "u" { $template = $projTestTemplate;  }
 "l" { $template = $projlibtemplate;  }
 default { return }
}

print "Target Folder: Press enter to accept the default [$($newParentFolderName)]"
$defaultValue = 'default'
$prompt = Read-Host "Press enter to accept the default [$($newParentFolderName)]"
$newParentFolderName = ($newParentFolderName,$prompt)[[bool]$prompt]

$newProjectFolder = Migrate-Project $sourceproject $newParentFolderName $template $null $null $defaultNugets
success "DONE: $newProjectFolder"
Exit-ReturnKey