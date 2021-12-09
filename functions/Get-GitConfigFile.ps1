function Get-GitConfigFile
{
	<#
	.SYNOPSIS
	Gets the config file for the given repository or scope.

	.DESCRIPTION
	Gets the config file for the given repository or scope.
	The Path property of the results shows the expected path of the config file.
	The FileInfo property of the results holds the file object of the config file, which may be null if the config file doesn't exist.

	.PARAMETER Repo
	The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
	If the Repo parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.
	For examples of using the Repo parameter, refer to the help text for Get-GitRepo.

	.PARAMETER Local
	Returns the repository config file when inside a repository.

	.PARAMETER Global
	Returns the global (user) config file.

	.PARAMETER System
	Returns the system config file.

	.PARAMETER Portable
	Returns the portable config file.

	.PARAMETER Worktree
	Returns the repository worktree config file when inside a repository.
	Note: When no switch parameters are specified, the worktree config file will only be returned as part of the results if it exists.

	.EXAMPLE
	## Call from outside a repository without parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitConfigFile | Format-Table -Property Scope,Path

	Scope    Path
	-----    ----
	System   C:\Program Files\Git\etc\gitconfig
	Global   C:\Users\nmbell\.gitconfig
	Portable C:\ProgramData\Git\config

	# When no scope switches are specified, the config files for all relevant scopes are returned.

	.EXAMPLE
	## Get only the system config file ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitConfigFile -System | Format-Table -Property Scope,Path

	Scope     Path
	-----     ----
	System    C:\Program Files\Git\etc\gitconfig

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Get-GitConfigFile -Repo NonExistentRepo -Local
	WARNING: [Get-GitConfigFile]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.

	.EXAMPLE
	## Call from outside a repository with Repo parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitConfigFile -Repo MyToolbox | Format-Table -Property Scope,Path

	Scope     Path
	-----     ----
	MyToolbox C:\PowdrgitExamples\MyToolbox\.git\config
	System    C:\Program Files\Git\etc\gitconfig
	Global    C:\Users\nmbell\.gitconfig
	Portable  C:\ProgramData\Git\config

	# When no scope switches are specified, the config files for all relevant scopes are returned.

	.EXAMPLE
	## Call from inside a repository without parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitConfigFile | Format-Table -Property Scope,Path

	Scope     Path
	-----     ----
	MyToolbox C:\PowdrgitExamples\MyToolbox\.git\config
	System    C:\Program Files\Git\etc\gitconfig
	Global    C:\Users\nmbell\.gitconfig
	Portable  C:\ProgramData\Git\config

	# When no scope switches are specified, the config files for all relevant scopes are returned.

	.EXAMPLE
	## See the worktree config file, if it exists ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitConfigFile -Worktree | Format-Table -Property Scope,FileInfo,Exists,Path

	Scope                FileInfo Exists Path
	-----                -------- ------ ----
	MyToolbox (worktree)           False D:\Users\mixol\Documents\_Documents\xWork\6 APX\_DBA\.git\config.worktree

	.EXAMPLE
	## Pipe results from Get-GitRepo ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo | Get-GitConfigFile | Format-Table -Property Scope,Path

	Scope     Path
	-----     ----
	MyToolbox C:\PowdrgitExamples\MyToolbox\.git\config
	Project1  C:\PowdrgitExamples\Project1\.git\config
	System    C:\Program Files\Git\etc\gitconfig
	Global    C:\Users\nmbell\.gitconfig
	Portable  C:\ProgramData\Git\config

	# System, Global, and Portable config files are returned only once per call.

	.INPUTS
	[System.String[]]
	Accepts string objects via the Repo parameter. The output of Get-GitRepo can be piped into Get-GitConfigFile.

	.OUTPUTS
	[GitConfigFile]
	Returns a custom GitConfigFile object. For details use Get-Member at a command prompt e.g.:
	PS C:\PowdrgitExamples\MyToolbox> Get-GitConfigFile | Get-Member -MemberType Properties

	.NOTES
	Author : nmbell

	.LINK
	Get-GitRepo
	.LINK
	about_powdrgit
	.LINK
	https://github.com/nmbell/powdrgit/blob/main/help/about_powdrgit.md
	#>

	# Function alias
	[Alias('ggcfg')]

	# Use cmdlet binding
	[CmdletBinding(
	  HelpURI = 'https://github.com/nmbell/powdrgit/blob/main/help/Get-GitConfigFile.md'
	)]

	# Declare output type
	[OutputType('GitConfigFile')]

	# Declare parameters
	Param(

		[Parameter(
		  Mandatory                       = $false
		, Position                        = 0
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		)]
	#	[ArgumentCompleter()]
		[Alias('RepoName','RepoPath')]
		[String[]]
		$Repo

	,	[Switch]
		$Local

	,	[Switch]
		$System

	,	[Switch]
		$Global

	,	[Switch]
		$Portable

	,	[Switch]
		$Worktree

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
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finding current location"
		$startLocation = $PWD.Path

		# git config --list --show-origin
	}

	PROCESS
	{
		$bk = 'P'

		# Setting no switches is the same as setting all of them
		$all = !($Local -or $Global -or $System -or $Worktree -or $Portable)

		If ($Local -or $Worktree -or $all)
		{
			# Find the repository name from current location
			If (!$PSBoundParameters.ContainsKey('Repo')) { $Repo = Get-GitRepo -Current | Select-Object -ExpandProperty RepoPath }

			# Get the repository info
			$validRepos = Get-ValidRepo -Repo $Repo

			# Get the config files
			ForEach ($validRepo in $validRepos)
			{
				# Go to the repository and get the repository info
				Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Moving to the repository directory: $($validRepo.RepoPath)"
				Set-GitRepo -Repo $validRepo.RepoPath -Verbose:$false -WarningAction Ignore

				# Local
				If ($Local -or $all)
				{
					Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finding local config file for $($validRepo.RepoName)"
					$repoConfigFilePathLocal = $($validRepo.RepoPath)+('\.git'*!$validRepo.IsBare)+'\config'
					[System.IO.FileInfo]$repoConfigFileLocal = Get-Item -Path $repoConfigFilePathLocal -ErrorAction Ignore
					If ($repoConfigFilePathLocal)
					{
						[GitConfigFile]@{
							'Scope'    = $validRepo.RepoName
							'Path'     = $repoConfigFilePathLocal
							'Exists'   = [Bool]$repoConfigFileLocal.Exists
							'FileInfo' = $repoConfigFileLocal
						}
					}
				}

				# Worktree - only return in 'all' set if it exists
				$repoConfigFilePathWorktree = $($validRepo.RepoPath)+('\.git'*!$validRepo.IsBare)+'\config.worktree'
				[System.IO.FileInfo]$repoConfigFileWorktree = Get-Item -Path $repoConfigFilePathWorktree -ErrorAction Ignore
				If ($Worktree -or ($all -and [Bool]$repoConfigFileWorktree))
				{
					Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finding worktree config file for $($validRepo.RepoName)"
					If ($repoConfigFilePathWorktree)
					{
						[GitConfigFile]@{
							'Scope'    = "$($validRepo.RepoName) (worktree)"
							'Path'     = $repoConfigFilePathWorktree
							'Exists'   = [Bool]$repoConfigFileWorktree
							'FileInfo' = $repoConfigFileWorktree
						}
					}
				}
			}
		}
	}

	END
	{
		$bk = 'E'

		# Function END:
		# System
		If ($System -or $all)
		{
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finding system config file"
			$systemConfigFilePath = "$Env:ProgramFiles\Git\etc\gitconfig"
			[System.IO.FileInfo]$systemConfigFile = Get-Item -Path $systemConfigFilePath -ErrorAction Ignore
			If ($systemConfigFilePath)
			{
				[GitConfigFile]@{
					'Scope'    = 'System'
					'Path'     = $systemConfigFilePath
					'Exists'   = [Bool]$systemConfigFile
					'FileInfo' = $systemConfigFile
				}
			}
		}

		# Global
		If ($Global -or $all)
		{
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finding global config file"
			$globalConfigFilePath = "$Env:USERPROFILE\.gitconfig"
			[System.IO.FileInfo]$globalConfigFile = Get-Item -Path $globalConfigFilePath -ErrorAction Ignore
			If ($globalConfigFilePath)
			{
				[GitConfigFile]@{
					'Scope'    = 'Global'
					'Path'     = $globalConfigFilePath
					'Exists'   = [Bool]$globalConfigFile
					'FileInfo' = $globalConfigFile
				}
			}
		}

		# Portable
		If ($Portable -or $all)
		{
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finding portable config file"
			$portableConfigFilePath = "$Env:ProgramData\Git\config"
			[System.IO.FileInfo]$portableConfigFile = Get-Item -Path $portableConfigFilePath -ErrorAction Ignore
			If ($portableConfigFilePath)
			{
				[GitConfigFile]@{
					'Scope'    = 'Portable'
					'Path'     = $portableConfigFilePath
					'Exists'   = [Bool]$portableConfigFile
					'FileInfo' = $portableConfigFile
				}
			}
		}

		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Setting location to original directory"
		Set-Location -Path $startLocation

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($($duration.ToString('d\d\ hh\:mm\:ss\.fff')))"
		$PowdrgitCallDepth--
	}
}
