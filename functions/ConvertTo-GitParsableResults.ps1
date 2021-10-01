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

	.LINK
	about_powdrgit
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
		$bk = 'B'

		# Common BEGIN:
		Set-StrictMode -Version 3.0
		$thisFunctionName = $MyInvocation.MyCommand
		$start            = Get-Date
		$indent           = ($Powdrgit.DebugIndentChar[0]+'   ')*($PowdrgitCallDepth++)
		$PSDefaultParameterValues += @{ '*:Verbose' = $(If ($DebugPreference -notin 'Ignore','SilentlyContinue') { $DebugPreference } Else { $VerbosePreference }) } # turn on Verbose with Debug
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Start: $($start.ToString('yyyy-MM-dd HH:mm:ss.fff'))"

		# Function BEGIN:
		$parseLine = $null
	}

	PROCESS
	{
		$bk = 'P'

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
		$bk = 'E'

		# Function END:

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($($duration.ToString('d\d\ hh\:mm\:ss\.fff')))"
		$PowdrgitCallDepth--
	}
}
