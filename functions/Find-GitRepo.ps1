function Find-GitRepo
{
	<#
	.SYNOPSIS
	Finds all git repositories that exist under the specifed root directory.

	.DESCRIPTION
	Finds all git repositories that exist under the specifed root directory.
	Searches the specifed directory and its subdirectories and returns a set of directory objects, each of which is a git repository.

	.PARAMETER RootDirectory
	An array of directory paths to be searched. Paths that do not exist will be ignored.
	If the parameter is omitted, or null, or an empty string, all fixed drives will be searched.

	.PARAMETER SetGitRepoPath
	Populates the $GitRepoPath module variable with a list of the paths for all found repositories.

	.PARAMETER AppendGitRepoPath
	Appends the list of paths for all found repositories to the $GitRepoPath module variable.
	Paths that are already in the $GitRepoPath module variable will not be duplicated.

	.EXAMPLE
	## Find git repositories under a root directory ##

	PS C:\> Find-GitRepo -RootDirectory 'C:\PowdrgitExamples' | Select-Object -ExpandProperty FullName
	C:\PowdrgitExamples\MyToolbox
	C:\PowdrgitExamples\Project1

	.EXAMPLE
	## Populate the $GitRepoPath module variable with SetGitRepoPath parameter ##

	PS C:\> $GitRepoPath = $null
	PS C:\> Find-GitRepo -RootDirectory 'C:\PowdrgitExamples' -SetGitRepoPath | Out-Null
	PS C:\> $GitRepoPath
	C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1

	.EXAMPLE
	## Populate the $GitRepoPath module variable with function output ##

	PS C:\> $GitRepoPath = $null
	PS C:\> $GitRepoPath = (Find-GitRepo -RootDirectory 'C:\PowdrgitExamples' | Select-Object -ExpandProperty FullName) -join ';'
	PS C:\> $GitRepoPath
	C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1

	# This example uses the output of Find-GitRepo to populate the $GitRepoPath module variable.
	# It is equivalent to the previous example, however, this method may be preferred when filtering is required e.g.:
	# $GitRepoPath = (Find-GitRepo -RootDirectory 'C:\PowdrgitExamples' | Where-Object Name -ne 'MyToolbox' | Select-Object -ExpandProperty FullName) -join ';'

	.EXAMPLE
	## Use AppendGitRepoPath to add new repositories to the $GitRepoPath module variable ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the existing repository paths are defined
	PS C:\> git init "C:\PowdrgitExamples2\Project2" 2>&1 | Out-Null # create a new git repository
	PS C:\> Find-GitRepo -RootDirectory 'C:\PowdrgitExamples2' -AppendGitRepoPath | Out-Null
	PS C:\> $GitRepoPath
	C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples2\Project2

	# Clean up if required: Remove-Item -Path 'C:\PowdrgitExamples2' -Recurse -Force

	.EXAMPLE
	## Find git repositories by piping objects ##

	PS C:\> 'C:\PowdrgitExamples' | Find-GitRepo | Select-Object -ExpandProperty FullName
	C:\PowdrgitExamples\MyToolbox
	C:\PowdrgitExamples\Project1

	# Strings can be piped directly into the function.

	PS C:\> Get-Item -Path 'C:\PowdrgitExamples' | Find-GitRepo | Select-Object -ExpandProperty FullName
	C:\PowdrgitExamples\MyToolbox
	C:\PowdrgitExamples\Project1

	# Path and FullName are aliases for the RootDirectory parameter, allowing directory objects to be piped to Find-GitRepo.

	.INPUTS
	[System.IO.DirectoryInfo]
	Accepts directory objects.

	.OUTPUTS
	[System.IO.DirectoryInfo]
	Returns directory objects.

	.NOTES
	Author : nmbell

	.LINK
	about_powdrgit
	.LINK
	Get-GitRepo
	.LINK
	Set-GitRepo
	.LINK
	Test-GitRepoPath
	#>

    # Use cmdlet binding
	[CmdletBinding(
	  DefaultParameterSetName = 'Set'
	, HelpURI                 = 'https://github.com/nmbell/powdrgit/blob/main/help/Find-GitRepo.md'
	)]

    # Declare parameters
    Param(

		[Parameter(
		  Mandatory                       = $false
		, Position                        = 0
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $true
		)]
		[Alias('FullName','Path')]
		[String[]]
		$RootDirectory

	,	[Parameter(
		  ParameterSetName = 'Set'
		, Mandatory        = $false
		)]
		[Switch]
		$SetGitRepoPath

	,	[Parameter(
		  ParameterSetName = 'Append'
		, Mandatory        = $false
		)]
		[Switch]
		$AppendGitRepoPath

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
		Push-Location -StackName FindGitRepo

		If (!$RootDirectory)
		{
			$RootDirectory = Get-Volume `
								| Where-Object { $_.DriveType -eq 'Fixed' -and $_.DriveLetter } `
								| Select-Object @{ l = 'DrivePath'; e = {$_.DriveLetter+':\'} } `
								| Sort-Object -Property DrivePath `
								| Select-Object -ExpandProperty DrivePath
			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Setting root directory list to $RootDirectory"
		}
	}

	PROCESS
	{
		$wvBlock = 'P'

		[System.IO.DirectoryInfo[]]$gitReposAll = @()
		ForEach ($drivePath in $RootDirectory)
		{
			[System.IO.DirectoryInfo[]]$gitRepos = @()
			If (!(Test-Path -Path $drivePath))
			{
				Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Skipping root directory $drivePath (does not exist)"
			}
			Else
			{
				Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Looking for git repositories under $drivePath"
				Set-Location -Path $drivePath
				Get-ChildItem -Directory -Hidden -Recurse -Filter '.git' -ErrorAction SilentlyContinue `
					| Where-Object { $_.FullName -notlike '*\$RECYCLE.BIN\*' } `
					| Select-Object -ExpandProperty Parent `
					| Tee-Object -Variable gitRepos
				Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Found $($gitRepos.Count) repositories under $drivePath"
			}
			$gitReposAll += $gitRepos
		}
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Found $($gitReposAll.Count) repositories total"

		If ($SetGitRepoPath)
		{
			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Setting `$GitRepoPath module variable"
			$script:GitRepoPath = ($gitReposAll | Select-Object -ExpandProperty FullName) -join ';'
		}

		If ($AppendGitRepoPath)
		{
			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Appending to `$GitRepoPath module variable"
			$script:GitRepoPath += (';'*[Bool]$script:GitRepoPath)+(($gitReposAll | Select-Object -ExpandProperty FullName) -join ';')
		}

		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Deduping and ordering items in `$GitRepoPath module variable"
		$script:GitRepoPath = (($script:GitRepoPath -split ';') | Select-Object -Unique | Sort-Object) -join ';'
    }

	END
	{
		$wvBlock = 'E'

		# Function END:
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Setting location to original directory"
		Pop-Location -StackName FindGitRepo

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($('{0}d {1:00}:{2:00}:{3:00}.{4:000}' -f $duration.Days,$duration.Hours,$duration.Minutes,$duration.Seconds,$duration.Milliseconds))"
		$PowdrgitCallDepth--
	}
}
