# A deliberately terse helper function for placing a timestamp in Write-* output
function Get-WriteVerboseTimestamp { [Alias('ts')] Param() (Get-Date).ToString('[yyyy-MM-dd HH:mm:ss.fff]') }
