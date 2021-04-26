# Get-GitLog

## SYNOPSIS
Gets a list of commits from the git log.

## SYNTAX

### InRef (Default)
```
Get-GitLog [[-RepoName] <String>] [-InRef <String[]>] [-NotInRef <String[]>] [-Count <Int32>] [-NoMerges] [<CommonParameters>]
```

### RefRange
```
Get-GitLog [[-RepoName] <String>] [-RefRange <String[]>] [-Count <Int32>] [-NoMerges] [<CommonParameters>]
```

## DESCRIPTION
Gets a list of commits from the git log.

## EXAMPLES

### EXAMPLE 1
```
## Call from outside a repository without parameters ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Get-GitLog

# Nothing was returned because a RepoName was not provided.
```

### EXAMPLE 2
```
## Call from outside a repository with RepoName parameter ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main # checkout the main branch from the current location
PS C:\> Get-GitLog -RepoName MyToolbox | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName Subject
--------  --------                                 ---------- -------
MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0 nmbell     Merging from feature1
MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64 nmbell     Add feature1_File1.txt
MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit
MyToolbox 87b1320518c17702d30e463966bc070ce6481459 nmbell     Initial commit

# The commits were returned even though the command was issued from outside the repository directory.
```

### EXAMPLE 3
```
## Get commits from the current repository ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox\> Get-GitLog | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName Subject
--------  --------                                 ---------- -------
MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0 nmbell     Merging from feature1
MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64 nmbell     Add feature1_File1.txt
MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit
MyToolbox 87b1320518c17702d30e463966bc070ce6481459 nmbell     Initial commit
```

### EXAMPLE 4
```
## Call with Count parameter ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox\> Get-GitLog -Count 3 | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName Subject
--------  --------                                 ---------- -------
MyToolbox ba6dfdc703948adbd01590c965932ae8ff692aa0 nmbell     Merging from feature1
MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64 nmbell     Add feature1_File1.txt
MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit

# Only the three most recent commits were returned.
```

### EXAMPLE 5
```
## Call with NoMerges switch ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox\> Get-GitLog -NoMerges | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName Subject
--------  --------                                 ---------- -------
MyToolbox beffe458a0460726f79316fd0dad2d2392a35b64 nmbell     Add feature1_File1.txt
MyToolbox 3a987081541ca2f31f575d47287cb3fdf82a1135 nmbell     feature1 commit
MyToolbox 87b1320518c17702d30e463966bc070ce6481459 nmbell     Initial commit

# Merge commits were omitted.
```

### EXAMPLE 6
```
## Call with InRef and NotInRef ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox\> Get-GitLog -InRef feature3 -NotInRef main | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName Subject
--------  --------                                 ---------- -------
MyToolbox 87e8501a197f8db5a54427c8a39803cf9e12ab66 nmbell     Add feature3_FileA.txt

# Only commits that were in the feature3 branch but not in main branch were returned.
```

### EXAMPLE 7
```
## Call with RefRange ##

PS C:\> $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -RepoName MyToolbox -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\MyToolbox\> Get-GitLog -RefRange 'main..feature3' | Format-Table -Property RepoName,SHA1Hash,AuthorName,Subject

RepoName  SHA1Hash                                 AuthorName Subject
--------  --------                                 ---------- -------
MyToolbox 87e8501a197f8db5a54427c8a39803cf9e12ab66 nmbell     Add feature3_FileA.txt

# Equivalent to the previous example.
```

## PARAMETERS

### -Count
Specifies the number of commits to retrieve.
Commits are retrieved in reverse order, so specifying a Count of 5 will return the last 5 commits.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InRef
A list of repository references (i.e. branch names, tag names, or commit SHA1 hashes).
Commits reachable from any of these references are included in the results.
If ommitted, defaults to HEAD.
See https://git-scm.com/docs/git-log#_description.

```yaml
Type: String[]
Parameter Sets: InRef
Aliases: SHA1Hash

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NoMerges
Excludes merge commits (commits with more than one parent) from the results.

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

### -NotInRef
A list of repository references (i.e. branch names, tag names, or commit SHA1 hashes).
Commits reachable from any of these references are excluded from the results.
If ommitted, defaults to HEAD.
See https://git-scm.com/docs/git-log#_description.

```yaml
Type: String[]
Parameter Sets: InRef
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RefRange
A revision range used to limit the commits returned, given in native git format e.g. "branch1...branch2".
See https://git-scm.com/docs/gitrevisions.

```yaml
Type: String[]
Parameter Sets: RefRange
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[System.String]

Accepts string objects via the RepoName parameter. The output of Get-GitRepo can be piped into Get-GitLog.

## OUTPUTS

[GitCommit]

Returns a custom GitCommit object. For details use Get-Member at a command prompt e.g.:

`PS C:\PowdrgitExamples\MyToolbox> Get-GitLog | Get-Member -MemberType Properties`


## NOTES
Author : nmbell

## RELATED LINKS

[about_powdrgit](about_powdrgit.md)

[Get-GitCommit](Get-GitCommit.md)

[Get-GitCommitFile](Get-GitCommitFile.md)

[Get-GitFileHistory](Get-GitFileHistory.md)



