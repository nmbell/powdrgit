function Get-GitFileHistory
{
	<#
	.SYNOPSIS
	Gets commit history for a given file.

	.DESCRIPTION
	Gets commit history for a given file.

	.PARAMETER RepoName
	The name of the git repository to return.
	This should match the directory name of one of the repositories defined in the $GitRepoPath module variable. If there is no match, a warning is generated.
	When the parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.

	.PARAMETER Path
	The Path to a file in the repository. Unqualifed paths (i.e. with no leading drive letter) will be assumed to be relative to the current repository.

	.EXAMPLE
	## Call from outside a repository without parameters ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitFileHistory

	# Nothing was returned because RepoName and Path were not provided.

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitFileHistory -RepoName NonExistentRepo
	WARNING: [Get-GitFileHistory]Repository 'NonExistentRepo' not found. Check the repository directory has been added to the $GitRepoPath module variable.

	.EXAMPLE
	## Call from outside a repository with RepoName parameter ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitFileHistory -RepoName MyToolbox

	# Nothing was returned because Path was not provided.

	.EXAMPLE
	## Call from outside a repository with RepoName and Path parameters ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitFileHistory -RepoName MyToolbox -Path 'feature1_File1.txt' | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName  Subject
	--------  --------                                 ----------  -------
	MyToolbox ebf9e4850f5e7023c052b90779abd56878c5215c nmbell      Add feature1_File1.txt

	.EXAMPLE
	## Call from inside a repository with Path parameter ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitFileHistory -Path 'feature1_File1.txt' | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName  Subject
	--------  --------                                 ----------  -------
	MyToolbox ebf9e4850f5e7023c052b90779abd56878c5215c nmbell      Add feature1_File1.txt

	.EXAMPLE
	## Pipe results from Get-Child-Item ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-ChildItem | Get-GitFileHistory | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName  Subject
	--------  --------                                 ----------  -------
	MyToolbox ebf9e4850f5e7023c052b90779abd56878c5215c nmbell      Add feature1_File1.txt

	.INPUTS
	[System.String]
	Accepts string objects via the Path parameter. The output of Get-ChildItem can be piped into Get-GitFileHistory.

	.OUTPUTS
	[GitCommit]
	Returns a custom GitCommit object. For details use Get-Member at a command prompt e.g.:
	PS C:\PowdrgitExamples\MyToolbox> Get-GitFileHistory | Get-Member -MemberType Properties

	.NOTES
	Author : nmbell

	.LINK
	about_powdrgit
	.LINK
	Get-GitCommit
	.LINK
	Get-GitCommitFile
	.LINK
	Get-GitLog
	#>

    # Use cmdlet binding
    [CmdletBinding(
	  HelpURI = 'https://github.com/nmbell/powdrgit/blob/main/help/Get-GitFileHistory.md'
	)]

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
		[Alias('FullName')]
		[String[]]
		$Path

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
		$gitCommandTemplate = 'git log --date=iso8601-strict-local --format="'+$startOfText+'%H|%T|%P|%ad|%an|%ae|%cd|%cn|%ce|%D|%s|%b'+$endOfText+'" -- "<Path>"' # https://git-scm.com/docs/git-log#_pretty_formats

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
			# Get commit info
			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Gathering commit info"

			ForEach ($filepath in $Path)
			{
				$gitCommand = $gitCommandTemplate.Replace('<Path>',$filepath)
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
