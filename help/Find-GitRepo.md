# Find-GitRepo

## SYNOPSIS
Finds all git repositories that exist under the specifed root directory.

## SYNTAX

### Set (Default)
```
Find-GitRepo [[-RootDirectory] <String[]>] [-SetGitRepoPath] [<CommonParameters>]
```

### Append
```
Find-GitRepo [[-RootDirectory] <String[]>] [-AppendGitRepoPath] [<CommonParameters>]
```

## DESCRIPTION
Finds all git repositories that exist under the specifed root directory.
Searches the specifed directory and its subdirectories and returns a set of directory objects, each of which is a git repository.

## EXAMPLES

### EXAMPLE 1
```
## Find git repositories under a root directory ##

PS C:\> Find-GitRepo -RootDirectory 'C:\PowdrgitExamples' | Select-Object -ExpandProperty FullName
C:\PowdrgitExamples\MyToolbox
C:\PowdrgitExamples\Project1
```

### EXAMPLE 2
```
## Populate the $GitRepoPath module variable with SetGitRepoPath parameter ##

PS C:\> $GitRepoPath = $null
PS C:\> Find-GitRepo -RootDirectory 'C:\PowdrgitExamples' -SetGitRepoPath | Out-Null
PS C:\> $GitRepoPath
C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1
```

### EXAMPLE 3
```
## Populate the $GitRepoPath module variable with function output ##

PS C:\> $GitRepoPath = $null
PS C:\> $GitRepoPath = (Find-GitRepo -RootDirectory 'C:\PowdrgitExamples' | Select-Object -ExpandProperty FullName) -join ';'
PS C:\> $GitRepoPath
C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1

# This example uses the output of Find-GitRepo to populate the $GitRepoPath module variable.
# It is equivalent to the previous example, however, this method may be preferred when filtering is required e.g.:
# $GitRepoPath = (Find-GitRepo -RootDirectory 'C:\PowdrgitExamples' | Where-Object Name -ne 'MyToolbox' | Select-Object -ExpandProperty FullName) -join ';'
```

### EXAMPLE 4
```
## Use AppendGitRepoPath to add new repositories to the $GitRepoPath module variable ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the existing repository paths are defined
PS C:\> git init "C:\PowdrgitExamples2\Project2" 2\>&1 | Out-Null # create a new git repository
PS C:\> Find-GitRepo -RootDirectory 'C:\PowdrgitExamples2' -AppendGitRepoPath | Out-Null
PS C:\> $GitRepoPath
C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples2\Project2

# Clean up if required: Remove-Item -Path 'C:\PowdrgitExamples2' -Recurse -Force
```

### EXAMPLE 5
```
## Find git repositories by piping objects ##

PS C:\> 'C:\PowdrgitExamples' | Find-GitRepo | Select-Object -ExpandProperty FullName
C:\PowdrgitExamples\MyToolbox
C:\PowdrgitExamples\Project1

# Strings can be piped directly into the function.

PS C:\> Get-Item -Path 'C:\PowdrgitExamples' | Find-GitRepo | Select-Object -ExpandProperty FullName
C:\PowdrgitExamples\MyToolbox
C:\PowdrgitExamples\Project1

# Path and FullName are aliases for the RootDirectory parameter, allowing directory objects to be piped to Find-GitRepo.
```

## PARAMETERS

### -AppendGitRepoPath
Appends the list of paths for all found repositories to the $GitRepoPath module variable.
Paths that are already in the $GitRepoPath module variable will not be duplicated.

```yaml
Type: SwitchParameter
Parameter Sets: Append
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RootDirectory
An array of directory paths to be searched.
Paths that do not exist will be ignored.
If the parameter is omitted, or null, or an empty string, all fixed drives will be searched.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: FullName, Path

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -SetGitRepoPath
Populates the $GitRepoPath module variable with a list of the paths for all found repositories.

```yaml
Type: SwitchParameter
Parameter Sets: Set
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

[System.IO.DirectoryInfo]

Accepts directory objects.

## OUTPUTS

[System.IO.DirectoryInfo]

Returns directory objects.


## NOTES
Author : nmbell

## RELATED LINKS

[about_powdrgit](about_powdrgit.md)

[Get-GitRepo](Get-GitRepo.md)

[Set-GitRepo](Set-GitRepo.md)

[Test-GitRepoPath](Test-GitRepoPath.md)
