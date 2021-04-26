# Get-GitCommitFile

## SYNOPSIS
Gets the files associated with a commit.

## SYNTAX

```
Get-GitCommitFile [[-RepoName] <String>] [[-SHA1Hash] <String>] [<CommonParameters>]
```

## DESCRIPTION
Gets the files associated with a commit.

## EXAMPLES

### EXAMPLE 1
```
## Call from outside a repository without parameters ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitCommitFile

# Nothing was returned because a RepoName was not provided.
```

### EXAMPLE 2
```
## Call from outside a repository for non-existent repository ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitCommitFile -RepoName NonExistentRepo
WARNING: [Get-GitCommitFile]Repository 'NonExistentRepo' not found. Check the repository directory has been added to the $GitRepoPath module variable.
```

### EXAMPLE 3
```
## Call from outside a repository with RepoName parameter ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main # checkout the main branch from the current location
PS C:\> Get-GitCommitFile -RepoName MyToolbox | Format-Table -Property RepoName,SHA1Hash,Exists,FullName

RepoName  SHA1Hash                                 Exists FullName
--------  --------                                 ------ --------
MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0  False

# When SHA1Hash is not specified, the HEAD commit is used.
```

### EXAMPLE 4
```
## Call from inside a repository with SHA1Hash parameter ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox\> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq 'Add feature1_File1.txt' | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
PS C:\PowdrgitExamples\MyToolbox\> Get-GitCommitFile -SHA1Hash $commitHash | Format-Table -Property RepoName,SHA1Hash,Exists,FullName

RepoName  SHA1Hash                                 Exists FullName
--------  --------                                 ------ --------
MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64   True C:\PowdrgitExamples\MyToolbox\feature1_File1.txt
```

### EXAMPLE 5
```
## Pipe results from Get-GitLog ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox\> Get-GitLog -NoMerges | Get-GitCommitFile | Format-Table -Property RepoName,SHA1Hash,Exists,FullName

RepoName  SHA1Hash                                 Exists FullName
--------  --------                                 ------ --------
MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64   True C:\PowdrgitExamples\MyToolbox\feature1_File1.txt
MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135  False
MyToolbox 87b1320518c17702d30e463966bc070ce6481459  False

# Commits with no files associated to them are included in the results.
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
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SHA1Hash
The SHA1 hash of (or a reference to) a commit in the current repository.
If omitted, the HEAD commit is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: HEAD
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[System.String]

Accepts string objects via the SHA1Hash parameter. The output of Get-GitLog and Get-GitCommit can be piped into Get-GitCommitFile.

## OUTPUTS

[GitCommitFile]

Returns a custom GitCommitFile object. For details use Get-Member at a command prompt e.g.:

`PS C:\PowdrgitExamples\MyToolbox> Get-GitCommitFile | Get-Member -MemberType Properties`


## NOTES
Author : nmbell

## RELATED LINKS

[about_powdrgit](about_powdrgit.md)

[Get-GitCommit](Get-GitCommit.md)

[Get-GitFileHistory](Get-GitFileHistory.md)

[Get-GitLog](Get-GitLog.md)



