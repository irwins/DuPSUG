<#

      Author: I.C.A. Strachan
      Version:
      Version History:

      Purpose: Infrastructure validation script to create ADUser from CSV file

#>

[CmdletBinding(SupportsShouldProcess=$True)]

Param(
   [string]
   $csvFileName = 'DuPSUG.csv',

   [string]
   $csvFilePath = 'C:\scripts\source\csv'
)

#Get csv File
$csvFile = $(Join-Path -Path $csvFilePath -ChildPath $csvFileName)

function ConvertTo-HashTable{
   param(
      [PSObject]$PSObject
   )
   $splat = @{}

   $PSObject | 
   Get-Member -MemberType *Property |
   ForEach-Object{
         $splat.$($_.Name) = $PSObject.$($_.Name)
   }

   $splat
}

Function Test-CSVNewADUserParameters{
   param(
      $objActual,
      $objExpected
   )

   
   $allValid = $objActual |
   ForEach-Object{
      @{
         Actual   = $($_)
         Valid    = $($objExpected.Name -contains $_)
      }
   }

   $allValid.Valid -notcontains $False
}

Function Create-TestCasesUserProperties{
   param(
      $objActual,
      $objExpected,
      $Properties
   )

   $Properties |
   ForEach-Object{
      @{
         Actual   = $objActual.$_
         Expected = $objExpected.$_
         Property = $_
      }
   }
}

#region Arrange
#Define proper dependencies
#1) Verify csv file exist
#   a) Verify Mandatory Name parameter
#   b) Verify Valid parameters
#2) Can user read AD properties.


$dependencies = @(
   @{
      Label  = 'ActiveDirectory module is available '
      Test   = {(Get-module -ListAvailable).Name -contains 'ActiveDirectory'}
      Action = {
         #Import ActiveDirectory
         Import-Module -Name ActiveDirectory

         #Get New-ADUser Parameters available
         $script:parametersNewADUser = (Get-Command New-ADUser -ErrorAction Stop).ParameterSets.Parameters | 
            Where-Object {$_.ValueFromPipelineByPropertyName -eq $true} |
            Select-Object Name,Ismandatory 
      }
   }

   @{
      Label  = "CSV File at $($csvFile) exists"
      Test   = {Test-Path -Path $csvFile}
      Action = {
         $script:csvDuPSUG        = Import-Csv -Path $csvFile -Delimiter ";" -Encoding UTF8
         $script:csvDuPSUGColumns = ($csvDuPSUG | Get-Member -MemberType NoteProperty).Name
         $script:UserProperties   = $csvDuPSUGColumns.Where{$_ -ne 'Path'}
      }
   }

   @{
      Label  = "CSV contains Mandatory `'Name`' parameter"
      Test   = {$csvDuPSUGColumns -Contains 'Name' }
      Action = {}
   }

   @{
      Label  = "CSV contains valid parameters For cmdlet New-ADUser"
      Test   = {Test-CSVNewADUserParameters -objActual $csvDuPSUGColumns -objExpected $parametersNewADUser}
      Action = {}
   }

   @{
      Label  = "$(& "$env:windir\system32\whoami.exe") can read AD user object properties"
      Test   = {[bool](Get-AdUser -Identity $("$((Get-ADDomain).DomainSID)-500"))}
      Action = {}
   }
)

foreach($dependency in $dependencies){
   if(!( & $dependency.Test)){
      throw "The check: $($dependency.Label) failed. Halting script"
   }
   else{
      Write-Verbose $($dependency.Label) 
      $dependency.Action.Invoke()
   }
}
#endregion

#region Just deleting the accounts in order to run scripts multiple times
Get-ADUser -SearchBase 'OU=Users,OU=DuPSUG,DC=pshirwin,DC=local' -filter '*' | 
Remove-ADUser -Confirm:$false
#endregion

#region Main
$csvDuPSUG  |
Foreach-Object{
   $Actual = $_
   Describe "Processing User $($Actual.SamAccountName)"{
      Context "Creating AD User account for $($Actual.SamAccountName) "{
         #Convert to HashTable for splatting
         $paramNewADUser = ConvertTo-HashTable -PSObject $Actual

         #region Act
         #1) Create ADUser from csv file

         It "Created an account for $($Actual.SamAccountName)"{
            New-ADUser @paramNewADUser
         }
         #endregion
      }

      Context "Verifying AD User properties for $($Actual.SamAccountName)"{
         #region Assert
         #1) Verify AD user has been created correctly

         #Get AD user properties
         #Get-ADUser doesn't have a Path parameter that's why it's been removed
         $Expected = Get-ADUser -Identity $Actual.SamAccountName -Properties $UserProperties

         #Create TestCases for verifying Properties
         $TestCases = Create-TestCasesUserProperties -objActual $Actual -objExpected $Expected -Properties $UserProperties

         It 'Verified that property <property> expected value <expected> actually is <actual>' -TestCases $TestCases   {
            param($Actual,$Expected,$Property)
            $Actual.$Property  | should be $Expected.$Property
         }
         #endregion
      }
   }
}
#endregion