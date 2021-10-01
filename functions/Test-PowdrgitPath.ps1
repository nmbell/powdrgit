function Test-PowdrgitPath
{
	<#
	.SYNOPSIS
	Validates the paths stored in the $Powdrgit.Path module variable.

	.DESCRIPTION
	Validates the paths stored in the $Powdrgit.Path module variable.
	The functions evaluates each path and returns the count of paths in the $Powdrgit.Path module variable that are valid git repositories.
	Test-PowdrgitPath will ignore duplicate and empty/whitespace paths in the $Powdrgit.Path module variable, and will evaluate and/or output paths in alphabetical order.
	A warning message is also generated when:
	  - a path doesn't exist; or
	  - a path is not a git repository; or
	  - the $Powdrgit.Path module variable is not defined (i.e. an empty string or $null).
	A PassThru parameter allows a string array of only valid paths to be returned instead of the count of valid paths.

	.PARAMETER PassThru
	Returns a string array of only valid paths.

	.PARAMETER Failing
	Causes the function to return the count of paths in $Powdrgit.Path that either do not exist or are not git repositories.

	.EXAMPLE
	## Valid paths ##

	# This example assumes that:
	# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1'
	PS C:\> Test-PowdrgitPath
	2

	.EXAMPLE
	## Valid and invalid paths ##

	# This example assumes that:
	# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\NotAGitRepo directory exists but is not a git repository (i.e. does not contain a .git subdirectory).
	# - C:\PowdrgitExamples\NonExistentFolder directory does not exist.

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\NonExistentFolder'
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Test-PowdrgitPath
	WARNING: [Test-PowdrgitPath]Directory does not exist: C:\PowdrgitExamples\NonExistentFolder
	WARNING: [Test-PowdrgitPath]Path is not a repository: C:\PowdrgitExamples\NotAGitRepo
	2

	.EXAMPLE
	## The $Powdrgit.Path module variable is undefined ##

	PS C:\> $Powdrgit.Path = $null
	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Test-PowdrgitPath
	WARNING: [Test-PowdrgitPath]The $Powdrgit.Path module variable is not defined.
	0
	PS C:\> $Powdrgit.Path = ''
	PS C:\> Test-PowdrgitPath
	WARNING: [Test-PowdrgitPath]The $Powdrgit.Path module variable is not defined.
	0

	.EXAMPLE
	## Valid and invalid paths - suppress warnings with -WarningAction Ignore##

	# This example assumes that:
	# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\NotAGitRepo directory exists but is not a git repository (i.e. does not contain a .git subdirectory).
	# - C:\PowdrgitExamples\NonExistentFolder directory does not exist.

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\NonExistentFolder'
	PS C:\> $myWarnings = $null
	PS C:\> Test-PowdrgitPath -WarningVariable myWarnings -WarningAction SilentlyContinue
	2
	PS C:\> $myWarnings
	[Test-PowdrgitPath]Directory does not exist: C:\PowdrgitExamples\NonExistentFolder
	[Test-PowdrgitPath]Path is not a repository: C:\PowdrgitExamples\NotAGitRepo

	# Warnings were not returned to the console, but were still captured in the myWarnings variable.

	PS C:\> $myWarnings = $null
	PS C:\> Test-PowdrgitPath -WarningAction Ignore -WarningVariable myWarnings
	2
	PS C:\> $myWarnings
	PS C:\>

	# $myWarnings is empty because warnings were never generated.

	.EXAMPLE
	## Valid and invalid paths - return an array of valid paths with PassThru ##

	# This example assumes that
	# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\NotAGitRepo directory exists but is not a git repository (i.e. does not contain a .git subdirectory).
	# - C:\PowdrgitExamples\NonExistentFolder directory does not exist.

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\NonExistentFolder'
	PS C:\> $Powdrgit.Path -split ';'
	C:\PowdrgitExamples\MyToolbox
	C:\PowdrgitExamples\Project1
	C:\PowdrgitExamples\NotAGitRepo
	C:\PowdrgitExamples\NonExistentFolder

	# All paths in the $Powdrgit.Path module variable were returned.

	PS C:\> Test-PowdrgitPath -PassThru -WarningAction Ignore
	C:\PowdrgitExamples\MyToolbox
	C:\PowdrgitExamples\Project1

	# Only the paths that are valid git repositories were returned.

	.EXAMPLE
	## Valid and invalid paths - return an array of invalid paths with Failing and PassThru ##

	# This example assumes that
	# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).
	# - C:\PowdrgitExamples\NotAGitRepo directory exists but is not a git repository (i.e. does not contain a .git subdirectory).
	# - C:\PowdrgitExamples\NonExistentFolder directory does not exist.

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\NonExistentFolder'
	PS C:\> $Powdrgit.Path -split ';'
	C:\PowdrgitExamples\MyToolbox
	C:\PowdrgitExamples\Project1
	C:\PowdrgitExamples\NotAGitRepo
	C:\PowdrgitExamples\NonExistentFolder

	# All paths in the $Powdrgit.Path module variable were returned.

	PS C:\> Test-PowdrgitPath -Failing -PassThru -WarningAction Ignore
	C:\PowdrgitExamples\NotAGitRepo
	C:\PowdrgitExamples\NonExistentFolder

	# Only the paths that are not valid git repositories were returned.

	.INPUTS
	None.

	.OUTPUTS
	[System.Int32]
	[System.String]
	Returns Int32 objects by default. When the PassThru parameter is used, returns String objects.

	.NOTES
	Author : nmbell

	.LINK
	Add-PowdrgitPath
	.LINK
	Remove-PowdrgitPath
	.LINK
	Find-GitRepo
	.LINK
	Get-GitRepo
	.LINK
	Set-GitRepo
	.LINK
	New-GitRepo
	.LINK
	Remove-GitRepo
	.LINK
	Invoke-GitClone
	.LINK
	about_powdrgit
	#>

	# Function alias
	[Alias('tpp')]

	# Use cmdlet binding
	[CmdletBinding(
	  HelpURI = 'https://github.com/nmbell/powdrgit/blob/main/help/Test-PowdrgitPath.md'
	)]

	# Declare parameters
	Param(

		[Switch]
		$PassThru

	,	[Switch]
		$Failing

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
		$warn             = !($PSBoundParameters.ContainsKey('WarningAction') -and $PSBoundParameters.WarningAction -eq 'Ignore') # because -WarningAction:Ignore is not implemented correctly
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Start: $($start.ToString('yyyy-MM-dd HH:mm:ss.fff'))"

		# Function BEGIN:
	}

	PROCESS
	{
		$bk = 'P'

		$validCount = 0
		$failsCount = 0

		If (!$Powdrgit.Path)
		{
			If ($warn) { Write-Warning "[$thisFunctionName]The `$Powdrgit.Path module variable is not defined." }
		}

		If ($Powdrgit.Path)
		{
			ForEach ($_powdrgitPath in ($Powdrgit.Path -split ';' | Where-Object { $_.Trim() } | Select-Object -Unique | Sort-Object))
			{
				If ($_powdrgitPath)
				{
					$isFail = $false
					If (!(Test-Path -Path $_powdrgitPath))
					{
						$isFail = $true
						If (!$Failing)
						{
							If ($warn) { Write-Warning "[$thisFunctionName]Directory does not exist: $_powdrgitPath" }
						}
					}
					ElseIf (!((Test-Path -Path "$_powdrgitPath\.git") -or ($_powdrgitPath -like '*.git')))
					{
						$isFail = $true
						If (!$Failing)
						{
							If ($warn) { Write-Warning "[$thisFunctionName]Path is not a repository: $_powdrgitPath" }
						}
					}
					If ($isFail) { $failsCount++ } Else { $validCount++ }
					Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]$(('Pass'*!$isFail)+('Fail'*$isFail)): $_powdrgitPath"

					If ($PassThru)
					{
						If ($Failing -and $isFail)
						{
							Write-Output $_powdrgitPath
						}
						ElseIf (!$Failing -and !$isFail)
						{
							Write-Output $_powdrgitPath
						}
					}
				}
			}
			Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Passes: $($validCount.ToString()); Fails: $($failsCount.ToString())"
		}

		If (!$PassThru)
		{
			If ($Failing)
			{
				Write-Output $failsCount
			}
			Else
			{
				Write-Output $validCount
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
