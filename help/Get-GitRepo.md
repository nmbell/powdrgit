# Get-GitRepo

## SYNOPSIS
Gets the directory objects for valid repositories defined in the $Powdrgit.Path module variable.

## SYNTAX

### Repo (Default)
```
Get-GitRepo [[-Repo] <String[]>] [<CommonParameters>]
```

### Current
```
Get-GitRepo [-Current] [<CommonParameters>]
```

## DESCRIPTION
Gets the directory objects for valid repositories defined in the $Powdrgit.Path module variable.

## EXAMPLES

### EXAMPLE 1
```
## Get all valid repositories defined in the $Powdrgit.Path module variable ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo | Select-Object -ExpandProperty RepoName
MyToolbox
Project1
```

### EXAMPLE 2
```
## Get the repository by name ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo -Repo MyToolBox | Select-Object -ExpandProperty RepoName
MyToolbox
```

### EXAMPLE 3
```
## Get the repository by directory path ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo -Repo 'C:\PowdrgitExamples\MyToolbox' | Select-Object -ExpandProperty RepoName
MyToolbox
```

### EXAMPLE 4
```
## Get the repository by partial match ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo -Repo 'Examples\MyTool' | Select-Object -ExpandProperty RepoName
MyToolbox
```

### EXAMPLE 5
```
## Get the repository by file path ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo -Repo 'C:\PowdrgitExamples\MyToolbox\feature1_File1.txt' | Select-Object -ExpandProperty RepoName
MyToolbox
```

### EXAMPLE 6
```
## Get the repository from multiple inputs ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo -Repo 'Examples\MyTool','Project1' | Select-Object -ExpandProperty RepoName
Project1
MyToolbox

# Both the partial match and exact match were returned
```

### EXAMPLE 7
```
## Get the current repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo -Current
PS C:\>

# Nothing was returned because the current location is not inside a repository.

PS C:\> Set-GitRepo -Repo MyToolbox # move to the repository directory
PS C:\PowdrgitExamples\MyToolbox> Get-GitRepo -Current | Select-Object -ExpandProperty RepoName
MyToolbox

# This time the repository name is returned because we were inside a repository.
```

### EXAMPLE 8
```
## Pass $null to the Repo parameter ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo -Repo $null
PS C:\>
```

## PARAMETERS

### -Current
Limits the results to the current git repository.
Returns nothing if the working directory is not a git repository.
Will return the current repository when the working directory is either the repository directory or any of its subdirectories.

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

### -Repo
The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
The value passed in is matched against the directory paths defined in the $Powdrgit.Path module variable:
  - If the value is an exact match to any repository names or paths, only those repositories will be returned.
  - If there are no exact matches but the value is a partial match to any repository paths, those repositories will be returned.
  - If there are no exact or partial matches, nothing will be returned.
  - If the value is $null or an empty\whitespace string, nothing will be returned.

If the Repo parameter is omitted, all valid repositories will be returned.
When using tab completion, if a repository name is unique, only the name will be displayed, otherwise the full directory path is displayed.
To force autocompletion to always show the full path, set $Powdrgit.AutoCompleteFullPaths = $true.
Tab completion values will match on a repository name or path.

```yaml
Type: String[]
Parameter Sets: Repo
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

[GitRepo]

Returns a custom GitRepo object. The DirectoryInfo property contains the filesystem directory object for the repository.

## NOTES
Author : nmbell

## RELATED LINKS

[Find-GitRepo](Find-GitRepo.md)

[Set-GitRepo](Set-GitRepo.md)

[New-GitRepo](New-GitRepo.md)

[Remove-GitRepo](Remove-GitRepo.md)

[Invoke-GitClone](Invoke-GitClone.md)

[Add-PowdrgitPath](Add-PowdrgitPath.md)

[Remove-PowdrgitPath](Remove-PowdrgitPath.md)

[Test-PowdrgitPath](Test-PowdrgitPath.md)

[about_powdrgit](about_powdrgit.md)



