#In order for this script to work you need to have configured powershell to work with office 365
#To save your $cred use Get-Credential user@domain.com | Export-Clixml location\credname.xml 

###########
#Variables#
###########
$students = "C:\scripts\stuO365.csv" #Location to Student save CSV
$Staffs = "c:\scripts\staffO365.csv" #Location to save Staff CSV
$stalicensecsv = "C:\scripts\stalicense.csv" #Location to Save CSV
$stulicensecsv = "C:\scripts\stulicense.csv" #Location to Save CSV
$Stulicense = "Yourlicensehere" #Use get-msolaccountsku to find the right SKU that you wish to assign.
$stafflicense = "Yourlicensehere" #Use get-msolaccountsku to find the right SKU that you wish to assign.
$cred = import-clixml "c:\scripts\O365.xml" #Import saved Credentials for automating/running the script on a schedule.

#Connect to Microsoft online Service
Connect-MsolService -Credential $cred 

#Generates a list of users who do not have a location assigned to them and saves to a CSV. O365 looks at the ms-ExchangeUserLocation attribute
Get-msoluser -all -Department Student -EnabledFilter EnabledOnly | Where-Object {$_.UsageLocation -eq $Null} | Export-Csv $Students

#Generates a list of users who do not have a location assigned to them and saves to a CSV. O365 looks at the ms-ExchangeUserLocation attribute
Get-msoluser -all -Department Staff -EnabledFilter EnabledOnly | Where-Object {$_.UsageLocation -eq $Null} | Export-Csv $Staffs

#Reads from the CSV to assign the two letter location. Full list found here https://www.iso.org/obp/ui/#search/code/
#Student assigned license
$Student = $students
Import-Csv $student | ForEach {
Set-Msoluser -ObjectId $_.ObjectID -UserPrincipalName $_.UserPrincipalName -UsageLocation "US"
}

#Reads from the CSV to assign the two letter location. Full list found here https://www.iso.org/obp/ui/#search/code/
#Staff assign licensed
$Staff = $Staffs
Import-Csv $staff | ForEach {
Set-Msoluser -ObjectId $_.ObjectID -UserPrincipalName $_.UserPrincipalName -UsageLocation "US"
}

Foreach ($user in (Get-MsolUser -All)) # Removes licenses from your inactive accounts
{
If ($user.BlockCredential -eq $true -and $user.isLicensed -eq $True)
{
    Write-Host $user.Userprincipalname "Is Disabled" -ForegroundColor Green
    Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -RemoveLicenses $Stulicense
    }
    }

#Once you have your users location set you need to assign a license Students
Get-msoluser -all -UnlicensedUsersOnly  -EnabledFilter EnabledOnly -Department Student | Export-CSV $stulicensecsv
$license = $stulicensecsv
Import-CSV $license | ForEach{
Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -AddLicenses $Stulicense
}

#Once you have your users location set you need to assign a license Staff
Get-msoluser -all -UnlicensedUsersOnly  -EnabledFilter EnabledOnly -Department Staff| Export-CSV $stalicensecsv
$license = $stalicensecsv
Import-CSV $license | ForEach{
Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -AddLicenses $stafflicense
}

