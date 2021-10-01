# *:Repo
$commands = @(
	'Get-GitBranch'
	'Get-GitCommit'
	'Get-GitCommitFile'
	'Get-GitConfigFile'
	'Get-GitFileHistory'
	'Get-GitLog'
	'Get-GitRepo'
	'Get-GitTag'
	'Remove-GitRepo'
	'Set-GitBranch'
	'Set-GitRepo'
)
$argumentCompleter =
{
	Param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
	$sortRepo = @{ Expression = { If ($_.RepoName -like   "$wordToComplete*") { 1 } ElseIf ($_.RepoPath -like "*\$wordToComplete*") { 2 } ElseIf ($_.RepoPath -like "*$wordToComplete*") { 3 } }; Ascending  = $true }
	Get-GitRepo -Debug:$false `
	| Where-Object { $_.RepoName -like "$wordToComplete*" -or $_.RepoPath -like "*\$wordToComplete*" -or $_.RepoPath -like "*$wordToComplete*" } `
	| Sort-Object $sortRepo,RepoName,RepoPath `
	| Select-Object @{ n = 'ReturnString'; e = {
		    If ($Powdrgit.AutoCompleteFullPaths         ) { "'"+$_.RepoPath+"'" }
		ElseIf (!$_.IsNameUnique                        ) { "'"+$_.RepoPath+"'" }
		ElseIf ($_.RepoName -notlike  "$wordToComplete*") { "'"+$_.RepoPath+"'" }
		Else                                              {     $_.RepoName     }
	} } `
	| Select-Object -ExpandProperty ReturnString
}
Register-ArgumentCompleter -CommandName $commands -ParameterName Repo -ScriptBlock $argumentCompleter


# Get-GitLog:*InRef
$argumentCompleter =
{
	Param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
	$argRepo = $fakeBoundParameters.Repo
	If (!($fakeBoundParameters.ContainsKey('Repo')))
	{
		$argRepo = Get-GitRepo -Debug:$false -Current | Select-Object -ExpandProperty RepoPath
	}
	@(
		Get-GitBranch -Repo $argRepo -WarningAction Ignore -Debug:$false  `
		| Sort-Object -Property @{ Expression = 'IsCheckedOut'; Descending = $true },@{ Expression = 'BranchName'; Ascending = $true } `
		| Select-Object -ExpandProperty BranchName `
	)+@(
		Get-GitTag -Repo $argRepo -WarningAction Ignore -Debug:$false `
		| Select-Object -ExpandProperty TagName `
		| Sort-Object TagName
	) `
	| Where-Object { $_ -like "$wordToComplete*" }
}
Register-ArgumentCompleter -CommandName 'Get-GitLog' -ParameterName    InRef -ScriptBlock $argumentCompleter
Register-ArgumentCompleter -CommandName 'Get-GitLog' -ParameterName NotInRef -ScriptBlock $argumentCompleter


# Set-GitBranch:BranchName
$argumentCompleter =
{
	Param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
	$argRepo = $fakeBoundParameters.Repo
	If (!($fakeBoundParameters.ContainsKey('Repo')))
	{
		$argRepo = Get-GitRepo -Debug:$false -Current | Select-Object -ExpandProperty RepoPath
	}
	Get-GitBranch -Repo $argRepo -IncludeRemote -WarningAction Ignore -Debug:$false `
	| Select-Object -ExpandProperty BranchName `
	| Where-Object { $_ -like "$wordToComplete*" }
}
Register-ArgumentCompleter -CommandName 'Set-GitBranch' -ParameterName BranchName -ScriptBlock $argumentCompleter


# Set-GitBranch:*Out
# Write-GitBranchOut:OutputStream
$argumentCompleter =
{
	Param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
	@('None','Pipe')+[Enum]::GetValues([System.ConsoleColor]) | Where-Object { $_ -like "$wordToComplete*" }
}
Register-ArgumentCompleter -CommandName 'Set-GitBranch'      -ParameterName HeaderOut    -ScriptBlock $argumentCompleter
Register-ArgumentCompleter -CommandName 'Set-GitBranch'      -ParameterName CommandOut   -ScriptBlock $argumentCompleter
Register-ArgumentCompleter -CommandName 'Set-GitBranch'      -ParameterName ResultsOut   -ScriptBlock $argumentCompleter
Register-ArgumentCompleter -CommandName 'Write-GitBranchOut' -ParameterName OutputStream -ScriptBlock $argumentCompleter


<#
# Verb-Noun:xParameterNamex
$argumentCompleter =
{
	Param ($commandName,$parameterName,$wordToComplete,$commandAst,$fakeBoundParameters)
	xCodex
}
Register-ArgumentCompleter -CommandName 'Verb-Noun' -ParameterName xParameterNamex -ScriptBlock $argumentCompleter
#>
