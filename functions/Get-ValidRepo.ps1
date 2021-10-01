function Get-ValidRepo
{
	<#
	.SYNOPSIS
	Private function. Used to return a list of valid repos and generate necessary warnings.

	.DESCRIPTION
	Private function. Used to return a list of valid repos and generate necessary warnings.

	.PARAMETER Repo
	Repo parameter passed to Get-GitRepo

	.PARAMETER FunctionName
	Value to be displayed in the warning message.

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
		  Mandatory                       = $true
		, Position                        = 0
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $true
		)]
	#	[ArgumentCompleter()]
		[AllowEmptyString()]
		[AllowNull()]
		[Alias('RepoName','RepoPath')]
		[String[]]
		$Repo

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
		$warn             = $Powdrgit.ShowWarnings -and !($PSBoundParameters.ContainsKey('WarningAction') -and $PSBoundParameters.WarningAction -eq 'Ignore') # because -WarningAction:Ignore is not implemented correctly
		$callingFunction  = (Get-PSCallStack)[1].Command; If ($callingFunction -eq '<ScriptBlock>') { $callingFunction = $thisFunctionName }
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Start: $($start.ToString('yyyy-MM-dd HH:mm:ss.fff'))"

		# Function BEGIN:
	}

	PROCESS
	{
		$bk = 'P'

		Try
		{
			# Get the repository info
			$validRepos = @()
			$matchCounts = $null
			$validRepos += Get-GitRepo -Repo $Repo -InformationVariable matchInfo

			# Provide a user warning for unexpected behavior
			ForEach ($_repo in $Repo)
			{
				$matchCounts = $matchInfo | Where-Object Tags -eq 'f6c9c6f3-11e4-49d7-abff-5d26c0b37160' | Select-Object -ExpandProperty MessageData

				If ($Repo -and ![String]::IsNullOrWhiteSpace($_repo) -and [Math]::Abs($matchCounts.$_repo) -lt 1)
				{
					If ($warn) { Write-Warning "[$callingFunction]Repository '$_repo' not found. Check the repository directory exists and has been added to the `$Powdrgit.Path module variable." }
				}

				If ([Math]::Abs($matchCounts.$_repo) -gt 1)
				{
					If ($warn) { Write-Warning "[$callingFunction]Repo argument '$_repo' matched multiple repositories. Please confirm any results or actions are as expected." }
				}
			}

			# Return the repos
			$validRepos
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
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($($duration.ToString('d\d\ hh\:mm\:ss\.fff')))"
		$PowdrgitCallDepth--
	}
}
