function Get-GitCommitFile
{
	<#
	.SYNOPSIS
	Gets the files associated with a commit.

	.DESCRIPTION
	Gets the files associated with a commit.

	.PARAMETER Repo
	The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
	If the Repo parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.
	For examples of using the Repo parameter, refer to the help text for Get-GitRepo.

	.PARAMETER SHA1Hash
	The SHA1 hash of (or a reference to) a commit in the current repository. If omitted, the HEAD commit is used.

	.EXAMPLE
	## Call from outside a repository without parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitCommitFile

	# Nothing was returned because a Repo was not provided.

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Get-GitCommitFile -Repo NonExistentRepo
	WARNING: [Get-GitCommitFile]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.

	.EXAMPLE
	## Call from outside a repository with Repo parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main # checkout the main branch from the current location
	PS C:\> Get-GitCommitFile -Repo MyToolbox | Format-Table -Property RepoName,SHA1Hash,Exists,FullName

	RepoName  SHA1Hash                                 Exists FullName
	--------  --------                                 ------ --------
	MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0  False

	# When SHA1Hash is not specified, the HEAD commit is used.

	.EXAMPLE
	## Call from inside a repository with SHA1Hash parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq 'Add feature1_File1.txt' | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
	PS C:\PowdrgitExamples\MyToolbox> Get-GitCommitFile -SHA1Hash $commitHash | Format-Table -Property RepoName,SHA1Hash,Exists,FullName

	RepoName  SHA1Hash                                 Exists FullName
	--------  --------                                 ------ --------
	MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64   True C:\PowdrgitExamples\MyToolbox\feature1_File1.txt

	.EXAMPLE
	## Pipe results from Get-GitLog ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog -NoMerges | Get-GitCommitFile | Format-Table -Property RepoName,SHA1Hash,Exists,FullName

	RepoName  SHA1Hash                                 Exists FullName
	--------  --------                                 ------ --------
	MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64   True C:\PowdrgitExamples\MyToolbox\feature1_File1.txt
	MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135  False
	MyToolbox 87b1320518c17702d30e463966bc070ce6481459  False

	# Commits with no files associated to them are included in the results.

	.INPUTS
	[System.String]
	Accepts string objects via the SHA1Hash parameter. The output of Get-GitLog and Get-GitCommit can be piped into Get-GitCommitFile.

	.OUTPUTS
	[GitCommitFile]
	Returns a custom GitCommitFile object. For details use Get-Member at a command prompt e.g.:
	PS C:\PowdrgitExamples\MyToolbox> Get-GitCommitFile | Get-Member -MemberType Properties

	.NOTES
	Author : nmbell

	.LINK
	Get-GitCommit
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
	[Alias('ggcf')]

	# Use cmdlet binding
	[CmdletBinding(
	  HelpURI = 'https://github.com/nmbell/powdrgit/blob/main/help/Get-GitCommitFile.md'
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
	  	, ValueFromPipeline               = $true
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

		$gitCommandTemplate = "git diff-tree --root --no-commit-id --name-status -r <SHA1Hash>"

		# Lookup array: https://git-scm.com/docs/git-diff-tree#Documentation/git-diff-tree.txt---diff-filterACDMRTUXB82308203
		$statusKey = @{
			'A' = 'Add'
			'B' = 'Broken'
			'C' = 'Copy'
			'D' = 'Delete'
			'M' = 'Modify'
			'R' = 'Rename'
			'T' = 'Type'
			'U' = 'Unmerged'
			'X' = 'Unknown'
		}
	}

	PROCESS
	{
		$bk = 'P'

		# Find the repository name from current location
		If (!$PSBoundParameters.ContainsKey('Repo')) { $Repo = Get-GitRepo -Current | Select-Object -ExpandProperty RepoPath }

		# Get the repository info
		$validRepos = Get-ValidRepo -Repo $Repo

		# Get the commit files
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
			If ($SHA1Hash -eq 'HEAD')
			{
				$SHA1Hash = Get-GitCommit -Repo $Repo -SHA1Hash HEAD | Select-Object -ExpandProperty SHA1Hash
			}

			# Gather commit files list
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Gathering commit files list"
			$gitCommand = $gitCommandTemplate.Replace('<SHA1Hash>',$SHA1Hash)
			$gitResults = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream
			Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Found commit files: $('{0,3}' -f ($gitResults | Measure-Object).Count)"

			# Parse the list
			If ($gitResults)
			{
				$gitResults = $gitResults.Replace('/','\')
				ForEach ($line in $gitResults | Where-Object { $_.Trim() })
				{
					$linesplit = $line -split "`t"

					$statusScore = $linesplit[0]
					$filePath1   = If ($linesplit.Count -gt 1) { $linesplit[1] } Else { $null }
					$filePath2   = If ($linesplit.Count -gt 2) { $linesplit[2] } Else { $null }

					$statusScore -match '(\w)(\d*)' | Out-Null
					$status = $statusKey[$Matches[1]]
					$score  = $Matches[2]
					$thisGitPath = $filePath1*(![Bool]$filePath2)+$filePath2*([Bool]$filePath2)
					$prevGitPath = $filePath2*(![Bool]$filePath2)+$filePath1*([Bool]$filePath2)
					$prevFilePath = ($validRepo.RepoPath+'\')*([Bool]$prevGitPath)+$prevGitPath

					# Output
					[GitCommitFile]@{
						'RepoName'         = $validRepo.RepoName
						'RepoPath'         = $validRepo.RepoPath
						'SHA1Hash'         = $SHA1Hash
						'Action'           = $status
						'Exists'           = Test-Path -Path ($validRepo.RepoPath+'\'+$thisGitPath)
						'FullName'         = $validRepo.RepoPath+'\'+$thisGitPath
						'Directory'        = $validRepo.RepoPath+'\'+[System.IO.Path]::GetDirectoryName($thisGitPath)
						'Name'             = [System.IO.Path]::GetFileName($thisGitPath)
						'BaseName'         = [System.IO.Path]::GetFileNameWithoutExtension($thisGitPath)
						'Extension'        = [System.IO.Path]::GetExtension($thisGitPath)
						'PreviousFilePath' = $prevFilePath
						'GitPath'          = $thisGitPath
						'GitDirectory'     = [System.IO.Path]::GetDirectoryName($thisGitPath)
						'PreviousGitPath'  = $prevGitPath
						'SimilarityPc'     = $score
					}
				}
			}
			Else
			{
				# Output an 'empty' object
				[GitCommitFile]@{
					'RepoName'         = $validRepo.RepoName
					'RepoPath'         = $validRepo.RepoPath
					'SHA1Hash'         = $SHA1Hash
					'Action'           = $null
					'Exists'           = $null
					'FullName'         = $null
					'Directory'        = $null
					'Name'             = $null
					'BaseName'         = $null
					'Extension'        = $null
					'PreviousFilePath' = $null
					'GitPath'          = $null
					'GitDirectory'     = $null
					'PreviousGitPath'  = $null
					'SimilarityPc'     = $null
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
