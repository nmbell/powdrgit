function Get-GitRepo
{
	<#
	.SYNOPSIS
	Gets the directory objects for valid repositories defined in the $GitRepoPath module variable.

	.DESCRIPTION
	Gets the directory objects for valid repositories defined in the $GitRepoPath module variable.

	.PARAMETER RepoName
	The name of the git repository to return.
	The powdrgit module always takes the name of the top-level repository directory as the repository name. It does not use values from a repository's config or origin URL as the name.
	This should match the directory name of one of the repositories defined in the $GitRepoPath module variable. If there is no match, nothing will be returned.
	When the parameter is omitted, all valid repositories will be returned.

	.PARAMETER Path
	The path of a git repository directory or any of its subdirectories or files.

	.PARAMETER Current
	Limits the results to the current git repository.
	Returns nothing if the working directory is not a git repository.
	Will return the current repository when the working directory is either the repository directory or any of its subdirectories.

	.EXAMPLE
	## Get all valid repositories defined in the $GitRepoPath module variable ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo | Select-Object -ExpandProperty RepoName
	MyToolbox
	Project1

	.EXAMPLE
	## Get the repository by RepoName ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo -RepoName MyToolBox | Select-Object -ExpandProperty RepoName
	MyToolbox

	.EXAMPLE
	## Get the repository by Path ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo -Path 'C:\PowdrgitExamples\MyToolbox' | Select-Object -ExpandProperty RepoName
	MyToolbox

	.EXAMPLE
	## Get the current repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo -Current
	PS C:\>

	# Nothing was returned because the current location is not inside a repository.

	PS C:\> Set-GitRepo -RepoName MyToolbox # move to the repository directory
	PS C:\PowdrgitExamples\MyToolbox> Get-GitRepo -Current | Select-Object -ExpandProperty RepoName
	MyToolbox

	# This time the repository name is returned because we were inside a repository.

	.INPUTS
	[System.String]
	Accepts string objects via the RepoName parameter.

	.OUTPUTS
	[System.IO.DirectoryInfo] (extended)
	Returns directory objects extended with a RepoName (String) alias property.

	.NOTES
	Author : nmbell

	.LINK
	about_powdrgit
	.LINK
	Find-GitRepo
	.LINK
	Set-GitRepo
	.LINK
	Test-GitRepoPath
	#>

    # Use cmdlet binding
	[CmdletBinding(
	  DefaultParameterSetName = 'RepoName'
	, HelpURI                 = 'https://github.com/nmbell/powdrgit/blob/main/help/Get-GitRepo.md'
	)]

    # Declare parameters
    Param(

		[Parameter(
		  ParameterSetName                = 'RepoName'
		, Mandatory                       = $false
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

	,	[Parameter(ParameterSetName = 'Path')]
		[ArgumentCompleter({
			Param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
			Get-GitRepo -Verbose:$false `
				| Select-Object @{ n = 'QuotedFullName'; e = { "'"+$_.FullName+"'" } } `
				| Select-Object -ExpandProperty QuotedFullName `
				| Where-Object { $_ -like "$wordToComplete*" } `
				| Sort-Object
		})]
		[Alias('FullName')]
		[String]
		$Path

	,	[Parameter(ParameterSetName = 'Current')]
		[Switch]
		$Current

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
		Push-Location -StackName GetGitRepo
	}

	PROCESS
	{
		$wvBlock = 'P'

		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Getting list of repositories from the `$GitRepoPath module variable"
		ForEach ($repoPath in (Test-GitRepoPath -PassThru -NoWarn)) # suppress warning output here
		{
			Get-Item -Path $repoPath -ErrorAction SilentlyContinue `
				| Where-Object { Test-Path -Path "$repoPath\.git" } `
				| Where-Object {
					If ($Current)
					{
						Get-Location -StackName GetGitRepo | Test-SubPath -ParentPath $_.FullName
					}
					ElseIf ($Path)
					{
						Test-SubPath -ParentPath $_.FullName -ChildPath $Path
					}
					ElseIf ($RepoName)
					{
						$_.Name -eq $RepoName
					}
					ElseIf (!$PSBoundParameters.ContainsKey('RepoName'))
					{
						$true
					}
				} `
				| ForEach-Object { Add-Member -InputObject $_ -MemberType AliasProperty -Name RepoName -Value Name -PassThru }
		}
    }

	END
	{
		$wvBlock = 'E'

		# Function END:
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Setting location to original directory"
		Pop-Location -StackName GetGitRepo

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($('{0}d {1:00}:{2:00}:{3:00}.{4:000}' -f $duration.Days,$duration.Hours,$duration.Minutes,$duration.Seconds,$duration.Milliseconds))"
		$PowdrgitCallDepth--
	}
}
