function Write-GitBranchOut
{
	<#
	.SYNOPSIS
	Private function. Used by Set-GitBranch.

	.DESCRIPTION
	Writes a formatted output.

	.PARAMETER OutputType
	Header or Command.

	.PARAMETER OutputValue
	The value to output.

	.PARAMETER OutputStream
	The stream to output to.

	.NOTES
	Author : nmbell

	.LINK
	about_powdrgit
	#>

	# Use cmdlet binding
	[CmdletBinding()]

	# Suppress warnings from PSScriptAnalyzer
	[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost","")]

	# Declare parameters
	Param(

		[Parameter(Mandatory = $true)]
	  	[ValidateSet('Header','Command')]
		[String]
		$OutputType

	, 	[Parameter(Mandatory = $true)]
		[String]
		$OutputValue

	,	[Parameter(Mandatory = $true)]
	#	[ArgumentCompleter()]
		[String]
		$OutputStream

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

		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Writing $OutputType"
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
					Write-Host $OutputValue -ForegroundColor $foregroundColor -BackgroundColor $OutputStream
				}
				If ($OutputType -eq 'Command')
				{
					Write-Host $OutputValue -ForegroundColor $OutputStream
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
