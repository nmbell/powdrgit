function Invoke-GitExpression
{
	<#
	.SYNOPSIS
	Runs the provided git command on the local computer.

	.DESCRIPTION
	Runs the provided git command on the local computer.
	Both git output streams (success (1) and error (2)) are redirected to the Powershell success (1) output stream.
	This provides behavior consistent with other Powershell commands, and means that piping to commands such as Out-Null will behave as expected.
	The output from either (or both) git streams can be suppressed with optional switches.
	The function will also accept non-git commands, but the output from non-git commands will be returned as strings.

	.PARAMETER Command
	The git command to be run.

	.PARAMETER SuppressGitSuccessStream
	When true, the output from the git success (1) stream will be suppressed.

	.PARAMETER SuppressGitErrorStream
	When true, the output from the git error (2) stream will be suppressed.

	.EXAMPLE
	## Native git command vs Invoke-GitExpression - output to console ##

	C:\PowdrgitExamples\MyToolbox> git checkout main
	Already on 'main'
	Your branch is ahead of 'origin/main' by 3 commits.
	  (use "git push" to publish your local commits)
	C:\PowdrgitExamples\MyToolbox>

	# Although not obvious, the first line of the above output from the native git command is from the error stream, and the second and third are from the success stream.

	C:\PowdrgitExamples\MyToolbox> Invoke-GitExpression -Command 'git checkout main'
	Already on 'main'
	Your branch is ahead of 'origin/main' by 3 commits.
	  (use "git push" to publish your local commits)
	C:\PowdrgitExamples\MyToolbox>

	# The same results appear in the console. Also not obvious, but this time all lines of output are coming from Powershell's success stream.

	.EXAMPLE
	## Native git command vs Invoke-GitExpression - output to Out-Null ##

	C:\PowdrgitExamples\MyToolbox> git checkout main | Out-Null
	Already on 'main'
	C:\PowdrgitExamples\MyToolbox>

	# Piping to Out-Null usually results in nothing returned to the console. However, here we see a message returned, coming from git's error stream.

	C:\PowdrgitExamples\MyToolbox> Invoke-GitExpression -Command 'git checkout main' | Out-Null
	C:\PowdrgitExamples\MyToolbox>

	# This time, all output is suppressed, as expected.

	.EXAMPLE
	## Invoke-GitExpression - suppressing output ##

	C:\PowdrgitExamples\MyToolbox> Invoke-GitExpression -Command 'git checkout main' -SuppressGitErrorStream
	Your branch is ahead of 'origin/main' by 3 commits.
	  (use "git push" to publish your local commits)
	C:\PowdrgitExamples\MyToolbox>

	# The message coming from git's error stream has been omitted.

	C:\PowdrgitExamples\MyToolbox> Invoke-GitExpression -Command 'git checkout main' -SuppressGitSuccessStream
	Already on 'main'
	C:\PowdrgitExamples\MyToolbox>

	# The message coming from git's success stream has been omitted.

	C:\PowdrgitExamples\MyToolbox> Invoke-GitExpression -Command 'git checkout main' -SuppressGitSuccessStream -SuppressGitErrorStream
	C:\PowdrgitExamples\MyToolbox>

	# Using both switches suppresses all output, equivalent to piping to Out-Null.

	.INPUTS
	[System.String]
	Accepts string objects via the Command parameter.

	.OUTPUTS
	[System.String]
	Returns String objects.

	.NOTES
	Author : nmbell

	.LINK
	Set-GitBranch
	.LINK
	Invoke-GitClone
	.LINK
	about_powdrgit
	#>

	# Function alias
	[Alias('ige')]

	# Use cmdlet binding
	[CmdletBinding(
	  HelpURI = 'https://github.com/nmbell/powdrgit/blob/main/help/Invoke-GitExpression.md'
	)]

	# Declare parameters
	Param
	(

		[Parameter(
		  Mandatory                       = $true
		, HelpMessage                     = 'Enter the git command to be run. Multiple commands can be separated with a semicolon ";".'
		, Position                        = 0
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $true
		)]
		[ValidateNotNullOrEmpty()]
		[String]
		$Command

	,	[Switch]
		$SuppressGitSuccessStream

	,	[Switch]
		$SuppressGitErrorStream

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

		# Force the command to capture both streams
		$gitCommand = $Command+' 2>&1'

		# Run the command
		Write-Verbose "$(ts)$indent[$thisFunctionName][$bk]$gitCommand"
		Invoke-Expression -Command $gitCommand -ErrorAction Ignore `
		| ForEach-Object {
			If ($_.GetType().Name -eq    'ErrorRecord'         ) { If (!$SuppressGitErrorStream  ) { $_.Exception.Message.ToString()}; Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]$($_.Exception.Message.ToString())" }
			If ($_.GetType().Name -eq    'String'              ) { If (!$SuppressGitSuccessStream) { $_                             }; Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]$_"                                 }
			If ($_.GetType().Name -notin 'ErrorRecord','String') { If (!$SuppressGitSuccessStream) { $_.ToString()                  }; Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]$($_.ToString())"                   }
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
