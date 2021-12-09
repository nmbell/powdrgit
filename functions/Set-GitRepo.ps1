function Set-GitRepo
{
	<#
	.SYNOPSIS
	Sets the working directory to the top level directory of the specified repository.

	.DESCRIPTION
	Sets the working directory to the top level directory of the specified repository.

	.PARAMETER Repo
	The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
	If the Repo parameter is omitted, nothing will happen.
	For examples of using the Repo parameter, refer to the help text for Get-GitRepo.

	.PARAMETER PassThru
	Returns the directory object for the repository top-level directory.

	.EXAMPLE
	## Call without specifying a repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo
	PS C:\>

	# The current location (reflected in the prompt) did not change.

	.EXAMPLE
	## Move to a non-existent repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Set-GitRepo -Repo NonExistentRepo
	WARNING: [Set-GitRepo]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.

	# The current location (reflected in the prompt) did not change.

	.EXAMPLE
	## Move to an existing repository ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -Repo MyToolbox
	PS C:\PowdrgitExamples\MyToolbox>

	# The current location (reflected in the prompt) changed to the repository's top-level directory.

	.EXAMPLE
	## Call with PassThru switch ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitRepo -Repo MyToolbox -PassThru | Select-Object -ExpandProperty RepoPath
	C:\PowdrgitExamples\MyToolbox
	PS C:\PowdrgitExamples\MyToolbox>

	# Because the object returned is an extension of a file system object, any of its usual properties are available in the output.

	.EXAMPLE
	## Call with Repo value matching multiple repositories ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Set-GitRepo -Repo PowdrgitExamples -PassThru | Select-Object -ExpandProperty RepoPath
	C:\PowdrgitExamples\MyToolbox
	WARNING: [Set-GitRepo]'PowdrgitExamples' matched multiple repositories. Please confirm any results or actions are as expected.
	C:\PowdrgitExamples\MyToolbox
	C:\PowdrgitExamples\Project1
	PS C:\PowdrgitExamples\Project1>

	# Note: in this case, the final location that is set will be the matching repository path that is last alphabetically.

	.INPUTS
	[System.String[]]
	Accepts string objects via the Repo parameter.

	.OUTPUTS
	[System.IO.DirectoryInfo]
	When the PassThru switch is used, returns directory objects.

	.NOTES
	Author : nmbell

	.LINK
	Find-GitRepo
	.LINK
	Get-GitRepo
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
	.LINK
	https://github.com/nmbell/powdrgit/blob/main/help/about_powdrgit.md
	#>

	# Function alias
	[Alias('sgr')]

	# Use cmdlet binding
	[CmdletBinding(
	  HelpURI = 'https://github.com/nmbell/powdrgit/blob/main/help/Set-GitRepo.md'
	)]

	# Declare output type
	[OutputType([System.IO.DirectoryInfo])]

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

	,	[Switch]
		$PassThru

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
	}

	PROCESS
	{
		$bk = 'P'

		# Get the repository info
		$validRepos = Get-ValidRepo -Repo $Repo

		# Set the location
		ForEach ($validRepo in $validRepos)
		{
			Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Setting location to repository directory: $($validRepo.RepoPath)"
			Set-Location -Path $validRepo.RepoPath
			If ($PassThru)
			{
				Write-Output $validRepo
			}
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
