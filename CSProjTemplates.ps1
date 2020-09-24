﻿#region -------------------------- Templates
$projEXETemplate = 
@"
<!-- generated by projEXETemplate by https://github.com/HSchwichtenberg/.NETFrameworkTo.NETCoreMigrationPowerShellScript [DATE] -->
<Project Sdk="Microsoft.NET.Sdk">

<!-- Framework -->
  <PropertyGroup>
    <OutputType>exe</OutputType>
    <TargetFramework>[TFM]</TargetFramework>
</PropertyGroup>

<!-- App Details -->
  <PropertyGroup>
    <ApplicationIcon>[icon]</ApplicationIcon>
    <GenerateAssemblyInfo>false</GenerateAssemblyInfo>
    <Deterministic>false</Deterministic>
    <RootNamespace>[rootnamespace]</RootNamespace>
  </PropertyGroup>

<!-- Publishing -->
  <PropertyGroup>
    <PublishSingleFile>true</PublishSingleFile>
    <IncludeNativeLibrariesInSingleFile>true</IncludeNativeLibrariesInSingleFile>
    <IncludeSymbolsInSingleFile>true</IncludeSymbolsInSingleFile>
    <DebugType>embedded</DebugType>
    <PublishTrimmed>false</PublishTrimmed>
    <PublishMode>Link</PublishMode>
    <UseAppHost>true</UseAppHost>
  </PropertyGroup>

<!-- Assets -->
  <ItemGroup>
[AssetsRef]
  </ItemGroup>

<!-- Nuget Packages -->
  <ItemGroup>
[NugetReference]
  </ItemGroup>

<!-- Projects -->
   <ItemGroup>
[ProjectReference]
   </ItemGroup>

<!-- DLLs -->
  <ItemGroup>
[LibReference]
  </ItemGroup>
</Project>
"@

$projWPFTemplate = 
@"
<!-- generated projWPFTemplate by https://github.com/HSchwichtenberg/.NETFrameworkTo.NETCoreMigrationPowerShellScript [DATE] -->
<Project Sdk="Microsoft.NET.Sdk.WindowsDesktop">

<!-- Framework -->
  <PropertyGroup>
    <TargetFramework>[TFM]</TargetFramework>
    <OutputType>winexe</OutputType>
    <UseWPF>true</UseWPF>
    <UseWindowsForms>true</UseWindowsForms>
  </PropertyGroup>

<!-- App Details -->
  <PropertyGroup>
    <GenerateAssemblyInfo>false</GenerateAssemblyInfo>
    <Deterministic>false</Deterministic>
    <RootNamespace>[rootnamespace]</RootNamespace>
    <ApplicationIcon>[icon]</ApplicationIcon>
  </PropertyGroup>

<!-- Publishing -->
  <PropertyGroup>
    <PublishSingleFile>true</PublishSingleFile>
    <IncludeNativeLibrariesInSingleFile>true</IncludeNativeLibrariesInSingleFile>
    <IncludeSymbolsInSingleFile>true</IncludeSymbolsInSingleFile>
    <DebugType>embedded</DebugType>
    <PublishTrimmed>false</PublishTrimmed>
    <PublishMode>Link</PublishMode>
    <UseAppHost>true</UseAppHost>
  </PropertyGroup>

<!-- Assets -->
  <ItemGroup>
[AssetsRef]
  </ItemGroup>

<!-- Nuget Packages -->
  <ItemGroup>
[NugetReference]
  </ItemGroup>

<!-- Projects -->
   <ItemGroup>
[ProjectReference]
   </ItemGroup>

<!-- DLLs -->
  <ItemGroup>
[LibReference]
  </ItemGroup>
</Project>
"@

$projLibTemplate = 
@"
<!-- generated by https://github.com/HSchwichtenberg/.NETFrameworkTo.NETCoreMigrationPowerShellScript [DATE] -->
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Library</OutputType>
    <TargetFramework>netstandard2.1</TargetFramework>
    <GenerateAssemblyInfo>false</GenerateAssemblyInfo>
    <Deterministic>false</Deterministic>
    <RootNamespace>[rootnamespace]</RootNamespace>

  </PropertyGroup>

<!-- Assets -->
  <ItemGroup>
[AssetsRef]
  </ItemGroup>

<!-- Nuget Packages -->
  <ItemGroup>
[NugetReference]
  </ItemGroup>

<!-- Projects -->
   <ItemGroup>
[ProjectReference]
   </ItemGroup>

<!-- DLLs -->
  <ItemGroup>
[LibReference]
  </ItemGroup>
</Project>
"@

$projTestTemplate = 
@"
<!-- generated by https://github.com/HSchwichtenberg/.NETFrameworkTo.NETCoreMigrationPowerShellScript [DATE] -->
<Project Sdk="Microsoft.NET.Sdk">

<PropertyGroup>
 <TargetFramework>[TFM]</TargetFramework>
 <GenerateAssemblyInfo>false</GenerateAssemblyInfo>
 <Deterministic>false</Deterministic>
 <RootNamespace>[rootnamespace]</RootNamespace>
 <RuntimeIdentifier>win-x64</RuntimeIdentifier>
</PropertyGroup>

<!-- Assets -->
  <ItemGroup>
[AssetsRef]
  </ItemGroup>

<!-- Nuget Packages -->
  <ItemGroup>
  <PackageReference Include="Microsoft.NET.Test.Sdk" Version="16.3.0" />
  <PackageReference Include="MSTest.TestAdapter" Version="2.1.2" />
  <PackageReference Include="MSTest.TestFramework" Version="2.1.2" />
  <PackageReference Include="coverlet.collector" Version="1.3.0" />
   <!-- Other Packages -->
[NugetReference]
  </ItemGroup>

<!-- Projects -->
   <ItemGroup>
[ProjectReference]
   </ItemGroup>

<!-- DLLs -->
  <ItemGroup>
[LibReference]
  </ItemGroup>
</Project>
"@

$NugetRefTemplate=
@"
<PackageReference Include="NAME" Version="VERSION" />
"@

$ProjRefTemplate=
@"
<ProjectReference Include="TODO" />
"@

$LibRefTemplate=  
@"
    <Reference Include="TODO">
      <HintPath>..\_Libs\TODO.dll</HintPath>
    </Reference>
"@

$AssetTemplate=
@"
<Resource Include="FILE" />
"@
#endregion # Templates