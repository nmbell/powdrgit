# Write Verbose Time Stamp
# A deliberately terse helper function for placing a timestamp in Write-Verbose output
function wvTimestamp { (Get-Date).ToString('[yyyy-MM-dd HH:mm:ss.fff]') }
