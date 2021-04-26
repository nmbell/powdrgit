# Get-GitBranch

## SYNOPSIS
Gets a list of branches for the specified repository.

## SYNTAX

### Remote (Default)
```
Get-GitBranch [[-RepoName] <String>] [-IncludeRemote] [-ExcludeLocal] [-SetLocation] [<CommonParameters>]
```

### Current
```
Get-GitBranch [[-RepoName] <String>] [-Current] [-SetLocation] [<CommonParameters>]
```

### CurrentFirst
```
Get-GitBranch [[-RepoName] <String>] [-CurrentFirst] [-IncludeRemote] [-SetLocation] [<CommonParameters>]
```

### CurrentLast
```
Get-GitBranch [[-RepoName] <String>] [-CurrentLast] [-IncludeRemote] [-SetLocation] [<CommonParameters>]
```

## DESCRIPTION
Gets a list of branches for the specified repository.
By default, branches are returned in branch name (alphabetical) order, as they are with native git commands.

## EXAMPLES

### EXAMPLE 1
```
## Call from outside a repository without parameters ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitBranch

# Nothing was returned because a RepoName was not provided.
```

### EXAMPLE 2
```
## Call from outside a repository for non-existent repository ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitBranch -RepoName NonExistentRepo
WARNING: [Get-GitBranch]Repository 'NonExistentRepo' not found. Check the repository directory has been added to the $GitRepoPath module variable.
```

### EXAMPLE 3
```
## Call from outside a repository with RepoName parameter ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitBranch -RepoName MyToolbox | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

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
## Call from outside a repository with RepoName and SetLocation parameters ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitBranch -RepoName MyToolbox -SetLocation | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox feature1          False    False
MyToolbox feature3          False    False
MyToolbox main               True    False
MyToolbox release           False    False

PS C:\PowdrgitExamples\MyToolbox\>

# The branches were returned and the current location (reflected in the prompt) changed to the repository's top-level directory.
```

### EXAMPLE 5
```
## Call from outside a repository with RepoName and IncludeRemote parameters ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitBranch -RepoName MyToolbox -IncludeRemote | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

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
## Call from outside a repository with RepoName, IncludeRemote and ExcludeLocal parameters ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitBranch -RepoName MyToolbox -IncludeRemote -ExcludeLocal | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox feature2          False     True

# Only remote branches were included in the results. Note that remotes that are also the upstream of a local branch are omitted.
```

### EXAMPLE 7
```
## Call from outside a repository with RepoName and ExcludeLocal parameters ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitBranch -RepoName MyToolbox -ExcludeLocal
PS C:\>

# Use of the ExcludeLocal switch without the IncludeRemote switch returns no results because the function returns only local branches by default.
```

### EXAMPLE 8
```
## Call from outside a repository with RepoName and ExcludeLocal parameters ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
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

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -RepoName MyToolbox # move to the repository directory
PS C:\PowdrgitExamples\MyToolbox\> Get-GitBranch | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

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

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -RepoName MyToolbox # move to the repository directory
PS C:\PowdrgitExamples\MyToolbox\> Get-GitBranch -CurrentFirst | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

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

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -RepoName MyToolbox # move to the repository directory
PS C:\PowdrgitExamples\MyToolbox\> Get-GitBranch -CurrentLast | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

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

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -RepoName MyToolbox # move to the repository directory
PS C:\PowdrgitExamples\MyToolbox\> Get-GitBranch -Current | Format-Table -Property RepoName,BranchName,IsCheckedOut,IsRemote

RepoName  BranchName IsCheckedOut IsRemote
--------  ---------- ------------ --------
MyToolbox main               True    False

# The Current switch caused only the checked out branch to be returned.
```

## PARAMETERS

### -Current
Limits the results to the current branch of the specified repository; otherwise, all branch names will be returned.

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

### -RepoName
The name of the git repository to return.
This should match the directory name of one of the repositories defined in the $GitRepoPath module variable.
If there is no match, a warning is generated.
When the parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -SetLocation
Sets the working directory to the top-level directory of the specified repository.
In the case where multiple RepoName values are passed in, the location will reflect the repository that was specified last.

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

[System.String]

Accepts string objects via the RepoName parameter. The output of Get-GitRepo can be piped into Get-GitBranch.

## OUTPUTS

[GitBranch]

Returns a custom GitBranch object. For details use Get-Member at a command prompt e.g.:

`PS C:\PowdrgitExamples\MyToolbox> Get-GitBranch | Get-Member -MemberType Properties`


## NOTES
Author : nmbell

## RELATED LINKS

[about_powdrgit](about_powdrgit.md)

[Get-GitRepo](Get-GitRepo.md)

[Set-GitBranch](Set-GitBranch.md)



