function Invoke-GitClone
{
	<#
	.SYNOPSIS
	Clones a git repository.

	.DESCRIPTION
	Clones a git repository to the specified directory.

	.PARAMETER RepoURL
	The URL of the git repository to clone.
	If a default URL root is defined in $Powdrgit.DefaultCloneUrl, only the repository name is required.
	The URL can start with any of the following: http://, https://, ftp://, ftps://, git://, ssh://, [A-Z]:\, \\

	.PARAMETER ParentDir
	The parent directory where the git repository will be cloned to.
	If the parameter is omitted, and a default parent directory is defined in $Powdrgit.DefaultDir, the repository will be cloned under that directory.
	If no directory is specified, the repository is cloned to the current location.

	.PARAMETER RepoName
	The name to give the repository (the folder name of the top-level directory of the cloned repository).
	If the parameter is omitted, the name will be derived from the RepoURL value.

	.PARAMETER UseDefaultDir
	Uses the directory stored in the $Powdrgit.DefaultDir variable as the ParentDir value.

	.PARAMETER AppendPowdrgitPath
	Appends the path of the cloned repository to the $Powdrgit.Path module variable.

	.PARAMETER SetLocation
	Sets the location to the top-level directory of the cloned repository.

	.EXAMPLE
	## Clone a non-existent repository from a URL ##

	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Invoke-GitClone -RepoURL 'https://my.repos.com/MyMissingRepo'
	WARNING: [Invoke-GitClone]fatal: repository 'https://my.repos.com/MyMissingRepo/' not found

	# Attempting to clone to a non-existent repository generates a warning.

	.EXAMPLE
	## Clone an existent repository from a URL ##

	PS C:\> Invoke-GitClone -RepoURL 'https://my.repos.com/MyToolbox' | Format-Table Name,FullName

	Name      FullName
	----      --------
	MyToolbox C:\MyToolbox

	# The repository was cloned to the current directory.

	.EXAMPLE
	## Clone a repository from a local path ##

	PS C:\> Invoke-GitClone -RepoURL 'C:\PowdrgitExamples\MyToolbox' | Format-Table Name,FullName

	Name      FullName
	----      --------
	MyToolbox C:\MyToolbox

	# The repository was cloned to the current directory.

	.EXAMPLE
	## Clone a repository to an existing repository ##

	PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
	PS C:\> Invoke-GitClone -RepoURL 'C:\PowdrgitExamples\MyToolbox'
	WARNING: [Invoke-GitClone]fatal: destination path 'C:\MyToolbox' already exists and is not an empty directory.

	# Attempting to clone to an existing repository generates a warning.

	.EXAMPLE
	## Clone a repository with $Powdrgit.DefaultCloneUrl set ##

	PS C:\> $Powdrgit.DefaultCloneUrl = 'C:\PowdrgitExamples\<RepoURL>'
	PS C:\> Invoke-GitClone -RepoURL 'MyToolbox' | Format-Table Name,FullName

	Name      FullName
	----      --------
	MyToolbox C:\MyToolbox

	# Equivalent to the previous example

	.EXAMPLE
	## Clone a repository to a specified directory ##

	PS C:\> Invoke-GitClone -RepoURL 'C:\PowdrgitExamples\MyToolbox' -ParentDir 'C:\Temp' | Format-Table Name,FullName

	Name      FullName
	----      --------
	MyToolbox C:\Temp\MyToolbox

	# The repository was cloned to the specified directory.

	.EXAMPLE
	## Clone a repository with a specified name ##

	PS C:\> Invoke-GitClone -RepoURL 'C:\PowdrgitExamples\MyToolbox' -RepoName 'MyTools' | Format-Table Name,FullName

	Name    FullName
	----    --------
	MyTools C:\MyTools

	# The repository was cloned to the specified directory and given the specified name.

	.EXAMPLE
	## Clone a repository to the default directory ##

	PS C:\> $Powdrgit.DefaultDir = 'C:\Temp'
	PS C:\> Invoke-GitClone -RepoURL 'C:\PowdrgitExamples\MyToolbox' -UseDefaultDir | Format-Table Name,FullName

	Name      FullName
	----      --------
	MyToolbox C:\Temp\MyToolbox

	# The repository was cloned to the default directory.

	.EXAMPLE
	## Clone a repository and add the path to $Powdrgit.Path ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project1'
	PS C:\> Invoke-GitClone -RepoURL 'C:\PowdrgitExamples\MyToolbox' -AppendPowdrgitPath | Out-Null
	PS C:\> Test-PowdrgitPath -PassThru
	C:\MyToolbox
	C:\PowdrgitExamples\Project1

	# A [GitRepo] object is returned and the repository path is added to the $Powdrgit.Path module variable.

	.EXAMPLE
	## Clone a repository and set the location to the repository ##

	PS C:\> Invoke-GitClone -RepoURL 'C:\PowdrgitExamples\MyToolbox' -SetLocation | Out-Null
	PS C:\MyToolbox>

	# The location was changed to the repository top-level folder.

	.INPUTS
	[System.String]
	Accepts string objects via the RepoURL parameter.

	.OUTPUTS
	[GitRepo]
	[System.IO.DirectoryInfo]
	Returns either a custom GitRepo object or a System.IO.DirectoryInfo object.
	The DirectoryInfo property of the GitRepo object contains the System.IO.DirectoryInfo object for the repository.

	.NOTES
	Author : nmbell

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
	[Alias('igc')]

	# Use cmdlet binding
	[CmdletBinding(
	  DefaultParameterSetName = 'ParentDir'
	, SupportsShouldProcess   = $true
	, ConfirmImpact           = 'Medium'
	, HelpURI                 = 'https://github.com/nmbell/powdrgit/blob/main/help/Invoke-GitClone.md'
	)]

	# Declare output type
	[OutputType('GitRepo'                , ParameterSetName = ('ParentDir','UseDefaultDir'))]
	[OutputType([System.IO.DirectoryInfo], ParameterSetName = ('ParentDir','UseDefaultDir'))]

	# Declare parameters
	Param(

	 	[Parameter(
		  Mandatory                       = $true
		, HelpMessage                     = 'Enter the URL of the git repository to clone.'
		, Position                        = 0
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $true
		)]
		[ValidateNotNullOrEmpty()]
		[String]
		$RepoURL

	,	[Parameter(
		  Mandatory                       = $false
		, Position                        = 1
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		, ParameterSetName                = 'ParentDir'
		)]
		[ValidateNotNullOrEmpty()]
		[Alias('FullName','Path')]
		[String]
		$ParentDir

	,	[Parameter(
		  Mandatory                       = $false
		, Position                        = 2
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		)]
		[ValidateNotNullOrEmpty()]
		[String]
		$RepoName

	,	[Parameter(
		  ParameterSetName = 'UseDefaultDir'
		)]
		[Switch]
		$UseDefaultDir

	,	[Switch]
		$AppendPowdrgitPath

	,	[Switch]
		$SetLocation

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
		$warn             = $Powdrgit.ShowWarnings -and !($PSBoundParameters.ContainsKey('WarningAction') -and $PSBoundParameters.WarningAction -eq 'Ignore') # because -WarningAction:Ignore is not implemented correctly
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Start: $($start.ToString('yyyy-MM-dd HH:mm:ss.fff'))"

		# Function BEGIN:
	}

	PROCESS
	{
		$bk = 'P'

		Try
		{
			$gitCloneUrl = $null
			$gitClonePath = $null

			# Determine URL to clone from
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Determining URL to clone from"
			$gitCloneUrl         = $RepoURL
			$cloneUrlMatchString = '^((https?|ftps?|git|ssh)://|[A-Z]:\\|\\\\)'
			$cloneUrlPlaceholder = '<RepoURL>'
			If ($RepoURL -notmatch $cloneUrlMatchString) # assumes a repository under the default URL root is intended
			{
				If (!$Powdrgit.DefaultCloneUrl)
				{
					Write-Error '$Powdrgit.DefaultCloneUrl is not defined.' -ErrorAction Stop
				}
				If ($Powdrgit.DefaultCloneUrl -notmatch $cloneUrlMatchString)
				{
					Write-Error '$Powdrgit.DefaultCloneUrl is not properly defined. Should start with one of the following: http://, https://, ftp://, ftps://, git://, ssh://, [A-Z]:\, \\' -ErrorAction Stop
				}
				If ($Powdrgit.DefaultCloneUrl -notlike "*$cloneUrlPlaceholder*")
				{
					Write-Error "`$Powdrgit.DefaultCloneUrl is not properly defined. Should be like *$cloneUrlPlaceholder*." -ErrorAction Stop
				}
				$gitCloneUrl = $Powdrgit.DefaultCloneUrl -replace $cloneUrlPlaceholder,$RepoURL
			}
			If (!$gitCloneUrl)
			{
				Write-Error 'URL to clone from could not be determined.' -ErrorAction Stop
			}
			If ($gitCloneUrl -notmatch $cloneUrlMatchString)
			{
				Write-Error "URL to clone from is not valid: $gitCloneUrl" -ErrorAction Stop
			}
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Will clone from: $gitCloneUrl"

			# Determine path to clone to
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Determining path to clone to"
			$gitClonePath = $PWD.Path # default to current location
			If ($UseDefaultDir)
			{
				If (Test-PowdrgitDefaultDir)
				{
					$gitClonePath = $Powdrgit.DefaultDir
				}
				Else
				{
					$warn = $false # Test-PowdrgitDefaultDir will generate a warning if necessary
					Write-Error $gitClonePath -ErrorAction Stop
				}
			}
			If ($ParentDir)
			{
				$gitClonePath = $ParentDir
			}
			If (!$PSBoundParameters.ContainsKey('RepoName'))
			{
				$RepoName = (Split-Path -Path $gitCloneUrl -Leaf).Replace('.git','')
			}
			$gitClonePath = Join-Path -Path $gitClonePath -ChildPath $RepoName
			If (!$gitClonePath)
			{
				Write-Error 'Path to clone to could not be determined.' -ErrorAction Stop
			}
			Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Will clone to  : $gitClonePath"

			# Determine procession
			$shouldText = ("Cloning: $gitCloneUrl >> $gitClonePath")
			If ($WhatIfPreference) { Write-Host }
			$shouldProcess = $PSCmdlet.ShouldProcess($shouldText,$null,$null)

			# Clone the repository
			# If ($WhatIfPreference) { Write-Host "What if: $shouldText" } # handled by ShouldProcess
			If ($shouldProcess)
			{
				Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]$shouldText"
				$pc = 0
				$gitCommand = "git clone `"$gitCloneUrl`" `"$gitClonePath`""
				Invoke-GitExpression -Command "$gitCommand --progress" `
				| ForEach-Object {
					If ($_ -match "Cloning into '(.*)'...")
					{
						Write-Progress -Activity $gitCommand -Status ' ' -CurrentOperation $_ -PercentComplete $pc
					}
					ElseIf ($_ -match '^(remote|Receiving objects|Resolving deltas|Updating files):' )
					{
						$Matches = $null
						If($_ -match '(\d+)%') { $pc = $Matches[1] }
						Write-Progress -Activity $gitCommand -Status ' ' -CurrentOperation $_ -PercentComplete $pc
					}
					ElseIf ($_ -like 'fatal:*')
					{
						Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Repository was not cloned."
						Write-Error $_ -ErrorAction Stop
					}
				}
				Write-Progress -Activity $gitCommand -Completed
			}

			# Add to the $Powdrgit.Path variable
			If ($AppendPowdrgitPath)
			{
				$shouldText = 'Adding path to `$Powdrgit.Path'
				If ($WhatIfPreference) { Write-Host "What if: $shouldText" }
				If ($shouldProcess)
				{
					Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]$shouldText"
					Add-PowdrgitPath -Path "$gitClonePath" -WhatIf:$false -Confirm:$false
				}
			}

			# Return the repository directory
			If ($AppendPowdrgitPath)
			{
				$shouldText = 'Returning [GitRepo]'
				If ($WhatIfPreference) { Write-Host "What if: $shouldText" }
				If ($shouldProcess)
				{
					Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]$shouldText"
					Get-GitRepo -Repo "$gitClonePath"
				}
			}
			Else
			{
				$shouldText = 'Returning [System.IO.DirectoryInfo]'
				If ($WhatIfPreference) { Write-Host "What if: $shouldText" }
				If ($shouldProcess)
				{
					Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]$shouldText"
					Get-Item -Path "$gitClonePath"
				}
			}
		}
		Catch
		{
			If ($warn) { Write-Warning "[$thisFunctionName]$_" }
		}
	}

	END
	{
		$bk = 'E'

		# Function END:

		# Set location to the repository directory
		If ($SetLocation)
		{
			$shouldText = "Setting location to: $gitClonePath"
			If ($WhatIfPreference) { Write-Host; Write-Host "What if: $shouldText" }
			If ($shouldProcess)
			{
				Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]$shouldText"
				Set-Location -Path "$gitClonePath" -ErrorAction Ignore
			}
		}
		If ($WhatIfPreference) { Write-Host }

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($($duration.ToString('d\d\ hh\:mm\:ss\.fff')))"
		$PowdrgitCallDepth--
	}
}
