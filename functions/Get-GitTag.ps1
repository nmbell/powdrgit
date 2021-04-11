function Get-GitTag
{
	<#
	.SYNOPSIS
	Gets a list of tags for the specified repository.

	.DESCRIPTION
	Gets a list of tags for the specified repository.
	By default, tags are returned in tag name (alphabetical) order.

	.PARAMETER RepoName
	The name of the git repository to return.
	This should match the directory name of one of the repositories defined in $GitRepoPath. If there is no match, a warning is generated.
	When the parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.

	.EXAMPLE
	## Call from outside a repository without parameters ##
	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitTag
	PS C:\>

	# Nothing was returned because a RepoName was not provided.

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitTag -RepoName NonExistentRepo
	WARNING: [Get-GitTag]Repository 'NonExistentRepo' not found. Check the repository directory has been added to the $GitRepoPath variable.

	.EXAMPLE
	## Call from outside a repository with RepoName parameter ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitTag -RepoName MyToolbox | Format-Table -Property RepoName,TagName,TagType,TagSubject

	RepoName  TagName        TagType TagSubject
	--------  -------        ------- ----------
	MyToolbox annotatedTag   tag     This is an annotated tag
	MyToolbox lightweightTag commit  feature1 commit

	# The tags were returned even though the command was issued from outside the repository directory.

	.EXAMPLE
	## Get all tags of the current repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -RepoName MyToolbox
	PS C:\PowdrgitExamples\MyToolbox> Get-GitTag | Format-Table -Property RepoName,TagName,TagType,TagSubject

	RepoName  TagName        TagType TagSubject
	--------  -------        ------- ----------
	MyToolbox annotatedTag   tag     This is an annotated tag
	MyToolbox lightweightTag commit  feature1 commit

	.OUTPUTS
	[GitTag]
	Returns a custom GitTag object. For details use Get-Member at a command prompt e.g.:
	PS C:\PowdrgitExamples\MyToolbox> Get-GitTag | Get-Member -MemberType Properties

	.NOTES
	Author : nmbell

	.LINK
	Get-GitBranch
	Get-GitRepo
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
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finding current location"
		Push-Location -StackName GetGitTag

		$startOfText = '!!>>' # commit info delimiter
		$endOfText   = '<<!!' # commit info delimiter
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
			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finding tags"
			$gitCommand = 'git for-each-ref "refs/tags" --format="'+$startOfText+'%(*objectname)|%(objectname)|%(refname)|%(objecttype)|%(subject)|%(body)|%(taggerdate:iso8601-strict-local)|%(taggername)|%(taggeremail:trim)'+$endOfText+'"' # https://git-scm.com/docs/git-for-each-ref#_field_names
			$gitResults = Invoke-GitExpression -Command $gitCommand -SuppressGitErrorStream `
							| ConvertTo-GitParsableResults -StartOfText $startOfText -EndOfText $endOfText

			ForEach ($line in $gitResults | Where-Object { $_.Trim() })
			{
				$lineSplit = $line.Replace($startOfText,'').Replace($endOfText,'').Split('|')

				$tagName  = Split-Path -Path $lineSplit[2] -Leaf
				$tagdate  = If ($lineSplit[6]) { [DateTime]::Parse($lineSplit[6]) } Else { $null }
				$sha1Hash = If ($lineSplit[3] -eq 'commit') { $lineSplit[1] } Else { $lineSplit[0] }

				# Output
				[GitTag]@{
					'RepoName'    = $repo.Name
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
		Pop-Location -StackName GetGitTag

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($('{0}d {1:00}:{2:00}:{3:00}.{4:000}' -f $duration.Days,$duration.Hours,$duration.Minutes,$duration.Seconds,$duration.Milliseconds))"
		$PowdrgitCallDepth--
	}
}
