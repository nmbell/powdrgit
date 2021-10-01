# Get-GitCommit

## SYNOPSIS
Gets information for a given SHA1 commit hash.

## SYNTAX

```
Get-GitCommit [[-Repo] <String[]>] [[-SHA1Hash] <String>] [<CommonParameters>]
```

## DESCRIPTION
Gets information for a given SHA1 commit hash.

## EXAMPLES

### EXAMPLE 1
```
## Call from outside a repository without parameters ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitCommit

# Nothing was returned because a Repo was not provided.
```

### EXAMPLE 2
```
## Call from outside a repository for non-existent repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Get-GitCommit -Repo NonExistentRepo
WARNING: [Get-GitCommit]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.
```

### EXAMPLE 3
```
## Call from outside a repository with Repo parameter ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitCommit -Repo MyToolbox | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName Subject
--------  --------                                 ---------- -------
MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0 nmbell     Merging from feature1

# When SHA1Hash is not specified, the HEAD commit is returned.
```

### EXAMPLE 4
```
## Call from inside a repository with SHA1Hash parameter ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq 'feature1 commit' | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
PS C:\PowdrgitExamples\MyToolbox> Get-GitCommit -SHA1Hash $commitHash | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName Subject
--------  --------                                 ---------- -------
MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit
```

### EXAMPLE 5
```
## Pipe results from Get-GitLog ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox> Get-GitLog | Get-GitCommit | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName Subject
--------  --------                                 ---------- -------
MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0 nmbell     Merging from feature1
MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64 nmbell     Add feature1_File1.txt
MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit
MyToolbox 87b1320518c17702d30e463966bc070ce6481459 nmbell     Initial commit

# Output is identical to:
# PS C:\PowdrgitExamples\MyToolbox> Get-GitLog | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject
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
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SHA1Hash
The SHA1 hash of (or a reference to) a commit in the current repository.
If omitted, the HEAD commit is returned.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: HEAD
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[System.String]

Accepts string objects via the SHA1Hash parameter. The output of Get-GitLog can be piped into Get-GitCommit.

## OUTPUTS

[GitCommit]

Returns a custom GitCommit object. For details use Get-Member at a command prompt e.g.:

PS C:\PowdrgitExamples\MyToolbox> Get-GitCommit | Get-Member -MemberType Properties

## NOTES
Author : nmbell

## RELATED LINKS

[Get-GitCommitFile](Get-GitCommitFile.md)

[Get-GitFileHistory](Get-GitFileHistory.md)

[Get-GitLog](Get-GitLog.md)

[Get-GitRepo](Get-GitRepo.md)

[about_powdrgit](about_powdrgit.md)



