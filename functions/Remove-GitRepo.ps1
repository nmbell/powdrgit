function Remove-GitRepo
{
	<#
	.SYNOPSIS
	Removes a git repository.

	.DESCRIPTION
	Removes a git repository.
	The function can remove either the repository directory and all of its files and subdirectories, or just the .git directory.
	Optionally, the path can be removed from the $Powdrgit.Path module variable.

	.PARAMETER Repo
	The name, or a relative or absolute path, to the git repository to remove.

	.PARAMETER RemoveGitFilesOnly
	When applied to a regular (not bare) repository, removes only the .git directory, leaving the working files intact.
	Note: Bare repositories will always have the repository directory and all of its files and subdirectories removed.

	.PARAMETER RemovePowdrgitPath
	Removes the path of the deleted repository from the $Powdrgit.Path module variable.

	.EXAMPLE
	## Call with no parameters ##

	PS C:\> Remove-GitRepo
	PS C:\>

	# When called without any parameters, nothing happens.

	.EXAMPLE
	## Call for non-existent repository ##

	PS C:\> $repoDir = 'C:\NonExistentRepo'
	PS C:\> $Powdrgit.Path = $repoDir
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Remove-GitRepo -Repo $repoDir -Confirm:$false
	WARNING: [Remove-GitRepo]Repository 'C:\NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.

	.EXAMPLE
	## Call from outside a repository ##

	PS C:\> $repoDir = 'C:\RemoveMe'
	PS C:\> $r = New-GitRepo -Repo $repoDir -AppendPowdrgitPath # first create a repo
	PS C:\> Test-Path -Path $repoDir
	True
	PS C:\> Remove-GitRepo -Repo $repoDir -Confirm:$false
	PS C:\> Test-Path -Path $repoDir
	False

	.EXAMPLE
	## Call from inside a repository ##

	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> $repoDir = 'C:\RemoveMe'
	PS C:\> $r = New-GitRepo -Repo $repoDir -AppendPowdrgitPath # first create a repo
	PS C:\> Test-Path -Path $repoDir
	True
	PS C:\> Set-Location -Path $repoDir
	PS C:\RemoveMe> Remove-GitRepo -Repo $repoDir -Confirm:$false
	WARNING: [Remove-GitRepo]Location was changed from inside a repository that was removed. Please check the current location.
	PS C:\> Test-Path -Path $repoDir
	False

	# When calling from inside a repository, the location changes to the parent of the repository.

	.EXAMPLE
	## Call matching multiple repos ##

	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> $repoDirs = 'C:\RemoveMe1','C:\RemoveMe2'
	PS C:\> $r = New-GitRepo -Repo $repoDirs -AppendPowdrgitPath # first create the repos
	PS C:\> Test-Path -Path $repoDirs
	True
	True
	PS C:\> Remove-GitRepo -Repo 'C:\RemoveMe' -Confirm:$false
	WARNING: [Remove-GitRepo]Repo argument 'C:\RemoveMe' matched multiple repositories. Please confirm any results or actions are as expected.
	PS C:\> Test-Path -Path $repoDirs
	False
	False

	.EXAMPLE
	## Call with RemovePowdrgitPath ##

	PS C:\> $repoDir = 'C:\RemoveMe'
	PS C:\> $Powdrgit.Path = $null
	PS C:\> $r = New-GitRepo -Repo $repoDir -AppendPowdrgitPath # first create a repo
	PS C:\> Test-Path -Path $repoDir
	True
	PS C:\> $Powdrgit.Path
	C:\RemoveMe
	PS C:\> Remove-GitRepo -Repo $repoDir -RemovePowdrgitPath -Confirm:$false
	PS C:\> Test-Path -Path $repoDir
	False
	PS C:\> $Powdrgit.Path
	PS C:\>

	.EXAMPLE
	## Call with RemoveGitFilesOnly ##

	PS C:\> $repoDir = 'C:\KeepMe'
	PS C:\> $r = New-GitRepo -Repo $repoDir -AppendPowdrgitPath # first create a repo
	PS C:\> $f = New-Item -Path "$repoDir\SomeFile.txt" -ItemType File -Value 'Some text.' # create a file in the repo
	PS C:\> Test-Path -Path $repoDir
	True
	PS C:\> Test-Path -Path "$repoDir\.git"
	True
	PS C:\> Test-Path -Path $f.FullName
	True
	PS C:\> Remove-GitRepo -Repo $repoDir -RemoveGitFilesOnly -Confirm:$false
	PS C:\> Test-Path -Path $repoDir
	True
	PS C:\> Test-Path -Path "$repoDir\.git"
	False
	PS C:\> Test-Path -Path "$repoDir\SomeFile.txt"
	True

	.EXAMPLE
	## Pipe from Get-GitRepo ##

	PS C:\> $repoDir = 'C:\RemoveMe'
	PS C:\> $r = New-GitRepo -Repo $repoDir -AppendPowdrgitPath # first create a repo
	PS C:\> Test-Path -Path $repoDir
	True
	PS C:\> Get-GitRepo -Repo $repoDir | Remove-GitRepo -Confirm:$false
	PS C:\> Test-Path -Path $repoDir
	False

	.INPUTS
	[System.String[]]
	Accepts string objects via the Repo parameter.

	.OUTPUTS
	[System.Void]
	The function does not return anything.

	.NOTES
	Author : nmbell

	.LINK
	Find-GitRepo
	.LINK
	Get-GitRepo
	.LINK
	Set-GitRepo
	.LINK
	New-GitRepo
	.LINK
	Invoke-GitClone
	.LINK
	Add-PowdrgitPath
	.LINK
	Remove-PowdrgitPath
	.LINK
	Test-PowdrgitPath
	.LINK
	about_powdrgit
	.LINK
	https://github.com/nmbell/powdrgit/blob/main/help/about_powdrgit.md
	#>

	# Function alias
	[Alias('rgr')]

	# Use cmdlet binding
	[CmdletBinding(
	  SupportsShouldProcess	= $true
	, ConfirmImpact         = 'High'
	, HelpURI               = 'https://github.com/nmbell/powdrgit/blob/main/help/Remove-GitRepo.md'
	)]

	# Declare output type
	[OutputType([System.Void])]

	# Declare parameters
	Param(

	 	[Parameter(
		  Mandatory                       = $false
		, Position                        = 0
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		)]
		[Alias('FullName','Path','RepoName','RepoPath')]
		[ValidateNotNullOrEmpty()]
		[String[]]
		$Repo

	,	[Switch]
		$RemoveGitFilesOnly

	,	[Switch]
		$RemovePowdrgitPath

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
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Start: $($start.ToString('yyyy-MM-dd HH:mm:ss.fff'))"

		# Function BEGIN:
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Storing current location"
		$startLocation = $PWD.Path
	}

	PROCESS
	{
		$bk = 'P'

		# Get the repository info
		$validRepos = Get-ValidRepo -Repo $Repo

		# Remove repo
		ForEach ($validRepo in $validRepos)
		{
			# Determine path to remove
			$removePath = $($validRepo.RepoPath)
			If ($RemoveGitFilesOnly -and !$validRepo.IsBare) { $removePath += '\.git' }

			# Determine procession
			$shouldText = If ($RemoveGitFilesOnly) { 'git files' } Else { 'repository' }
			$shouldText = "Removing $shouldText`: $removePath"
			If ($WhatIfPreference) { Write-Host }
			$shouldProcess = $PSCmdlet.ShouldProcess($shouldText,$null,$null)

			# If ($WhatIfPreference) { Write-Host "What if: $shouldText" } # handled by ShouldProcess
			If ($shouldProcess)
			{
				# Make sure we move to a parent directory
				While (Test-SubPath -Parent $validRepo.RepoPath -ChildPath $PWD.Path)
				{
					Set-Location -Path (Split-Path -Path $PWD.Path -Parent)
				}
				If ($PWD.Path -ne $startLocation)
				{
					If ($warn) { Write-Warning "[$thisFunctionName]Location was changed from inside a repository that was removed. Please check the current location." }
				}

				# Remove the repo
				Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]$shouldText"
				Remove-Item -Path $removePath -Recurse -Force -Verbose:$false -WhatIf:$false -Confirm:$false
			}

			# Remove from $Powdrgit.Path
			If ($RemovePowdrgitPath)
			{
				$shouldText = 'Removing path from `$Powdrgit.Path'
				If ($WhatIfPreference) { Write-Host "What if: $shouldText" }
				If ($shouldProcess)
				{
					Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]$shouldText"
					Remove-PowdrgitPath -Path $validRepo.RepoPath -WhatIf:$false -Confirm:$false
				}
			}

		}


	}

	END
	{
		$bk = 'E'

		# Function END:
		If ($WhatIfPreference) { Write-Host }

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($($duration.ToString('d\d\ hh\:mm\:ss\.fff')))"
		$PowdrgitCallDepth--
	}
}
