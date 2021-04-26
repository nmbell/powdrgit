function Get-GitLog
{
	<#
	.SYNOPSIS
	Gets a list of commits from the git log.

	.DESCRIPTION
	Gets a list of commits from the git log.

	.PARAMETER RepoName
	The name of the git repository to return.
	This should match the directory name of one of the repositories defined in the $GitRepoPath module variable. If there is no match, a warning is generated.
	When the parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.

	.PARAMETER InRef
	A list of repository references (i.e. branch names, tag names, or commit SHA1 hashes).
	Commits reachable from any of these references are included in the results. If ommitted, defaults to HEAD.
	See https://git-scm.com/docs/git-log#_description.

	.PARAMETER NotInRef
	A list of repository references (i.e. branch names, tag names, or commit SHA1 hashes).
	Commits reachable from any of these references are excluded from the results. If ommitted, defaults to HEAD.
	See https://git-scm.com/docs/git-log#_description.

	.PARAMETER RefRange
	A revision range used to limit the commits returned, given in native git format e.g. "branch1...branch2".
	See https://git-scm.com/docs/gitrevisions.

	.PARAMETER Count
	Specifies the number of commits to retrieve. Commits are retrieved in reverse order, so specifying a Count of 5 will return the last 5 commits.

	.PARAMETER NoMerges
	Excludes merge commits (commits with more than one parent) from the results.

	.EXAMPLE
	## Call from outside a repository without parameters ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitLog

	# Nothing was returned because a RepoName was not provided.

	.EXAMPLE
	## Call from outside a repository with RepoName parameter ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main # checkout the main branch from the current location
	PS C:\> Get-GitLog -RepoName MyToolbox | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0 nmbell     Merging from feature1
	MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64 nmbell     Add feature1_File1.txt
	MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit
	MyToolbox 87b1320518c17702d30e463966bc070ce6481459 nmbell     Initial commit

	# The commits were returned even though the command was issued from outside the repository directory.

	.EXAMPLE
	## Get commits from the current repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0 nmbell     Merging from feature1
	MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64 nmbell     Add feature1_File1.txt
	MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit
	MyToolbox 87b1320518c17702d30e463966bc070ce6481459 nmbell     Initial commit

	.EXAMPLE
	## Call with Count parameter ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog -Count 3 | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0 nmbell     Merging from feature1
	MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64 nmbell     Add feature1_File1.txt
	MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit

	# Only the three most recent commits were returned.

	.EXAMPLE
	## Call with NoMerges switch ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog -NoMerges | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64 nmbell     Add feature1_File1.txt
	MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit
	MyToolbox 87b1320518c17702d30e463966bc070ce6481459 nmbell     Initial commit

	# Merge commits were omitted.

	.EXAMPLE
	## Call with InRef and NotInRef ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog -InRef feature3 -NotInRef main | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox 87e8501a197f8db5a54427c8a39803cf9e12ab66 nmbell     Add feature3_FileA.txt

	# Only commits that were in the feature3 branch but not in main branch were returned.

	.EXAMPLE
	## Call with RefRange ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog -RefRange 'main..feature3' | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox 87e8501a197f8db5a54427c8a39803cf9e12ab66 nmbell     Add feature3_FileA.txt

	# Equivalent to the previous example.

	.INPUTS
	[System.String]
	Accepts string objects via the RepoName parameter. The output of Get-GitRepo can be piped into Get-GitLog.

	.OUTPUTS
	[GitCommit]
	Returns a custom GitCommit object. For details use Get-Member at a command prompt e.g.:
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog | Get-Member -MemberType Properties

	.NOTES
	Author : nmbell

	.LINK
	https://github.com/nmbell/powdrgit/help/Get-GitLog.md
	.LINK
	about_powdrgit
	.LINK
	Get-GitCommit
	.LINK
	Get-GitCommitFile
	.LINK
	Get-GitFileHistory
	#>

    # Use cmdlet binding
	[CmdletBinding(DefaultParameterSetName = 'InRef')]

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
			Get-GitRepo -Verbose:$false `
				| Select-Object -ExpandProperty RepoName `
				| Where-Object { $_ -like "$wordToComplete*" } `
				| Sort-Object
		})]
		[String]
		$RepoName

    ,	[Parameter(
    	  ParameterSetName                = 'InRef'
    	, Mandatory                       = $false
    	, ValueFromPipeline               = $false
    	, ValueFromPipelineByPropertyName = $true
		)]
		[ArgumentCompleter({
			Param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
			$argRepoName = $fakeBoundParameters.RepoName
			If (!($fakeBoundParameters.ContainsKey('RepoName')))
			{
				$argRepoName = Get-GitRepo -Verbose:$false -Current | Select-Object -ExpandProperty RepoName
			}
			@(
				Get-GitBranch -Verbose:$false -RepoName $argRepoName `
					| Sort-Object -Property @{ Expression = 'IsCheckedOut'; Descending = $true },@{ Expression = 'BranchName'; Ascending = $true } `
					| Select-Object -ExpandProperty BranchName `
			)+@(
				Get-GitTag -Verbose:$false -RepoName $argRepoName `
					| Select-Object -ExpandProperty TagName `
					| Sort-Object TagName
			) `
				| Where-Object { $_ -like "$wordToComplete*" }

		})]
		[Alias('SHA1Hash')]
		[String[]]
		$InRef

    ,	[Parameter(
    	  ParameterSetName                = 'InRef'
    	, Mandatory                       = $false
    	, ValueFromPipeline               = $false
    	, ValueFromPipelineByPropertyName = $false
		)]
		[ArgumentCompleter({
			Param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
			$argRepoName = $fakeBoundParameters.RepoName
			If (!($fakeBoundParameters.ContainsKey('RepoName')))
			{
				$argRepoName = Get-GitRepo -Verbose:$false -Current | Select-Object -ExpandProperty RepoName
			}
			@(
				Get-GitBranch -Verbose:$false -RepoName $argRepoName `
					| Sort-Object -Property @{ Expression = 'IsCheckedOut'; Descending = $true },@{ Expression = 'BranchName'; Ascending = $true } `
					| Select-Object -ExpandProperty BranchName `
			)+@(
				Get-GitTag -Verbose:$false -RepoName $argRepoName `
					| Select-Object -ExpandProperty TagName `
					| Sort-Object TagName
			) `
				| Where-Object { $_ -like "$wordToComplete*" }

		})]
		[String[]]
		$NotInRef

	,	[Parameter(
    	  ParameterSetName                = 'RefRange'
    	, Mandatory                       = $false
    	, ValueFromPipeline               = $false
    	, ValueFromPipelineByPropertyName = $false
		)]
		[String[]]
		$RefRange

    ,	[Parameter(
    	  Mandatory                       = $false
    	, ValueFromPipeline               = $false
    	, ValueFromPipelineByPropertyName = $true
		)]
		[Int32]
		$Count

    ,	[Switch]
		$NoMerges

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
		Push-Location -StackName GetGitLog

		$startOfText = '!!>>' # commit info delimiter
		$endOfText   = '<<!!' # commit info delimiter
		$gitCommandTemplate = 'git log <InRef><NotInRef><Count><NoMerges>--date=iso8601-strict-local --format="'+$startOfText+'%H|%T|%P|%ad|%an|%ae|%cd|%cn|%ce|%D|%s|%b'+$endOfText+'"' # https://git-scm.com/docs/git-log#_pretty_formats
	}

	PROCESS
	{
		$wvBlock = 'P'

		# Find the repository name from current location
		If (!$RepoName) { $RepoName = Get-GitRepo -Current | Select-Object -ExpandProperty RepoName }

		# Go to the repository and get the repository info
		$repo = Set-GitRepo -RepoName $RepoName -PassThru -WarningAction SilentlyContinue

		If ($repo)
		{
			$gitCommand = $gitCommandTemplate

			$refRangeReplacement = '<InRef><NotInRef>'
			$inRefReplacement    = 'HEAD '
			$notInRefReplacement = ''
			$countReplacement    = ''
			$noMergesReplacement = ''

			If ($RefRange              ) { $refRangeReplacement = $RefRange.Trim()                +' ' }
			If ($InRef                 ) { $inRefReplacement    =     ($InRef    -join ' ' )      +' ' }
			If ($NotInRef              ) { $notInRefReplacement = '^'+($NotInRef -join ' ^')      +' ' }
			If ($Count -or $Count -gt 0) { $countReplacement    = '--max-count='+$Count.ToString()+' ' }
			If ($NoMerges              ) { $noMergesReplacement = '--no-merges'                   +' ' }

			$gitCommand = $gitCommand.Replace('<InRef><NotInRef>',$refRangeReplacement)
			$gitCommand = $gitCommand.Replace('<InRef>'          ,$inRefReplacement   )
			$gitCommand = $gitCommand.Replace('<NotInRef>'       ,$notInRefReplacement)
			$gitCommand = $gitCommand.Replace('<Count>'          ,$countReplacement   )
			$gitCommand = $gitCommand.Replace('<NoMerges>'       ,$noMergesReplacement)

			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Getting git log for $RepoName"
			$gitResults = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream `
							| ConvertTo-GitParsableResults -StartOfText $startOfText -EndOfText $endOfText

			# Parse the results
			If ($gitResults)
			{
				ForEach ($line in $gitResults | Where-Object { $_.Trim() })
				{
					$lineSplit = $line.Replace($startOfText,'').Replace($endOfText,'').Split('|')

					# Output
					[GitCommit]@{
						'RepoName'       = $repo.Name
						'SHA1Hash'       = $lineSplit[0]
						'TreeHash'       = $lineSplit[1]
						'ParentHashes'   = $lineSplit[2].Split(' ').Trim()
						'IsMerge'        = $lineSplit[2].Split(' ').Count -gt 1
						'AuthorDate'     = [DateTime]::Parse($lineSplit[3])
						'AuthorName'     = $lineSplit[4]
						'AuthorEmail'    = $lineSplit[5]
						'CommitterDate'  = $lineSplit[6]
						'CommitterName'  = $lineSplit[7]
						'CommitterEmail' = $lineSplit[8]
						'RefNames'       = $lineSplit[9].Split(',').Trim()
						'Subject'        = $lineSplit[10]
						'Body'           = $lineSplit[11]
					}
				}
			}
		}
		ElseIf ($RepoName)
		{
			Write-Warning "[$thisFunctionName]Repository '$RepoName' not found. Check the repository directory has been added to the `$GitRepoPath module variable."
		}
    }

	END
	{
		$wvBlock = 'E'

		# Function END:
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Setting location to original directory"
		Pop-Location -StackName GetGitLog

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($('{0}d {1:00}:{2:00}:{3:00}.{4:000}' -f $duration.Days,$duration.Hours,$duration.Minutes,$duration.Seconds,$duration.Milliseconds))"
		$PowdrgitCallDepth--
	}
}
