function Write-GitOut
{
	<#
	.SYNOPSIS
	Private function. Used by Set-GitBranch.

	.DESCRIPTION
	Writes a formatted output.

	.PARAMETER OutputType
	Header or Body.

	.PARAMETER OutputValue
	The value to output.

	.PARAMETER OutputStream
	The stream to output to.

	.PARAMETER NoNewLine
	Suppresses the new line at the end of the write.

	.INPUTS
	[System.String]
	Accepts string objects via the OutputValue parameter.

	.OUTPUTS
	[System.String]
	When the OutputStream parameter is 'Pipe', returns String objects.

	.NOTES
	Author : nmbell

	.LINK
	about_powdrgit
	.LINK
	https://github.com/nmbell/powdrgit/blob/main/help/about_powdrgit.md
	#>

	# Use cmdlet binding
	[CmdletBinding()]

	# Declare output type
	[OutputType([System.String])]

	# Suppress warnings from PSScriptAnalyzer
	[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost","")]

	# Declare parameters
	Param(

		[Parameter(Mandatory = $true)]
	  	[ValidateSet('Header','Body')]
		[String]
		$OutputType

	, 	[Parameter(
		  Mandatory                       = $false
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $true
		)]
		[System.Object]
		$OutputValue

	,	[Parameter(Mandatory = $true)]
	#	[ArgumentCompleter()]
		[String]
		$OutputStream

	,	[Switch]
		$NoNewLine

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
	}

	PROCESS
	{
		$bk = 'P'

		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Writing $OutputType to $OutputStream"
		If (!$OutputValue) { $OutputValue = '' }
		If ($OutputStream -ne 'None')
		{
			If ($OutputStream -eq 'Pipe')
			{
				Write-Output $OutputValue
			}
			Else
			{
				If ($OutputType -eq 'Header')
				{
					$foregroundColor = 'Black'
					If ($OutputStream -in 'Black','Blue','DarkBlue','DarkCyan','DarkGray','DarkGreen','DarkMagenta','DarkRed') { $foregroundColor = 'White' }
					[Microsoft.PowerShell.PSConsoleReadLine]::ScrollDisplayDownLine() # https://github.com/PowerShell/PowerShell/issues/15130
					Write-Host $OutputValue -ForegroundColor $foregroundColor -BackgroundColor $OutputStream -NoNewLine:$NoNewLine
				}
				If ($OutputType -eq 'Body')
				{
					Write-Host $OutputValue -ForegroundColor $OutputStream -NoNewLine:$NoNewLine
				}
			}
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
