function Remove-PowdrgitPath
{
	<#
	.SYNOPSIS
	Removes a path from the $Powdrgit.Path module variable.

	.DESCRIPTION
	Removes a path from the $Powdrgit.Path module variable.
	When a path is removed, $Powdrgit.Path is (re)written as a unique sorted list of paths.
	If there are no paths in $Powdrgit.Path, it is set to $null.

	.PARAMETER Path
	The paths to be removed.
	Can be an array of strings, or a string containing a semicolon-separated list of paths.
	Empty, whitespace, or null paths are ignored.

	.EXAMPLE
	## Remove empty, whitespace, or null paths ##

	PS C:\> $Powdrgit.Path = 'C:\Temp\a;C:\Temp\b;C:\Temp\c'
	PS C:\> Remove-PowdrgitPath -Path $null
	PS C:\> Remove-PowdrgitPath -Path ''
	PS C:\> Remove-PowdrgitPath -Path ';'
	PS C:\> $Powdrgit.Path
	C:\Temp\a;C:\Temp\b;C:\Temp\c

	# Empty paths are ignored.

	.EXAMPLE
	## Remove valid paths ##

	PS C:\> $Powdrgit.Path = 'C:\Temp\a;C:\Temp\b;C:\Temp\c'
	PS C:\> Remove-PowdrgitPath -Path 'C:\Temp\b;C:\Temp\a'
	PS C:\> $Powdrgit.Path
	C:\Temp\c
	PS C:\> Remove-PowdrgitPath -Path 'C:\Temp\c','C:\Temp\b'
	PS C:\> $null -eq $Powdrgit.Path
	True

	# When all paths are removed from $Powdrgit.Path, it is set to $null.

	.EXAMPLE
	## Pipe into Remove-PowdrgitPath ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\Project1'
	PS C:\> Get-ChildItem -Path 'C:\PowdrgitExamples' -Directory | Remove-PowdrgitPath
	PS C:\> $null -eq $Powdrgit.Path
	True

	# Get-ChildItem is used here by way of example. Repository paths can also be retrieved using Get-GitRepo or Test-PowdrgitPath.

	.INPUTS
	[System.String[]]
	Accepts string objects via the Path parameter.

	.OUTPUTS
	[System.Void]
	The function does not return anything.

	.NOTES
	Author : nmbell

	.LINK
	Add-PowdrgitPath
	.LINK
	Test-PowdrgitPath
	.LINK
	Find-GitRepo
	.LINK
	Get-GitRepo
	.LINK
	Set-GitRepo
	.LINK
	New-GitRepo
	.LINK
	Remove-GitRepo
	.LINK
	Invoke-GitClone
	.LINK
	about_powdrgit
	.LINK
	https://github.com/nmbell/powdrgit/blob/main/help/about_powdrgit.md
	#>

	# Function alias
	[Alias('rpp')]

	# Use cmdlet binding
	[CmdletBinding(
	  SupportsShouldProcess = $true
	, ConfirmImpact         = 'Low'
	, HelpURI               = 'https://github.com/nmbell/powdrgit/blob/main/help/Remove-PowdrgitPath.md'
	)]

	# Declare output type
	[OutputType([System.Void])]

	# Declare parameters
	Param
	(

		[Parameter(
		  Mandatory                       = $true
		, Position                        = 0
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $true
		)]
		[AllowEmptyString()]
		[AllowNull()]
		[Alias('FullName')]
		[String[]]
		$Path

	)

	BEGIN
	{
		$bk = 'B'

		# Common BEGIN:
		Set-StrictMode -Version 3.0
		$thisFunctionName = $MyInvocation.MyCommand
		$start            = Get-Date
		$indent           = ($Powdrgit.DebugIndentChar[0]+'   ')*($PowdrgitCallDepth++); [RegEx]$pattern = ".\s\s\s"; $indent = $pattern.Replace($indent,'',1) # because Pester
		$PSDefaultParameterValues += @{ '*:Verbose' = $(If ($DebugPreference -notin 'Ignore','SilentlyContinue') { $DebugPreference } Else { $VerbosePreference }) } # turn on Verbose with Debug
		$confirmImpact    = $MyInvocation.MyCommand.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] } | Select-Object -ExpandProperty ConfirmImpact
		$callingFunction  = (Get-PSCallStack)[1].Command; If ($callingFunction -eq '<ScriptBlock>') { $callingFunction = $thisFunctionName }
		Write-Debug "  $(ts)$indent[$callingFunction][$bk]Start: $($start.ToString('yyyy-MM-dd HH:mm:ss.fff'))"

		# Function BEGIN:
	}

	PROCESS
	{
		$bk = 'P'

		Try
		{
			# Construct the new Path value
			$existPaths = @()
			$inputPaths = @()
			$newPaths   = @()
			$existPaths += ($Powdrgit.Path -split ';')              | ForEach-Object { $_.Trim() } | Where-Object { ![String]::IsNullOrEmpty($_) } | Select-Object -Unique
			$inputPaths += $Path | ForEach-Object { $_ -split ';' } | ForEach-Object { $_.Trim() } | Where-Object { ![String]::IsNullOrEmpty($_) } | Select-Object -Unique
			$newPaths   += $existPaths | Where-Object { $_ -notin $inputPaths } | Select-Object -Unique | Sort-Object

			# Preview changes for WhatIf/Confirm
			If ($WhatIfPreference -or ($ConfirmPreference -and $confirmImpact -ge $ConfirmPreference))
			{
				ForEach ($_path in $existPaths)
				{
					If ($_path -notin $newPaths)
					{
						Write-Host "[-] $_path" -ForegroundColor White
					}
					ElseIf (!$MyInvocation.ExpectingInput)
					{
						Write-Host "    $_path" -ForegroundColor DarkGray
					}
				}
			}

			# Make the changes
			$diffCount = $existPaths.Count-$newPaths.Count
			$s = If ($diffCount -eq 1) { '' } Else { 's' }
			$shouldText = "Removing $($diffCount.ToString()) path$s from `$Powdrgit.Path"
			If ($PSCmdlet.ShouldProcess($shouldText,'Proceed?',$shouldText))
			{
				Write-Verbose "$(ts)$indent[$callingFunction][$bk]$shouldText"
				If ($newPaths.Count)
				{
					$Powdrgit.Path = $newPaths -join ';'
				}
				Else
				{
					$Powdrgit.Path = $null
				}
			}

		}
		Catch
		{
			Throw
		}
	}

	END
	{
		$bk = 'E'

		# Function END:

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Debug "  $(ts)$indent[$callingFunction][$bk]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($($duration.ToString('d\d\ hh\:mm\:ss\.fff')))"
		$PowdrgitCallDepth--
	}
}
