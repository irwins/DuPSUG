function Get-LargestNumber ([int[]]$targetArray) {
   $max = $targetArray[0]

   for ($i = 1; $i -lt $targetArray.count; $i++) {

      if($targetArray[$i] -gt $max) {
         $max=$targetArray[$i]
      }
   }

   $max
}

$testCases = @(
   @{
      Set = @(5,4,3,2)
      Expected = 5
   }
   @{
      Set = @(2,5,4,3)
      Expected = 5
   }
   @{
      Set = @(-5,-2,-4,-3)
      Expected = -2
   }
   @{
      Set = @(-5,-2,-4,-1)
      Expected = -1
   }
   @{
      Set = @(-1,-2,-8,-5)
      Expected = -1
   }
)

Describe "Test function Get-LargestNumber" {

   It "Given the set <set> Should Return <expected>" -TestCases $testCases {
      param($set,$expected)

      $(Get-LargestNumber $set) | should be $expected
   }
}
