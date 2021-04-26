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
	https://github.com/nmbell/powdrgit/help/Write-GitBranchOut.md
	.LINK
	about_powdrgit
	.LINK
	Set-GitBranch
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
		[ArgumentCompleter({
			Param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
			@('None','Pipe')+[Enum]::GetValues([System.ConsoleColor]) | Where-Object { $_ -like "$wordToComplete*" }
		})]
		[String]
		$OutputStream

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
	}

	PROCESS
	{
		# $wvBlock = 'P'

		# Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Writing $OutputType"
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
		# $wvBlock = 'E'

		# Function END:

		# Common END:
		# $end      = Get-Date
		# $duration = New-TimeSpan -Start $start -End $end
		# Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($('{0}d {1:00}:{2:00}:{3:00}.{4:000}' -f $duration.Days,$duration.Hours,$duration.Minutes,$duration.Seconds,$duration.Milliseconds))"
		# $PowdrgitCallDepth--
	}
}
