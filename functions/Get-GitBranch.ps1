function Get-GitBranch
{
	<#
	.SYNOPSIS
	Gets a list of branches for the specified repository.

	.DESCRIPTION
	Gets a list of branches for the specified repository.
	By default, branches are returned in branch name (alphabetical) order, as they are with native git commands.

	.PARAMETER RepoName
	The name of the git repository to return.
	This should match the directory name of one of the repositories defined in $GitRepoPath. If there is no match, a warning is generated.
	When the parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.

	.PARAMETER Current
	Limits the results to the current branch of the specified repository; otherwise, all branch names will be returned.

	.PARAMETER CurrentFirst
	Forces the current branch to be the first returned item.
	All other branches will be returned in branch name (alphabetical) order.

	.PARAMETER IncludeRemote
	Includes remote branches in the output.

	.PARAMETER ExcludeLocal
	Excludes local branches from the output.

	.PARAMETER SetLocation
	Sets the working directory to the top-level directory of the specified repository.
	In the case where multiple RepoName values are passed in, the location will reflect the repository that was specified last.

	.EXAMPLE
	## Call from outside a repository without parameters ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitBranch

	# Nothing was returned because a RepoName was not provided.

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitBranch -RepoName NonExistentRepo
	WARNING: [Get-GitBranch]Repository 'NonExistentRepo' not found. Check the repository directory has been added to the $GitRepoPath variable.

	.EXAMPLE
	## Call from outside a repository with RepoName parameter ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitBranch -RepoName MyToolbox | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox feature1          False    False
	MyToolbox feature3          False    False
	MyToolbox main               True    False
	MyToolbox release           False    False

	# The branches were returned even though the command was issued from outside the repository directory.

	.EXAMPLE
	## Call from outside a repository with RepoName and SetLocation parameters ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitBranch -RepoName MyToolbox -SetLocation | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox feature1          False    False
	MyToolbox feature3          False    False
	MyToolbox main               True    False
	MyToolbox release           False    False

	PS C:\PowdrgitExamples\MyToolbox>

	# The branches were returned and the current location (reflected in the prompt) changed to the repository's top-level directory.

	.EXAMPLE
	## Call from outside a repository with RepoName and IncludeRemote parameters ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitBranch -RepoName MyToolbox -IncludeRemote | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox feature1          False    False
	MyToolbox feature3          False    False
	MyToolbox main               True    False
	MyToolbox release           False    False
	MyToolbox feature2          False     True

	# Remote branches were also included in the results. Note that remotes that are also the upstream of a local branch are omitted.

	.EXAMPLE
	## Call from outside a repository with RepoName, IncludeRemote and ExcludeLocal parameters ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitBranch -RepoName MyToolbox -IncludeRemote -ExcludeLocal | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox feature2          False     True

	# Only remote branches were included in the results. Note that remotes that are also the upstream of a local branch are omitted.

	.EXAMPLE
	## Call from outside a repository with RepoName and ExcludeLocal parameters ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitBranch -RepoName MyToolbox -ExcludeLocal
	PS C:\>

	# Use of the ExcludeLocal switch without the IncludeRemote switch returns no results because the function returns only local branches by default.

	.EXAMPLE
	## Call from outside a repository with RepoName and ExcludeLocal parameters ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
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

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -RepoName MyToolbox # move to the repository directory
	PS C:\PowdrgitExamples\MyToolbox> Get-GitBranch | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox feature1          False    False
	MyToolbox feature3          False    False
	MyToolbox main               True    False
	MyToolbox release           False    False

	.EXAMPLE
	## Call with -CurrentFirst switch ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -RepoName MyToolbox # move to the repository directory
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

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -RepoName MyToolbox # move to the repository directory
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

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -RepoName MyToolbox # move to the repository directory
	PS C:\PowdrgitExamples\MyToolbox> Get-GitBranch -Current | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox main               True    False

	# The Current switch caused only the checked out branch to be returned.

	.OUTPUTS
	[GitBranch]
	Returns a custom GitBranch object. For details use Get-Member at a command prompt e.g.:
	PS C:\PowdrgitExamples\MyToolbox> Get-GitBranch | Get-Member -MemberType Properties

	.NOTES
	Author : nmbell

	.LINK
	Get-GitRepo
	Set-GitBranch
	#>

    # Use cmdlet binding
	[CmdletBinding(DefaultParameterSetName = 'Remote')]

    # Declare parameters
    Param(

    	[Parameter(
    	  Mandatory                       = $false
    	, Position                        = 0
    	, ValueFromPipeline               = $true
    	, ValueFromPipelineByPropertyName = $true
		)]
		[ArgumentCompleter({
			Param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
			Get-GitRepo -Verbose:$false -WarningAction SilentlyContinue `
				| Select-Object -ExpandProperty RepoName `
				| Where-Object { $_ -like "$wordToComplete*" } `
				| Sort-Object
		})]
		[String]
		$RepoName

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
		[Parameter(ParameterSetName = 'CurrentLast')]
		[Parameter(ParameterSetName = 'Remote')]
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
		$wvBlock          = 'B'

		# Common BEGIN:
		Set-StrictMode -Version 2.0
		$thisFunctionName = $MyInvocation.InvocationName
		$start            = Get-Date
		$wvIndent         = '|  '*($PowdrgitCallDepth++)
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Start: $($start.ToString('yyyy-MM-dd HH:mm:ss.fff'))"

		# Function BEGIN:
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finding current location"
		Push-Location -StackName GetGitBranch

		# Initialize variable for output
		$branches = @()
	}

	PROCESS
	{
		$wvBlock = 'P'

		# Find the repository name from current location
		If (!$RepoName) { $RepoName = Get-GitRepo -Current | Select-Object -ExpandProperty RepoName }

		# Get the repository info
		$repo = Set-GitRepo -RepoName $RepoName -PassThru -WarningAction SilentlyContinue

		# Get the branches
		If ($repo)
		{
			# Get local branch info
			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finding local branch info"
			$gitCommand = 'git for-each-ref "refs/heads" --format="%(objectname)|%(refname)|%(HEAD)|%(upstream)"'
			$gitResults = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream
			ForEach ($line in $gitResults | Where-Object { $_.Trim() })
			{
				$lineSplit = $line.Split('|')

				$branchFullName =   $lineSplit[1]
				$isCheckedOut     = $lineSplit[2] -eq '*'
				$upstreamFullName = $lineSplit[3]
				$branchName       = Split-Path -Path $branchFullName -Leaf
				$upstreamName     = $upstreamFullName.Replace('refs/remotes/','')

				$branches += [GitBranch]@{
					'RepoName'         = $repo.RepoName
					'SHA1Hash'         = $lineSplit[0]
					'BranchName'       = $branchName
					'IsCheckedOut'     = $isCheckedOut
					'IsRemote'         = $false
					'Upstream'         = $upstreamName
					'BranchFullName'   = $branchFullName
					'UpstreamFullName' = $upstreamFullName
				}
			}

			# Get remote branch info
			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finding remote branch info"
			$gitCommand = 'git for-each-ref "refs/remotes" --format="%(objectname)|%(refname)"'
			$gitResults = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream
			ForEach ($line in $gitResults | Where-Object { $_.Trim() })
			{
				$lineSplit = $line.Split('|')

				$branchFullName = $lineSplit[1]
				$branchName     = Split-Path -Path $branchFullName -Leaf

				If ($branches.Count -gt 0 -and $branchFullName -in $branches.UpstreamFullName) { Continue } # omit remote branches that are the upstream for a local one
				If ($branchName -eq 'HEAD') { Continue }                                                    # omit HEAD

				$branches += [GitBranch]@{
					'RepoName'         = $repo.RepoName
					'SHA1Hash'         = $lineSplit[0]
					'BranchName'       = $branchName
					'IsCheckedOut'     = $false
					'IsRemote'         = $true
					'Upstream'         = $null
					'BranchFullName'   = $branchFullName
					'UpstreamFullName' = $null
				}
			}
		}
		ElseIf ($RepoName)
		{
			Write-Warning "[$thisFunctionName]Repository '$RepoName' not found. Check the repository directory has been added to the `$GitRepoPath variable."
		}
    }

	END
	{
		$wvBlock = 'E'

		# Set sort order
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Setting sort order"
		$sortRepoName          = @{ Expression = 'RepoName'    ; Ascending  = $true }
		$sortBranchName        = @{ Expression = 'BranchName'  ; Ascending  = $true }
		$sortIsCheckedOutFirst = @{ Expression = 'IsCheckedOut'; Descending = $true }
		$sortIsCheckedOutLast  = @{ Expression = 'IsCheckedOut'; Ascending  = $true }
		$sortIsRemote          = @{ Expression = 'IsRemote'    ; Ascending  = $true }
		$sortProperty = @()
		$sortProperty += $sortRepoName
		If ($CurrentFirst) { $sortProperty += $sortIsCheckedOutFirst }
		If ($CurrentLast ) { $sortProperty += $sortIsCheckedOutLast  }
		$sortProperty += $sortIsRemote
		$sortProperty += $sortBranchName

		# Output
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Outputting branches: $(($branches | Measure-Object).Count)"
		Write-Output $branches `
			| Where-Object { ($Current -and $_.IsCheckedOut) -or !$Current } `
			| Where-Object { ($IncludeRemote -and $_.IsRemote) -or (!$ExcludeLocal -and !$_.IsRemote) } `
			| Sort-Object -Property $sortProperty

		# Function END:
		If (!$SetLocation)
		{
			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Setting location to original directory"
			Pop-Location -StackName GetGitBranch
		}

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($('{0}d {1:00}:{2:00}:{3:00}.{4:000}' -f $duration.Days,$duration.Hours,$duration.Minutes,$duration.Seconds,$duration.Milliseconds))"
		$PowdrgitCallDepth--
	}
}
