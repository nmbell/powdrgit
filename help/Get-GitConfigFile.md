# Get-GitConfigFile

## SYNOPSIS
Gets the config file for the given repository or scope.

## SYNTAX

```
Get-GitConfigFile [[-RepoName] <String>] [-Local] [-System] [-Global] [<CommonParameters>]
```

## DESCRIPTION
Gets the config file for the given repository or scope.

## EXAMPLES

### EXAMPLE 1
```
## Call from outside a repository without parameters ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitConfigFile | Format-Table -Property Scope,ConfigFile

Scope  ConfigFile
-----  ----------
System C:\Program Files\Git\etc\gitconfig
Global C:\Users\nmbell\.gitconfig

# When no scope switches are specified, the config files for all relevant scopes are returned.
```

### EXAMPLE 2
```
## Get only the system config file ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitConfigFile -System | Format-Table -Property Scope,ConfigFile

Scope     ConfigFile
-----     ----------
System    C:\Program Files\Git\etc\gitconfig
```

### EXAMPLE 3
```
## Call from outside a repository for non-existent repository ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitConfigFile -RepoName NonExistentRepo -Local
WARNING: [Get-GitConfigFile]Repository 'NonExistentRepo' not found. Check the repository directory has been added to the $GitRepoPath module variable.
```

### EXAMPLE 4
```
## Call from outside a repository with RepoName parameter ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitConfigFile -RepoName MyToolbox | Format-Table -Property Scope,ConfigFile

Scope     ConfigFile
-----     ----------
MyToolbox C:\PowdrgitExamples\MyToolbox\.git\config
System    C:\Program Files\Git\etc\gitconfig
Global    C:\Users\nmbell\.gitconfig

# When no scope switches are specified, the config files for all relevant scopes are returned.
```

### EXAMPLE 5
```
## Call from inside a repository without parameters ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox\> Get-GitConfigFile | Format-Table -Property Scope,ConfigFile

Scope     ConfigFile
-----     ----------
MyToolbox C:\PowdrgitExamples\MyToolbox\.git\config
System    C:\Program Files\Git\etc\gitconfig
Global    C:\Users\nmbell\.gitconfig

# When no scope switches are specified, the config files for all relevant scopes are returned.
```

### EXAMPLE 6
```
## Pipe results from Get-GitRepo ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo | Get-GitConfigFile | Format-Table -Property Scope,ConfigFile

Scope     ConfigFile
-----     ----------
MyToolbox C:\PowdrgitExamples\MyToolbox\.git\config
Project1  C:\PowdrgitExamples\Project1\.git\config
System    C:\Program Files\Git\etc\gitconfig
Global    C:\Users\nmbell\.gitconfig

# System and Global config files are returned only once per call.
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
Returns the repository config file.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[System.String]

Accepts string objects via the RepoName parameter. The output of Get-GitRepo can be piped into Get-GitConfigFile.

## OUTPUTS

[GitConfigFile]

Returns a custom GitConfigFile object. For details use Get-Member at a command prompt e.g.:

`PS C:\PowdrgitExamples\MyToolbox> Get-GitConfigFile | Get-Member -MemberType Properties`


## NOTES
Author : nmbell

## RELATED LINKS

[about_powdrgit](about_powdrgit.md)

[Get-GitRepo](Get-GitRepo.md)



