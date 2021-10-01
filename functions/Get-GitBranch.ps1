function Get-GitBranch
{
	<#
	.SYNOPSIS
	Gets a list of branches for the specified repository.

	.DESCRIPTION
	Gets a list of branches for the specified repository.
	By default, branches are returned in branch name (alphabetical) order, as they are with native git commands.

	.PARAMETER Repo
	The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
	If the Repo parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.
	For examples of using the Repo parameter, refer to the help text for Get-GitRepo.

	.PARAMETER BranchName
	The names of the branches to be checked out.
	Wildcard characters are allowed. The pattern will match against existing branches in the specified repository.
	A warning will be generated for any values that do not match the name of an existing branch.

	.PARAMETER Current
	Limits the results to the current branch of the specified repository; otherwise, all matching branch names will be returned.

	.PARAMETER CurrentFirst
	Forces the current branch to be the first returned item.
	All other branches will be returned in branch name (alphabetical) order.

	.PARAMETER CurrentLast
	Forces the current branch to be the last returned item.
	All other branches will be returned in branch name (alphabetical) order.

	.PARAMETER IncludeRemote
	Includes remote branches in the output.

	.PARAMETER ExcludeLocal
	Excludes local branches from the output.

	.PARAMETER SetLocation
	Sets the working directory to the top-level directory of the specified repository.
	In the case where multiple Repo values are passed in, the location will reflect the repository that was specified last.

	.EXAMPLE
	## Call from outside a repository without parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitBranch

	# Nothing was returned because a Repo was not provided.

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Get-GitBranch -Repo NonExistentRepo
	WARNING: [Get-GitBranch]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.

	.EXAMPLE
	## Call from outside a repository with Repo parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitBranch -Repo MyToolbox | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox feature1          False    False
	MyToolbox feature3          False    False
	MyToolbox main               True    False
	MyToolbox release           False    False

	# The branches were returned even though the command was issued from outside the repository directory.

	.EXAMPLE
	## Call from outside a repository with Repo and SetLocation parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitBranch -Repo MyToolbox -SetLocation | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox feature1          False    False
	MyToolbox feature3          False    False
	MyToolbox main               True    False
	MyToolbox release           False    False

	PS C:\PowdrgitExamples\MyToolbox>

	# The branches were returned and the current location (reflected in the prompt) changed to the repository's top-level directory.

	.EXAMPLE
	## Call from outside a repository with Repo and IncludeRemote parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitBranch -Repo MyToolbox -IncludeRemote | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox feature1          False    False
	MyToolbox feature3          False    False
	MyToolbox main               True    False
	MyToolbox release           False    False
	MyToolbox feature2          False     True

	# Remote branches were also included in the results. Note that remotes that are also the upstream of a local branch are omitted.

	.EXAMPLE
	## Call from outside a repository with Repo, IncludeRemote and ExcludeLocal parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitBranch -Repo MyToolbox -IncludeRemote -ExcludeLocal | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox feature2          False     True

	# Only remote branches were included in the results. Note that remotes that are also the upstream of a local branch are omitted.

	.EXAMPLE
	## Call from outside a repository with Repo and ExcludeLocal parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitBranch -Repo MyToolbox -ExcludeLocal
	PS C:\>

	# Use of the ExcludeLocal switch without the IncludeRemote switch returns no results because the function returns only local branches by default.

	.EXAMPLE
	## Call from outside a repository with Repo and ExcludeLocal parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo | Get-GitBranch | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox feature1          False    False
	MyToolbox feature3          False    False
	MyToolbox main               True    False
	MyToolbox release           False    False
	Project1  main              False    False
	Project1  newfeature         True    False

	# By piping the results of Get-GitRepo into Get-GitBranch we can get a list of branches for multiple repositories in a single command.

	.EXAMPLE
	## Get all local branches of the current repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -Repo MyToolbox # move to the repository directory
	PS C:\PowdrgitExamples\MyToolbox> Get-GitBranch | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox feature1          False    False
	MyToolbox feature3          False    False
	MyToolbox main               True    False
	MyToolbox release           False    False

	.EXAMPLE
	## Call with -CurrentFirst switch ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -Repo MyToolbox # move to the repository directory
	PS C:\PowdrgitExamples\MyToolbox> Get-GitBranch -CurrentFirst | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox main               True    False
	MyToolbox feature1          False    False
	MyToolbox feature3          False    False
	MyToolbox release           False    False

	# The CurrentFirst switch caused the checked out branch to be returned in the first position.
	# This may be useful when piping to Set-GitBranch so that the script block is applied to the current branch before checking out another.

	.EXAMPLE
	## Call with -CurrentLast switch ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -Repo MyToolbox # move to the repository directory
	PS C:\PowdrgitExamples\MyToolbox> Get-GitBranch -CurrentLast | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox feature1          False    False
	MyToolbox feature3          False    False
	MyToolbox release           False    False
	MyToolbox main               True    False

	# The CurrentLast switch caused the checked out branch to be returned in the last position.
	# This may be useful when piping to Set-GitBranch so that when the prompt returns, the same branch is checked out as when the command was executed.

	.EXAMPLE
	## Call with -Current switch ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -Repo MyToolbox # move to the repository directory
	PS C:\PowdrgitExamples\MyToolbox> Get-GitBranch -Current | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox main               True    False

	# The Current switch caused only the checked out branch to be returned.

	.EXAMPLE
	## Call with Repo value matching multiple repositories ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Get-GitBranch -Repo PowdrgitExamples -BranchName *feature* | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote,RepoPath
	WARNING: [Get-GitBranch]Repo argument 'PowdrgitExamples' matched multiple repositories. Please confirm any results or actions are as expected.

	RepoName  BranchName IsCheckedOut IsRemote RepoPath
	--------  ---------- ------------ -------- --------
	MyToolbox feature1          False    False C:\PowdrgitExamples\MyToolbox
	MyToolbox feature3          False    False C:\PowdrgitExamples\MyToolbox
	Project1  newfeature         True    False C:\PowdrgitExamples\Project1

	.INPUTS
	[System.String]
	Accepts string objects via the Repo parameter. The output of Get-GitRepo can be piped into Get-GitBranch.

	.OUTPUTS
	[GitBranch]
	Returns a custom GitBranch object. For details use Get-Member at a command prompt e.g.:
	PS C:\PowdrgitExamples\MyToolbox> Get-GitBranch | Get-Member -MemberType Properties

	.NOTES
	Author : nmbell

	.LINK
	Set-GitBranch
	.LINK
	Get-GitRepo
	.LINK
	Get-GitLog
	.LINK
	Get-GitTag
	.LINK
	about_powdrgit
	#>

	# Function alias
	[Alias('ggb')]

	# Use cmdlet binding
	[CmdletBinding(
	  DefaultParameterSetName = 'Remote'
	, HelpURI                 = 'https://github.com/nmbell/powdrgit/blob/main/help/Get-GitBranch.md'
	)]

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

	,	[Parameter(
		  Mandatory                       = $false
		, Position                        = 1
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		)]
	#	[ArgumentCompleter()]
		[String[]]
		$BranchName = '*'

	,	[Parameter(ParameterSetName = 'Current')]
		[Switch]
		$Current

	,	[Parameter(ParameterSetName = 'CurrentFirst')]
		[Switch]
		$CurrentFirst

	,	[Parameter(ParameterSetName = 'CurrentLast')]
		[Switch]
		$CurrentLast

	,	[Parameter(ParameterSetName = 'CurrentFirst')]
		[Parameter(ParameterSetName = 'CurrentLast' )]
		[Parameter(ParameterSetName = 'Remote'      )]
		[Switch]
		$IncludeRemote

	,	[Parameter(ParameterSetName = 'Remote')]
		[Switch]
		$ExcludeLocal

	,	[Switch]
		$SetLocation

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
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finding current location"
		$startLocation = $PWD.Path

		# Initialize variables
		$matchingBranchesTotal = 0
		$sortRepoName          = @{ Expression = 'RepoName'    ; Ascending  = $true }
		$sortBranchName        = @{ Expression = 'BranchName'  ; Ascending  = $true }
		$sortIsCheckedOutFirst = @{ Expression = 'IsCheckedOut'; Descending = $true }
		$sortIsCheckedOutLast  = @{ Expression = 'IsCheckedOut'; Ascending  = $true }
		$sortIsRemote          = @{ Expression = 'IsRemote'    ; Ascending  = $true }
	}

	PROCESS
	{
		$bk = 'P'

		# Find the repository path from current location if necessary
		If (!$PSBoundParameters.ContainsKey('Repo')) { $Repo = Get-GitRepo -Current | Select-Object -ExpandProperty RepoPath }

		# Get the repository info
		$validRepos = Get-ValidRepo -Repo $Repo

		# Get the branches
		$matchingBranches = @()
		ForEach ($validRepo in $validRepos)
		{
 			# Keep track of which BranchName patterns don't match any branches
			$unmatchedBranchNames = @{}
			ForEach ($_branchName in $BranchName) { $unmatchedBranchNames.$_branchName = $null }

			# Move to the repository directory
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Moving to the repository directory: $($validRepo.RepoPath)"
			Set-GitRepo -Repo $validRepo.RepoPath -WarningAction Ignore

			# Get local branch info
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finding local branch info"
			$gitCommand = 'git for-each-ref "refs/heads" --format="%(objectname)|%(refname)|%(HEAD)|%(upstream)"'
			$gitResults = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream
			Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Found local  branches: $('{0,3}' -f ($gitResults | Measure-Object).Count)"
			ForEach ($line in $gitResults | Where-Object { $_.Trim() })
			{
				$lineSplit = $line.Split('|')

				$branchFullName   = $lineSplit[1]
				$isCheckedOut     = $lineSplit[2] -eq '*'
				$upstreamFullName = $lineSplit[3]
				$thisBranchName   = Split-Path -Path $branchFullName -Leaf
				$upstreamName     = $upstreamFullName.Replace('refs/remotes/','')

				ForEach ($_branchName in $BranchName)
				{
					If ($thisBranchName -like $_branchName)
					{
						$matchingBranches += [GitBranch]@{
							'RepoName'         = $validRepo.RepoName
							'RepoPath'         = $validRepo.RepoPath
							'SHA1Hash'         = $lineSplit[0]
							'BranchName'       = $thisBranchName
							'IsCheckedOut'     = $isCheckedOut
							'IsRemote'         = $false
							'Upstream'         = $upstreamName
							'BranchFullName'   = $branchFullName
							'UpstreamFullName' = $upstreamFullName
						}
						$unmatchedBranchNames.Remove($_branchName)
					}
				}
			}

			# Get remote branch info
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finding remote branch info"
			$gitCommand = 'git for-each-ref "refs/remotes" --format="%(objectname)|%(refname)"'
			$gitResults = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream
			Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Found remote branches: $('{0,3}' -f ($gitResults | Measure-Object).Count)"
			ForEach ($line in $gitResults | Where-Object { $_.Trim() })
			{
				$lineSplit = $line.Split('|')

				$branchFullName = $lineSplit[1]
				$thisBranchName = Split-Path -Path $branchFullName -Leaf

				If ($matchingBranches.Count -gt 0 -and $branchFullName -in $matchingBranches.UpstreamFullName) { Continue } # omit remote branches that are the upstream for a local one
				If ($thisBranchName -eq 'HEAD') { Continue }                                                                # omit HEAD

				ForEach ($_branchName in $BranchName)
				{
					If ($thisBranchName -like $_branchName)
					{
						$matchingBranches += [GitBranch]@{
							'RepoName'         = $validRepo.RepoName
							'RepoPath'         = $validRepo.RepoPath
							'SHA1Hash'         = $lineSplit[0]
							'BranchName'       = $thisBranchName
							'IsCheckedOut'     = $false
							'IsRemote'         = $true
							'Upstream'         = $null
							'BranchFullName'   = $branchFullName
							'UpstreamFullName' = $null
						}
						$unmatchedBranchNames.Remove($_branchName)
					}
				}
			}

			# Warn if any BranchName values didn't match a branch
			If ($unmatchedBranchNames.Count)
			{
				If ($warn) { Write-Warning "[$thisFunctionName]The following BranchName patterns did not match any branches in the '$($validRepo.RepoName)' repository: '$($unmatchedBranchNames.Keys -join "','")'" }
			}
		}
		$matchingBranchesTotal += $matchingBranches.Count

		# Set sort order
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Setting sort order"
		$sortProperty = @()
		$sortProperty += $sortRepoName
		If ($CurrentFirst) { $sortProperty += $sortIsCheckedOutFirst }
		If ($CurrentLast ) { $sortProperty += $sortIsCheckedOutLast  }
		$sortProperty += $sortIsRemote
		$sortProperty += $sortBranchName

		# Output
		Write-Debug "$(ts)$indent[$thisFunctionName][$bk]Outputting branches  : $('{0,3}' -f $matchingBranches.Count)"
		Write-Output $matchingBranches `
		| Where-Object { ($Current -and $_.IsCheckedOut) -or !$Current } `
		| Where-Object { ($IncludeRemote -and $_.IsRemote) -or (!$ExcludeLocal -and !$_.IsRemote) } `
		| Sort-Object -Property $sortProperty
	}

	END
	{
		$bk = 'E'

		# Function END:
		Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Output branches total: $('{0,3}' -f $matchingBranchesTotal)"
		If (!$SetLocation)
		{
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Setting location to original directory"
			Set-Location -Path $startLocation
		}

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($($duration.ToString('d\d\ hh\:mm\:ss\.fff')))"
		$PowdrgitCallDepth--
	}
}
