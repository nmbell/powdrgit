function Get-GitDiff
{
	<#
	.SYNOPSIS
	Gets the diff between a range of commits.

	.DESCRIPTION
	Gets the diff between a range of commits.
	If only a single 'to' commit is specified, the diff will be from its immediate parent.
	If only a single 'from' commit is specified, the diff will be to the HEAD commit.
	One [GitCommitDiff] object is returned for each file covered by the diff.
	[GitCommitDiff] objects can be displayed in readable format using Format-GitDiff.

	.PARAMETER Repo
	The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
	If the Repo parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.
	For examples of using the Repo parameter, refer to the help text for Get-GitRepo.

	.PARAMETER SHA1HashFrom
	The SHA1 hash of (or a reference to) a commit in the current repository. If omitted, the parent of the SHA1HashTo commit is used.

	.PARAMETER SHA1HashTo
	The SHA1 hash of (or a reference to) a commit in the current repository. If omitted, the HEAD commit is used.

	.PARAMETER InputObject
	GitCommit object from e.g. Get-GitLog.

	.EXAMPLE
	## Call from outside a repository without parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
	PS C:\> Get-GitDiff

	# Nothing was returned because a Repo was not provided.

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Get-GitDiff -Repo NonExistentRepo
	WARNING: [Get-GitDiff]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.

	.EXAMPLE
	## Call from outside a repository with Repo parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
	PS C:\> $diff = Get-GitDiff -Repo Project2
	PS C:\> $diff.Summary; $diff.File | Format-Table

	1 file changed, 1 insertion(+)

	Action Path     PathNew Similarity New Old DiffLine
	------ ----     ------- ---------- --- --- --------
	Modify Jack.txt                    1   0   { Little Jack Horner, +Sat in the corner}

	# When neither SHA1HashFrom or SHA1HashTo are specified, the diff of the HEAD commit is returned.

	.EXAMPLE
	## Call from inside a repository with the same commit for SHA1HashFrom and SHA1HashTo parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\Project2> $commitHash = Get-GitLog -NoMerges | Select-Object -First 1 -ExpandProperty SHA1Hash # pick a commit from the log
	PS C:\PowdrgitExamples\Project2> Get-GitDiff -SHA1HashFrom $commitHash -SHA1HashTo $commitHash

	# Nothing was returned because there are no differences when comparing a commit against itself.

	.EXAMPLE
	## Call from inside a repository with only the SHA1HashFrom parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\Project2> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq "Update Mary's bio" | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
	PS C:\PowdrgitExamples\Project2> $diff = Get-GitDiff -SHA1HashFrom $commitHash
	PS C:\PowdrgitExamples\Project2> $diff.Summary; $diff.File | Format-Table

	2 files changed, 2 insertions(+), 2 deletions(-)

	Action Path     PathNew Similarity New Old DiffLine
	------ ----     ------- ---------- --- --- --------
	Add    Jack.txt                    2   0   {+Little Jack Horner, +Sat in the corner}
	Delete Mary.txt                    0   2   {-Mary had a little lamb, -It's fleece was white as snow}

	# When only SHA1HashFrom is specified, the HEAD commit is used as the SHA1HashTo commit.

	.EXAMPLE
	## Call from inside a repository with only the SHA1HashTo parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\Project2> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq "Update Mary's bio" | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
	PS C:\PowdrgitExamples\Project2> $diff = Get-GitDiff -SHA1HashTo $commitHash
	PS C:\PowdrgitExamples\Project2> $diff.Summary; $diff.File | Format-Table

	1 file changed, 1 insertion(+)

	Action Path     PathNew Similarity New Old DiffLine
	------ ----     ------- ---------- --- --- --------
	Modify Mary.txt                    1   0   { Mary had a little lamb, +It's fleece was white as snow}

	# When only SHA1HashTo is specified, the parent of the SHA1HashTocommit is used as the SHA1HashFrom commit.

	.EXAMPLE
	## Call from inside a repository with both the SHA1HashTo and SHA1HashFrom parameters ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\Project2> $commitHashFrom = Get-GitLog -NoMerges | Where-Object Subject -eq 'Initial commit' | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
	PS C:\PowdrgitExamples\Project2> $commitHashTo   = Get-GitLog -NoMerges | Where-Object Subject -eq "Replace Mary's bio with Jack's" | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
	PS C:\PowdrgitExamples\Project2> $diff = Get-GitDiff -SHA1HashFrom $commitHashFrom -SHA1HashTo $commitHashTo
	PS C:\PowdrgitExamples\Project2> $diff.Summary; $diff.File | Format-Table

	1 file changed, 1 insertion(+)

	Action Path     PathNew Similarity New Old DiffLine
	------ ----     ------- ---------- --- --- --------
	Add    Jack.txt                    1   0   {+Little Jack Horner}

	# When SHA1HashFrom and SHA1HashTo are specified, the result shows the net diff for the range of commits.

	.EXAMPLE
	## Pipe results from Get-GitLog ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\Project2> $diffs = Get-GitLog -NoMerges | Where-Object { $_.ParentHashes } | Get-GitDiff
	PS C:\PowdrgitExamples\Project2> $diffs.Summary; $diffs.File | Format-Table

	1 file changed, 1 insertion(+)
	2 files changed, 1 insertion(+), 2 deletions(-)
	1 file changed, 1 insertion(+)
	1 file changed, 1 insertion(+)

	Action Path     PathNew Similarity New Old DiffLine
	------ ----     ------- ---------- --- --- --------
	Modify Jack.txt                    1   0   { Little Jack Horner, +Sat in the corner}
	Add    Jack.txt                    1   0   {+Little Jack Horner}
	Delete Mary.txt                    0   2   {-Mary had a little lamb, -It's fleece was white as snow}
	Modify Mary.txt                    1   0   { Mary had a little lamb, +It's fleece was white as snow}
	Add    Mary.txt                    1   0   {+Mary had a little lamb}

	# When piping commits from Get-GitLog, a diff is created for each commit (from its parent)

	.INPUTS
	[System.String[]]
	Accepts string objects via the SHA1Hash parameter. The output of Get-GitLog can be piped into Get-GitCommit.

	.OUTPUTS
	[GitCommit]
	Returns git diff output.

	.NOTES
	Author : nmbell

	.LINK
	Get-GitCommit
	.LINK
	Format-GitDiff
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
	.LINK
	https://github.com/nmbell/powdrgit/blob/main/help/about_powdrgit.md
	#>

	# Function alias
	[Alias('ggd')]

	# Use cmdlet binding
	[CmdletBinding(
	  DefaultParameterSetName = 'Hash'
	, HelpURI                 = 'https://github.com/nmbell/powdrgit/blob/main/help/Get-GitDiff.md'
	)]

	# Declare output type
	[OutputType('System.String[]')]

	# Declare parameters
	Param(

		[Parameter(
		  Mandatory                       = $false
		, Position                        = 0
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		, ParameterSetName                = 'Hash'
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
		, ParameterSetName                = 'Hash'
		)]
		[String]
		$SHA1HashFrom

	,	[Parameter(
		  Mandatory                       = $false
		, Position                        = 2
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		, ParameterSetName                = 'Hash'
		)]
		[String]
		$SHA1HashTo

	,	[Parameter(
		  Mandatory                       = $false
		, Position                        = 0
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $false
		, ParameterSetName                = 'InputObject'
		)]
		[GitCommit]
		$InputObject

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

		$gitCommandTemplate = 'git diff --find-renames --find-copies --ignore-space-at-eol <option> <SHA1HashFrom> <SHA1HashTo>'
		# --output-indicator-new=<char>
		# --output-indicator-old=<char>
		# --output-indicator-context=<char>
		# --src-prefix=<prefix>
		# --dst-prefix=<prefix>
		# --find-copies-harder
	}

	PROCESS
	{
		$bk = 'P'

		# Set commits if not provided
		If ($InputObject)
		{
			$SHA1HashTo   = $InputObject.SHA1Hash
			$SHA1HashFrom = "$SHA1HashTo^"
		}
		Else
		{
			If (!$SHA1HashTo  ) { $SHA1HashTo   = 'HEAD'         }
			If (!$SHA1HashFrom) { $SHA1HashFrom = "$SHA1HashTo^" }
		}
		Write-Debug "  [$thisFunctionName]`$SHA1HashTo   = $SHA1HashTo"
		Write-Debug "  [$thisFunctionName]`$SHA1HashFrom = $SHA1HashFrom"

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
			ForEach ($SHA1Hash in $SHA1HashFrom,$SHA1HashTo)
			{
				$gitCommandRefType = "git cat-file -t $SHA1Hash"
				$refType = Invoke-GitExpression -Command $gitCommandRefType -SuppressGitErrorStream
				If ($refType -notin 'commit')
				{
					If ($warn) { Write-Warning "[$thisFunctionName]`"$SHA1Hash`" is not a valid commit in repository '$($validRepo.RepoName)'." }
				}
			}

			# Get diff info
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Gathering commit diff info"
			$diff         = [GitCommitDiff]::new()
			$gitCommand   = $gitCommandTemplate.Replace('<option>','--shortstat').Replace('<SHA1HashFrom>',$SHA1HashFrom).Replace('<SHA1HashTo>',$SHA1HashTo)
			$diffOutput   = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream
			If ($diffOutput)
			{
				$diff.Summary = $diffOutput.Trim()
				$gitCommand   = $gitCommandTemplate.Replace('<option>','--name-status').Replace('<SHA1HashFrom>',$SHA1HashFrom).Replace('<SHA1HashTo>',$SHA1HashTo)
				$nameStatDiff = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream
				ForEach ($line in $nameStatDiff)
				{
					$diffFile           = [GitCommitDiffFile]::new()
					$type,$file1,$file2 = $line-split "`t"
					$diffFile.Path      = $file1
					$diffFile.PathNew   = $file2
					$diffFile.New       = $null
					$diffFile.Old       = $null
					If ($type -eq   'A' ) { $diffFile.Action = 'Add'                                                 }
					If ($type -like 'C*') { $diffFile.Action = 'Copy'    ; $diffFile.Similarity = $type.Substring(1) }
					If ($type -eq   'D' ) { $diffFile.Action = 'Delete'                                              }
					If ($type -eq   'M' ) { $diffFile.Action = 'Modify'                                              }
					If ($type -like 'R*') { $diffFile.Action = 'Rename'  ; $diffFile.Similarity = $type.Substring(1) }
					If ($type -eq   'T' ) { $diffFile.Action = 'Type'                                                }
					If ($type -eq   'U' ) { $diffFile.Action = 'Unmerged'                                            }
					If ($type -eq   'X' ) { $diffFile.Action = 'Unknown'                                             }
					$diff.File += $diffFile
				}

				$gitCommand   = $gitCommandTemplate.Replace('<option>','--numstat').Replace('<SHA1HashFrom>',$SHA1HashFrom).Replace('<SHA1HashTo>',$SHA1HashTo)
				$numStatsDiff = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream
				$f = 0
				ForEach ($line in $numStatsDiff)
				{
					$diff.File[$f].New,$diff.File[$f].Old,$file = $line -split "`t"
					$f++
				}

				$gitCommand   = $gitCommandTemplate.Replace('<option>','--unified=9').Replace('<SHA1HashFrom>',$SHA1HashFrom).Replace('<SHA1HashTo>',$SHA1HashTo)
				$unifiedDiff  = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream

				$isHeader = $f = -1
				ForEach ($line in $unifiedDiff)
				{
					If ($line -like 'diff --git*')
					{
						$lineRange  = $null
						$isHeader = 1
						$f++
					}
					If ($line -like '@@ *')
					{
						$isHeader    = 0
						$lineRange   = ($line -split ' ')[1,2]
						$range1      = ($lineRange[0].Replace('-','')) -split ','
						$range2      = ($lineRange[1].Replace('+','')) -split ','
						$rangeBefore = [Int]($range1)[0]
						$rangeAfter  = [Int]($range2)[0]
						Continue
					}
					If ($isHeader) { Continue }
					If ($lineRange)
					{
						$diffLine = [GitCommitDiffLine]::new()
						If ($line -like '+*')
						{
							$lineChange        = '+'
							$rangeBeforeString = ''
							$rangeAfterString  = $rangeAfter.ToString()
							$rangeAfter++
						}
						ElseIf ($line -like '-*')
						{
							$lineChange        = '-'
							$rangeBeforeString = $rangeBefore.ToString()
							$rangeAfterString  = ''
							$rangeBefore++
						}
						ElseIf ($line -eq '\ No newline at end of file')
						{
							$lineChange        = ' '
							$rangeBeforeString = ''
							$rangeAfterString  = ''
							$line              = ' [No newline at end of file]'
						}
						Else
						{
							$lineChange        = ' '
							$rangeBeforeString = $rangeBefore.ToString()
							$rangeAfterString  = $rangeAfter.ToString()
							$rangeBefore++
							$rangeAfter++
						}
						$line                   = $line.Substring(1)
						$diffLine.LineNumBefore = $rangeBeforeString
						$diffLine.LineNumAfter  = $rangeAfterString
						$diffLine.LineChange    = $lineChange
						$diffLine.LineText      = $line
						$diff.File[$f].DiffLine += $diffLine
					}
				}

				# Output
				$diff
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
