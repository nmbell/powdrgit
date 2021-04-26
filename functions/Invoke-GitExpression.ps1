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

	# This example assumes commands are run against the main branch of an existing git repository, which is tracking a remote repository branch and is up to date.

	C:\MyRepo> git checkout main
	Already on 'main'
	Your branch is up to date with 'origin/main'.
	C:\MyRepo>

	# Although not obvious, the first line of the above output from the native git command is from the error stream, and the second is from the success stream.

	C:\MyRepo> Invoke-GitExpression -Command 'git checkout main'
	Already on 'main'
	Your branch is up to date with 'origin/main'.
	C:\MyRepo>

	# The same results appear in the console. Also not obvious, but this time both lines of output are coming from Powershell's success stream.

	.EXAMPLE
	## Native git command vs Invoke-GitExpression - output to Out-Null ##

	# This example assumes commands are run against the main branch of an existing git repository, which is tracking a remote repository branch and is up to date.

	C:\MyRepo> git checkout main | Out-Null
	Already on 'main'
	C:\MyRepo>

	# Piping to Out-Null usually results in nothing returned to the console. However, here we see a message returned, coming from git's error stream.

	C:\MyRepo> Invoke-GitExpression -Command 'git checkout main' | Out-Null
	C:\MyRepo>

	# This time, all output is suppressed, as expected.

	.EXAMPLE
	## Invoke-GitExpression - suppressing output ##

	# This example assumes commands are run against the main branch of an existing git repository, which is tracking a remote repository branch and is up to date.

	C:\MyRepo> Invoke-GitExpression -Command 'git checkout main' -SuppressGitErrorStream
	Your branch is up to date with 'origin/main'.
	C:\MyRepo>

	# The message coming from git's error stream has been omitted.

	C:\MyRepo> Invoke-GitExpression -Command 'git checkout main' -SuppressGitSuccessStream
	Already on 'main'
	C:\MyRepo>

	# The message coming from git's success stream has been omitted.

	C:\MyRepo> Invoke-GitExpression -Command 'git checkout main' -SuppressGitSuccessStream -SuppressGitErrorStream
	C:\MyRepo>

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
	https://github.com/nmbell/powdrgit/blob/main/help/Invoke-GitExpression.md
	.LINK
	about_powdrgit
	.LINK
	Set-GitBranch
	#>

    # Use cmdlet binding
    [CmdletBinding()]

    # Declare parameters
	Param
	(

		[Parameter(
		  Mandatory                       = $true
		, Position                        = 0
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $true
		, HelpMessage                     = 'Enter a command to be run. Multiple commands can be separated with a semi-colon ";".'
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

		# Force the command to capture both streams
		$gitCommand = $Command+' 2>&1'


		# Run the command
		Write-Verbose "$(wvTimestamp)$wvIndent[$thisFunctionName][$wvBlock]Running command: $gitCommand"
		$gitOutput = $null
		$gitOutput = Invoke-Expression -Command $gitCommand -ErrorAction SilentlyContinue

		# Prepare the output
		$fnOutput = @()
		$gitOutput | Where-Object { $_.GetType().Name -eq    'ErrorRecord'          -and !$SuppressGitErrorStream   }                      | ForEach-Object { $fnOutput += $_.Exception.Message.ToString() }
		$gitOutput | Where-Object { $_.GetType().Name -eq    'String'               -and !$SuppressGitSuccessStream }                      | ForEach-Object { $fnOutput += $_                              }
		$gitOutput | Where-Object { $_.GetType().Name -notin 'ErrorRecord','String' -and !$SuppressGitSuccessStream } | Out-String -Stream | ForEach-Object { $fnOutput += $_                              }

		# Output
		Write-Output $fnOutput
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
