# Get-GitFileHistory

## SYNOPSIS
Gets commit history for a given file.

## SYNTAX

```
Get-GitFileHistory [[-RepoName] <String>] [[-Path] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets commit history for a given file.

## EXAMPLES

### EXAMPLE 1
```
## Call from outside a repository without parameters ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitFileHistory

# Nothing was returned because RepoName and Path were not provided.
```

### EXAMPLE 2
```
## Call from outside a repository for non-existent repository ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitFileHistory -RepoName NonExistentRepo
WARNING: [Get-GitFileHistory]Repository 'NonExistentRepo' not found. Check the repository directory has been added to the $GitRepoPath module variable.
```

### EXAMPLE 3
```
## Call from outside a repository with RepoName parameter ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitFileHistory -RepoName MyToolbox

# Nothing was returned because Path was not provided.
```

### EXAMPLE 4
```
## Call from outside a repository with RepoName and Path parameters ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitFileHistory -RepoName MyToolbox -Path 'feature1_File1.txt' | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName  Subject
--------  --------                                 ----------  -------
MyToolbox ebf9e4850f5e7023c052b90779abd56878c5215c nmbell      Add feature1_File1.txt
```

### EXAMPLE 5
```
## Call from inside a repository with Path parameter ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox\> Get-GitFileHistory -Path 'feature1_File1.txt' | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName  Subject
--------  --------                                 ----------  -------
MyToolbox ebf9e4850f5e7023c052b90779abd56878c5215c nmbell      Add feature1_File1.txt
```

### EXAMPLE 6
```
## Pipe results from Get-Child-Item ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox\> Get-ChildItem | Get-GitFileHistory | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName  Subject
--------  --------                                 ----------  -------
MyToolbox ebf9e4850f5e7023c052b90779abd56878c5215c nmbell      Add feature1_File1.txt
```

## PARAMETERS

### -Path
The Path to a file in the repository.
Unqualifed paths (i.e. with no leading drive letter) will be assumed to be relative to the current repository.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: FullName

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[System.String]

Accepts string objects via the Path parameter. The output of Get-ChildItem can be piped into Get-GitFileHistory.

## OUTPUTS

[GitCommit]

Returns a custom GitCommit object. For details use Get-Member at a command prompt e.g.:

`PS C:\PowdrgitExamples\MyToolbox> Get-GitFileHistory | Get-Member -MemberType Properties`


## NOTES
Author : nmbell

## RELATED LINKS

[about_powdrgit](about_powdrgit.md)

[Get-GitCommit](Get-GitCommit.md)

[Get-GitCommitFile](Get-GitCommitFile.md)

[Get-GitLog](Get-GitLog.md)



