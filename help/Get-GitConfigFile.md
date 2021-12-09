# Get-GitConfigFile

## SYNOPSIS
Gets the config file for the given repository or scope.

## SYNTAX

```
Get-GitConfigFile [[-Repo] <String[]>] [-Local] [-System] [-Global] [-Portable] [-Worktree] [<CommonParameters>]
```

## DESCRIPTION
Gets the config file for the given repository or scope.
The Path property of the results shows the expected path of the config file.
The FileInfo property of the results holds the file object of the config file, which may be null if the config file doesn't exist.

## EXAMPLES

### EXAMPLE 1
```
## Call from outside a repository without parameters ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitConfigFile | Format-Table -Property Scope,Path

Scope    Path
-----    ----
System   C:\Program Files\Git\etc\gitconfig
Global   C:\Users\nmbell\.gitconfig
Portable C:\ProgramData\Git\config

# When no scope switches are specified, the config files for all relevant scopes are returned.
```

### EXAMPLE 2
```
## Get only the system config file ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitConfigFile -System | Format-Table -Property Scope,Path

Scope     Path
-----     ----
System    C:\Program Files\Git\etc\gitconfig
```

### EXAMPLE 3
```
## Call from outside a repository for non-existent repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Get-GitConfigFile -Repo NonExistentRepo -Local
WARNING: [Get-GitConfigFile]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.
```

### EXAMPLE 4
```
## Call from outside a repository with Repo parameter ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitConfigFile -Repo MyToolbox | Format-Table -Property Scope,Path

Scope     Path
-----     ----
MyToolbox C:\PowdrgitExamples\MyToolbox\.git\config
System    C:\Program Files\Git\etc\gitconfig
Global    C:\Users\nmbell\.gitconfig
Portable  C:\ProgramData\Git\config

# When no scope switches are specified, the config files for all relevant scopes are returned.
```

### EXAMPLE 5
```
## Call from inside a repository without parameters ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox> Get-GitConfigFile | Format-Table -Property Scope,Path

Scope     Path
-----     ----
MyToolbox C:\PowdrgitExamples\MyToolbox\.git\config
System    C:\Program Files\Git\etc\gitconfig
Global    C:\Users\nmbell\.gitconfig
Portable  C:\ProgramData\Git\config

# When no scope switches are specified, the config files for all relevant scopes are returned.
```

### EXAMPLE 6
```
## See the worktree config file, if it exists ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox> Get-GitConfigFile -Worktree | Format-Table -Property Scope,FileInfo,Exists,Path

Scope                FileInfo Exists Path
-----                -------- ------ ----
MyToolbox (worktree)           False D:\Users\mixol\Documents\_Documents\xWork\6 APX\_DBA\.git\config.worktree
```

### EXAMPLE 7
```
## Pipe results from Get-GitRepo ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo | Get-GitConfigFile | Format-Table -Property Scope,Path

Scope     Path
-----     ----
MyToolbox C:\PowdrgitExamples\MyToolbox\.git\config
Project1  C:\PowdrgitExamples\Project1\.git\config
System    C:\Program Files\Git\etc\gitconfig
Global    C:\Users\nmbell\.gitconfig
Portable  C:\ProgramData\Git\config

# System, Global, and Portable config files are returned only once per call.
```

## PARAMETERS

### -Global
Returns the global (user) config file.

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

### -Local
Returns the repository config file when inside a repository.

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

### -Portable
Returns the portable config file.

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

### -System
Returns the system config file.

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

### -Worktree
Returns the repository worktree config file when inside a repository.
Note: When no switch parameters are specified, the worktree config file will only be returned as part of the results if it exists.

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

Accepts string objects via the Repo parameter. The output of Get-GitRepo can be piped into Get-GitConfigFile.

## OUTPUTS

[GitConfigFile]

Returns a custom GitConfigFile object. For details use Get-Member at a command prompt e.g.:

PS C:\PowdrgitExamples\MyToolbox> Get-GitConfigFile | Get-Member -MemberType Properties

## NOTES
Author : nmbell

## RELATED LINKS

[Get-GitRepo](Get-GitRepo.md)

[about_powdrgit](about_powdrgit.md)



