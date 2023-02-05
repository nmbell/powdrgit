# powdrgit 1.3.0
[CmdletBinding()]
Param()


# Include files
. "$PSScriptRoot\classes\GitBranch.ps1"
. "$PSScriptRoot\classes\GitCommit.ps1"
. "$PSScriptRoot\classes\GitCommitDiff.ps1"
. "$PSScriptRoot\classes\GitCommitFile.ps1"
. "$PSScriptRoot\classes\GitConfigFile.ps1"
. "$PSScriptRoot\classes\GitRepo.ps1"
. "$PSScriptRoot\classes\GitTag.ps1"

. "$PSScriptRoot\functions\Add-PowdrgitPath.ps1"
. "$PSScriptRoot\functions\ConvertTo-GitParsableResults.ps1"
. "$PSScriptRoot\functions\Find-GitRepo.ps1"
. "$PSScriptRoot\functions\Format-GitDiff.ps1"
. "$PSScriptRoot\functions\Get-ChildDirs.ps1"
. "$PSScriptRoot\functions\Get-GitBranch.ps1"
. "$PSScriptRoot\functions\Get-GitCommit.ps1"
. "$PSScriptRoot\functions\Get-GitCommitFile.ps1"
. "$PSScriptRoot\functions\Get-GitConfigFile.ps1"
. "$PSScriptRoot\functions\Get-GitDiff.ps1"
. "$PSScriptRoot\functions\Get-GitFileHistory.ps1"
. "$PSScriptRoot\functions\Get-GitLog.ps1"
. "$PSScriptRoot\functions\Get-GitRepo.ps1"
. "$PSScriptRoot\functions\Get-GitTag.ps1"
. "$PSScriptRoot\functions\Get-ValidRepo.ps1"
. "$PSScriptRoot\functions\Get-WriteVerboseTimestamp.ps1"
. "$PSScriptRoot\functions\Invoke-GitClone.ps1"
. "$PSScriptRoot\functions\Invoke-GitExpression.ps1"
. "$PSScriptRoot\functions\New-GitRepo.ps1"
. "$PSScriptRoot\functions\Remove-GitRepo.ps1"
. "$PSScriptRoot\functions\Remove-PowdrgitPath.ps1"
. "$PSScriptRoot\functions\Set-GitBranch.ps1"
. "$PSScriptRoot\functions\Set-GitRepo.ps1"
. "$PSScriptRoot\functions\Test-PowdrgitDefaultDir.ps1"
. "$PSScriptRoot\functions\Test-PowdrgitPath.ps1"
. "$PSScriptRoot\functions\Test-SubPath.ps1"
. "$PSScriptRoot\functions\Write-GitOut.ps1"


# Initialize variables
$moduleVars = Get-Content -Path "$PSScriptRoot\config\powdrgit.json" | ConvertFrom-Json
New-Variable -Name Powdrgit -Value $moduleVars -Scope Script -Force
New-Variable -Name PowdrgitCallDepth -Value 0 -Scope Script -Force


# Aliases to export
$AliasesToExport =
@(
	'app'
	'fgd'
	'fgr'
	'ggb'
	'ggc'
	'ggcf'
	'ggcfg'
	'ggd'
	'ggfh'
	'ggl'
	'ggr'
	'ggt'
	'igc'
	'ige'
	'ngr'
	'rgr'
	'rpp'
	'sgb'
	'sgr'
	'tpp'
)


# Cmdlets to export
$CmdletsToExport = @()


# Functions to export
$FunctionsToExport =
@(
	# 'ConvertTo-GitParsableResults'
	'Add-PowdrgitPath'
	'Find-GitRepo'
	'Format-GitDiff'
	'Get-GitBranch'
	# 'Get-ChildDirs'
	'Get-GitCommit'
	'Get-GitCommitFile'
	'Get-GitConfigFile'
	'Get-GitDiff'
	'Get-GitFileHistory'
	'Get-GitLog'
	'Get-GitRepo'
	'Get-GitTag'
	# 'Get-ValidRepo'
	# 'Get-WriteVerboseTimestamp'
	'Invoke-GitClone'
	'Invoke-GitExpression'
	'New-GitRepo'
	'Remove-GitRepo'
	'Remove-PowdrgitPath'
	'Set-GitBranch'
	'Set-GitRepo'
	# 'Test-PowdrgitDefaultDir'
	'Test-PowdrgitPath'
	# 'Test-SubPath'
	# 'Write-GitOut'
)


# Variables to export
$VariablesToExport =
@(
	'Powdrgit'
)


# Export the members
$moduleMembers =
@{
	'Alias'    = $AliasesToExport
	'Cmdlet'   = $CmdletsToExport
	'Function' = $FunctionsToExport
	'Variable' = $VariablesToExport
}
Export-ModuleMember @moduleMembers
