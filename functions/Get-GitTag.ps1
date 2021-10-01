function Get-GitTag
{
	<#
	.SYNOPSIS
	Gets a list of tags for the specified repository.

	.DESCRIPTION
	Gets a list of tags for the specified repository.
	By default, tags are returned in tag name (alphabetical) order.

	.PARAMETER Repo
	The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
	If the Repo parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.
	For examples of using the Repo parameter, refer to the help text for Get-GitRepo.

	.EXAMPLE
	## Call from outside a repository without parameters ##
	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitTag
	PS C:\>

	# Nothing was returned because a Repo was not provided.

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Get-GitTag -Repo NonExistentRepo
	WARNING: [Get-GitTag]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.

	.EXAMPLE
	## Call from outside a repository with Repo parameter ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitTag -Repo MyToolbox | Format-Table -Property RepoName,TagName,TagType,TagSubject

	RepoName  TagName        TagType TagSubject
	--------  -------        ------- ----------
	MyToolbox annotatedTag   tag     This is an annotated tag
	MyToolbox lightweightTag commit  feature1 commit

	# The tags were returned even though the command was issued from outside the repository directory.

	.EXAMPLE
	## Get all tags of the current repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -Repo MyToolbox
	PS C:\PowdrgitExamples\MyToolbox> Get-GitTag | Format-Table -Property RepoName,TagName,TagType,TagSubject

	RepoName  TagName        TagType TagSubject
	--------  -------        ------- ----------
	MyToolbox annotatedTag   tag     This is an annotated tag
	MyToolbox lightweightTag commit  feature1 commit

	.EXAMPLE
	## Pipe results from Get-GitRepo ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo | Get-GitTag | Format-Table -Property RepoName,TagName,TagType,TagSubject

	RepoName  TagName        TagType TagSubject
	--------  -------        ------- ----------
	MyToolbox annotatedTag   tag     This is an annotated tag
	MyToolbox lightweightTag commit  feature1 commit
	Project1  lightweightTag commit  Initial commit

	.INPUTS
	[System.String]
	Accepts string objects via the Repo parameter. The output of Get-GitRepo can be piped into Get-GitTag.

	.OUTPUTS
	[GitTag]
	Returns a custom GitTag object. For details use Get-Member at a command prompt e.g.:
	PS C:\PowdrgitExamples\MyToolbox> Get-GitTag | Get-Member -MemberType Properties

	.NOTES
	Author : nmbell

	.LINK
	Get-GitCommit
	.LINK
	Get-GitLog
	.LINK
	Get-GitBranch
	.LINK
	Get-GitRepo
	.LINK
	about_powdrgit
	#>

	# Function alias
	[Alias('ggt')]

	# Use cmdlet binding
	[CmdletBinding(
	  HelpURI = 'https://github.com/nmbell/powdrgit/blob/main/help/Get-GitTag.md'
	)]

	# Declare parameters
	Param(

		[Parameter(
		  Mandatory                       = $false
		, Position                        = 0
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $true
		)]
	#	[ArgumentCompleter()]
		[Alias('RepoName','RepoPath')]
		[String[]]
		$Repo

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
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finding current location"
		$startLocation = $PWD.Path

		$startOfText = '!!>>' # commit info delimiter
		$endOfText   = '<<!!' # commit info delimiter
	}

	PROCESS
	{
		$bk = 'P'

		# Find the repository name from current location
		If (!$PSBoundParameters.ContainsKey('Repo')) { $Repo = Get-GitRepo -Current | Select-Object -ExpandProperty RepoPath }

		# Get the repository info
		$validRepos = Get-ValidRepo -Repo $Repo

		# Get the tags
		ForEach ($validRepo in $validRepos)
		{
			# Go to the repository and get the repository info
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Moving to the repository directory: $($validRepo.RepoPath)"
			Set-GitRepo -Repo $validRepo.RepoPath -WarningAction Ignore

			# Get tag info
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finding tags"
			$gitCommand = 'git for-each-ref "refs/tags" --format="'+$startOfText+'%(*objectname)|%(objectname)|%(refname)|%(objecttype)|%(subject)|%(body)|%(taggerdate:iso8601-strict-local)|%(taggername)|%(taggeremail:trim)'+$endOfText+'"' # https://git-scm.com/docs/git-for-each-ref#_field_names
			$gitResults = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream `
						  | ConvertTo-GitParsableResults -StartOfText $startOfText -EndOfText $endOfText
			Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Found tags: $('{0,3}' -f ($gitResults | Measure-Object).Count)"

			ForEach ($line in $gitResults | Where-Object { $_.Trim() })
			{
				$lineSplit = $line.Replace($startOfText,'').Replace($endOfText,'').Split('|')

				$tagName  = Split-Path -Path $lineSplit[2] -Leaf
				$tagdate  = If ($lineSplit[6]) { [DateTime]::Parse($lineSplit[6]) } Else { $null }
				$sha1Hash = If ($lineSplit[3] -eq 'commit') { $lineSplit[1] } Else { $lineSplit[0] }

				# Output
				[GitTag]@{
					'RepoName'    = $validRepo.RepoName
					'RepoPath'    = $validRepo.RepoPath
					'SHA1Hash'    = $sha1Hash
					'TagHash'     = $lineSplit[1]
					'TagName'     = $tagName
					'TagFullName' = $lineSplit[2]
					'TagType'     = $lineSplit[3]
					'TagSubject'  = $lineSplit[4]
					'TagBody'     = $lineSplit[5]
					'TagDate'     = $tagdate
					'TaggerName'  = $lineSplit[7]
					'TaggerEmail' = $lineSplit[8]
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
