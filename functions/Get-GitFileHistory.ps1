function Get-GitFileHistory
{
	<#
	.SYNOPSIS
	Gets commit history for a given file.

	.DESCRIPTION
	Gets commit history for a given file.

	.PARAMETER Repo
	The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
	If the Repo parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.
	For examples of using the Repo parameter, refer to the help text for Get-GitRepo.

	.PARAMETER FilePath
	The path to a file in the repository.
	The path may be for a file that no longer exists.
	Unqualifed paths (i.e. with no leading drive letter) will be assumed to be relative to the current repository.

	.EXAMPLE
	## Call from outside a repository without parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitFileHistory

	# Nothing was returned because Repo and FilePath were not provided.

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Get-GitFileHistory -Repo NonExistentRepo
	WARNING: [Get-GitFileHistory]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.

	.EXAMPLE
	## Call from outside a repository with Repo parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitFileHistory -Repo MyToolbox

	# Nothing was returned because FilePath was not provided.

	.EXAMPLE
	## Call from outside a repository with Repo and FilePath parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitFileHistory -Repo MyToolbox -FilePath 'feature1_File1.txt' | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName  Subject
	--------  --------                                 ----------  -------
	MyToolbox ebf9e4850f5e7023c052b90779abd56878c5215c nmbell      Add feature1_File1.txt

	.EXAMPLE
	## Call from inside a repository with FilePath parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitFileHistory -FilePath 'feature1_File1.txt' | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName  Subject
	--------  --------                                 ----------  -------
	MyToolbox ebf9e4850f5e7023c052b90779abd56878c5215c nmbell      Add feature1_File1.txt

	.EXAMPLE
	## Pipe results from Get-Child-Item ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-ChildItem | Get-GitFileHistory | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

	RepoName  SHA1Hash                                 AuthorName  Subject
	--------  --------                                 ----------  -------
	MyToolbox ebf9e4850f5e7023c052b90779abd56878c5215c nmbell      Add feature1_File1.txt

	.INPUTS
	[System.String[]]
	Accepts string objects via the FilePath parameter. The output of Get-ChildItem can be piped into Get-GitFileHistory.

	.OUTPUTS
	[GitCommit]
	Returns a custom GitCommit object. For details use Get-Member at a command prompt e.g.:
	PS C:\PowdrgitExamples\MyToolbox> Get-GitFileHistory | Get-Member -MemberType Properties

	.NOTES
	Author : nmbell

	.LINK
	Get-GitCommit
	.LINK
	Get-GitCommitFile
	.LINK
	Get-GitLog
	.LINK
	Get-GitRepo
	.LINK
	about_powdrgit
	.LINK
	https://github.com/nmbell/powdrgit/blob/main/help/about_powdrgit.md
	#>

	# Function alias
	[Alias('ggfh')]

	# Use cmdlet binding
	[CmdletBinding(
	  HelpURI = 'https://github.com/nmbell/powdrgit/blob/main/help/Get-GitFileHistory.md'
	)]

	# Declare output type
	[OutputType('GitCommit')]

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
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $true
		)]
		[Alias('FullName','Path')]
		[String[]]
		$FilePath

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
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Storing current location"
		$startLocation = $PWD.Path

		$startOfText = '!!>>'   # commit info delimiter
		$endOfText   = '<<!!'   # commit info delimiter
		$separator   = [char]30 # ASCII Record Separator
		$gitCommandTemplate = 'git log --date=iso8601-strict-local --format="'+$startOfText+'%H'+$separator+'%T'+$separator+'%P'+$separator+'%ad'+$separator+'%an'+$separator+'%ae'+$separator+'%cd'+$separator+'%cn'+$separator+'%ce'+$separator+'%D'+$separator+'%s'+$separator+'%b'+$endOfText+'" -- "<Path>"' # https://git-scm.com/docs/git-log#_pretty_formats

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

			# Get commit info
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Gathering commit info"

			ForEach ($_filePath in $FilePath)
			{
				$gitCommand = $gitCommandTemplate.Replace('<Path>',$_filePath)
				$gitResults = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream `
							  | ConvertTo-GitParsableResults -StartOfText $startOfText -EndOfText $endOfText
				Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]$('{0,3}' -f ($gitResults | Measure-Object).Count) commits for $_filePath"

				# Parse the results
				If ($gitResults)
				{
					ForEach ($line in $gitResults | Where-Object { $_.Trim() })
					{
						$lineSplit = $line.Replace($startOfText,'').Replace($endOfText,'').Split($separator)

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
