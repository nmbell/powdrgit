function Test-GitRepoPath
{
	<#
	.SYNOPSIS
	Validates the paths stored in the $GitRepoPath module variable.

	.DESCRIPTION
	Validates the paths stored in the $GitRepoPath module variable.
	The functions evaluates each path and returns the count of paths in the $GitRepoPath module variable that are valid git repositories.
	A warning message is also generated when:
	 - a path doesn't exist; or
	 - a path is not a git repository; or
	 - the $GitRepoPath module variable is not defined (i.e. an empty string or $null).
	A NoWarn switch allows these warnings to be suppressed.
	A PassThru parameter allows a string array of only valid paths to be returned instead of the count of valid paths.

	.PARAMETER NoWarn
	Suppresses warnings.

	.PARAMETER PassThru
	Returns a string array of only valid paths.

	.EXAMPLE
	## Valid paths ##

	# This example assumes that:
	# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1'
	PS C:\> Test-GitRepoPath
	2

	.EXAMPLE
	## Valid and invalid paths ##

	# This example assumes that:
	# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\NotAGitRepo directory exists but is not a git repository (i.e. does not contain a .git subdirectory).
	# - C:\PowdrgitExamples\NonExistentFolder directory does not exist.

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\NonExistentFolder'
	PS C:\> Test-GitRepoPath
	WARNING: [Test-GitRepoPath]Path is not a repository: C:\PowdrgitExamples\NotAGitRepo
	WARNING: [Test-GitRepoPath]Directory does not exist: C:\PowdrgitExamples\NonExistentFolder
	2

	.EXAMPLE
	## The $GitRepoPath module variable is undefined ##

	PS C:\> $GitRepoPath = $null
	PS C:\> Test-GitRepoPath
	WARNING: [Test-GitRepoPath]The $GitRepoPath module variable is not defined.
	0
	PS C:\> $GitRepoPath = ''
	PS C:\> Test-GitRepoPath
	WARNING: [Test-GitRepoPath]The $GitRepoPath module variable is not defined.
	0

	.EXAMPLE
	## Valid and invalid paths - suppress warnings with -NoWarn ##

	# This example assumes that:
	# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\NotAGitRepo directory exists but is not a git repository (i.e. does not contain a .git subdirectory).
	# - C:\PowdrgitExamples\NonExistentFolder directory does not exist.

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\NonExistentFolder'
	PS C:\> $MyWarnings = $null
	PS C:\> Test-GitRepoPath -WarningVariable MyWarnings -WarningAction SilentlyContinue
	2
	PS C:\> $MyWarnings
	[Test-GitRepoPath]Path is not a repository: C:\PowdrgitExamples\NotAGitRepo
	[Test-GitRepoPath]Directory does not exist: C:\PowdrgitExamples\NonExistentFolder

	# Warnings were not returned to the console, but were still captured in the MyWarnings variable.

	PS C:\> $MyWarnings = $null
	PS C:\> Test-GitRepoPath -NoWarn -WarningVariable MyWarnings
	2
	PS C:\> $MyWarnings
	PS C:\>

	# $MyWarnings is empty because warnings were never generated.

	.EXAMPLE
	## Valid and invalid paths - return an array of valid paths with PassThru ##

	# This example assumes that
	# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\NotAGitRepo directory exists but is not a git repository (i.e. does not contain a .git subdirectory).
	# - C:\PowdrgitExamples\NonExistentFolder directory does not exist.

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\NonExistentFolder'
	PS C:\> $GitRepoPath -split ';'
	C:\PowdrgitExamples\MyToolbox
	C:\PowdrgitExamples\Project1
	C:\PowdrgitExamples\NotAGitRepo
	C:\PowdrgitExamples\NonExistentFolder

	# All paths in the $GitRepoPath module variable were returned.

	PS C:\> Test-GitRepoPath -NoWarn -PassThru
	C:\PowdrgitExamples\MyToolbox
	C:\PowdrgitExamples\Project1

	# Only the paths that are valid git repositories were returned.

	.INPUTS
	None.

	.OUTPUTS
	[System.Int32]
	[System.String]
	Returns Int32 objects by default. When the PassThru parameter is used, returns String objects.

	.NOTES
	Author : nmbell

	.LINK
	https://github.com/nmbell/powdrgit/blob/main/help/Test-GitRepoPath.md
	.LINK
	about_powdrgit
	.LINK
	Find-GitRepo
	.LINK
	Get-GitRepo
	.LINK
	Set-GitRepo
	#>

    # Use cmdlet binding
    [CmdletBinding()]

    # Declare parameters
    Param(

		[Switch]
		$PassThru

	,	[Switch]
		$NoWarn

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

		$validCount = 0

		If (!$GitRepoPath)
		{
			If (!$NoWarn)
			{
				Write-Warning "[$thisFunctionName]The `$GitRepoPath module variable is not defined."
			}
		}

		If ($GitRepoPath)
		{
			ForEach ($repoPath in ($GitRepoPath -split ';'))
			{
				If ($repoPath)
				{
					If (!(Test-Path -Path $repoPath))
					{
						If (!$NoWarn)
						{
							Write-Warning "[$thisFunctionName]Directory does not exist: $repoPath"
						}
					}
					ElseIf (!(Test-Path -Path "$repoPath\.git"))
					{
						If (!$NoWarn)
						{
							Write-Warning "[$thisFunctionName]Path is not a repository: $repoPath"
						}
					}
					Else
					{
						If ($PassThru)
						{
							Write-Output $repoPath
						}
						$validCount++
					}
				}
			}
		}

		If (!$PassThru)
		{
			Write-Output $validCount
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
