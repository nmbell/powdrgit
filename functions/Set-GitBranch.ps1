function Set-GitBranch
{
	<#
	.SYNOPSIS
	Checks out the specified branches for the specified repository.

	.DESCRIPTION
	Checks out the specified branches for the specified repository.
	An optional script block may be passed in containing git commands to be executed against each specified branch after it has been checked out. The command in the script block will be split by semi-colon (default) or a user-defined separator, and each command run in turn.
	The output of the command has three components: header (in the form "<RepoName> | <BranchName>"), command, and results. Each section can be directed to the host, the pipeline, or suppressed. By default, the header, command, and results are only written when GitScript is used.

	.PARAMETER RepoName
	The name of the git repository that has the specified branches.
	This should match the directory name of one of the repositories defined in the $GitRepoPath module variable. If there is no match, a warning is generated.
	When the parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.

	.PARAMETER BranchName
	The names of the branches to be checked out.
	These should match existing branches in the specified repository.

	.PARAMETER SetLocation
	Sets the working directory to the top-level directory of the specified repository.
	In the case where multiple RepoName values are passed in, the location will reflect the repository that was specified last.

	.PARAMETER GitScript
	Used to provide git commands that will be executed against the specified branches.
	The default command separator is the semi-colon (";").
	An alternative separator can be specified with the GitScriptSeparator parameter.
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
	The default separator is a semi-colon (";").

	.EXAMPLE
	## Check out a branch from outside a repository without naming a repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -BranchName main

	# Nothing was returned because the current location is not inside a repository.

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName NonExistentRepo -BranchName main
	WARNING: [Set-GitBranch]Repository 'NonExistentRepo' not found. Check the repository directory has been added to the $GitRepoPath module variable.

	.EXAMPLE
	## Check out a branch from outside a repository by naming a repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName feature1

	# Nothing was returned, but the specified branch is now checked out for the specified repository.

	# To confirm the checkout:
	PS C:\> Get-GitBranch -RepoName MyToolbox -Current | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox feature1           True    False

	# Checkout main branch:
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main

	# To confirm the checkout:
	PS C:\> Get-GitBranch -RepoName MyToolbox -Current | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

	RepoName  BranchName IsCheckedOut IsRemote
	--------  ---------- ------------ --------
	MyToolbox main               True    False

	.EXAMPLE
	## Check out a branch from outside a repository and use SetLocation parameter ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation
	PS C:\PowdrgitExamples\MyToolbox>

	# Nothing was returned, but the specified branch is now checked out for the specified repository
	# Also, because the SetLocation switch was used, the current location (reflected in the prompt) changed to the repository's top-level directory.

	.EXAMPLE
	## Check out a branch from outside a repository and use GitScript to run a git command against the branch ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -GitScript 'git pull'
	MyToolbox | main
	git pull
	Already up to date.

	.EXAMPLE
	## Use GitScript to run a git command against a branch and capture the only the git output in a variable ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> $gitPullOutput = $null
	PS C:\> $gitPullOutput = Set-GitBranch -RepoName MyToolbox -BranchName main -GitScript 'git pull' -ResultsOut Pipe
	MyToolbox | main
	git pull
	PS C:\> $gitPullOutput
	Already up to date.

	# The header and command output were still seen in the host as they were not suppressed with the HeaderOut and CommandOut parameters.

	.EXAMPLE
	## Use GitScript to run a git command against a branch and suppress all output ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -GitScript 'git pull' -HeaderOut None -CommandOut None -ResultsOut None
	PS C:\>

	# No output was seen in the host as it was suppressed with the HeaderOut, CommandOut, and ResultsOut parameters.

	.EXAMPLE
	## Run a git command against multiple branches ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> $branchesToPull = Get-GitBranch -RepoName MyToolbox | Where-Object BranchName -in 'feature1','release' | Select-Object -ExpandProperty BranchName
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName $branchesToPull -GitScript 'git pull'
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

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
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
	Accepts string objects via the RepoName parameter. The output of Get-GitBranch can be piped into Set-GitTag.

	.OUTPUTS
	[System.String]
	When output is present, returns String objects.

	.NOTES
	Author : nmbell

	.LINK
	about_powdrgit
	.LINK
	Get-GitBranch
	.LINK
	Get-GitRepo
	.LINK
	Invoke-GitExpression
	#>

    # Use cmdlet binding
    [CmdletBinding(
	  HelpURI = 'https://github.com/nmbell/powdrgit/blob/main/help/Set-GitBranch.md'
	)]

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
		  Mandatory                       = $true
		, Position                        = 1
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		, HelpMessage                     = 'Enter the name of a branch that exists in the repository'
		)]
		[ArgumentCompleter({
			Param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
			$argRepoName = $fakeBoundParameters.RepoName
			If (!($fakeBoundParameters.ContainsKey('RepoName')))
			{
				$argRepoName = Get-GitRepo -Verbose:$false -Current | Select-Object -ExpandProperty RepoName
			}
			Get-GitBranch -Verbose:$false -RepoName $argRepoName -IncludeRemote `
				| Select-Object -ExpandProperty BranchName `
				| Where-Object { $_ -like "$wordToComplete*" }
		})]
		[String[]]
		$BranchName

	,	[Switch]
		$SetLocation

	,	[ValidateNotNullOrEmpty()]
		[String]
		$GitScript

	,	[ArgumentCompleter({
			Param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
			@('None','Pipe')+[Enum]::GetValues([System.ConsoleColor]) | Where-Object { $_ -like "$wordToComplete*" }
		})]
		[String]
		$HeaderOut

	,	[ArgumentCompleter({
			Param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
			@('None','Pipe')+[Enum]::GetValues([System.ConsoleColor]) | Where-Object { $_ -like "$wordToComplete*" }
		})]
		[String]
		$CommandOut = 'Green'

	,	[ArgumentCompleter({
			Param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
			@('None','Pipe','Native')+[Enum]::GetValues([System.ConsoleColor]) | Where-Object { $_ -like "$wordToComplete*" }
		})]
		[String]
		$ResultsOut = 'DarkGray'

	,	[String]
		$GitScriptSeparator = ';'

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
		Push-Location -StackName SetGitBranch
		If (!$HeaderOut)
		{
			$HeaderOut = 'None'
			If ($GitScript) { $HeaderOut = 'DarkGray' }
		}
	}

	PROCESS
	{
		$wvBlock = 'P'

		# Find the repository name from current location
		If (!$RepoName) { $RepoName = Get-GitRepo -Current | Select-Object -ExpandProperty RepoName }

		# Go to the repository and get the repository info
		$repo = Set-GitRepo -RepoName $RepoName -PassThru -WarningAction SilentlyContinue

		# Set the branch
		If ($repo)
		{
			# Validate parameters
			$validBranches   = @()
			$invalidBranches = @()
			$allBranches     = Get-GitBranch -RepoName $RepoName -IncludeRemote -WarningAction SilentlyContinue | Select-Object -ExpandProperty BranchName
			$validBranches   = $BranchName | Where-Object { $_ -in    $allBranches }
			$invalidBranches = $BranchName | Where-Object { $_ -notin $allBranches }
			If ($invalidBranches)
			{
				Write-Warning ("[$thisFunctionName]The following are not valid branches in the '$RepoName' repository: $($invalidBranches -join ',')") -ErrorAction Stop
			}

			ForEach ($branch in $validBranches)
			{
				Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Checking out branch $branch"
				$gitCommand = "git checkout $branch"
				$gitResults = Invoke-GitExpression -Command $gitCommand
				$currentBranch = Get-GitBranch -Current | Select-Object -ExpandProperty BranchName
				Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Current branch is $currentBranch"
				If ($currentBranch -ne $branch)
				{
					$gitResults | Out-String | Write-Host
					Write-Warning "[$thisFunctionName]Failed to checkout branch $branch`:"
				}
				Else
				{
					Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Writing header"
					Write-GitBranchOut -OutputType Header -OutputValue "$RepoName | $branch" -OutputStream $HeaderOut

					If ($GitScript)
					{
						Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Executing script block"
						If (!$GitScriptSeparator) { $GitScriptSeparator = 'z%G1+$jNMuU%XUCASoPf312osOOjMHCOnh+kn3Ke' } # some unlikely to occur string
						$GitScript = $GitScript.Replace('`'+$GitScriptSeparator,'<separator>') # to preserve escaped separators
						$gitScriptLines = ($GitScript) -split $GitScriptSeparator

						ForEach ($line in $gitScriptLines | Where-Object { $_.Trim() })
						{
							$line = $line.Replace('<separator>',$GitScriptSeparator).Trim()

							Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Writing command"
							Write-GitBranchOut -OutputType Command -OutputValue $line -OutputStream $CommandOut

							# results
							Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Running command"
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
		ElseIf ($RepoName)
		{
			Write-Warning "[$thisFunctionName]Repository '$RepoName' not found. Check the repository directory has been added to the `$GitRepoPath module variable."
		}
    }

	END
	{
		$wvBlock = 'E'

		# Function END:
		If (!$SetLocation)
		{
			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Setting location to original directory"
			Pop-Location -StackName SetGitBranch
		}

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($('{0}d {1:00}:{2:00}:{3:00}.{4:000}' -f $duration.Days,$duration.Hours,$duration.Minutes,$duration.Seconds,$duration.Milliseconds))"
		$PowdrgitCallDepth--
	}
}
