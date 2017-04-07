#region Get Parameters for New-ADUser
$paramsNewADUser = (Get-Command New-ADUser -ErrorAction Stop).ParameterSets.Parameters | 
Where-Object {$_.ValueFromPipelineByPropertyName -eq $true}|
Select-Object Name,Ismandatory

'Total parameters New-ADUser cmdlet: {0}' -f $paramsNewADUser.Count
$paramsNewADUser.Where{$_.IsMandatory -eq $true}
#endregion

Get-ADUser -SearchBase 'OU=Users,OU=DuPSUG,DC=pshirwin,DC=local' -filter '*' | 
Remove-ADUser -Confirm:$false

#region Without Mandatory parameter Name
$csvDuPSUG = @"
SamAccountName;Path
mikem;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
sarap;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
henkd;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
urvs;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
"@ | ConvertFrom-Csv -Delimiter ';'

$csvDuPSUG | New-ADUser
#endregion


#region Without parameter SamAccountName
#Technet says: You must specify the SAMAccountName parameter to create a user.
$csvDuPSUG = @"
Name;Path
Mike.Miller;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Sara.Palindrome;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Henk.Darma;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Urvino.Sam;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
"@ | ConvertFrom-Csv -Delimiter ';'

$csvDuPSUG | New-ADUser -PassThru
#endregion

#region Without parameter SamAccountName in a ForEach. SamAccountName equals Name
#Technet says: You must specify the SAMAccountName parameter to create a user. 
#But this will work
$csvDuPSUG = @"
Name;Path
Mike.Miller;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Sara.Palindrome;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Henk.Darma;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Urvino.Sam;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
"@ | ConvertFrom-Csv -Delimiter ';'

$csvDuPSUG | 
ForEach-Object{
   New-ADUser -Name $_.Name -Path $_.Path -PassThru
}

Get-ADUser -SearchBase 'OU=Users,OU=DuPSUG,DC=pshirwin,DC=local' -filter '*' | 
Remove-ADUser -Confirm:$false
#endregion

#region Without parameter SamAccountName in a ForEach. SamAccountName equals Name
$csvDuPSUG = @"
SamAccountName;Path
MikeM;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
SaraP;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
HenkD;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
UrvinoS;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
"@ | ConvertFrom-Csv -Delimiter ';'

<#
Supply values for the following parameters:
Name: 
#>
$csvDuPSUG | 
ForEach-Object{
   New-ADUser -SamAccountName $_.SamAccountName -Path $_.Path -PassThru
}
#endregion

#region With Mandatory parameter Name & SamAccountName
$csvDuPSUG = @"
Name;SamAccountName;Path
Mike.Miller;mikem;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Sara.Palindrome;sarap;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Henk.Darma;henkd;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Urvino.Sam;urvs;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
"@ | ConvertFrom-Csv -Delimiter ';'

$csvDuPSUG | New-ADUser -PassThru

Get-ADUser -SearchBase 'OU=Users,OU=DuPSUG,DC=pshirwin,DC=local' -filter '*' | 
Remove-ADUser -Confirm:$false
#endregion

