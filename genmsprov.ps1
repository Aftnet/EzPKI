# Need to have Windows Configuration Designer installed for this to work.
# Get at https://www.microsoft.com/store/productId/9NBLGGH4TX22

$wwwRootDir = "$PSScriptRoot\pki\onboarding"
$tempDir = "$wwwRootDir\temp"
$custXmlPath = "$tempDir\msprovisioning.xml"
$certPath = "$wwwRootDir\publish\ca.cer"

$htmlPath = "$wwwRootDir\index.html"
$html = cat "$htmlPath"
$orgDisplayName = $html -match "<!--ORG_NAME=.+$"
$orgDisplayName = $orgDisplayName -replace "<!--ORG_NAME=", ""
$orgDisplayName = $orgDisplayName -replace "-->", ""
echo "Setting organization name to: $orgDisplayName"

mkdir $tempDir
$content = cat "$PSScriptRoot\templates\provisioning\msprovisioning.xml"
$content = $content -replace "%UUID%", "$(new-guid)"
$content = $content -replace "%ORGNAME%", $orgDisplayName
$content = $content -replace "%CACERTPATH%", "$certPath"
echo $content > $custXmlPath

&icd /Build-ProvisioningPackage "/PackagePath:$tempDir\ca.ppkg" "/CustomizationXML:$custXmlPath" +Overwrite
mv $tempDir\ca.ppkg -Destination "$PSScriptRoot\pki\onboarding\publish" -Force
rm $tempDir -Recurse -Force

$htmlPath = "$wwwRootDir\index.html"
$html = cat "$htmlPath"
$html = $html -replace "<!--PPKGBTN", ""
$html = $html -replace "PPKGBTN!-->", ""
echo $html > $htmlPath
