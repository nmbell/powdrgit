# Get-GitBranch

## SYNOPSIS
Gets a list of branches for the specified repository.

## SYNTAX

### Remote (Default)
```
Get-GitBranch [[-Repo] <String[]>] [[-BranchName] <String[]>] [-IncludeRemote] [-ExcludeLocal] [-SetLocation]
 [-Force] [<CommonParameters>]
```

### Current
```
Get-GitBranch [[-Repo] <String[]>] [[-BranchName] <String[]>] [-Current] [-SetLocation] [-Force] [<CommonParameters>]
```

### CurrentFirst
```
Get-GitBranch [[-Repo] <String[]>] [[-BranchName] <String[]>] [-CurrentFirst] [-IncludeRemote] [-SetLocation]
 [-Force] [<CommonParameters>]
```

### CurrentLast
```
Get-GitBranch [[-Repo] <String[]>] [[-BranchName] <String[]>] [-CurrentLast] [-IncludeRemote] [-SetLocation]
 [-Force] [<CommonParameters>]
```

## DESCRIPTION
Gets a list of branches for the specified repository.
By default, branches are returned in branch name (alphabetical) order, as they are with native git commands.

## EXAMPLES

### EXAMPLE 1
```
## Call from outside a repository without parameters ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitBranch

# Nothing was returned because a Repo was not provided.
```

### EXAMPLE 2
```
## Call from outside a repository for non-existent repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Get-GitBranch -Repo NonExistentRepo
WARNING: [Get-GitBranch]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.
```

### EXAMPLE 3
```
## Call from outside a repository with Repo parameter ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitBranch -Repo MyToolbox | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox feature1          False    False
MyToolbox feature3          False    False
MyToolbox main               True    False
MyToolbox release           False    False

# The branches were returned even though the command was issued from outside the repository directory.
```

### EXAMPLE 4
```
## Call from outside a repository with Repo and SetLocation parameters ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitBranch -Repo MyToolbox -SetLocation | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox feature1          False    False
MyToolbox feature3          False    False
MyToolbox main               True    False
MyToolbox release           False    False

PS C:\PowdrgitExamples\MyToolbox>

# The branches were returned and the current location (reflected in the prompt) changed to the repository's top-level directory.
```

### EXAMPLE 5
```
## Call from outside a repository with Repo and IncludeRemote parameters ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitBranch -Repo MyToolbox -IncludeRemote | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox feature1          False    False
MyToolbox feature3          False    False
MyToolbox main               True    False
MyToolbox release           False    False
MyToolbox feature2          False     True

# Remote branches were also included in the results. Note that remotes that are also the upstream of a local branch are omitted.
```

### EXAMPLE 6
```
## Call from outside a repository with Repo, IncludeRemote and ExcludeLocal parameters ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitBranch -Repo MyToolbox -IncludeRemote -ExcludeLocal | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox feature2          False     True

# Only remote branches were included in the results. Note that remotes that are also the upstream of a local branch are omitted.
```

### EXAMPLE 7
```
## Call from outside a repository with Repo and ExcludeLocal parameters ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitBranch -Repo MyToolbox -ExcludeLocal
PS C:\>

# Use of the ExcludeLocal switch without the IncludeRemote switch returns no results because the function returns only local branches by default.
```

### EXAMPLE 8
```
## Call from outside a repository with Repo and ExcludeLocal parameters ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo | Get-GitBranch | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox feature1          False    False
MyToolbox feature3          False    False
MyToolbox main               True    False
MyToolbox release           False    False
Project1  main              False    False
Project1  newfeature         True    False

# By piping the results of Get-GitRepo into Get-GitBranch we can get a list of branches for multiple repositories in a single command.
```

### EXAMPLE 9
```
## Get all local branches of the current repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -Repo MyToolbox # move to the repository directory
PS C:\PowdrgitExamples\MyToolbox> Get-GitBranch | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox feature1          False    False
MyToolbox feature3          False    False
MyToolbox main               True    False
MyToolbox release           False    False
```

### EXAMPLE 10
```
## Call with -CurrentFirst switch ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -Repo MyToolbox # move to the repository directory
PS C:\PowdrgitExamples\MyToolbox> Get-GitBranch -CurrentFirst | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox main               True    False
MyToolbox feature1          False    False
MyToolbox feature3          False    False
MyToolbox release           False    False

# The CurrentFirst switch caused the checked out branch to be returned in the first position.
# This may be useful when piping to Set-GitBranch so that the script block is applied to the current branch before checking out another.
```

### EXAMPLE 11
```
## Call with -CurrentLast switch ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -Repo MyToolbox # move to the repository directory
PS C:\PowdrgitExamples\MyToolbox> Get-GitBranch -CurrentLast | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox feature1          False    False
MyToolbox feature3          False    False
MyToolbox release           False    False
MyToolbox main               True    False

# The CurrentLast switch caused the checked out branch to be returned in the last position.
# This may be useful when piping to Set-GitBranch so that when the prompt returns, the same branch is checked out as when the command was executed.
```

### EXAMPLE 12
```
## Call with -Current switch ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -Repo MyToolbox # move to the repository directory
PS C:\PowdrgitExamples\MyToolbox> Get-GitBranch -Current | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox main               True    False

# The Current switch caused only the checked out branch to be returned.
```

### EXAMPLE 13
```
## Call with Repo value matching multiple repositories ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Get-GitBranch -Repo PowdrgitExamples -BranchName *feature* | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote,RepoPath
WARNING: [Get-GitBranch]Repo argument 'PowdrgitExamples' matched multiple repositories. Please confirm any results or actions are as expected.

RepoName  BranchName IsCheckedOut IsRemote RepoPath
--------  ---------- ------------ -------- --------
MyToolbox feature1          False    False C:\PowdrgitExamples\MyToolbox
MyToolbox feature3          False    False C:\PowdrgitExamples\MyToolbox
Project1  newfeature         True    False C:\PowdrgitExamples\Project1
```

### EXAMPLE 14
```
## Hide branches from results using $Powdrgit.BranchExcludes ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> $Powdrgit.BranchExcludesNoWarn = $false # to ensure warnings are visible
PS C:\> $Powdrgit.BranchExcludes = [PSCustomObject]@{ RepoPattern = '.*'; BranchPattern = 'feature\d'; ApplyTo = 'Local' }
PS C:\> Get-GitBranch -Repo MyToolbox | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote
WARNING: [Get-GitBranch]Branches excluded due to conditions in $Powdrgit.BranchExcludes: 4

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox main               True    False
MyToolbox release           False    False
```

### EXAMPLE 15
```
## Show all branches including branches usually hidden from results with $Powdrgit.BranchExcludes ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> $Powdrgit.BranchExcludesNoWarn = $false # to ensure warnings are visible
PS C:\> $Powdrgit.BranchExcludes = [PSCustomObject]@{ RepoPattern = '.*'; BranchPattern = 'feature\d'; ApplyTo = 'Local' }
PS C:\> Get-GitBranch -Repo MyToolbox -Force | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox feature1          False    False
MyToolbox feature3          False    False
MyToolbox main               True    False
MyToolbox release           False    False
```

## PARAMETERS

### -BranchName
The names of the branches to be checked out.
Wildcard characters are allowed.
The pattern will match against existing branches in the specified repository.
A warning will be generated for any values that do not match the name of an existing branch.
Branches can be suppressed from results on either a global, local only, or remote only basis by adding filters to $Powdrgit.BranchExcludes value (see examples).
RepoPattern is a regular expression evaluated against RepoName to identify repositories that the filter will be applied to.
BranchPattern is a regular expression evaluated against BranchFullName to identify branches that will be excluded from results.
ApplyTo can be used to limit the filtering to either local branches, remote branches, or either.
Valid ApplyTo values are: 'Local', 'Remote', or 'Global.
An empty string or $null is equivalent to 'Global'.
Any other value will cause the filter to be ignored.
Multiple filters can be defined, and all filters that match a given repository will be applied.
By default, when a filter causes exclusion of branches from the results a warning will be displayed.
This can be suppressed by setting $Powdrgit.BranchExcludesNoWarn = $true.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: *
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Current
Limits the results to the current branch of the specified repository; otherwise, all matching branch names will be returned.
Implies Force.

```yaml
Type: SwitchParameter
Parameter Sets: Current
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CurrentFirst
Forces the current branch to be the first returned item.
All other branches will be returned in branch name (alphabetical) order.

```yaml
Type: SwitchParameter
Parameter Sets: CurrentFirst
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CurrentLast
Forces the current branch to be the last returned item.
All other branches will be returned in branch name (alphabetical) order.

```yaml
Type: SwitchParameter
Parameter Sets: CurrentLast
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeLocal
Excludes local branches from the output.

```yaml
Type: SwitchParameter
Parameter Sets: Remote
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Return all branches even when a matching filter in $Powdrgit.BranchExcludes exists.

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

### -IncludeRemote
Includes remote branches in the output.

```yaml
Type: SwitchParameter
Parameter Sets: Remote, CurrentFirst, CurrentLast
Aliases:

Required: False
Position: Named
Default value: False
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[System.String[]]

Accepts string objects via the Repo parameter. The output of Get-GitRepo can be piped into Get-GitBranch.

## OUTPUTS

[GitBranch]

Returns a custom GitBranch object. For details use Get-Member at a command prompt e.g.:

PS C:\PowdrgitExamples\MyToolbox> Get-GitBranch | Get-Member -MemberType Properties

## NOTES
Author : nmbell

## RELATED LINKS

[Set-GitBranch](Set-GitBranch.md)

[Get-GitRepo](Get-GitRepo.md)

[Get-GitLog](Get-GitLog.md)

[Get-GitTag](Get-GitTag.md)

[about_powdrgit](about_powdrgit.md)



