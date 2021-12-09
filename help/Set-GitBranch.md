# Set-GitBranch

## SYNOPSIS
Checks out the specified branches for the specified repository.

## SYNTAX

```
Set-GitBranch [[-Repo] <String[]>] [-BranchName] <String[]> [-SetLocation] [-GitScript <String>] [-HeaderOut <String>] [-CommandOut <String>] [-ResultsOut <String>] [-GitScriptSeparator <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Checks out the specified branches for the specified repository.
An optional script block may be passed in containing git commands to be executed against each specified branch after it has been checked out.
The script will be split by semicolon (default) or a user-defined separator, and each command run in turn.
The output of the command has three components: header (in the form "\<RepoName\> | \<BranchName\>"), command, and results.
Each section can be directed to the host, the pipeline, or suppressed.
By default, the header, command, and results are only written when GitScript is used.

## EXAMPLES

### EXAMPLE 1
```
## Check out a branch from outside a repository without naming a repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -BranchName main

# Nothing was returned because the current location is not inside a repository.
```

### EXAMPLE 2
```
## Call from outside a repository for non-existent repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Set-GitBranch -Repo NonExistentRepo -BranchName main
WARNING: [Set-GitBranch]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.
```

### EXAMPLE 3
```
## Check out a branch from outside a repository by naming a repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo MyToolbox -BranchName feature1

# Nothing was returned, but the specified branch is now checked out for the specified repository.

# To confirm the checkout:
PS C:\> Get-GitBranch -Repo MyToolbox -Current | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox feature1           True    False

# Checkout main branch:
PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main

# To confirm the checkout:
PS C:\> Get-GitBranch -Repo MyToolbox -Current | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox main               True    False
```

### EXAMPLE 4
```
## Check out a branch from outside a repository and use SetLocation parameter ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation
PS C:\PowdrgitExamples\MyToolbox>

# Nothing was returned, but the specified branch is now checked out for the specified repository
# Also, because the SetLocation switch was used, the current location (reflected in the prompt) changed to the repository's top-level directory.
```

### EXAMPLE 5
```
## Check out a branch from outside a repository and use GitScript to run a git command against the branch ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -GitScript 'git pull'
MyToolbox | main
git pull
Already up to date.
```

### EXAMPLE 6
```
## Use GitScript to run a git command against a branch and capture the only the git output in a variable ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> $gitPullOutput = $null
PS C:\> $gitPullOutput = Set-GitBranch -Repo MyToolbox -BranchName main -GitScript 'git pull' -ResultsOut Pipe
MyToolbox | main
git pull
PS C:\> $gitPullOutput
Already up to date.

# The header and command output were still seen in the host as they were not suppressed with the HeaderOut and CommandOut parameters.
```

### EXAMPLE 7
```
## Use GitScript to run a git command against a branch and suppress all output ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -GitScript 'git pull' -HeaderOut None -CommandOut None -ResultsOut None
PS C:\>

# No output was seen in the host as it was suppressed with the HeaderOut, CommandOut, and ResultsOut parameters.
```

### EXAMPLE 8
```
## Run a git command against multiple branches ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> $branchesToPull = Get-GitBranch -Repo MyToolbox | Where-Object BranchName -in 'feature1','release' | Select-Object -ExpandProperty BranchName
PS C:\> Set-GitBranch -Repo MyToolbox -BranchName $branchesToPull -GitScript 'git pull'
MyToolbox | feature1
git pull
Already up to date.
MyToolbox | release
git pull
Already up to date.
PS C:\>

# The command passed to the script block parameter was executed against each branch stored in the $branchesToPull variable.
```

### EXAMPLE 9
```
## Run a git command against multiple branches in multiple repositories ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo | Get-GitBranch | Set-GitBranch -GitScript 'git status'
MyToolbox | feature1
git status
On branch feature1
Your branch is ahead of 'origin/feature1' by 1 commit.
(use "git push" to publish your local commits)

nothing to commit, working tree clean
MyToolbox | feature3
git status
On branch feature3
nothing to commit, working tree clean
MyToolbox | main
git status
On branch main
Your branch is ahead of 'origin/main' by 3 commits.
(use "git push" to publish your local commits)

nothing to commit, working tree clean
MyToolbox | release
git status
On branch release
Your branch is up to date with 'origin/release'.

nothing to commit, working tree clean
Project1 | main
git status
On branch main
nothing to commit, working tree clean
Project1 | newfeature
git status
On branch newfeature
nothing to commit, working tree clean

# By piping the results of Get-GitRepo | Get-GitBranch into Set-GitBranch, we can see the status of all branches in all repositories in a single command.
```

## PARAMETERS

### -BranchName
The names of the branches to be checked out.
Wildcard characters are allowed.
The pattern will match against existing branches in the specified repository.
A warning will be generated for any values that do not match the name of an existing branch.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: *
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CommandOut
Used to suppress, direct, or color the command output.
When the value is 'None', the command will be suppressed.
When the value is 'Pipe', the command will be sent to the pipeline.
When the value is a standard Powershell color, the command will be written to the host in that color.
Default is 'Green'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Green
Accept pipeline input: False
Accept wildcard characters: False
```

### -GitScript
Used to provide git commands that will be executed against the specified branches.
The default command separator is the semicolon (";").
An alternative separator can be specified with the GitScriptSeparator parameter or by setting $Powdrgit.DefaultGitScriptSeparator.
A literal separator character can be specified with a backtick escape e.g. "\`;".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GitScriptSeparator
An alternative separator for splitting commands passed in to the GitScript parameter.
If an empty string ('') or $null is passed in, no splitting will occur i.e. the script will execute as a single statement.
The default separator is a semicolon (";").
An empty of null value will treat the GitScript value as a single statement.
The GitScriptSeparator parameter will override the value in $Powdrgit.DefaultGitScriptSeparator.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HeaderOut
Used to suppress, direct, or color the background of the header output.
When the value is 'None', the header will be suppressed.
When the value is 'Pipe', the header will be sent to the pipeline.
When the value is a standard Powershell color, the header will be written to the host with a background in that color.
When GitScript is provided, default is 'DarkGray'; otherwise it is 'None'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Repo
The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
If the Repo parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.
For examples of using the Repo parameter, refer to the help text for Get-GitRepo.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: RepoName, RepoPath

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ResultsOut
Used to suppress, direct, or color the results output.
When the value is 'None', the results will be suppressed.
When the value is 'Pipe', the results will be sent to the pipeline.
When the value is 'Native', the results will be written to the host using both native git colors and git output streams.
When the value is a standard Powershell color, the results will be written to the host in that color.
Default is 'DarkGray'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: DarkGray
Accept pipeline input: False
Accept wildcard characters: False
```

### -SetLocation
Sets the working directory to the top-level directory of the specified repository.
In the case where multiple Repo values are passed in, the location will reflect the repository that was specified last.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[System.String[]]

Accepts string objects via the Repo parameter. The output of Get-GitBranch can be piped into Set-GitTag.

## OUTPUTS

[System.String]

When output is present, returns String objects.

## NOTES
Author : nmbell

## RELATED LINKS

[Get-GitBranch](Get-GitBranch.md)

[Get-GitRepo](Get-GitRepo.md)

[Set-GitRepo](Set-GitRepo.md)

[Get-GitLog](Get-GitLog.md)

[Invoke-GitExpression](Invoke-GitExpression.md)

[about_powdrgit](about_powdrgit.md)



