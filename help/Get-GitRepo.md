# Get-GitRepo

## SYNOPSIS
Gets the directory objects for valid repositories defined in the $GitRepoPath module variable.

## SYNTAX

### RepoName (Default)
```
Get-GitRepo [[-RepoName] <String>] [<CommonParameters>]
```

### Path
```
Get-GitRepo [-Path <String>] [<CommonParameters>]
```

### Current
```
Get-GitRepo [-Current] [<CommonParameters>]
```

## DESCRIPTION
Gets the directory objects for valid repositories defined in the $GitRepoPath module variable.

## EXAMPLES

### EXAMPLE 1
```
## Get all valid repositories defined in the $GitRepoPath module variable ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo | Select-Object -ExpandProperty RepoName
MyToolbox
Project1
```

### EXAMPLE 2
```
## Get the repository by RepoName ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo -RepoName MyToolBox | Select-Object -ExpandProperty RepoName
MyToolbox
```

### EXAMPLE 3
```
## Get the repository by Path ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo -Path 'C:\PowdrgitExamples\MyToolbox' | Select-Object -ExpandProperty RepoName
MyToolbox
```

### EXAMPLE 4
```
## Get the current repository ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo -Current
PS C:\>

# Nothing was returned because the current location is not inside a repository.

PS C:\> Set-GitRepo -RepoName MyToolbox # move to the repository directory
PS C:\PowdrgitExamples\MyToolbox\> Get-GitRepo -Current | Select-Object -ExpandProperty RepoName
MyToolbox

# This time the repository name is returned because we were inside a repository.
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

### -Path
The path of a git repository directory or any of its subdirectories or files.

```yaml
Type: String
Parameter Sets: Path
Aliases: FullName

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepoName
The name of the git repository to return.
The powdrgit module always takes the name of the top-level repository directory as the repository name.
It does not use values from a repository's config or origin URL as the name.
This should match the directory name of one of the repositories defined in the $GitRepoPath module variable.
If there is no match, nothing will be returned.
When the parameter is omitted, all valid repositories will be returned.

```yaml
Type: String
Parameter Sets: RepoName
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

[System.IO.DirectoryInfo] (extended)

Returns directory objects extended with a RepoName (String) alias property.


## NOTES
Author : nmbell

## RELATED LINKS

[about_powdrgit](about_powdrgit.md)

[Find-GitRepo](Find-GitRepo.md)

[Set-GitRepo](Set-GitRepo.md)

[Test-GitRepoPath](Test-GitRepoPath.md)



