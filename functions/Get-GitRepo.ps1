function Get-GitRepo
{
	<#
	.SYNOPSIS
	Gets the directory objects for valid repositories defined in the $Powdrgit.Path module variable.

	.DESCRIPTION
	Gets the directory objects for valid repositories defined in the $Powdrgit.Path module variable.

	.PARAMETER Repo
	The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
	The value passed in is matched against the directory paths defined in the $Powdrgit.Path module variable:
	  - If the value is an exact match to any repository names or paths, only those repositories will be returned.
	  - If there are no exact matches but the value is a partial match to any repository paths, those repositories will be returned.
	  - If there are no exact or partial matches, nothing will be returned.
	  - If the value is $null or an empty\whitespace string, nothing will be returned.
	If the Repo parameter is omitted, all valid repositories will be returned.
	When using tab completion, if a repository name is unique, only the name will be displayed, otherwise the full directory path is displayed. To force autocompletion to always show the full path, set $Powdrgit.AutoCompleteFullPaths = $true. Tab completion values will match on a repository name or path.

	.PARAMETER Current
	Limits the results to the current git repository.
	Returns nothing if the working directory is not a git repository.
	Will return the current repository when the working directory is either the repository directory or any of its subdirectories.

	.EXAMPLE
	## Get all valid repositories defined in the $Powdrgit.Path module variable ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo | Select-Object -ExpandProperty RepoName
	MyToolbox
	Project1

	.EXAMPLE
	## Get the repository by name ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo -Repo MyToolBox | Select-Object -ExpandProperty RepoName
	MyToolbox

	.EXAMPLE
	## Get the repository by directory path ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo -Repo 'C:\PowdrgitExamples\MyToolbox' | Select-Object -ExpandProperty RepoName
	MyToolbox

	.EXAMPLE
	## Get the repository by partial match ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo -Repo 'Examples\MyTool' | Select-Object -ExpandProperty RepoName
	MyToolbox

	.EXAMPLE
	## Get the repository by file path ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo -Repo 'C:\PowdrgitExamples\MyToolbox\feature1_File1.txt' | Select-Object -ExpandProperty RepoName
	MyToolbox

	.EXAMPLE
	## Get the repository from multiple inputs ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo -Repo 'Examples\MyTool','Project1' | Select-Object -ExpandProperty RepoName
	Project1
	MyToolbox

	# Both the partial match and exact match were returned

	.EXAMPLE
	## Get the current repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo -Current
	PS C:\>

	# Nothing was returned because the current location is not inside a repository.

	PS C:\> Set-GitRepo -Repo MyToolbox # move to the repository directory
	PS C:\PowdrgitExamples\MyToolbox> Get-GitRepo -Current | Select-Object -ExpandProperty RepoName
	MyToolbox

	# This time the repository name is returned because we were inside a repository.

	.EXAMPLE
	## Pass $null to the Repo parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo -Repo $null
	PS C:\>

	.INPUTS
	[System.String]
	Accepts string objects via the Repo parameter.

	.OUTPUTS
	[GitRepo]
	Returns a custom GitRepo object. The DirectoryInfo property contains the filesystem directory object for the repository.

	.NOTES
	Author : nmbell

	.LINK
	Find-GitRepo
	.LINK
	Set-GitRepo
	.LINK
	New-GitRepo
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
	[Alias('ggr')]

	# Use cmdlet binding
	[CmdletBinding(
	  DefaultParameterSetName = 'Repo'
	, HelpURI                 = 'https://github.com/nmbell/powdrgit/blob/main/help/Get-GitRepo.md'
	)]

	# Declare parameters
	Param(

		[Parameter(
		  Mandatory                       = $false
		, Position                        = 0
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		, ParameterSetName                = 'Repo'
		)]
	#	[ArgumentCompleter()]
		[Alias('RepoName','RepoPath')]
		[String[]]
		$Repo

	,	[Parameter(ParameterSetName = 'Current')]
		[Switch]
		$Current

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
		$outputPaths = @()

		# Get list of all valid repository paths
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Getting list of repositories from the `$Powdrgit.Path module variable:"
		$allRepoPaths = Test-PowdrgitPath -PassThru -WarningAction Ignore
		# $allRepoPaths | ForEach-Object { Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]    $_" }

		# Group paths by repository name
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Grouping paths by repository name"
		$repoGroups = $allRepoPaths `
					  | Select-Object @{ n = 'RepoPath'; e = { $_ } },@{ n = 'RepoName'; e = { (Split-Path -Path $_ -Leaf) } } `
					  | Group-Object -Property RepoName
	}

	PROCESS
	{
		$bk = 'P'

		# Keep track of which items in Repo have been matched: +ve for exact matches, -ve for partial matches
		$RepoHash = @{}
		$Repo | Select-Object -Unique | ForEach-Object { $RepoHash.$_ = 0 }

		# Get exact name matches
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Getting exact matches on repository name:"
		ForEach ($repoGroup in $repoGroups)
		{
			If ($repoGroup.Name -in $RepoHash.Keys)
			{
				ForEach ($repoGroupPath in $repoGroup.Group.RepoPath)
				{
					$outputPaths += $repoGroupPath
					# Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]  $repoGroupPath"
				}
				$RepoHash.$($repoGroup.Name) = $repoGroup.Count
			}
		}

		# Get exact path matches
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Getting exact matches on repository path:"
		ForEach ($repoPath in $allRepoPaths)
		{
			If ($repoPath -in $RepoHash.Keys)
			{
				$RepoHash.$repoPath = 1
				$outputPaths += $repoPath
				# Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]  $repoPath"
			}
		}

		# Get like path matches
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Getting like matches on repository path:"
		ForEach ($repoPath in $allRepoPaths)
		{
			If ($Current)
			{
				If (Test-SubPath -ParentPath $repoPath -ChildPath $PWD.Path)
				{
					$outputPaths += $repoPath
					# Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]  $repoPath"
				}
			}
			ElseIf ($PSBoundParameters.ContainsKey('Repo'))
			{
				ForEach ($_Repo in $RepoHash.Keys | Where-Object { $RepoHash.$_ -le 0 })
				{
					$isPathMatch = $false
					If ([String]::IsNullOrWhiteSpace($_Repo))
					{
						$isPathMatch = $isPathMatch -or $false
					}
					ElseIf ($repoPath -like "*$_Repo*")
					{
						$isPathMatch = $isPathMatch -or $true
					}
					ElseIf ($_Repo)
					{
						$isPathMatch = $isPathMatch -or (Test-SubPath -ParentPath $repoPath -ChildPath $_Repo)
					}
					If ($isPathMatch)
					{
						$RepoHash.$_Repo -= 1
						$outputPaths += $repoPath
						# Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]  $repoPath"
					}
				}
			}
			Else
			{
				$outputPaths += $repoPath
				# Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]  $repoPath"
			}
		}

		# Output the matching repositories
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Outputting the matching repositories"
		ForEach ($outputPath in $outputPaths | Select-Object -Unique)
		{
			Get-Item -Path $outputPath -ErrorAction Ignore `
			| ForEach-Object {
				[GitRepo]@{
					'RepoName'      = $_.Name
					'RepoPath'      = $_.FullName
					'DirectoryInfo' = $_
					'IsNameUnique'  = $(($repoGroups | Where-Object Name -eq $_.Name).Count -eq 1)
					'IsBare'        = $($_.Name -like '*.git')
				}
			}
		}
		Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Found matching repositories: $('{0,3}' -f $outputPaths.Count)"

		# Output the match counts if necessary
		If ($PSBoundParameters.ContainsKey('InformationVariable'))
		{
			Write-Information -MessageData $RepoHash -Tags 'f6c9c6f3-11e4-49d7-abff-5d26c0b37160'
		}
	}

	END
	{
		$bk = 'E'

		# Function END:

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($($duration.ToString('d\d\ hh\:mm\:ss\.fff')))"
		$PowdrgitCallDepth--
	}
}
