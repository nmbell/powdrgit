function Test-PowdrgitDefaultDir
{
	<#
	.SYNOPSIS
	Private function. Validates the path stored in the $Powdrgit.DefaultDir module variable.

	.DESCRIPTION
	Private function. Validates the path stored in the $Powdrgit.DefaultDir module variable.
	Returns the path it exists. Otherwise returns a warning

	.PARAMETER FunctionName
	Value to be displayed in the warning message.

	.EXAMPLE
	## Test $Powdrgit.DefaultDir ##

	PS C:\> Test-PowdrgitDefaultDir
	True

	.INPUTS
	None.

	.OUTPUTS
	[System.Boolean]
	Returns a boolean (true/false) object.

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
	[OutputType([System.Boolean])]

	# Declare parameters
	Param()

	BEGIN
	{
		$bk = 'B'

		# Common BEGIN:
		Set-StrictMode -Version 3.0
		$thisFunctionName = $MyInvocation.MyCommand
		$start            = Get-Date
		$indent           = ($Powdrgit.DebugIndentChar[0]+'   ')*($PowdrgitCallDepth++)
		$PSDefaultParameterValues += @{ '*:Verbose' = $(If ($DebugPreference -notin 'Ignore','SilentlyContinue') { $DebugPreference } Else { $VerbosePreference }) } # turn on Verbose with Debug
		$warn             = !($PSBoundParameters.ContainsKey('WarningAction') -and $PSBoundParameters.WarningAction -eq 'Ignore') # because -WarningAction:Ignore is not implemented correctly
		$callingFunction  = (Get-PSCallStack)[1].Command; If ($callingFunction -eq '<ScriptBlock>') { $callingFunction = $thisFunctionName }
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Start: $($start.ToString('yyyy-MM-dd HH:mm:ss.fff'))"

		# Function BEGIN:
	}

	PROCESS
	{
		$bk = 'P'

		If (!$Powdrgit.DefaultDir)
		{
			If ($warn) { Write-Warning "[$callingFunction]The `$Powdrgit.DefaultDir module variable is not defined. Either set to a valid location or don't use the UseDefaultDir parameter." }
		}
		Else
		{
			$defaultDirExists = Test-Path -Path $Powdrgit.DefaultDir
			If (!$defaultDirExists)
			{
				If ($warn) { Write-Warning "[$callingFunction]The path specified in the `$Powdrgit.DefaultDir could not be found." }
			}
			$defaultDirExists
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
