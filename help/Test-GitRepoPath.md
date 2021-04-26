# Test-GitRepoPath

## SYNOPSIS
Validates the paths stored in the $GitRepoPath module variable.

## SYNTAX

```
Test-GitRepoPath [-PassThru] [-NoWarn] [<CommonParameters>]
```

## DESCRIPTION
Validates the paths stored in the $GitRepoPath module variable.
The functions evaluates each path and returns the count of paths in the $GitRepoPath module variable that are valid git repositories.
A warning message is also generated when:
 - a path doesn't exist; or
 - a path is not a git repository; or
 - the $GitRepoPath module variable is not defined (i.e. an empty string or $null).
A NoWarn switch allows these warnings to be suppressed.
A PassThru parameter allows a string array of only valid paths to be returned instead of the count of valid paths.

## EXAMPLES

### EXAMPLE 1
```
## Valid paths ##

# This example assumes that:
# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1'
PS C:\> Test-GitRepoPath
2
```

### EXAMPLE 2
```
## Valid and invalid paths ##

# This example assumes that:
# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).
# - C:\PowdrgitExamples\NotAGitRepo directory exists but is not a git repository (i.e. does not contain a .git subdirectory).
# - C:\PowdrgitExamples\NonExistentFolder directory does not exist.

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\NonExistentFolder'
PS C:\> Test-GitRepoPath
WARNING: [Test-GitRepoPath]Path is not a repository: C:\PowdrgitExamples\NotAGitRepo
WARNING: [Test-GitRepoPath]Directory does not exist: C:\PowdrgitExamples\NonExistentFolder
2
```

### EXAMPLE 3
```
## The $GitRepoPath module variable is undefined ##

PS C:\> $GitRepoPath = $null
PS C:\> Test-GitRepoPath
WARNING: [Test-GitRepoPath]The $GitRepoPath module variable is not defined.
0
PS C:\> $GitRepoPath = ''
PS C:\> Test-GitRepoPath
WARNING: [Test-GitRepoPath]The $GitRepoPath module variable is not defined.
0
```

### EXAMPLE 4
```
## Valid and invalid paths - suppress warnings with -NoWarn ##

# This example assumes that:
# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).
# - C:\PowdrgitExamples\NotAGitRepo directory exists but is not a git repository (i.e. does not contain a .git subdirectory).
# - C:\PowdrgitExamples\NonExistentFolder directory does not exist.

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\NonExistentFolder'
PS C:\> $MyWarnings = $null
PS C:\> Test-GitRepoPath -WarningVariable MyWarnings -WarningAction SilentlyContinue
2
PS C:\> $MyWarnings
[Test-GitRepoPath]Path is not a repository: C:\PowdrgitExamples\NotAGitRepo
[Test-GitRepoPath]Directory does not exist: C:\PowdrgitExamples\NonExistentFolder

# Warnings were not returned to the console, but were still captured in the MyWarnings variable.

PS C:\> $MyWarnings = $null
PS C:\> Test-GitRepoPath -NoWarn -WarningVariable MyWarnings
2
PS C:\> $MyWarnings
PS C:\>

# $MyWarnings is empty because warnings were never generated.
```

### EXAMPLE 5
```
## Valid and invalid paths - return an array of valid paths with PassThru ##

# This example assumes that
# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).
# - C:\PowdrgitExamples\NotAGitRepo directory exists but is not a git repository (i.e. does not contain a .git subdirectory).
# - C:\PowdrgitExamples\NonExistentFolder directory does not exist.

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\NonExistentFolder'
PS C:\> $GitRepoPath -split ';'
C:\PowdrgitExamples\MyToolbox
C:\PowdrgitExamples\Project1
C:\PowdrgitExamples\NotAGitRepo
C:\PowdrgitExamples\NonExistentFolder

# All paths in the $GitRepoPath module variable were returned.

PS C:\> Test-GitRepoPath -NoWarn -PassThru
C:\PowdrgitExamples\MyToolbox
C:\PowdrgitExamples\Project1

# Only the paths that are valid git repositories were returned.
```

## PARAMETERS

### -NoWarn
Suppresses warnings.

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

### -PassThru
Returns a string array of only valid paths.

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

None.

## OUTPUTS

[System.Int32]

[System.String]

Returns Int32 objects by default. When the PassThru parameter is used, returns String objects.


## NOTES
Author : nmbell

## RELATED LINKS

[about_powdrgit](about_powdrgit.md)

[Find-GitRepo](Find-GitRepo.md)

[Get-GitRepo](Get-GitRepo.md)

[Set-GitRepo](Set-GitRepo.md)



