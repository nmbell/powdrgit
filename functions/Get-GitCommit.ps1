function Get-GitCommit
{
	<#
	.SYNOPSIS
	Gets information for a given SHA1 commit hash.

	.DESCRIPTION
	Gets information for a given SHA1 commit hash.

	.PARAMETER RepoName
	The name of the git repository to return.
	This should match the directory name of one of the repositories defined in the $GitRepoPath module variable. If there is no match, a warning is generated.
	When the parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.

	.PARAMETER SHA1Hash
	The SHA1 hash of (or a reference to) a commit in the current repository. If omitted, the HEAD commit is returned.

	.EXAMPLE
	## Call from outside a repository without parameters ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitCommit

	# Nothing was returned because a RepoName was not provided.

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitCommit -RepoName NonExistentRepo
	WARNING: [Get-GitCommit]Repository 'NonExistentRepo' not found. Check the repository directory has been added to the $GitRepoPath module variable.

	.EXAMPLE
	## Call from outside a repository with RepoName parameter ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitCommit -RepoName MyToolbox | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0 nmbell     Merging from feature1

	# When SHA1Hash is not specified, the HEAD commit is returned.

	.EXAMPLE
	## Call from inside a repository with SHA1Hash parameter ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq 'feature1 commit' | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
	PS C:\PowdrgitExamples\MyToolbox> Get-GitCommit -SHA1Hash $commitHash | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName Subject
	--------  --------                                 ---------- -------
	MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit

	.EXAMPLE
	## Pipe results from Get-GitLog ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
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
	https://github.com/nmbell/powdrgit/help/Get-GitCommit.md
	.LINK
	about_powdrgit
	.LINK
	Get-GitCommitFile
	.LINK
	Get-GitFileHistory
	.LINK
	Get-GitLog
	#>

    # Use cmdlet binding
    [CmdletBinding()]

    # Declare parameters
    Param(

    	[Parameter(
    	  Mandatory                       = $false
    	, Position                        = 0
    	, ValueFromPipeline               = $false
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
		  Mandatory                       = $false
		, Position                        = 1
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $true
		)]
		[String]
		$SHA1Hash = 'HEAD'

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
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Storing current location"
		Push-Location -StackName GetGitCommitInfo

		$startOfText = '!!>>' # commit info delimiter
		$endOfText   = '<<!!' # commit info delimiter
		$gitCommandTemplate = 'git show <SHA1Hash> --date=iso8601-strict-local --format=format:"'+$startOfText+'%H|%T|%P|%ad|%an|%ae|%cd|%cn|%ce|%D|%s|%b'+$endOfText+'"' # https://git-scm.com/docs/git-show#_pretty_formats
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
			# Validate parameters
			$gitCommandRefType = "git cat-file -t $SHA1Hash"
			$refType = Invoke-GitExpression -Command $gitCommandRefType -SuppressGitErrorStream
			If ($refType -notin 'commit')
			{
				Write-Warning "`"$SHA1Hash`" is not a valid commit in repository '$($repo.Name)'."
			}

			# Get commit info
			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Gathering commit info"
			$gitCommand = $gitCommandTemplate.Replace('<SHA1Hash>',$SHA1Hash)
			$gitResults = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream `
							| ConvertTo-GitParsableResults -StartOfText $startOfText -EndOfText $endOfText

			# Parse the results
			If ($gitResults)
			{
				$lineSplit = $gitResults.Split('|')

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
		Pop-Location -StackName GetGitCommitInfo

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($('{0}d {1:00}:{2:00}:{3:00}.{4:000}' -f $duration.Days,$duration.Hours,$duration.Minutes,$duration.Seconds,$duration.Milliseconds))"
		$PowdrgitCallDepth--
	}
}
