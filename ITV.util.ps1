# A few small PowerShell Utilities / Colorful output, RegEx utilities etc.
# Dr. Holger Schwichtenberg, www.IT-Visions.de, 2007-2020


function Exit-ReturnKey($message = "Press RETURN key to exit.")
{
    <#
        .SYNOPSIS
          Wait for RETURN key and than exit script
    #>
Write-host $message
read-host
exit
}

function Get-RegExFromFile($path, $pattern)
    <#
        .SYNOPSIS
          Get a tag oder value from a project file
    #>
{
  $content = get-content $path
  $matches = ($content | select-string -pattern $pattern).Matches
  if ( $matches -eq $null) { return $null }
  $matches | foreach { $_.Groups[1].Value }
}

function Replace-TextInFile($path, $oldtext, $newtext)
{
    <#
        .SYNOPSIS
          Replace a text in a file
    #>
((Get-Content -path $path -Raw).Replace($oldtext, $newtext)) | Set-Content -Path $path
}

function Replace-RegExInFile($path, $reg, $newtext)
{
    <#
        .SYNOPSIS
          Replace a text in a file
    #>
(Get-Content -path $path -Raw) -replace $reg,$newtext | Set-Content -Path $path -Encoding UTF8
}

function head()
{
[CmdletBinding()]
Param( [Parameter(ValueFromPipeline)]$s)
Write-Host $s -ForegroundColor Blue -BackgroundColor White
}

function print()
{
[CmdletBinding()]
Param( [Parameter(ValueFromPipeline)]$s)
Write-Host $s 
}

function h1()
{
[CmdletBinding()]
Param( [Parameter(ValueFromPipeline)]$s)
Write-Host $s -ForegroundColor black -BackgroundColor Yellow
}

function h2()
{
[CmdletBinding()]
Param( [Parameter(ValueFromPipeline)]$s)
Write-Host $s -ForegroundColor White -BackgroundColor Green
}

function h3()
{
[CmdletBinding()]
Param( [Parameter(ValueFromPipeline)]$s)
Write-Host $s -ForegroundColor White -BackgroundColor DarkBlue
}

function error()
{
[CmdletBinding()]
Param( [Parameter(ValueFromPipeline)]$s)
Write-Host $s -ForegroundColor white -BackgroundColor red
}

function warning()
{
[CmdletBinding()]
Param( [Parameter(ValueFromPipeline)]$s)
Write-Host $s -ForegroundColor yellow 
}

function info()
{
[CmdletBinding()]
Param( [Parameter(ValueFromPipeline)]$s)
Write-Host $s -ForegroundColor cyan 
}

function success()
{
[CmdletBinding()]
Param( [Parameter(ValueFromPipeline)]$s)
Write-Host $s -ForegroundColor green 
}