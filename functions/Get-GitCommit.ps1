function Get-GitCommit
{
	<#
	.SYNOPSIS
	Gets information for a given SHA1 commit hash.

	.DESCRIPTION
	Gets information for a given SHA1 commit hash.

	.PARAMETER Repo
	The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
	If the Repo parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.
	For examples of using the Repo parameter, refer to the help text for Get-GitRepo.

	.PARAMETER SHA1Hash
	The SHA1 hash of (or a reference to) a commit in the current repository. If omitted, the HEAD commit is returned.

	.EXAMPLE
	## Call from outside a repository without parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitCommit

	# Nothing was returned because a Repo was not provided.

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Get-GitCommit -Repo NonExistentRepo
	WARNING: [Get-GitCommit]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.

	.EXAMPLE
	## Call from outside a repository with Repo parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitCommit -Repo MyToolbox | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0 nmbell     Merging from feature1

	# When SHA1Hash is not specified, the HEAD commit is returned.

	.EXAMPLE
	## Call from inside a repository with SHA1Hash parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq 'feature1 commit' | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
	PS C:\PowdrgitExamples\MyToolbox> Get-GitCommit -SHA1Hash $commitHash | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit

	.EXAMPLE
	## Pipe results from Get-GitLog ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog | Get-GitCommit | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0 nmbell     Merging from feature1
	MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64 nmbell     Add feature1_File1.txt
	MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit
	MyToolbox 87b1320518c17702d30e463966bc070ce6481459 nmbell     Initial commit

	# Output is identical to:
	# PS C:\PowdrgitExamples\MyToolbox> Get-GitLog | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	.INPUTS
	[System.String]
	Accepts string objects via the SHA1Hash parameter. The output of Get-GitLog can be piped into Get-GitCommit.

	.OUTPUTS
	[GitCommit]
	Returns a custom GitCommit object. For details use Get-Member at a command prompt e.g.:
	PS C:\PowdrgitExamples\MyToolbox> Get-GitCommit | Get-Member -MemberType Properties

	.NOTES
	Author : nmbell

	.LINK
	Get-GitCommitFile
	.LINK
	Get-GitFileHistory
	.LINK
	Get-GitLog
	.LINK
	Get-GitRepo
	.LINK
	about_powdrgit
	#>

	# Function alias
	[Alias('ggc')]

	# Use cmdlet binding
	[CmdletBinding(
	  HelpURI = 'https://github.com/nmbell/powdrgit/blob/main/help/Get-GitCommit.md'
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
		[String]
		$SHA1Hash = 'HEAD'

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

		$startOfText = '!!>>' # commit info delimiter
		$endOfText   = '<<!!' # commit info delimiter
		$gitCommandTemplate = 'git show <SHA1Hash> --no-patch --date=iso8601-strict-local --format=format:"'+$startOfText+'%H|%T|%P|%ad|%an|%ae|%cd|%cn|%ce|%D|%s|%b'+$endOfText+'"' # https://git-scm.com/docs/git-show#_pretty_formats
	}

	PROCESS
	{
		$bk = 'P'

		# Find the repository name from current location
		If (!$PSBoundParameters.ContainsKey('Repo')) { $Repo = Get-GitRepo -Current | Select-Object -ExpandProperty RepoPath }

		# Get the repository info
		$validRepos = Get-ValidRepo -Repo $Repo

		# Get the commits
		ForEach ($validRepo in $validRepos)
		{
			# Go to the repository and get the repository info
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Moving to the repository directory: $($validRepo.RepoPath)"
			Set-GitRepo -Repo $validRepo.RepoPath -WarningAction Ignore

			# Validate parameters
			$gitCommandRefType = "git cat-file -t $SHA1Hash"
			$refType = Invoke-GitExpression -Command $gitCommandRefType -SuppressGitErrorStream
			If ($refType -notin 'commit')
			{
				If ($warn) { Write-Warning "[$thisFunctionName]`"$SHA1Hash`" is not a valid commit in repository '$($validRepo.RepoName)'." }
			}

			# Get commit info
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Gathering commit info"
			$gitCommand = $gitCommandTemplate.Replace('<SHA1Hash>',$SHA1Hash)
			$gitResults = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream `
						  | ConvertTo-GitParsableResults -StartOfText $startOfText -EndOfText $endOfText
			Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Found commits: $('{0,3}' -f ($gitResults | Measure-Object).Count)"

			# Parse the results
			If ($gitResults)
			{
				$lineSplit = $gitResults.Split('|')

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
