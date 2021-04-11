function ConvertTo-GitParsableResults
{
	<#
	.SYNOPSIS
	Converts git output with line breaks into parsable form.

	.DESCRIPTION
	Converts git output with line breaks into parsable form.

	.PARAMETER Line
	Line of text.

	.PARAMETER StartOfText
	Marker indicating the start of a line of text.

	.PARAMETER EndOfText
	Marker indicating the end of a line of text.

	.NOTES
	Author : nmbell
	#>

    # Use cmdlet binding
    [CmdletBinding()]

    # Declare parameters
	Param
	(

    	[Parameter(
    	  Mandatory                       = $false
    	, Position                        = 0
    	, ValueFromPipeline               = $true
    	, ValueFromPipelineByPropertyName = $true
		)]
      	[String]
		$Line

    ,	[Parameter(
    	  Mandatory                       = $true
    	, Position                        = 1
    	, ValueFromPipeline               = $false
    	, ValueFromPipelineByPropertyName = $true
		)]
      	[String]
		$StartOfText

    ,	[Parameter(
    	  Mandatory                       = $true
    	, Position                        = 2
    	, ValueFromPipeline               = $false
    	, ValueFromPipelineByPropertyName = $true
		)]
      	[String]
		$EndOfText

    )

	BEGIN
	{
		# $wvBlock          = 'B'

		# Common BEGIN:
		Set-StrictMode -Version 2.0
		# $thisFunctionName = $MyInvocation.InvocationName
		# $start            = Get-Date
		# $wvIndent         = '|  '*($PowdrgitCallDepth++)
		# Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Start: $($start.ToString('yyyy-MM-dd HH:mm:ss.fff'))"

		# Function BEGIN:
		$parseLine = $null
	}

	PROCESS
	{
		# $wvBlock = 'P'

		If ($Line -like "$StartOfText*")
		{
			$parseLine = $Line
		}
		Else
		{
			$parseLine += $Line
		}
		If ($parseLine -like "*$EndOfText")
		{
			Write-Output $parseLine.Replace($StartOfText,'').Replace($EndOfText,'')
			$parseLine = $null
		}
    }

	END
	{
		# $wvBlock = 'E'

		# Function END:

		# Common END:
		# $end      = Get-Date
		# $duration = New-TimeSpan -Start $start -End $end
		# Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($('{0}d {1:00}:{2:00}:{3:00}.{4:000}' -f $duration.Days,$duration.Hours,$duration.Minutes,$duration.Seconds,$duration.Milliseconds))"
		# $PowdrgitCallDepth--
	}
}
