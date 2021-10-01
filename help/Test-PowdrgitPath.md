# Test-PowdrgitPath

## SYNOPSIS
Validates the paths stored in the $Powdrgit.Path module variable.

## SYNTAX

```
Test-PowdrgitPath [-PassThru] [-Failing] [<CommonParameters>]
```

## DESCRIPTION
Validates the paths stored in the $Powdrgit.Path module variable.
The functions evaluates each path and returns the count of paths in the $Powdrgit.Path module variable that are valid git repositories.
Test-PowdrgitPath will ignore duplicate and empty/whitespace paths in the $Powdrgit.Path module variable, and will evaluate and/or output paths in alphabetical order.
A warning message is also generated when:
  - a path doesn't exist; or
  - a path is not a git repository; or
  - the $Powdrgit.Path module variable is not defined (i.e. an empty string or $null).

A PassThru parameter allows a string array of only valid paths to be returned instead of the count of valid paths.

## EXAMPLES

### EXAMPLE 1
```
## Valid paths ##

# This example assumes that:
# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1'
PS C:\> Test-PowdrgitPath
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

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\NonExistentFolder'
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Test-PowdrgitPath
WARNING: [Test-PowdrgitPath]Directory does not exist: C:\PowdrgitExamples\NonExistentFolder
WARNING: [Test-PowdrgitPath]Path is not a repository: C:\PowdrgitExamples\NotAGitRepo
2
```

### EXAMPLE 3
```
## The $Powdrgit.Path module variable is undefined ##

PS C:\> $Powdrgit.Path = $null
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Test-PowdrgitPath
WARNING: [Test-PowdrgitPath]The $Powdrgit.Path module variable is not defined.
0
PS C:\> $Powdrgit.Path = ''
PS C:\> Test-PowdrgitPath
WARNING: [Test-PowdrgitPath]The $Powdrgit.Path module variable is not defined.
0
```

### EXAMPLE 4
```
## Valid and invalid paths - suppress warnings with -WarningAction Ignore##

# This example assumes that:
# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).
# - C:\PowdrgitExamples\NotAGitRepo directory exists but is not a git repository (i.e. does not contain a .git subdirectory).
# - C:\PowdrgitExamples\NonExistentFolder directory does not exist.

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\NonExistentFolder'
PS C:\> $myWarnings = $null
PS C:\> Test-PowdrgitPath -WarningVariable myWarnings -WarningAction SilentlyContinue
2
PS C:\> $myWarnings
[Test-PowdrgitPath]Directory does not exist: C:\PowdrgitExamples\NonExistentFolder
[Test-PowdrgitPath]Path is not a repository: C:\PowdrgitExamples\NotAGitRepo

# Warnings were not returned to the console, but were still captured in the myWarnings variable.

PS C:\> $myWarnings = $null
PS C:\> Test-PowdrgitPath -WarningAction Ignore -WarningVariable myWarnings
2
PS C:\> $myWarnings
PS C:\>

# $myWarnings is empty because warnings were never generated.
```

### EXAMPLE 5
```
## Valid and invalid paths - return an array of valid paths with PassThru ##

# This example assumes that
# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).
# - C:\PowdrgitExamples\NotAGitRepo directory exists but is not a git repository (i.e. does not contain a .git subdirectory).
# - C:\PowdrgitExamples\NonExistentFolder directory does not exist.

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\NonExistentFolder'
PS C:\> $Powdrgit.Path -split ';'
C:\PowdrgitExamples\MyToolbox
C:\PowdrgitExamples\Project1
C:\PowdrgitExamples\NotAGitRepo
C:\PowdrgitExamples\NonExistentFolder

# All paths in the $Powdrgit.Path module variable were returned.

PS C:\> Test-PowdrgitPath -PassThru -WarningAction Ignore
C:\PowdrgitExamples\MyToolbox
C:\PowdrgitExamples\Project1

# Only the paths that are valid git repositories were returned.
```

### EXAMPLE 6
```
## Valid and invalid paths - return an array of invalid paths with Failing and PassThru ##

# This example assumes that
# - C:\PowdrgitExamples\MyToolbox directory exists and is a git repository (i.e. contains a .git subdirectory).
# - C:\PowdrgitExamples\Project1 directory exists and is a git repository (i.e. contains a .git subdirectory).
# - C:\PowdrgitExamples\NotAGitRepo directory exists but is not a git repository (i.e. does not contain a .git subdirectory).
# - C:\PowdrgitExamples\NonExistentFolder directory does not exist.

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\NonExistentFolder'
PS C:\> $Powdrgit.Path -split ';'
C:\PowdrgitExamples\MyToolbox
C:\PowdrgitExamples\Project1
C:\PowdrgitExamples\NotAGitRepo
C:\PowdrgitExamples\NonExistentFolder

# All paths in the $Powdrgit.Path module variable were returned.

PS C:\> Test-PowdrgitPath -Failing -PassThru -WarningAction Ignore
C:\PowdrgitExamples\NotAGitRepo
C:\PowdrgitExamples\NonExistentFolder

# Only the paths that are not valid git repositories were returned.
```

## PARAMETERS

### -Failing
Causes the function to return the count of paths in $Powdrgit.Path that either do not exist or are not git repositories.

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

[Add-PowdrgitPath](Add-PowdrgitPath.md)

[Remove-PowdrgitPath](Remove-PowdrgitPath.md)

[Find-GitRepo](Find-GitRepo.md)

[Get-GitRepo](Get-GitRepo.md)

[Set-GitRepo](Set-GitRepo.md)

[New-GitRepo](New-GitRepo.md)

[Remove-GitRepo](Remove-GitRepo.md)

[Invoke-GitClone](Invoke-GitClone.md)

[about_powdrgit](about_powdrgit.md)



