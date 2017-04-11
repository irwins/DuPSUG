# DuPSUG - PowerShell Saturday iSense 08-04-2017

Presentation and Demo material

## Get largest number
The basics of a unit, testcases and unittest

![image](https://cloud.githubusercontent.com/assets/10112589/24896405/14a99e2a-1e95-11e7-885c-9a4e404f0554.png)

## Demo create user from CSV file
   1. [Missing mandatory parameter](#NoMandatoryParameter)
   2. [Missing SamAccountName parameter](#NoSamAccountNameParameter)
   3. [Workaround without SamAccountName parameter](#WorkaroundNoSamAccountNameParameter)
   4. [Workaround without Name parameter](#WorkaroundNoNameParameter)
   5. [Valid CSV File](#ValidCSVFile)
   
### 1. CSV file without mandatory parameter <a name="NoMandatoryParameter"></a>
``` powershell
$csvDuPSUG = @"
SamAccountName;Path
mikem;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
sarap;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
henkd;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
urvs;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
"@ | ConvertFrom-Csv -Delimiter ';'

$csvDuPSUG | New-ADUser
```
All errors... Manadatory parameter Name is missing
![image](https://cloud.githubusercontent.com/assets/10112589/24846553/ab5168ce-1dbb-11e7-8a01-9564c5692e35.png)

### 2. CSV file without SamAccountName parameter <a name="NoSamAccountNameParameter"></a>
```PowerShell
$csvDuPSUG = @"
Name;Path
Mike.Miller;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Sara.Palindrome;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Henk.Darma;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Urvino.Sam;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
"@ | ConvertFrom-Csv -Delimiter ';'

$csvDuPSUG | New-ADUser -PassThru
```
Only the first account is created. All other fail..
![image](https://cloud.githubusercontent.com/assets/10112589/24846676/492a44b2-1dbc-11e7-872b-6969103f5671.png)

### 3. Workaround creating users without SamAccountName <a name="WorkAroundNoSamAccountNameParameter"></a>
```PowerShell
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
```
This works fine. Notice that SamAccountName equals Name
![image](https://cloud.githubusercontent.com/assets/10112589/24846727/be2337a6-1dbc-11e7-872a-d5975356bedc.png)

### 4. Try workaround without Name parameter. <a name="WorkaroundNoNameParameter"></a>
```PowerShell
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
```
Request Name input

![image](https://cloud.githubusercontent.com/assets/10112589/24846836/76cf2fc6-1dbd-11e7-96cf-0ad4ff035bf7.png)

### 5. Creating users with a valid CSV file <a name="ValidCSVFile"></a>
```PowerShell
$csvDuPSUG = @"
Name;SamAccountName;Path
Mike.Miller;mikem;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Sara.Palindrome;sarap;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Henk.Darma;henkd;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
Urvino.Sam;urvs;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local
"@ | ConvertFrom-Csv -Delimiter ';'

$csvDuPSUG | New-ADUser -PassThru
```
Notice that Name & SamAccountName are different
![image](https://cloud.githubusercontent.com/assets/10112589/24846903/d5158f8a-1dbd-11e7-8568-bf28bf01015c.png)

## Describe a valid CSV file for New-ADUser 
Using .contains method makes everything case sensitive. The -contains operator doesn't have a problem with that. So unless you want to have your Parameters precisely use -contains...

Eventhough the parameters may look funky, they still work 
![image](https://cloud.githubusercontent.com/assets/10112589/24846222/1dc84e16-1db9-11e7-8786-e410570329e9.png)

## Dependencies
The script won't continue if the dependencies aren't met. Once all dependencies pass the test the script continues.

Creating the user this way makes for some decent error handling. User henkd already exists, his other parameters seems to be correct.
User urvs was created and his parameters are what you'd expect

![image](https://cloud.githubusercontent.com/assets/10112589/24846296/d4998c7c-1db9-11e7-9507-7e1e5221fd26.png)


