function Get-GitCommitFile
{
	<#
	.SYNOPSIS
	Gets the files associated with a commit.

	.DESCRIPTION
	Gets the files associated with a commit.

	.PARAMETER RepoName
	The name of the git repository to return.
	This should match the directory name of one of the repositories defined in $GitRepoPath. If there is no match, a warning is generated.
	When the parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.

	.PARAMETER SHA1Hash
	The SHA1 hash of (or a reference to) a commit in the current repository. If omitted, the HEAD commit is used.

	.EXAMPLE
	## Call from outside a repository without parameters ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitCommitFile

	# Nothing was returned because a RepoName was not provided.

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitCommitFile -RepoName NonExistentRepo
	WARNING: [Get-GitCommitFile]Repository 'NonExistentRepo' not found. Check the repository directory has been added to the $GitRepoPath variable.

	.EXAMPLE
	## Call from outside a repository with RepoName parameter ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main # checkout the main branch from the current location
	PS C:\> Get-GitCommitFile -RepoName MyToolbox | Format-Table -Property RepoName,SHA1Hash,Exists,FullName

	RepoName  SHA1Hash                                 Exists FullName
	--------  --------                                 ------ --------
	MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0  False

	# When SHA1Hash is not specified, the HEAD commit is used.

	.EXAMPLE
	## Call from inside a repository with SHA1Hash parameter ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq 'Add feature1_File1.txt' | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
	PS C:\PowdrgitExamples\MyToolbox> Get-GitCommitFile -SHA1Hash $commitHash | Format-Table -Property RepoName,SHA1Hash,Exists,FullName

	RepoName  SHA1Hash                                 Exists FullName
	--------  --------                                 ------ --------
	MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64   True C:\PowdrgitExamples\MyToolbox\feature1_File1.txt

	.EXAMPLE
	## Pipe results from Get-GitLog ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitLog -NoMerges | Get-GitCommitFile | Format-Table -Property RepoName,SHA1Hash,Exists,FullName

	RepoName  SHA1Hash                                 Exists FullName
	--------  --------                                 ------ --------
	MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64   True C:\PowdrgitExamples\MyToolbox\feature1_File1.txt
	MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135  False
	MyToolbox 87b1320518c17702d30e463966bc070ce6481459  False

	# Commits with no files associated to them are included in the results.

	.OUTPUTS
	[GitCommitFile]
	Returns a custom GitCommitFile object. For details use Get-Member at a command prompt e.g.:
	PS C:\PowdrgitExamples\MyToolbox> Get-GitCommitFile | Get-Member -MemberType Properties

	.NOTES
	Author : nmbell

	.LINK
	Get-GitCommit
	Get-GitFileHistory
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
		$wvBlock = 'P'

		# Find the repository name from current location
		If (!$RepoName) { $RepoName = Get-GitRepo -Current | Select-Object -ExpandProperty RepoName }

		# move to the repository directory and get the repository info
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
			If ($SHA1Hash -eq 'HEAD')
			{
				$SHA1Hash = Get-GitCommit -RepoName $RepoName -SHA1Hash HEAD | Select-Object -ExpandProperty SHA1Hash
			}

			# Gather commit files list
			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Gathering commit files list"
			$gitCommand = $gitCommandTemplate.Replace('<SHA1Hash>',$SHA1Hash)
			$gitResults = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream

			# Parse the list
			If ($gitResults)
			{
				$gitResults = $gitResults.Replace('/','\')
				ForEach ($line in $gitResults | Where-Object { $_.Trim() })
				{
					$linesplit = $line -split "`t"

					$statusScore = $linesplit[0]
					$filePath1   = $linesplit[1]
					$filePath2   = $linesplit[2]

					$statusScore -match '(\w)(\d*)' | Out-Null
					$status = $statusKey[$Matches[1]]
					$score  = $Matches[2]
					$thisGitPath = $filePath1*(![Bool]$filePath2)+$filePath2*([Bool]$filePath2)
					$prevGitPath = $filePath2*(![Bool]$filePath2)+$filePath1*([Bool]$filePath2)
					$prevFilePath = ($repo.FullName+'\')*([Bool]$prevGitPath)+$prevGitPath

					# Output
					[GitCommitFile]@{
						'RepoName'         = $repo.Name
						'SHA1Hash'         = $SHA1Hash
						'Action'           = $status
						'Exists'           = Test-Path -Path ($repo.FullName+'\'+$thisGitPath)
						'FullName'         = $repo.FullName+'\'+$thisGitPath
						'Directory'        = $repo.FullName+'\'+[System.IO.Path]::GetDirectoryName($thisGitPath)
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
					'RepoName'         = $repo.Name
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
		ElseIf ($RepoName)
		{
			Write-Warning "[$thisFunctionName]Repository '$RepoName' not found. Check the repository directory has been added to the `$GitRepoPath variable."
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
