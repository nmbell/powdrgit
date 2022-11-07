function Get-ChildDirs
{
	<#
	.SYNOPSIS
	Private function. Used by Find-GitRepo.

	.DESCRIPTION
	Gets child directories of a path.
	Allows recursion and control of recursion into junction points.

	.PARAMETER Path
	The parent path to inspect.

	.PARAMETER Recurse
	Controls recursion into child directories.

	.PARAMETER RecurseJunctions
	Controls recursion into junction points.

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
	https://github.com/nmbell/powdrgit/blob/main/help/about_powdrgit.md
	#>

	# Use cmdlet binding
	[CmdletBinding()]

	# Declare output type
	[OutputType([System.IO.DirectoryInfo])]

	# Declare parameters
	Param
	(

		[Parameter(
		  Mandatory                       = $false
		, Position                        = 0
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $true
		)]
		[Alias('FullName')]
		[String[]]
		$Path = $PWD.Path

	,	[Parameter(
		  Mandatory                       = $false
		, Position                        = 1
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		)]
		[String]
		$Filter

	,	[Switch]
		$Recurse

	,	[Switch]
		$RecurseJunction

	)

	BEGIN
	{
		# Common BEGIN:
		Set-StrictMode -Version 3.0
		$start            = Get-Date
		$thisFunctionName = $MyInvocation.MyCommand
		Write-Debug "[$thisFunctionName]Started: $($start.ToString('yyyy-MM-dd HH:mm:ss.fff'))"

		# Function BEGIN:
	}

	PROCESS
	{
		ForEach ($dir in Get-ChildItem -Path $Path -Directory -ErrorAction Ignore)
		{
			# Return the current item
			If (!$Filter -or ($Filter -and $dir.Name -like $Filter))
			{
				$dir
			}

			# Recurse if necessary
			$recursable = $false
			$recursable = $recursable -or (($Recurse -or $RecurseJunction) -and !($dir.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint)))
			$recursable = $recursable -or ($RecurseJunction -and $dir.Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint))
			If ($recursable)
			{
				Get-ChildDirs -Path $dir.FullName -Filter $Filter -Recurse:$Recurse -RecurseJunction:$RecurseJunction
			}
		}
	}

	END
	{
		# Function END:

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Debug "[$thisFunctionName]Stopped: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($($duration.ToString('d\d\ hh\:mm\:ss\.fff')))"
	}
}
