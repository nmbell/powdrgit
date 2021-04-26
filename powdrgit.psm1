# powdrgit 1.0.1
[CmdletBinding()]
Param()


# Files to include
. "$PSScriptRoot\classes\GitBranch.ps1"
. "$PSScriptRoot\classes\GitCommit.ps1"
. "$PSScriptRoot\classes\GitCommitFile.ps1"
. "$PSScriptRoot\classes\GitConfigFile.ps1"
. "$PSScriptRoot\classes\GitTag.ps1"

. "$PSScriptRoot\functions\ConvertTo-GitParsableResults.ps1"
. "$PSScriptRoot\functions\Find-GitRepo.ps1"
. "$PSScriptRoot\functions\Get-GitBranch.ps1"
. "$PSScriptRoot\functions\Get-GitCommit.ps1"
. "$PSScriptRoot\functions\Get-GitCommitFile.ps1"
. "$PSScriptRoot\functions\Get-GitConfigFile.ps1"
. "$PSScriptRoot\functions\Get-GitFileHistory.ps1"
. "$PSScriptRoot\functions\Get-GitLog.ps1"
. "$PSScriptRoot\functions\Get-GitRepo.ps1"
. "$PSScriptRoot\functions\Get-GitTag.ps1"
. "$PSScriptRoot\functions\Invoke-GitExpression.ps1"
. "$PSScriptRoot\functions\Set-GitBranch.ps1"
. "$PSScriptRoot\functions\Set-GitRepo.ps1"
. "$PSScriptRoot\functions\Test-GitRepoPath.ps1"
. "$PSScriptRoot\functions\Test-SubPath.ps1"
. "$PSScriptRoot\functions\Write-GitBranchOut.ps1"
. "$PSScriptRoot\functions\wvTimestamp.ps1"


# Variables to initialize
New-Variable -Name GitRepoPath       -Value $null -Scope Script -Force
New-Variable -Name PowdrgitCallDepth -Value 0     -Scope Script -Force


# Functions to export
$FunctionsToExport = @(
	# 'ConvertTo-GitParsableResults'
	'Find-GitRepo'
	'Get-GitBranch'
	'Get-GitCommit'
	'Get-GitCommitFile'
	'Get-GitConfigFile'
	'Get-GitFileHistory'
	'Get-GitLog'
	'Get-GitRepo'
	'Get-GitTag'
	'Invoke-GitExpression'
	'Set-GitBranch'
	'Set-GitRepo'
	'Test-GitRepoPath'
	# 'Test-SubPath'
	# 'Write-GitBranchOut'
	# 'wvTimestamp'
)


# Cmdlets to export
$CmdletsToExport = @()


# Variables to export
$VariablesToExport = @(
	'GitRepoPath'
	'PowdrgitCallDepth'
)


# Aliases to export
$AliasesToExport = @()


# Export the members
$moduleMembers = @{
	'Function' = $FunctionsToExport
	'Cmdlet'   = $CmdletsToExport
	'Variable' = $VariablesToExport
	'Alias'    = $AliasesToExport
}
Export-ModuleMember @moduleMembers
