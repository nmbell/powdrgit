# Get-GitTag

## SYNOPSIS
Gets a list of tags for the specified repository.

## SYNTAX

```
Get-GitTag [[-Repo] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets a list of tags for the specified repository.
By default, tags are returned in tag name (alphabetical) order.

## EXAMPLES

### EXAMPLE 1
```
## Call from outside a repository without parameters ##
PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitTag
PS C:\>

# Nothing was returned because a Repo was not provided.
```

### EXAMPLE 2
```
## Call from outside a repository for non-existent repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Get-GitTag -Repo NonExistentRepo
WARNING: [Get-GitTag]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.
```

### EXAMPLE 3
```
## Call from outside a repository with Repo parameter ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitTag -Repo MyToolbox | Format-Table -Property RepoName,TagName,TagType,TagSubject

RepoName  TagName        TagType TagSubject
--------  -------        ------- ----------
MyToolbox annotatedTag   tag     This is an annotated tag
MyToolbox lightweightTag commit  feature1 commit

# The tags were returned even though the command was issued from outside the repository directory.
```

### EXAMPLE 4
```
## Get all tags of the current repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -Repo MyToolbox
PS C:\PowdrgitExamples\MyToolbox> Get-GitTag | Format-Table -Property RepoName,TagName,TagType,TagSubject

RepoName  TagName        TagType TagSubject
--------  -------        ------- ----------
MyToolbox annotatedTag   tag     This is an annotated tag
MyToolbox lightweightTag commit  feature1 commit
```

### EXAMPLE 5
```
## Pipe results from Get-GitRepo ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitRepo | Get-GitTag | Format-Table -Property RepoName,TagName,TagType,TagSubject

RepoName  TagName        TagType TagSubject
--------  -------        ------- ----------
MyToolbox annotatedTag   tag     This is an annotated tag
MyToolbox lightweightTag commit  feature1 commit
Project1  lightweightTag commit  Initial commit
```

## PARAMETERS

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
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[System.String[]]

Accepts string objects via the Repo parameter. The output of Get-GitRepo can be piped into Get-GitTag.

## OUTPUTS

[GitTag]

Returns a custom GitTag object. For details use Get-Member at a command prompt e.g.:

PS C:\PowdrgitExamples\MyToolbox> Get-GitTag | Get-Member -MemberType Properties

## NOTES
Author : nmbell

## RELATED LINKS

[Get-GitCommit](Get-GitCommit.md)

[Get-GitLog](Get-GitLog.md)

[Get-GitBranch](Get-GitBranch.md)

[Get-GitRepo](Get-GitRepo.md)

[about_powdrgit](about_powdrgit.md)



