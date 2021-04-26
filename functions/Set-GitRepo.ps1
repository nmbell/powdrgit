function Set-GitRepo
{
	<#
	.SYNOPSIS
	Sets the working directory to the top level directory of the specified repository.

	.DESCRIPTION
	Sets the working directory to the top level directory of the specified repository.

	.PARAMETER RepoName
	The name of the git repository to return.
	The powdrgit module always takes the name of the top-level repository directory as the repository name. It does not use values from a repository's config or origin URL as the name.
	This should match the directory name of one of the repositories defined in the $GitRepoPath module variable. If there is no match, a warning is generated.

	.PARAMETER PassThru
	Returns the directory object for the repository top-level directory.

	.EXAMPLE
	## Call without specifying a repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo
	PS C:\>

	# The current location (reflected in the prompt) did not change.

	.EXAMPLE
	## Move to a non-existent repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -RepoName NonExistentRepo
	WARNING: [Set-GitRepo]Repository 'NonExistentRepo' not found. Check the repository directory has been added to the $GitRepoPath module variable.
	PS C:\>

	# The current location (reflected in the prompt) did not change.

	.EXAMPLE
	## Move to an existing repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -RepoName MyToolbox
	PS C:\PowdrgitExamples\MyToolbox>

	# The current location (reflected in the prompt) changed to the repository's top-level directory.

	.EXAMPLE
	## Call with PassThru switch ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -RepoName MyToolbox -PassThru | Select-Object -ExpandProperty FullName
	C:\PowdrgitExamples\MyToolbox
	PS C:\PowdrgitExamples\MyToolbox>

	# Because the object returned is an extension of a file system object, any of its usual properties are available in the output.

	.INPUTS
	[System.String]
	Accepts string objects via the RepoName parameter.

	.OUTPUTS
	[System.IO.DirectoryInfo]
	When the PassThru switch is used, returns directory objects.

	.NOTES
	Author : nmbell

	.LINK
	https://github.com/nmbell/powdrgit/help/Set-GitRepo.md
	.LINK
	about_powdrgit
	.LINK
	Find-GitRepo
	.LINK
	Get-GitRepo
	.LINK
	Test-GitRepoPath
	#>

    # Use cmdlet binding
	[CmdletBinding()]

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

	,	[Switch]
		$PassThru

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
	}

	PROCESS
	{
		$wvBlock = 'P'

		# Get the repository info
		$repo = Get-GitRepo -RepoName $RepoName

		If ($repo)
		{
			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Setting location to repository directory: $($repo.FullName)"
			Set-Location -Path $repo.FullName
			If ($PassThru)
			{
				Write-Output $repo
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

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($('{0}d {1:00}:{2:00}:{3:00}.{4:000}' -f $duration.Days,$duration.Hours,$duration.Minutes,$duration.Seconds,$duration.Milliseconds))"
		$PowdrgitCallDepth--
	}
}
