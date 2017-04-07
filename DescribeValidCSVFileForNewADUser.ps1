<#
      Describe a CSV File to Create AD Users
      External Factors
         It should have .csv as extension
         It should exists/resolve 

      Interal
         It should be UTF8 encoded (optional)
         It should have valid Column Names
         It should contain manadatory parameter Name
#>

#region Get paramter set from New-ADUser
$parametersNewADUser = (Get-Command New-ADUser -ErrorAction Stop).ParameterSets.Parameters | 
Where-Object {$_.ValueFromPipelineByPropertyName -eq $true} |
Select-Object Name,Ismandatory 
#endregion

Function Create-TestCases{
   param(
      $objActual,
      $objExpected
   )

   $objActual |
   ForEach-Object{
      @{
         Actual   = $($_)
         Valid    = $($objExpected.Name -contains $_)
      }
   }
}

#region Create CSV File
$csvFilePath = 'C:\scripts\source\csv'
$csvFileName = 'DuPSUG.csv'
$csvFile  = Get-childItem $(Join-Path -Path $csvFilePath -ChildPath $csvFileName)

@'
NAME;SamAccountName;path;MobiLEPhones
Mike.Miller;mikem;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local;0612345678
Sara.Palindrome;sarap;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local;0612345678
Henk.Darma;henkd;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local;0612345678
Urvino.Sam;urvs;OU=Users,OU=DuPSUG,DC=pshirwin,DC=local;0612345678
'@ | Out-file $csvFile.FullName -Encoding utf8 -Force
#endregion

Describe 'CSV File used as input for New-ADUser'{
   $csvDuPSUG = Import-Csv -Path $csvFile.FullName -Delimiter ';' -Encoding UTF8
   $csvDuPSUGColumns = ($csvDuPSUG | Get-Member -MemberType NoteProperty).Name

   #Is this an issue?
   It "CSV File $($csvFile.Name) Should have .csv as extension"{
      $csvFile.Extension | Should -Be '.csv'
   }
   
   #This is redundant. We've already established this. For reporting purposes this might be interesting
   It "CSV File $($csvFile.FullName) is available"{
      Test-Path -Path $csvFile.FullName
   }
   
   #region .Contains method
   Context 'Veryfing Manadatory Name parameter using .contains method'{
      It "CSV File contains Mandatory `'Name`' parameter .Contains( method"{
         $csvDuPSUGColumns.Contains('Name') | Should -Be $true
      }

      It "CSV File contains Mandatory `'NAME`' parameter .Contains( method"{
         $csvDuPSUGColumns.Contains('NAME') | Should -Be $true
      }

      It "CSV File contains Mandatory `'name`' parameter .Contains( method"{
         $csvDuPSUGColumns.Contains('name') | Should -Be $true
      }
   }
   #endregion

   #region -contains operator
   Context 'Veryfing Manadatory Name parameter using -contains operator'{
      It "CSV File contains Mandatory `'Name`' parameter -contains Operator"{
         $csvDuPSUGColumns -Contains 'Name' | Should -Be $true
      }

      It "CSV File contains Mandatory `'NAME`' parameter -contains Operator"{
         $csvDuPSUGColumns -Contains 'NAME'| Should -Be $true
      }

      It "CSV File contains Mandatory `'name`' parameter -contains Operator"{
         $csvDuPSUGColumns -Contains 'name'| Should -Be $true
      }
   }
   #endregion

   Context 'Verifying Parameter names in CSV file' {

      #Create TestCases for verifying Properties
      $TestCases = Create-TestCases -objActual $csvDuPSUGColumns -objExpected $parametersNewADUser

      It 'Verify that property <actual> is a valid New-ADUser property' -TestCases $TestCases   {
         param($Actual,$Valid)
         $valid | Should be $true
      }
   }
}
