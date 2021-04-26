function Get-GitConfigFile
{
	<#
	.SYNOPSIS
	Gets the config file for the given repository or scope.

	.DESCRIPTION
	Gets the config file for the given repository or scope.

	.PARAMETER RepoName
	The name of the git repository to return.
	This should match the directory name of one of the repositories defined in the $GitRepoPath module variable. If there is no match, a warning is generated.
	When the parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.

	.PARAMETER Local
	Returns the repository config file.

	.PARAMETER Global
	Returns the global (user) config file.

	.PARAMETER System
	Returns the system config file.

	.EXAMPLE
	## Call from outside a repository without parameters ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitConfigFile | Format-Table -Property Scope,ConfigFile

	Scope  ConfigFile
	-----  ----------
	System C:\Program Files\Git\etc\gitconfig
	Global C:\Users\nmbell\.gitconfig

	# When no scope switches are specified, the config files for all relevant scopes are returned.

	.EXAMPLE
	## Get only the system config file ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitConfigFile -System | Format-Table -Property Scope,ConfigFile

	Scope     ConfigFile
	-----     ----------
	System    C:\Program Files\Git\etc\gitconfig

	.EXAMPLE
	## Call from outside a repository for non-existent repository ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitConfigFile -RepoName NonExistentRepo -Local
	WARNING: [Get-GitConfigFile]Repository 'NonExistentRepo' not found. Check the repository directory has been added to the $GitRepoPath module variable.

	.EXAMPLE
	## Call from outside a repository with RepoName parameter ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitConfigFile -RepoName MyToolbox | Format-Table -Property Scope,ConfigFile

	Scope     ConfigFile
	-----     ----------
	MyToolbox C:\PowdrgitExamples\MyToolbox\.git\config
	System    C:\Program Files\Git\etc\gitconfig
	Global    C:\Users\nmbell\.gitconfig

	# When no scope switches are specified, the config files for all relevant scopes are returned.

	.EXAMPLE
	## Call from inside a repository without parameters ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\MyToolbox> Get-GitConfigFile | Format-Table -Property Scope,ConfigFile

	Scope     ConfigFile
	-----     ----------
	MyToolbox C:\PowdrgitExamples\MyToolbox\.git\config
	System    C:\Program Files\Git\etc\gitconfig
	Global    C:\Users\nmbell\.gitconfig

	# When no scope switches are specified, the config files for all relevant scopes are returned.

	.EXAMPLE
	## Pipe results from Get-GitRepo ##

	PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
	PS C:\> Get-GitRepo | Get-GitConfigFile | Format-Table -Property Scope,ConfigFile

	Scope     ConfigFile
	-----     ----------
	MyToolbox C:\PowdrgitExamples\MyToolbox\.git\config
	Project1  C:\PowdrgitExamples\Project1\.git\config
	System    C:\Program Files\Git\etc\gitconfig
	Global    C:\Users\nmbell\.gitconfig

	# System and Global config files are returned only once per call.

	.INPUTS
	[System.String]
	Accepts string objects via the RepoName parameter. The output of Get-GitRepo can be piped into Get-GitConfigFile.

	.OUTPUTS
	[GitConfigFile]
	Returns a custom GitConfigFile object. For details use Get-Member at a command prompt e.g.:
	PS C:\PowdrgitExamples\MyToolbox> Get-GitConfigFile | Get-Member -MemberType Properties

	.NOTES
	Author : nmbell

	.LINK
	https://github.com/nmbell/powdrgit/blob/main/help/Get-GitConfigFile.md
	.LINK
	about_powdrgit
	.LINK
	Get-GitRepo
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
		$Local

	,	[Switch]
		$System

	,	[Switch]
		$Global

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
		Push-Location -StackName GetGitConfigFile

		$gitCommandTemplate = 'git -c core.editor=echo -c advice.waitingForEditor=false config --<scope> --edit'
	}

	PROCESS
	{
		$wvBlock = 'P'

		# Setting no switches is the same as setting all of them
		$all = !($Local -or $Global -or $System)

		If ($Local -or $all)
		{
			# Find the repository name from current location
			If (!$RepoName) { $RepoName = Get-GitRepo -Current | Select-Object -ExpandProperty RepoName }

			# Go to the repository and get the repository info
			$repo = Set-GitRepo -RepoName $RepoName -PassThru -WarningAction SilentlyContinue

			If ($repo)
			{
				Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finding config file for $($repo.Name)"
				$repoConfigFilePath = Invoke-GitExpression -Command ($gitCommandTemplate.Replace('<scope>','local')) -SuppressGitErrorStream
				If ($repoConfigFilePath )
				{
					[GitConfigFile]@{
						'Scope'      = $RepoName
						'ConfigFile' = (Get-Item -Path $repoConfigFilePath)
					}
				}
			}
			ElseIf ($RepoName)
			{
				Write-Warning "[$thisFunctionName]Repository '$RepoName' not found. Check the repository directory has been added to the `$GitRepoPath module variable."
			}
		}
    }

	END
	{
		$wvBlock = 'E'

		# Function END:
		If ($System -or $all)
		{
			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finding system config file"
			$systemConfigFilePath = Invoke-GitExpression -Command ($gitCommandTemplate.Replace('<scope>','system')) -SuppressGitErrorStream
			If ($systemConfigFilePath)
			{
				[GitConfigFile]@{
					'Scope'      = 'System'
					'ConfigFile' = (Get-Item -Path $systemConfigFilePath)
				}
			}
		}

		If ($Global -or $all)
		{
			Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finding global config file"
			$globalConfigFilePath = Invoke-GitExpression -Command ($gitCommandTemplate.Replace('<scope>','global')) -SuppressGitErrorStream
			If ($globalConfigFilePath)
			{
				[GitConfigFile]@{
					'Scope'      = 'Global'
					'ConfigFile' = (Get-Item -Path $globalConfigFilePath)
				}
			}
		}

		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Setting location to original directory"
		Pop-Location -StackName GetGitConfigFile

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Finish: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($('{0}d {1:00}:{2:00}:{3:00}.{4:000}' -f $duration.Days,$duration.Hours,$duration.Minutes,$duration.Seconds,$duration.Milliseconds))"
		$PowdrgitCallDepth--
	}
}
