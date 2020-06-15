﻿# Downloading Acrobat_DC_Web_WWMUI.exe
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
$Parameters = @{
	Uri = "http://trials.adobe.com/AdobeProducts/APRO/20/win32/Acrobat_DC_Web_WWMUI.exe"
	OutFile = "$DownloadsFolder\Acrobat_DC_Web_WWMUI.exe"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters

# Extracting Acrobat_DC_Web_WWMUI.exe to the folder "Downloads folder\AcrobatTemp"
$ExtractPath = "$DownloadsFolder\AcrobatTemp"
Start-Process -FilePath "$DownloadsFolder\Acrobat_DC_Web_WWMUI.exe" -ArgumentList "/d $ExtractPath /o /x /s" -Wait

# Extracting AcroPro.msi to the "AcroPro.msi extracted" folder
$Arguments = @(
	"/a `"$ExtractPath\Adobe Acrobat\AcroPro.msi`""
	"TARGETDIR=`"$ExtractPath\Adobe Acrobat\AcroPro.msi extracted`""
	"/qb"
)
Start-Process "msiexec" -ArgumentList $Arguments -Wait

# Removing unnecessary files and folders
Get-ChildItem -Path $ExtractPath -Filter *.htm | ForEach-Object -Process {Remove-Item -Path $_.FullName}
Remove-Item -Path "$ExtractPath\GB18030" -Recurse -Force

Get-ChildItem -Path "$ExtractPath\Adobe Acrobat\Transforms" -Exclude 1049.mst | ForEach-Object -Process {Remove-Item -Path $_.FullName}
Remove-Item -Path "$ExtractPath\Adobe Acrobat\VCRT_x64" -Recurse -Force
Remove-Item -Path "$ExtractPath\Adobe Acrobat\AcrobatDCUpd*.msp" -Force
Remove-Item -Path "$ExtractPath\Adobe Acrobat\WindowsInstaller-KB893803-v2-x86.exe" -Force

Remove-Item -Path "$ExtractPath\Adobe Acrobat\AcroPro.msi" -Force
Remove-Item -Path "$ExtractPath\Adobe Acrobat\Data1.cab" -Force
Get-ChildItem -Path "$ExtractPath\Adobe Acrobat\AcroPro.msi extracted" -Recurse -Force | Move-Item -Destination "$ExtractPath\Adobe Acrobat" -Force
Remove-Item -Path "$ExtractPath\Adobe Acrobat\AcroPro.msi extracted" -Force

# Create edited setup.ini
$setupini = @"
[Product]
PATCH=AcrobatDCUpd2000920063.msp
msi=AcroPro.msi
Languages=1049
1049=Russian
"@
Set-Content -Path "$ExtractPath\Adobe Acrobat\setup.ini" -Value $setupini -Encoding Unicode -Force

# Converting setup.ini to the UTF-8 encoding
$Content = Get-Content -Path "$ExtractPath\Adobe Acrobat\setup.ini" -Raw
Set-Content -Value (New-Object System.Text.UTF8Encoding).GetBytes($Content) -Encoding Byte -Path "$ExtractPath\Adobe Acrobat\setup.ini" -Force

# Downloading the latest patch
$Parameters = @{
	Uri = "http://ardownload.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2000920063/AcrobatDCUpd2000920063.msp"
	OutFile = "$ExtractPath\Adobe Acrobat\AcrobatDCUpd2000920063.msp"
	Verbose = [switch]::Present
}
Invoke-WebRequest @Parameters