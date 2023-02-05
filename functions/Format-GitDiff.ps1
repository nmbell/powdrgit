function Format-GitDiff
{
	<#
	.SYNOPSIS
	Formats GitCommitDiff objects as a readable diff.

	.DESCRIPTION
	Formats GitCommitDiff objects as a readable diff.
	The diff contains two parts: the summary and the diff lines.
	The summary contains the following:
	- An overall summary of all changed files, inserted lines, deleted lines e.g:
		3 files changed, 78 insertions(+), 18 deletions(-)
	- A summary of each changed file in the format "<Type> : <delete lines count>- : <added lines count>+ : <filepath>", e.g.:
		Add      :   0- :  55+ : MyFolder/MyFirstFile.txt
		Delete   :   1- :   0+ : MyFolder/MySecondFile.txt
		Modify   :  17- :  23+ : MyFolder/MyThirdFile.txt
	The diff lines contains the following for each file in the diff:
	- A summary of the changed file, similar to that included in the summary information
	- A series of lines showing the line changes for the file in the format "<old line number>→<new line number> <change type indicator> <line text>".
	  Removed lines have an old line number but no new line number, and a "-" indicator.
	  Added lines have a new line number but no old line number, and a "+" indicator.
	  Changed lines are represented as a removed lined and an added line.
	  E.g.:
		Modify   : 2- : 2+ : MyFile.txt
		1→1   The first line of text
		2→  - This line needs to be updated
		3→  - This line needs to be removed
		 →2 + This line was updated
		4→3   This line shouldn't be changed
		 →4 + This line was added
	The colors that summary, old, new, and unchanged lines in the diff appear with when outputting to the console host can be controlled by setting the following module variable values:
		$Powdrgit.DiffLineColorNew     = 'Cyan'
		$Powdrgit.DiffLineColorOld     = 'Magenta'
		$Powdrgit.DiffLineColorSame    = 'DarkGray'
		$Powdrgit.DiffLineColorSummary = 'Gray'
	Any color values recognized by Write-Host as a foreground color can be used.
	To output the text as string objects (e.g. to write to a file), use the PassThru switch parameter.

	.PARAMETER InputObject
	GitCommitDiff object from e.g. Get-GitDiff.

	.PARAMETER NoSummary
	Suppresses the diff summary information.

	.PARAMETER NoLines
	Suppresses the diff line information.

	.PARAMETER PassThru
	Outputs the formatted diff as an array of strings.

	.EXAMPLE
	## Get formatted summary and line diff information for a diff ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\Project2> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq "Update Mary's bio" | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
	PS C:\PowdrgitExamples\Project2> $diff = Get-GitDiff -SHA1HashFrom $commitHash
	PS C:\PowdrgitExamples\Project2> $diff | Format-GitDiff

	2 files changed, 2 insertions(+), 2 deletions(-)
	Add      : 0- : 2+ : Jack.txt
	Delete   : 2- : 0+ : Mary.txt

	Add      : 0- : 2+ : Jack.txt
	→1 + Little Jack Horner
	→2 + Sat in the corner

	Delete   : 2- : 0+ : Mary.txt
	1→  - Mary had a little lamb
	2→  - It's fleece was white as snow

	# Summary and line diff information is shown for all files in the diff.

	.EXAMPLE
	## Get formatted summary information only for a diff ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\Project2> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq "Update Mary's bio" | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
	PS C:\PowdrgitExamples\Project2> $diff = Get-GitDiff -SHA1HashFrom $commitHash
	PS C:\PowdrgitExamples\Project2> $diff | Format-GitDiff -NoLines

	2 files changed, 2 insertions(+), 2 deletions(-)
	Add      : 0- : 2+ : Jack.txt
	Delete   : 2- : 0+ : Mary.txt

	# Only summary information is shown for all files in the diff.

	.EXAMPLE
	## Get formatted line diff information only for a diff ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\Project2> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq "Update Mary's bio" | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
	PS C:\PowdrgitExamples\Project2> $diff = Get-GitDiff -SHA1HashFrom $commitHash
	PS C:\PowdrgitExamples\Project2> $diff | Format-GitDiff -NoSummary

	Add      : 0- : 2+ : Jack.txt
	→1 + Little Jack Horner
	→2 + Sat in the corner

	Delete   : 2- : 0+ : Mary.txt
	1→  - Mary had a little lamb
	2→  - It's fleece was white as snow

	# Only line diff information is shown for all files in the diff.

	.EXAMPLE
	## Write formatted summary and line diff information to a text file ##

	PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
	PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
	PS C:\PowdrgitExamples\Project2> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq "Update Mary's bio" | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
	PS C:\PowdrgitExamples\Project2> $diff = Get-GitDiff -SHA1HashFrom $commitHash
	PS C:\PowdrgitExamples\Project2> $file = New-TemporaryFile
	PS C:\PowdrgitExamples\Project2> $diff | Format-GitDiff -PassThru | Add-Content -Path $file
	PS C:\PowdrgitExamples\Project2> Get-Content -Path $file

	2 files changed, 2 insertions(+), 2 deletions(-)
	Add      : 0- : 2+ : Jack.txt
	Delete   : 2- : 0+ : Mary.txt

	Add      : 0- : 2+ : Jack.txt
	→1 + Little Jack Horner
	→2 + Sat in the corner

	Delete   : 2- : 0+ : Mary.txt
	1→  - Mary had a little lamb
	2→  - It's fleece was white as snow

	.NOTES
	Author : nmbell

	.LINK
	Get-GitCommit
	.LINK
	Get-GitDiff
	.LINK
	Get-GitCommitFile
	.LINK
	Get-GitFileHistory
	.LINK
	Get-GitLog
	.LINK
	Get-GitRepo
	.LINK
	about_powdrgit
	.LINK
	https://github.com/nmbell/powdrgit/blob/main/help/about_powdrgit.md
	#>

	# Function alias
	[Alias('fgd')]

	# Use cmdlet binding
	[CmdletBinding(
	  HelpURI = 'https://github.com/nmbell/powdrgit/blob/main/help/Format-GitDiff.md'
	)]

	# Declare output type
	[OutputType([System.String])]

	# Declare parameters
	Param
	(

		[Parameter(
		  Mandatory                       = $true
		, HelpMessage                     = 'xHelpMessagex'  #displays this message in the prompt that appears when a mandatory parameter value is missing from a command
		, Position                        = 0                #0-based; the Position argument takes precedence over the value of the PositionalBinding argument for the parameters on which it's declared
		, ValueFromPipeline               = $true            #indicates that the parameter accepts input from a pipeline object. Specify this argument if the function accepts the entire object, not just a property of the object.
		, ValueFromPipelineByPropertyName = $true            #indicates that the parameter accepts input from a property of a pipeline object. The object property must have the same name or alias as the parameter.
		)]
		[AllowEmptyCollection()]
		[AllowNull()]
		[GitCommitDiff[]]
		$InputObject

	,	[Switch]
		$NoSummary

	,	[Switch]
		$NoLines

	,	[Switch]
		$PassThru

	)

	BEGIN
	{
		# Common BEGIN:
		# Set-StrictMode -Version 3.0
		$thisFunctionName = $MyInvocation.MyCommand
		$start            = Get-Date
		$indent           = ($Powdrgit.DebugIndentChar[0]+'   ')*($PowdrgitCallDepth++)
		$PSDefaultParameterValues += @{ '*:Verbose' = $(If ($DebugPreference -notin 'Ignore','SilentlyContinue') { $DebugPreference } Else { $VerbosePreference }) } # turn on Verbose with Debug
		# $warn             = $Powdrgit.ShowWarnings -and !($PSBoundParameters.ContainsKey('WarningAction') -and $PSBoundParameters.WarningAction -eq 'Ignore') # because -WarningAction:Ignore is not implemented correctly
		Write-Debug "  $(ts)$indent[$thisFunctionName][$bk]Start: $($start.ToString('yyyy-MM-dd HH:mm:ss.fff'))"

		# Function BEGIN:
		$wgo = @{
			OutputType   = 'Body'
			OutputStream = If ($PassThru) { 'Pipe' } Else { $Powdrgit.DiffLineColorSummary }
		}
	}

	PROCESS
	{
		ForEach ($diff in $InputObject)
		{
			# For spacing line numbers evenly
			$oldMax = $diff.File.DiffLine.LineNumBefore | ForEach-Object { $_.Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
			$newMax = $diff.File.DiffLine.LineNumAfter  | ForEach-Object { $_.Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

			# Output diff summary info
			If (!$NoSummary)
			{
				$wgo.OutputStream = If ($PassThru) { 'Pipe' } Else { $Powdrgit.DiffLineColorSummary }
				Write-GitOut @wgo $diff.Summary

				ForEach ($file in $diff.File)
				{
					$outLine  = '{0,-8} : ' -f $file.Action
					$outLine += "{0,$oldMax}- : {1,$newMax}+ : " -f $file.Old,$file.New
					$outLine += $file.Path
					$outLine += If ($file.PathNew) { " → $($file.PathNew)" } Else { '' }
					Write-GitOut @wgo $outLine
				}
				Write-GitOut @wgo
			}

			# Output diff line info
			If (!$NoLines)
			{
				ForEach ($file in $diff.File)
				{
					$outLine  = '{0,-8} : ' -f $file.Action
					$outLine += "{0,$oldMax}- : {1,$newMax}+ : " -f $file.Old,$file.New
					$outLine += $file.Path
					$outLine += If ($file.PathNew) { " → $($file.PathNew)" } Else { '' }
					$wgo.OutputStream = If ($PassThru) { 'Pipe' } Else { $Powdrgit.DiffLineColorSummary }
					Write-GitOut @wgo $outLine
					If ($file.Action -notin 'Copy','Rename')
					{
						ForEach ($line in $file.DiffLine)
						{
							If (!$PassThru)
							{
								$fgColor = If ($line.LineChange -eq '+') { $Powdrgit.DiffLineColorNew } ElseIf ($line.LineChange -eq '-') { $Powdrgit.DiffLineColorOld } Else { $Powdrgit.DiffLineColorSame }
								$wgo.OutputStream = $fgColor
							}
							Write-GitOut @wgo ("{0,$oldMax}→{1,$newMax} {2} {3}" -f $line.LineNumBefore,$line.LineNumAfter,$line.LineChange,$line.LineText)
						}
					}
					Write-GitOut @wgo
				}
			}
		}
	}

	END
	{
		# Function END:

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Verbose "[$thisFunctionName]Stopped: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($($duration.ToString('d\d\ hh\:mm\:ss\.fff')))"
	}
}
