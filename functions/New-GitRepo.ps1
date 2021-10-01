function New-GitRepo
{
	<#
	.SYNOPSIS
	Creates a new git repository and returns the repository or directory object.

	.DESCRIPTION
	Creates a new git repository and returns the repository or directory object.

	.PARAMETER Repo
	The name, or a relative or absolute path, to the git repository to create.
	If the directory does not exist, it will be created.
	If RepoPath is not specified, the repository is created at the current location.
	If the UseDefaultDir switch is used, then Repo allows a repository name or relative path.

	.PARAMETER UseDefaultDir
	Uses the directory stored in the $Powdrgit.DefaultDir variable as the parent directory.

	.PARAMETER Bare
	Create a bare repository.

	.PARAMETER InitialBranchName
	Name of the initial branch.
	If not specified, the git default will be used.

	.PARAMETER InitialCommit
	Make an initial commit against the new repo using the given text.
	This commit will associate any existing files in the repository with it and will be the parent to all subsequent commits.
	Until an initial commit has been made, the initial branch will not be visible in git.
	If multiple strings are passed in, the first string is used as the commit subject. All remaining strings are used as the commit body.

	.PARAMETER UseDefaultInitialCommit
	Same behavior as the InitialCommit parameter, but the commit message will use the value in $Powdrgit.DefaultInitialCommit.

	.PARAMETER TemplateDir
	Path to the template directory.
	Files and directories in the template directory whose name do not start with a dot will be copied to the new repository after it is created.

	.PARAMETER AppendPowdrgitPath
	Appends the path of the new repository to the $Powdrgit.Path module variable.

	.PARAMETER SetLocation
	Sets the location to the top-level directory of the new repository.

	.EXAMPLE
	## Call with no parameters ##

	PS C:\> New-Item -ItemType Directory -Path 'C:\MyEmptyFolder'
	PS C:\> Set-Location 'C:\MyEmptyFolder'
	PS C:\MyEmptyFolder> $r = New-GitRepo
	PS C:\MyEmptyFolder> Get-ChildItem -Hidden | Select-Object -ExpandProperty FullName
	C:\MyEmptyFolder\.git

	# A repository was created at the current location

	.EXAMPLE
	## Call with an absolute path ##

	PS C:\> $r = New-GitRepo -Repo 'C:\MyNewRepo'
	PS C:\> Get-ChildItem -Path 'C:\MyNewRepo' -Hidden | Select-Object -ExpandProperty FullName
	C:\MyNewRepo\.git

	# A repository was created at the specified location

	.EXAMPLE
	## Call with a relative path ##

	PS C:\> New-Item -ItemType Directory -Path 'C:\MyEmptyFolder'
	PS C:\> Set-Location 'C:\MyEmptyFolder'
	PS C:\MyEmptyFolder> $r = New-GitRepo -Repo 'MyRepos\MyNewRepo'
	PS C:\MyEmptyFolder> Get-ChildItem -Hidden -Recurse | Select-Object -ExpandProperty FullName
	C:\MyEmptyFolder\MyRepos\MyNewRepo\.git

	# A repository was created relative to the current location

	.EXAMPLE
	## Call with a repository name ##

	PS C:\> New-Item -ItemType Directory -Path 'C:\MyEmptyFolder'
	PS C:\> Set-Location 'C:\MyEmptyFolder'
	PS C:\MyEmptyFolder> $r = New-GitRepo -Repo 'MyNewRepo'
	PS C:\MyEmptyFolder> Get-ChildItem -Hidden -Recurse | Select-Object -ExpandProperty FullName
	C:\MyEmptyFolder\MyNewRepo\.git

	# A repository with the specified name was created at the current location

	.EXAMPLE
	## Call with UseDefaultDir ##

	PS C:\> $Powdrgit.DefaultDir = 'C:\PowdrgitExamples'
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> $r = New-GitRepo -Repo 'C:\PowdrgitExamples\MyNewRepo' -UseDefaultDir
	WARNING: [New-GitRepo]The UseDefaultDir switch cannot be used with an absolute path for Repo: C:\PowdrgitExamples\MyNewRepo.

	# A warning is generated for the incompatible parameter values.

	PS C:\> $r = New-GitRepo -Repo 'MyNewRepo' -UseDefaultDir
	PS C:\> Get-ChildItem -Path "$($Powdrgit.DefaultDir)\MyNewRepo" -Hidden -Recurse | Select-Object -ExpandProperty FullName
	C:\PowdrgitExamples\MyNewRepo\.git

	# A repository was created in the default directory.

	.EXAMPLE
	## Call with SetLocation ##

	PS C:\> $r = New-GitRepo -Repo 'C:\PowdrgitExamples\MyNewRepo' -SetLocation
	PS C:\PowdrgitExamples\MyNewRepo>

	# The location changed to the new repository.

	.EXAMPLE
	## Call with Bare ##

	PS C:\> $r = New-GitRepo -Repo 'C:\PowdrgitExamples\MyNewRepo' -Bare
	PS C:\> Get-ChildItem -Path 'C:\PowdrgitExamples\MyNewRepo*' -Directory | Select-Object -ExpandProperty FullName
	C:\PowdrgitExamples\MyNewRepo.git

	# The name of the repository was automatically appended with ".git" to indicate a bare repository.

	.EXAMPLE
	## Call with AppendPowdrgitPath ##

	PS C:\> $Powdrgit.Path = $null
	PS C:\> $r = New-GitRepo -Repo 'C:\PowdrgitExamples\MyNewRepo' -AppendPowdrgitPath
	PS C:\> $Powdrgit.Path
	C:\PowdrgitExamples\MyNewRepo
	PS C:\> $r.GetType().FullName
	GitRepo

	# The name of the repository was appended with ".git" to indicate a bare repository.
	# Because the repository exists in the $Powdrgit.Path module variable, New-GitRepo returns a GitRepo object.

	.EXAMPLE
	## Call with InitialBranchName and InitialCommit ##

	PS C:\> $r = New-GitRepo -Repo 'C:\PowdrgitExamples\MyNewRepo' -AppendPowdrgitPath -InitialBranchName 'MyBranch' -InitialCommit 'Initial commit'

	# AppendPowdrgitPath is used to make the repo visible to Powdrgit.
	# InitialCommit is used to make the branch visible in git.

	PS C:\> $r | Get-GitBranch | Select-Object RepoName,BranchName

	RepoName   BranchName
	--------   ----------
	MyNewRepo  MyBranch

	PS C:\> $r | Get-GitLog | Select-Object RepoName,SHA1Hash,Subject

	RepoName   SHA1Hash                                 Subject
	--------   --------                                 -------
	MyNewRepo  6ef6fab1a36bd165a898e06e053515ce114a4390 Initial commit

	.EXAMPLE
	## Call with TemplateDir ##

	PS C:\> $t = New-GitRepo -Repo 'C:\PowdrgitExamples\TemplateRepo' # create a template repository
	PS C:\> $f = New-Item -Path "$($t.FullName)\TemplateFile.txt" -ItemType File -Value 'This is a template file.' # add a file to the template repository
	PS C:\> $r = New-GitRepo -Repo 'C:\PowdrgitExamples\NewRepoFromTemplateRepo' -TemplateDir $t.FullName # create a new repository from the template repository
	PS C:\> Get-ChildItem -Path 'C:\PowdrgitExamples\NewRepoFromTemplateRepo' -Force -Recurse -Filter *.txt | Select-Object -ExpandProperty FullName
	C:\PowdrgitExamples\NewRepoFromTemplateRepo\.git\TemplateFile.txt

	# Note that git copies files from with working directory of the template repository to the git directory of the new repository.

	.OUTPUTS
	If the AppendPowdrgitPath switch was used, then a [GitRepo] object is returned. Otherwise a [System.IO.DirectoryInfo] object is returned.

	.NOTES
	Author : nmbell

	.LINK
	Find-GitRepo
	.LINK
	Get-GitRepo
	.LINK
	Set-GitRepo
	.LINK
	Remove-GitRepo
	.LINK
	Invoke-GitClone
	.LINK
	Add-PowdrgitPath
	.LINK
	Remove-PowdrgitPath
	.LINK
	Test-PowdrgitPath
	.LINK
	about_powdrgit
	#>

	# Function alias
	[Alias('ngr')]

	# Use cmdlet binding
	[CmdletBinding(
	  DefaultParameterSetName = 'InitialCommit'
	, SupportsShouldProcess   = $true
	, ConfirmImpact           = 'Medium'
	, HelpURI                 = 'https://github.com/nmbell/powdrgit/blob/main/help/New-GitRepo.md'
	)]

	# Declare parameters
	Param(

	 	[Parameter(
		  Mandatory                       = $false
		, Position                        = 0
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $true
		)]
		[Alias('FullName','Path','RepoName','RepoPath')]
		[ValidateNotNullOrEmpty()]
		[String[]]
		$Repo

	,	[Switch]
		$UseDefaultDir

	,	[Parameter(
		  ParameterSetName = 'Bare'
		)]
		[Switch]
		$Bare

	, 	[Parameter(
		  Mandatory                       = $false
		, Position                        = 1
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		)]
		[ValidateNotNullOrEmpty()]
		[String]
		$InitialBranchName

	,	[Parameter(
		  Mandatory                       = $false
		, Position                        = 2
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		, ParameterSetName                = 'InitialCommit'
		)]
		[ValidateNotNullOrEmpty()]
		[String[]]
		$InitialCommit

	,	[Parameter(
		  ParameterSetName = 'UseDefaultInitialCommit'
		)]
		[Switch]
		$UseDefaultInitialCommit

	, 	[Parameter(
		  Mandatory                       = $false
		, Position                        = 3
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		)]
		[ValidateNotNullOrEmpty()]
		[String]
		$TemplateDir

	,	[Switch]
		$AppendPowdrgitPath

	,	[Switch]
		$SetLocation

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
	}

	PROCESS
	{
		$bk = 'P'

		# Use the current path if none was supplied
		If (!$Repo) { $Repo = $PWD.Path }

		ForEach ($_Repo in $Repo)
		{
			# Validate Repo parameter
			<#
			Repo       UseDefaultDir=True UseDefaultDir=False
			----       ------------------ -------------------
			Absolute   Warning;NoOp       $Repo
			Relative   DefaultDir+$Repo   $PWD+$Repo
			NotPresent DefaultDir         $PWD
			#>
			$repoPath = $null
			If ($PSBoundParameters.ContainsKey('Repo'))
			{
				If ($_Repo -like '[A-Z]:\*' -or $_Repo -like '\\*') # if absolute path
				{
					If ($UseDefaultDir)
					{
						If ($warn) { Write-Warning "[$thisFunctionName]The UseDefaultDir switch cannot be used with an absolute path for Repo: $_Repo." }
					}
					Else
					{
						$repoPath = $_Repo
					}
				}
				Else
				{
					If ($UseDefaultDir)
					{
						If (Test-PowdrgitDefaultDir)
						{
							$repoPath = Join-Path -Path $Powdrgit.DefaultDir -ChildPath $_Repo
						}
					}
					Else
					{
						$repoPath = Join-Path -Path $PWD.Path -ChildPath $_Repo
					}
				}
			}
			Else
			{
				If ($UseDefaultDir)
				{
					If (Test-PowdrgitDefaultDir)
					{
						$repoPath = $Powdrgit.DefaultDir
					}
				}
				Else
				{
					$repoPath = $PWD.Path
				}
			}

			If ($repoPath)
			{
				Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Repository path: $repoPath"

				# Construct git command
				$gitCommand = "git init"
				If ($Bare)
				{
					$gitCommand += ' --bare'
					If ($repoPath -notlike '*.git') { $repoPath += '.git' }
				}
				If ($InitialBranchName) { $gitCommand += " --initial-branch=`"$InitialBranchName`"" }
				If ($TemplateDir      ) { $gitCommand += " --template=`"$TemplateDir`"" }
				$gitCommand += " `"$repoPath`""

				# Determine procession
				$shouldText = ("Creating repository: $repoPath")
				If ($WhatIfPreference) { Write-Host }
				$shouldProcess = $PSCmdlet.ShouldProcess($shouldText,$null,$null)

				# Create the repo
				# If ($WhatIfPreference) { Write-Host "What if: $shouldText" } # handled by ShouldProcess
				If ($shouldProcess)
				{
					Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]$shouldText"
					$gitResults = Invoke-GitExpression -Command $gitCommand
					If ($gitResults -like 'fatal:*')
					{
						If ($warn) { Write-Warning "[$thisFunctionName]$gitResults" }
					}
				}

				# Process remaining parameters and return the repository
				$shouldText = "Setting location: $repoPath"
				# If ($WhatIfPreference) { Write-Host "What if: $shouldText" } # moved to END block
				If ($shouldProcess)
				{
					Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]$shouldText"
					Set-Location -Path $repoPath -ErrorAction Ignore
				}
				If ($repoPath -eq $PWD.Path -or $WhatIfPreference)
				{
					If ($UseDefaultInitialCommit)
					{
						$InitialCommit = @($Powdrgit.DefaultInitialCommit)
					}
					If ($InitialCommit)
					{
						$commitSubject = "-m `"$($InitialCommit[0])`""
						$commitBody    = ''
						If ($InitialCommit.Count -gt 1)
						{
							$commitBody = "-m `"$($InitialCommit[1..($InitialCommit.Count-1)] -join "`r`n")`""
						}

						$shouldText = "Making initial commit: $($InitialCommit[0])"
						If ($WhatIfPreference) { Write-Host "What if: $shouldText" }
						If ($shouldProcess)
						{
							Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]$shouldText"
							Invoke-GitExpression -Command 'git add .' -SuppressGitSuccessStream -SuppressGitErrorStream
							Invoke-GitExpression -Command "git commit --allow-empty $commitSubject $commitBody" -SuppressGitSuccessStream -SuppressGitErrorStream
						}
					}

					If ($AppendPowdrgitPath)
					{
						$shouldText = 'Adding path to `$Powdrgit.Path'
						If ($WhatIfPreference) { Write-Host "What if: $shouldText" }
						If ($shouldProcess)
						{
							Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]$shouldText"
							Add-PowdrgitPath -Path $repoPath -WhatIf:$false -Confirm:$false
						}

						$shouldText = 'Returning [GitRepo]'
						If ($WhatIfPreference) { Write-Host "What if: $shouldText" }
						If ($shouldProcess)
						{
							Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]$shouldText"
							Get-GitRepo -Repo $repoPath
						}
					}
					Else
					{
						$shouldText = 'Returning [System.IO.DirectoryInfo]'
						If ($WhatIfPreference) { Write-Host "What if: $shouldText" }
						If ($shouldProcess)
						{
							Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]$shouldText"
							Get-Item -Path $repoPath
						}
					}
				}
				ElseIf ($repoPath -and $shouldProcess)
				{
					If ($warn) { Write-Warning "[$thisFunctionName]Could not move to repository location: $repoPath. Check the repository has been created." }
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
		Else
		{
			$shouldText = "Setting location: $repoPath"
			If ($WhatIfPreference) { Write-Host; Write-Host "What if: $shouldText" }
		}
		If ($WhatIfPreference) { Write-Host }

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($($duration.ToString('d\d\ hh\:mm\:ss\.fff')))"
		$PowdrgitCallDepth--
	}
}
