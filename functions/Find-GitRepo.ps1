function Find-GitRepo
{
	<#
	.SYNOPSIS
	Finds all git repositories that exist under the specifed directory.

	.DESCRIPTION
	Finds all git repositories that exist under the specifed directory.
	Searches the specifed directory and, optionally, its subdirectories and returns a set of directory objects, each of which is a git repository.

	.PARAMETER Path
	An array of directory paths to be searched. Paths that do not exist will be ignored.
	If the parameter is omitted, or null, or an empty string, all fixed drives will be searched.

	.PARAMETER Recurse
	Search subdirectories of the specifed directory.

	.PARAMETER RecurseJunction
	Search subdirectories of any junction points.
	Implies Recurse.

	.PARAMETER SetPowdrgitPath
	Populates the $Powdrgit.Path module variable with a list of the paths for all found repositories.

	.PARAMETER AppendPowdrgitPath
	Appends the list of paths for all found repositories to the $Powdrgit.Path module variable.
	Paths that are already in the $Powdrgit.Path module variable will not be duplicated.

	.EXAMPLE
	## Find git repositories under a specifed directory ##

	PS C:\> Find-GitRepo -Path 'C:\PowdrgitExamples' | Select-Object -ExpandProperty FullName
	C:\PowdrgitExamples\MyToolbox
	C:\PowdrgitExamples\Project1

	.EXAMPLE
	## Find git repositories under the default directory ##

	PS C:\> $Powdrgit.DefaultDir = 'C:\PowdrgitExamples'
	PS C:\> Find-GitRepo -Path $Powdrgit.DefaultDir | Select-Object -ExpandProperty FullName
	C:\PowdrgitExamples\MyToolbox
	C:\PowdrgitExamples\Project1

	# PowerShell does not currently support multiple optional mutually exlusive parameter sets, which would allow a DefaultDir parameter.
	# To work around this, the $Powdrgit.DefaultDir module variable is instead passed to the Path parameter.

	.EXAMPLE
	## Populate the $Powdrgit.Path module variable with SetPowdrgitPath parameter ##

	PS C:\> $Powdrgit.Path = $null
	PS C:\> Find-GitRepo -Path 'C:\PowdrgitExamples' -SetPowdrgitPath | Out-Null
	PS C:\> $Powdrgit.Path
	C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1

	.EXAMPLE
	## Populate the $Powdrgit.Path module variable with function output ##

	PS C:\> $Powdrgit.Path = $null
	PS C:\> $Powdrgit.Path = (Find-GitRepo -Path 'C:\PowdrgitExamples' | Select-Object -ExpandProperty FullName) -join ';'
	PS C:\> $Powdrgit.Path
	C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1

	# This example uses the output of Find-GitRepo to populate the $Powdrgit.Path module variable.
	# It is equivalent to the previous example, however, this method may be preferred when filtering is required e.g.:
	# $Powdrgit.Path = (Find-GitRepo -Path 'C:\PowdrgitExamples' | Where-Object Name -ne 'MyToolbox' | Select-Object -ExpandProperty FullName) -join ';'

	.EXAMPLE
	## Use AppendPowdrgitPath to add new repositories to the $Powdrgit.Path module variable ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox' # to ensure the existing repository paths are defined
	PS C:\> Find-GitRepo -Path 'C:\PowdrgitExamples\Project1' -AppendPowdrgitPath | Out-Null
	PS C:\> $Powdrgit.Path
	C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1'

	.EXAMPLE
	## Find git repositories by piping objects ##

	PS C:\> 'C:\PowdrgitExamples' | Find-GitRepo | Select-Object -ExpandProperty FullName
	C:\PowdrgitExamples\MyToolbox
	C:\PowdrgitExamples\Project1

	# Strings can be piped directly into the function.

	PS C:\> Get-Item -Path 'C:\PowdrgitExamples' | Find-GitRepo | Select-Object -ExpandProperty FullName
	C:\PowdrgitExamples\MyToolbox
	C:\PowdrgitExamples\Project1

	# FullName is an alias for the Path parameter, allowing directory objects to be piped to Find-GitRepo.

	.INPUTS
	[System.IO.DirectoryInfo]
	Accepts directory objects.

	.OUTPUTS
	[System.IO.DirectoryInfo]
	Returns directory objects.

	.NOTES
	Author : nmbell

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
	[Alias('fgr')]

	# Use cmdlet binding
	[CmdletBinding(
	  DefaultParameterSetName = 'AppendPowdrgitPath'
	, HelpURI                 = 'https://github.com/nmbell/powdrgit/blob/main/help/Find-GitRepo.md'
	)]

	# Declare output type
	[OutputType([System.IO.DirectoryInfo], ParameterSetName = ('SetPowdrgitPath','AppendPowdrgitPath'))]

	# Declare parameters
	Param(

		[Parameter(
		  Mandatory                       = $false
		, Position                        = 0
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $true
		)]
		[Alias('FullName')]
		[String[]]
		$Path

	,	[Switch]
		$Recurse

	,	[Switch]
		$RecurseJunction

	,	[Parameter(
		  Mandatory        = $false
		, ParameterSetName = 'SetPowdrgitPath'
		)]
		[Switch]
		$SetPowdrgitPath

	,	[Parameter(
		  Mandatory        = $false
		, ParameterSetName = 'AppendPowdrgitPath'
		)]
		[Switch]
		$AppendPowdrgitPath

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
	}

	PROCESS
	{
		$bk = 'P'

		$literalPaths = New-Object -TypeName System.Collections.ArrayList
		ForEach ($_path in $Path)
		{
			If (Test-Path -LiteralPath $_path)
			{
				$literalPaths += $_path
			}
			Else
			{
				$literalPaths += Resolve-Path -Path $_path | Select-Object -ExpandProperty Path
			}
		}

		If (!$literalPaths)
		{
			$literalPaths = Get-Volume `
							| Where-Object { $_.DriveType -eq 'Fixed' -and $_.DriveLetter } `
							| Select-Object @{ l = 'DrivePath'; e = {$_.DriveLetter+':\'} } `
							| Sort-Object -Property DrivePath `
							| Select-Object -ExpandProperty DrivePath
			Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Setting root directory list to $literalPaths"
		}

		$gitReposAll = New-Object -TypeName System.Collections.ArrayList

		ForEach ($_path in $literalPaths)
		{
			$gitReposDir = New-Object -TypeName System.Collections.ArrayList

			If (!(Test-Path -Path $_path))
			{
				Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Skipping root directory $_path (does not exist)"
			}
			Else
			{
				Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Looking for git repositories under $_path"

				# .git repositories
				$gitRepos = New-Object -TypeName System.Collections.ArrayList
				$gitRepos = Get-ChildDirs -Path $_path -Recurse:$Recurse -RecurseJunction:$RecurseJunction -ErrorAction Ignore `
							| Where-Object { $_.FullName -notlike '*\$RECYCLE.BIN\*' } `
							| Where-Object { Test-Path -Path "$($_.FullName)\.git" } `
							| Select-Object -ExpandProperty FullName `
							| Where-Object { $_ -notin $gitReposDir }
				If ($gitRepos)
				{
					$gitReposDir += $gitRepos
					Get-Item -Path $gitRepos
				}

				# Bare repositories
				$gitRepos = New-Object -TypeName System.Collections.ArrayList
				$gitRepos = Get-ChildDirs -Path $_path -Filter '*.git' -Recurse:$Recurse -RecurseJunction:$RecurseJunction -ErrorAction Ignore `
							| Select-Object -ExpandProperty FullName `
							| Where-Object { $_ -notin $gitReposDir }
				If ($gitRepos)
				{
					$gitReposDir += $gitRepos
					Get-Item -Path $gitRepos
				}

				# The root directory itself
				$gitRepos = New-Object -TypeName System.Collections.ArrayList
				$gitRepos = Get-Item -Path $_path -ErrorAction Ignore `
							| Where-Object { (Test-Path -Path "$($_.FullName)\.git") -or ($_.PSIsContainer -eq $true -and $_.Name -like '*.git') } `
							| Select-Object -ExpandProperty FullName `
							| Where-Object { $_ -notin $gitReposDir }
				If ($gitRepos)
				{
					$gitReposDir += $gitRepos
					Get-Item -Path $gitRepos
				}

				Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Found $('{0,3}' -f $gitReposDir.Count) repositories in $_path`:"
				$gitReposDir | Sort-Object | ForEach-Object { Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]  $_" }
				If ($gitReposDir) { $gitReposAll += $gitReposDir }
			}
		}
		$gitReposAllCount = $gitReposAll | Select-Object -Unique | Measure-Object | Select-Object -ExpandProperty Count
		Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]Found $('{0,3}' -f $gitReposAllCount) unique repositories total"

		If ($gitReposAll)
		{
			If ($SetPowdrgitPath)
			{
				Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Setting `$Powdrgit.Path module variable"
				$Powdrgit.Path = $null
			}
			If ($AppendPowdrgitPath)
			{
				Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Appending to `$Powdrgit.Path module variable"
			}
			Add-PowdrgitPath -Path $gitReposAll
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
