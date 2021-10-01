# Set-GitRepo

## SYNOPSIS
Sets the working directory to the top level directory of the specified repository.

## SYNTAX

```
Set-GitRepo [[-Repo] <String[]>] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
Sets the working directory to the top level directory of the specified repository.

## EXAMPLES

### EXAMPLE 1
```
## Call without specifying a repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo
PS C:\>

# The current location (reflected in the prompt) did not change.
```

### EXAMPLE 2
```
## Move to a non-existent repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Set-GitRepo -Repo NonExistentRepo
WARNING: [Set-GitRepo]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.

# The current location (reflected in the prompt) did not change.
```

### EXAMPLE 3
```
## Move to an existing repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -Repo MyToolbox
PS C:\PowdrgitExamples\MyToolbox>

# The current location (reflected in the prompt) changed to the repository's top-level directory.
```

### EXAMPLE 4
```
## Call with PassThru switch ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -Repo MyToolbox -PassThru | Select-Object -ExpandProperty RepoPath
C:\PowdrgitExamples\MyToolbox
PS C:\PowdrgitExamples\MyToolbox>

# Because the object returned is an extension of a file system object, any of its usual properties are available in the output.
```

### EXAMPLE 5
```
## Call with Repo value matching multiple repositories ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Set-GitRepo -Repo PowdrgitExamples -PassThru | Select-Object -ExpandProperty RepoPath
C:\PowdrgitExamples\MyToolbox
WARNING: [Set-GitRepo]'PowdrgitExamples' matched multiple repositories. Please confirm any results or actions are as expected.
C:\PowdrgitExamples\MyToolbox
C:\PowdrgitExamples\Project1
PS C:\PowdrgitExamples\Project1>

# Note: in this case, the final location that is set will be the matching repository path that is last alphabetically.
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

### -Repo
The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
If the Repo parameter is omitted, nothing will happen.
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[System.String]

Accepts string objects via the Repo parameter.

## OUTPUTS

[System.IO.DirectoryInfo]

When the PassThru switch is used, returns directory objects.

## NOTES
Author : nmbell

## RELATED LINKS

[Find-GitRepo](Find-GitRepo.md)

[Get-GitRepo](Get-GitRepo.md)

[New-GitRepo](New-GitRepo.md)

[Remove-GitRepo](Remove-GitRepo.md)

[Invoke-GitClone](Invoke-GitClone.md)

[Add-PowdrgitPath](Add-PowdrgitPath.md)

[Remove-PowdrgitPath](Remove-PowdrgitPath.md)

[Test-PowdrgitPath](Test-PowdrgitPath.md)

[about_powdrgit](about_powdrgit.md)



