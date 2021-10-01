function Set-GitBranch
{
	<#
	.SYNOPSIS
	Checks out the specified branches for the specified repository.

	.DESCRIPTION
	Checks out the specified branches for the specified repository.
	An optional script block may be passed in containing git commands to be executed against each specified branch after it has been checked out. The script will be split by semicolon (default) or a user-defined separator, and each command run in turn.
	The output of the command has three components: header (in the form "<RepoName> | <BranchName>"), command, and results. Each section can be directed to the host, the pipeline, or suppressed. By default, the header, command, and results are only written when GitScript is used.

	.PARAMETER Repo
	The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
	If the Repo parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.
	For examples of using the Repo parameter, refer to the help text for Get-GitRepo.

	.PARAMETER BranchName
	The names of the branches to be checked out.
	Wildcard characters are allowed. The pattern will match against existing branches in the specified repository.
	A warning will be generated for any values that do not match the name of an existing branch.

	.PARAMETER SetLocation
	Sets the working directory to the top-level directory of the specified repository.
	In the case where multiple Repo values are passed in, the location will reflect the repository that was specified last.

	.PARAMETER GitScript
	Used to provide git commands that will be executed against the specified branches.
	The default command separator is the semicolon (";").
	An alternative separator can be specified with the GitScriptSeparator parameter or by setting $Powdrgit.DefaultGitScriptSeparator.
	A literal separator character can be specified with a backtick escape e.g. "`;".

	.PARAMETER HeaderOut
	Used to suppress, direct, or color the background of the header output.
	When the value is 'None', the header will be suppressed.
	When the value is 'Pipe', the header will be sent to the pipeline.
	When the value is a standard Powershell color, the header will be written to the host with a background in that color.
	When GitScript is provided, default is 'DarkGray'; otherwise it is 'None'.

	.PARAMETER CommandOut
	Used to suppress, direct, or color the command output.
	When the value is 'None', the command will be suppressed.
	When the value is 'Pipe', the command will be sent to the pipeline.
	When the value is a standard Powershell color, the command will be written to the host in that color.
	Default is 'Green'.

	.PARAMETER ResultsOut
	Used to suppress, direct, or color the results output.
	When the value is 'None', the results will be suppressed.
	When the value is 'Pipe', the results will be sent to the pipeline.
	When the value is 'Native', the results will be written to the host using both native git colors and git output streams.
	When the value is a standard Powershell color, the results will be written to the host in that color.
	Default is 'DarkGray'.

	.PARAMETER GitScriptSeparator
	An alternative separator for splitting commands passed in to the GitScript parameter.
	If an empty string ('') or $null is passed in, no splitting will occur i.e. the script will execute as a single statement.
	The default separator is a semicolon (";").
	An empty of null value will treat the GitScript value as a single statement.
	The GitScriptSeparator parameter will override the value in $Powdrgit.DefaultGitScriptSeparator.

	.EXAMPLE
	## Check out a branch from outside a repository without naming a repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -BranchName main

	# Nothing was returned because the current location is not inside a repository.

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Set-GitBranch -Repo NonExistentRepo -BranchName main
	WARNING: [Set-GitBranch]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.

	.EXAMPLE
	## Check out a branch from outside a repository by naming a repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName feature1

	# Nothing was returned, but the specified branch is now checked out for the specified repository.

	# To confirm the checkout:
	PS C:\> Get-GitBranch -Repo MyToolbox -Current | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox feature1           True    False

	# Checkout main branch:
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main

	# To confirm the checkout:
	PS C:\> Get-GitBranch -Repo MyToolbox -Current | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox main               True    False

	.EXAMPLE
	## Check out a branch from outside a repository and use SetLocation parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation
	PS C:\PowdrgitExamples\MyToolbox>

	# Nothing was returned, but the specified branch is now checked out for the specified repository
	# Also, because the SetLocation switch was used, the current location (reflected in the prompt) changed to the repository's top-level directory.

	.EXAMPLE
	## Check out a branch from outside a repository and use GitScript to run a git command against the branch ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -GitScript 'git pull'
	MyToolbox | main
	git pull
	Already up to date.

	.EXAMPLE
	## Use GitScript to run a git command against a branch and capture the only the git output in a variable ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> $gitPullOutput = $null
	PS C:\> $gitPullOutput = Set-GitBranch -Repo MyToolbox -BranchName main -GitScript 'git pull' -ResultsOut Pipe
	MyToolbox | main
	git pull
	PS C:\> $gitPullOutput
	Already up to date.

	# The header and command output were still seen in the host as they were not suppressed with the HeaderOut and CommandOut parameters.

	.EXAMPLE
	## Use GitScript to run a git command against a branch and suppress all output ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -GitScript 'git pull' -HeaderOut None -CommandOut None -ResultsOut None
	PS C:\>

	# No output was seen in the host as it was suppressed with the HeaderOut, CommandOut, and ResultsOut parameters.

	.EXAMPLE
	## Run a git command against multiple branches ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> $branchesToPull = Get-GitBranch -Repo MyToolbox | Where-Object BranchName -in 'feature1','release' | Select-Object -ExpandProperty BranchName
	PS C:\> Set-GitBranch -Repo MyToolbox -BranchName $branchesToPull -GitScript 'git pull'
	MyToolbox | feature1
	git pull
	Already up to date.
	MyToolbox | release
	git pull
	Already up to date.
	PS C:\>

	# The command passed to the script block parameter was executed against each branch stored in the $branchesToPull variable.

	.EXAMPLE
	## Run a git command against multiple branches in multiple repositories ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo | Get-GitBranch | Set-GitBranch -GitScript 'git status'
	MyToolbox | feature1
	git status
	On branch feature1
	Your branch is ahead of 'origin/feature1' by 1 commit.
	(use "git push" to publish your local commits)

	nothing to commit, working tree clean
	MyToolbox | feature3
	git status
	On branch feature3
	nothing to commit, working tree clean
	MyToolbox | main
	git status
	On branch main
	Your branch is ahead of 'origin/main' by 3 commits.
	(use "git push" to publish your local commits)

	nothing to commit, working tree clean
	MyToolbox | release
	git status
	On branch release
	Your branch is up to date with 'origin/release'.

	nothing to commit, working tree clean
	Project1 | main
	git status
	On branch main
	nothing to commit, working tree clean
	Project1 | newfeature
	git status
	On branch newfeature
	nothing to commit, working tree clean

	# By piping the results of Get-GitRepo | Get-GitBranch into Set-GitBranch, we can see the status of all branches in all repositories in a single command.

	.INPUTS
	[System.String]
	Accepts string objects via the Repo parameter. The output of Get-GitBranch can be piped into Set-GitTag.

	.OUTPUTS
	[System.String]
	When output is present, returns String objects.

	.NOTES
	Author : nmbell

	.LINK
	Get-GitBranch
	.LINK
	Get-GitRepo
	.LINK
	Set-GitRepo
	.LINK
	Get-GitLog
	.LINK
	Invoke-GitExpression
	.LINK
	about_powdrgit
	#>

	# Function alias
	[Alias('sgb')]

	# Use cmdlet binding
	[CmdletBinding(
	  SupportsShouldProcess = $true
	, ConfirmImpact         = 'Medium'
	, HelpURI               = 'https://github.com/nmbell/powdrgit/blob/main/help/Set-GitBranch.md'
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
		  Mandatory                       = $true
		, HelpMessage                     = 'Enter the name of a branch to be checked out. Wildcard characters are allowed.'
		, Position                        = 1
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		)]
	#	[ArgumentCompleter()]
		[String[]]
		$BranchName = '*'

	,	[Switch]
		$SetLocation

	,	[ValidateNotNullOrEmpty()]
		[String]
		$GitScript

	,
	#	[ArgumentCompleter()]
		[String]
		$HeaderOut

	,
	#	[ArgumentCompleter()]
		[String]
		$CommandOut = 'Green'

	,
	#	[ArgumentCompleter()]
		[String]
		$ResultsOut = 'DarkGray'

	,	[String]
		$GitScriptSeparator

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
		If (!$HeaderOut)
		{
			$HeaderOut = 'None'
			If ($GitScript) { $HeaderOut = 'DarkGray' }
		}
	}

	PROCESS
	{
		$bk = 'P'

		# Find the repository name from current location
		If (!$PSBoundParameters.ContainsKey('Repo')) { $Repo = Get-GitRepo -Current | Select-Object -ExpandProperty RepoPath }

		# Get the repository info
		$validRepos = Get-ValidRepo -Repo $Repo

		# Set the branches
		ForEach ($validRepo in $validRepos)
		{
			# Move to the repository directory
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Moving to the repository directory: $($validRepo.RepoPath)"
			Set-GitRepo -Repo $validRepo.RepoPath -WarningAction Ignore

			# Get matching branches
			$validBranches = Get-GitBranch -Repo $validRepo.RepoPath -BranchName $BranchName -IncludeRemote -Verbose:$false -Debug:$false | Select-Object -ExpandProperty BranchName

			# Set branches
			ForEach ($validBranch in $validBranches)
			{
				Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Checking out branch $validBranch"
				$gitCommand = "git checkout $validBranch"
				$gitResults = Invoke-GitExpression -Command $gitCommand
				$currentBranch = Get-GitBranch -Current -Verbose:$false -Debug:$false | Select-Object -ExpandProperty BranchName
				Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Current branch is $currentBranch"
				If ($currentBranch -ne $validBranch)
				{
					$gitResults | Out-String | Write-Host
					If ($warn) { Write-Warning "[$thisFunctionName]Failed to checkout branch $validBranch`:" }
				}
				Else
				{
					Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Writing header"
					Write-GitBranchOut -OutputType Header -OutputValue "`r`n$($validRepo.RepoName) | $validBranch" -OutputStream $HeaderOut

					If ($GitScript)
					{
						Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Executing script block"
						If (!$PSBoundParameters.ContainsKey('GitScriptSeparator')) { $GitScriptSeparator = $Powdrgit.DefaultGitScriptSeparator }
						If (!$GitScriptSeparator) { $GitScriptSeparator = 'z%G1+$jNMuU%XUCASoPf312osOOjMHCOnh+kn3Ke' } # some unlikely to occur string
						Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Separator: $GitScriptSeparator"
						$GitScript = $GitScript.Replace('`'+$GitScriptSeparator,'<separator>') # to preserve escaped separators
						$gitScriptLines = $GitScript.Split($GitScriptSeparator)

						ForEach ($line in $gitScriptLines | Where-Object { $_.Trim() })
						{
							$line = $line.Replace('<separator>',$GitScriptSeparator).Trim()

							Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Writing command"
							Write-GitBranchOut -OutputType Command -OutputValue $line -OutputStream $CommandOut

							# results
							$shouldText = $line
							# If ($WhatIfPreference) { Write-Host "What if: $shouldText" } # handled by ShouldProcess
							If ($PSCmdlet.ShouldProcess($shouldText,$null,$null))
							{
								Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]$shouldText"
								If (!$ResultsOut -or $ResultsOut -eq 'Pipe')
								{
									Invoke-GitExpression -Command $line
								}
								ElseIf ($ResultsOut -eq 'None')
								{
									Invoke-GitExpression -Command $line | Out-Null
								}
								ElseIf ($ResultsOut -eq 'Native')
								{
									Invoke-Expression -Command $line
								}
								Else
								{
									Invoke-GitExpression -Command $line | Write-Host -ForegroundColor $ResultsOut
								}
							}
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
		If (!$SetLocation)
		{
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Setting location to original directory"
			Set-Location -Path $startLocation
		}

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($($duration.ToString('d\d\ hh\:mm\:ss\.fff')))"
		$PowdrgitCallDepth--
	}
}
