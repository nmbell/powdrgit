# Get-GitFileHistory

## SYNOPSIS
Gets commit history for a given file.

## SYNTAX

```
Get-GitFileHistory [[-Repo] <String[]>] [[-FilePath] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets commit history for a given file.

## EXAMPLES

### EXAMPLE 1
```
## Call from outside a repository without parameters ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitFileHistory

# Nothing was returned because Repo and FilePath were not provided.
```

### EXAMPLE 2
```
## Call from outside a repository for non-existent repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Get-GitFileHistory -Repo NonExistentRepo
WARNING: [Get-GitFileHistory]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.
```

### EXAMPLE 3
```
## Call from outside a repository with Repo parameter ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitFileHistory -Repo MyToolbox

# Nothing was returned because FilePath was not provided.
```

### EXAMPLE 4
```
## Call from outside a repository with Repo and FilePath parameters ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitFileHistory -Repo MyToolbox -FilePath 'feature1_File1.txt' | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName  Subject
--------  --------                                 ----------  -------
MyToolbox ebf9e4850f5e7023c052b90779abd56878c5215c nmbell      Add feature1_File1.txt
```

### EXAMPLE 5
```
## Call from inside a repository with FilePath parameter ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox> Get-GitFileHistory -FilePath 'feature1_File1.txt' | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName  Subject
--------  --------                                 ----------  -------
MyToolbox ebf9e4850f5e7023c052b90779abd56878c5215c nmbell      Add feature1_File1.txt
```

### EXAMPLE 6
```
## Pipe results from Get-Child-Item ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox> Get-ChildItem | Get-GitFileHistory | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName  Subject
--------  --------                                 ----------  -------
MyToolbox ebf9e4850f5e7023c052b90779abd56878c5215c nmbell      Add feature1_File1.txt
```

## PARAMETERS

### -FilePath
The path to a file in the repository.
The path may be for a file that no longer exists.
Unqualifed paths (i.e. with no leading drive letter) will be assumed to be relative to the current repository.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: FullName, Path

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

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
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[System.String]

Accepts string objects via the FilePath parameter. The output of Get-ChildItem can be piped into Get-GitFileHistory.

## OUTPUTS

[GitCommit]

Returns a custom GitCommit object. For details use Get-Member at a command prompt e.g.:

PS C:\PowdrgitExamples\MyToolbox> Get-GitFileHistory | Get-Member -MemberType Properties

## NOTES
Author : nmbell

## RELATED LINKS

[Get-GitCommit](Get-GitCommit.md)

[Get-GitCommitFile](Get-GitCommitFile.md)

[Get-GitLog](Get-GitLog.md)

[Get-GitRepo](Get-GitRepo.md)

[about_powdrgit](about_powdrgit.md)



