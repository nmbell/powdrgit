# Set-GitRepo

## SYNOPSIS
Sets the working directory to the top level directory of the specified repository.

## SYNTAX

```
Set-GitRepo [[-RepoName] <String>] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
Sets the working directory to the top level directory of the specified repository.

## EXAMPLES

### EXAMPLE 1
```
## Call without specifying a repository ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo
PS C:\>

# The current location (reflected in the prompt) did not change.
```

### EXAMPLE 2
```
## Move to a non-existent repository ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -RepoName NonExistentRepo
WARNING: [Set-GitRepo]Repository 'NonExistentRepo' not found. Check the repository directory has been added to the $GitRepoPath module variable.
PS C:\>

# The current location (reflected in the prompt) did not change.
```

### EXAMPLE 3
```
## Move to an existing repository ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -RepoName MyToolbox
PS C:\PowdrgitExamples\MyToolbox\>

# The current location (reflected in the prompt) changed to the repository's top-level directory.
```

### EXAMPLE 4
```
## Call with PassThru switch ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -RepoName MyToolbox -PassThru | Select-Object -ExpandProperty FullName
C:\PowdrgitExamples\MyToolbox
PS C:\PowdrgitExamples\MyToolbox\>

# Because the object returned is an extension of a file system object, any of its usual properties are available in the output.
```

## PARAMETERS

### -PassThru
Returns the directory object for the repository top-level directory.

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
The powdrgit module always takes the name of the top-level repository directory as the repository name.
It does not use values from a repository's config or origin URL as the name.
This should match the directory name of one of the repositories defined in the $GitRepoPath module variable.
If there is no match, a warning is generated.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[System.String]

Accepts string objects via the RepoName parameter.

## OUTPUTS

[System.IO.DirectoryInfo]

When the PassThru switch is used, returns directory objects.


## NOTES
Author : nmbell

## RELATED LINKS

[about_powdrgit](about_powdrgit.md)

[Find-GitRepo](Find-GitRepo.md)

[Get-GitRepo](Get-GitRepo.md)

[Test-GitRepoPath](Test-GitRepoPath.md)



