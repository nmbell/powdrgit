function Get-GitLog
{
	<#
	.SYNOPSIS
	Gets a list of commits from the git log.

	.DESCRIPTION
	Gets a list of commits from the git log.

	.PARAMETER Repo
	The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
	If the Repo parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.
	For examples of using the Repo parameter, refer to the help text for Get-GitRepo.

	.PARAMETER InRef
	A list of repository references (i.e. branch names, tag names, or commit SHA1 hashes).
	Commits reachable from any of these references are included in the results. If ommitted, defaults to HEAD.
	For further details on how to specify a reference, see https://git-scm.com/docs/gitrevisions#_specifying_revisions.

	.PARAMETER NotInRef
	A list of repository references (i.e. branch names, tag names, or commit SHA1 hashes).
	Commits reachable from any of these references are excluded from the results. If ommitted, defaults to HEAD.
	For further details on how to specify a reference, see https://git-scm.com/docs/gitrevisions#_specifying_revisions.

	.PARAMETER RefRange
	A revision range used to limit the commits returned, given in native git format e.g. "branch1...branch2".
	For further details on how to specify a range, see https://git-scm.com/docs/gitrevisions#_specifying_ranges.

	.PARAMETER Count
	Specifies the number of commits to retrieve. Commits are retrieved in reverse order, so specifying a Count of 5 will return the last 5 commits.

	.PARAMETER NoMerges
	Excludes merge commits (commits with more than one parent) from the results.

	.EXAMPLE
	## Call from outside a repository without parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitLog

	# Nothing was returned because a Repo was not provided.

	.EXAMPLE
	## Call from outside a repository with Repo parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main # checkout the main branch from the current location
	PS C:\> Get-GitLog -Repo MyToolbox | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0 nmbell     Merging from feature1
	MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64 nmbell     Add feature1_File1.txt
	MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit
	MyToolbox 87b1320518c17702d30e463966bc070ce6481459 nmbell     Initial commit

	# The commits were returned even though the command was issued from outside the repository directory.

	.EXAMPLE
	## Get commits from the current repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0 nmbell     Merging from feature1
	MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64 nmbell     Add feature1_File1.txt
	MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit
	MyToolbox 87b1320518c17702d30e463966bc070ce6481459 nmbell     Initial commit

	.EXAMPLE
	## Call with Count parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog -Count 3 | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0 nmbell     Merging from feature1
	MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64 nmbell     Add feature1_File1.txt
	MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit

	# Only the three most recent commits were returned.

	.EXAMPLE
	## Call with NoMerges switch ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog -NoMerges | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64 nmbell     Add feature1_File1.txt
	MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit
	MyToolbox 87b1320518c17702d30e463966bc070ce6481459 nmbell     Initial commit

	# Merge commits were omitted.

	.EXAMPLE
	## Call with InRef and NotInRef ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog -InRef feature3 -NotInRef main | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox 87e8501a197f8db5a54427c8a39803cf9e12ab66 nmbell     Add feature3_FileA.txt

	# Only commits that were in the feature3 branch but not in main branch were returned.

	.EXAMPLE
	## Call with RefRange ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog -RefRange 'main..feature3' | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox 87e8501a197f8db5a54427c8a39803cf9e12ab66 nmbell     Add feature3_FileA.txt

	# Equivalent to the previous example.

	.INPUTS
	[System.String]
	Accepts string objects via the Repo parameter. The output of Get-GitRepo can be piped into Get-GitLog.

	.OUTPUTS
	[GitCommit]
	Returns a custom GitCommit object. For details use Get-Member at a command prompt e.g.:
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog | Get-Member -MemberType Properties

	.NOTES
	Author : nmbell

	.LINK
	Get-GitCommit
	.LINK
	Get-GitCommitFile
	.LINK
	Get-GitFileHistory
	.LINK
	Get-GitRepo
	.LINK
	about_powdrgit
	#>

	# Function alias
	[Alias('ggl')]

	# Use cmdlet binding
	[CmdletBinding(
	  DefaultParameterSetName = 'InRef'
	, HelpURI                 = 'https://github.com/nmbell/powdrgit/blob/main/help/Get-GitLog.md'
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
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		, ParameterSetName                = 'InRef'
		)]
	#	[ArgumentCompleter()]
		[Alias('SHA1Hash')]
		[String[]]
		$InRef

	,	[Parameter(
		  Mandatory                       = $false
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $false
		, ParameterSetName                = 'InRef'
		)]
	#	[ArgumentCompleter()]
		[String[]]
		$NotInRef

	,	[Parameter(
		  Mandatory                       = $false
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $false
		, ParameterSetName                = 'RefRange'
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

		$startOfText = '!!>>' # commit info delimiter
		$endOfText   = '<<!!' # commit info delimiter
		$gitCommandTemplate = 'git log <InRef><NotInRef><Count><NoMerges>--date=iso8601-strict-local --format="'+$startOfText+'%H|%T|%P|%ad|%an|%ae|%cd|%cn|%ce|%D|%s|%b'+$endOfText+'"' # https://git-scm.com/docs/git-log#_pretty_formats
	}

	PROCESS
	{
		$bk = 'P'

		# Find the repository name from current location
		If (!$PSBoundParameters.ContainsKey('Repo')) { $Repo = Get-GitRepo -Current | Select-Object -ExpandProperty RepoPath }

		# Get the repository info
		$validRepos = Get-ValidRepo -Repo $Repo

		# Get the log entries
		ForEach ($validRepo in $validRepos)
		{
			# Go to the repository and get the repository info
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Moving to the repository directory: $($validRepo.RepoPath)"
			Set-GitRepo -Repo $validRepo.RepoPath -WarningAction Ignore

			# Get log entries
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

			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Getting git log for $($validRepo.RepoName)"
			$gitResults = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream `
						  | ConvertTo-GitParsableResults -StartOfText $startOfText -EndOfText $endOfText
			Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Found log entries: $('{0,3}' -f ($gitResults | Measure-Object).Count)"

			# Parse the results
			If ($gitResults)
			{
				ForEach ($line in $gitResults | Where-Object { $_.Trim() })
				{
					$lineSplit = $line.Replace($startOfText,'').Replace($endOfText,'').Split('|')

					# Output
					[GitCommit]@{
						'RepoName'       = $validRepo.RepoName
						'RepoPath'       = $validRepo.RepoPath
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
	}

	END
	{
		$bk = 'E'

		# Function END:
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Setting location to original directory"
		Set-Location -Path $startLocation

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($($duration.ToString('d\d\ hh\:mm\:ss\.fff')))"
		$PowdrgitCallDepth--
	}
}
