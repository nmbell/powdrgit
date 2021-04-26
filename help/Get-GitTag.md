# Get-GitTag

## SYNOPSIS
Gets a list of tags for the specified repository.

## SYNTAX

```
Get-GitTag [[-RepoName] <String>] [<CommonParameters>]
```

## DESCRIPTION
Gets a list of tags for the specified repository.
By default, tags are returned in tag name (alphabetical) order.

## EXAMPLES

### EXAMPLE 1
```
## Call from outside a repository without parameters ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitTag
PS C:\>

# Nothing was returned because a RepoName was not provided.
```

### EXAMPLE 2
```
## Call from outside a repository for non-existent repository ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitTag -RepoName NonExistentRepo
WARNING: [Get-GitTag]Repository 'NonExistentRepo' not found. Check the repository directory has been added to the $GitRepoPath module variable.
```

### EXAMPLE 3
```
## Call from outside a repository with RepoName parameter ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitTag -RepoName MyToolbox | Format-Table -Property RepoName,TagName,TagType,TagSubject

RepoName  TagName        TagType TagSubject
--------  -------        ------- ----------
MyToolbox annotatedTag   tag     This is an annotated tag
MyToolbox lightweightTag commit  feature1 commit

# The tags were returned even though the command was issued from outside the repository directory.
```

### EXAMPLE 4
```
## Get all tags of the current repository ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitRepo -RepoName MyToolbox
PS C:\PowdrgitExamples\MyToolbox\> Get-GitTag | Format-Table -Property RepoName,TagName,TagType,TagSubject

RepoName  TagName        TagType TagSubject
--------  -------        ------- ----------
MyToolbox annotatedTag   tag     This is an annotated tag
MyToolbox lightweightTag commit  feature1 commit
```

## PARAMETERS

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[System.String]

Accepts string objects via the RepoName parameter. The output of Get-GitRepo can be piped into Get-GitTag.

## OUTPUTS

[GitTag]

Returns a custom GitTag object. For details use Get-Member at a command prompt e.g.:

`PS C:\PowdrgitExamples\MyToolbox> Get-GitTag | Get-Member -MemberType Properties`


## NOTES
Author : nmbell

## RELATED LINKS

[about_powdrgit](about_powdrgit.md)

[Get-GitBranch](Get-GitBranch.md)

[Get-GitRepo](Get-GitRepo.md)



