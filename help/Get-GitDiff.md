# Get-GitDiff

## SYNOPSIS
Gets the diff between a range of commits.

## SYNTAX

### Hash (Default)
```
Get-GitDiff [[-Repo] <String[]>] [[-SHA1HashFrom] <String>] [[-SHA1HashTo] <String>] [<CommonParameters>]
```

### InputObject
```
Get-GitDiff [[-InputObject] <GitCommit>] [<CommonParameters>]
```

## DESCRIPTION
Gets the diff between a range of commits.
If only a single 'to' commit is specified, the diff will be from its immediate parent.
If only a single 'from' commit is specified, the diff will be to the HEAD commit.
One [GitCommitDiff] object is returned for each file covered by the diff.
[GitCommitDiff] objects can be displayed in readable format using Format-GitDiff.

## EXAMPLES

### EXAMPLE 1
```
## Call from outside a repository without parameters ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
PS C:\> Get-GitDiff

# Nothing was returned because a Repo was not provided.
```

### EXAMPLE 2
```
## Call from outside a repository for non-existent repository ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Get-GitDiff -Repo NonExistentRepo
WARNING: [Get-GitDiff]Repository 'NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.
```

### EXAMPLE 3
```
## Call from outside a repository with Repo parameter ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
PS C:\> $diff = Get-GitDiff -Repo Project2
PS C:\> $diff.Summary; $diff.File | Format-Table

1 file changed, 1 insertion(+)

Action Path     PathNew Similarity New Old DiffLine
------ ----     ------- ---------- --- --- --------
Modify Jack.txt                    1   0   { Little Jack Horner, +Sat in the corner}

# When neither SHA1HashFrom or SHA1HashTo are specified, the diff of the HEAD commit is returned.
```

### EXAMPLE 4
```
## Call from inside a repository with the same commit for SHA1HashFrom and SHA1HashTo parameters ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\Project2> $commitHash = Get-GitLog -NoMerges | Select-Object -First 1 -ExpandProperty SHA1Hash # pick a commit from the log
PS C:\PowdrgitExamples\Project2> Get-GitDiff -SHA1HashFrom $commitHash -SHA1HashTo $commitHash

# Nothing was returned because there are no differences when comparing a commit against itself.
```

### EXAMPLE 5
```
## Call from inside a repository with only the SHA1HashFrom parameter ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\Project2> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq "Update Mary's bio" | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
PS C:\PowdrgitExamples\Project2> $diff = Get-GitDiff -SHA1HashFrom $commitHash
PS C:\PowdrgitExamples\Project2> $diff.Summary; $diff.File | Format-Table

2 files changed, 2 insertions(+), 2 deletions(-)

Action Path     PathNew Similarity New Old DiffLine
------ ----     ------- ---------- --- --- --------
Add    Jack.txt                    2   0   {+Little Jack Horner, +Sat in the corner}
Delete Mary.txt                    0   2   {-Mary had a little lamb, -It's fleece was white as snow}

# When only SHA1HashFrom is specified, the HEAD commit is used as the SHA1HashTo commit.
```

### EXAMPLE 6
```
## Call from inside a repository with only the SHA1HashTo parameter ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\Project2> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq "Update Mary's bio" | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
PS C:\PowdrgitExamples\Project2> $diff = Get-GitDiff -SHA1HashTo $commitHash
PS C:\PowdrgitExamples\Project2> $diff.Summary; $diff.File | Format-Table

1 file changed, 1 insertion(+)

Action Path     PathNew Similarity New Old DiffLine
------ ----     ------- ---------- --- --- --------
Modify Mary.txt                    1   0   { Mary had a little lamb, +It's fleece was white as snow}

# When only SHA1HashTo is specified, the parent of the SHA1HashTocommit is used as the SHA1HashFrom commit.
```

### EXAMPLE 7
```
## Call from inside a repository with both the SHA1HashTo and SHA1HashFrom parameters ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\Project2> $commitHashFrom = Get-GitLog -NoMerges | Where-Object Subject -eq 'Initial commit' | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
PS C:\PowdrgitExamples\Project2> $commitHashTo   = Get-GitLog -NoMerges | Where-Object Subject -eq "Replace Mary's bio with Jack's" | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
PS C:\PowdrgitExamples\Project2> $diff = Get-GitDiff -SHA1HashFrom $commitHashFrom -SHA1HashTo $commitHashTo
PS C:\PowdrgitExamples\Project2> $diff.Summary; $diff.File | Format-Table

1 file changed, 1 insertion(+)

Action Path     PathNew Similarity New Old DiffLine
------ ----     ------- ---------- --- --- --------
Add    Jack.txt                    1   0   {+Little Jack Horner}

# When SHA1HashFrom and SHA1HashTo are specified, the result shows the net diff for the range of commits.
```

### EXAMPLE 8
```
## Pipe results from Get-GitLog ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\Project2> $diffs = Get-GitLog -NoMerges | Where-Object { $_.ParentHashes } | Get-GitDiff
PS C:\PowdrgitExamples\Project2> $diffs.Summary; $diffs.File | Format-Table

1 file changed, 1 insertion(+)
2 files changed, 1 insertion(+), 2 deletions(-)
1 file changed, 1 insertion(+)
1 file changed, 1 insertion(+)

Action Path     PathNew Similarity New Old DiffLine
------ ----     ------- ---------- --- --- --------
Modify Jack.txt                    1   0   { Little Jack Horner, +Sat in the corner}
Add    Jack.txt                    1   0   {+Little Jack Horner}
Delete Mary.txt                    0   2   {-Mary had a little lamb, -It's fleece was white as snow}
Modify Mary.txt                    1   0   { Mary had a little lamb, +It's fleece was white as snow}
Add    Mary.txt                    1   0   {+Mary had a little lamb}

# When piping commits from Get-GitLog, a diff is created for each commit (from its parent)
```

## PARAMETERS

### -InputObject
GitCommit object from e.g. Get-GitLog.

```yaml
Type: GitCommit
Parameter Sets: InputObject
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Repo
The name of a git repository, or the path or a substring of the path of a repository directory or any of its subdirectories or files.
If the Repo parameter is omitted, the current repository will be used if currently inside a repository; otherwise, nothing is returned.
For examples of using the Repo parameter, refer to the help text for Get-GitRepo.

```yaml
Type: String[]
Parameter Sets: Hash
Aliases: RepoName, RepoPath

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SHA1HashFrom
The SHA1 hash of (or a reference to) a commit in the current repository.
If omitted, the parent of the SHA1HashTo commit is used.

```yaml
Type: String
Parameter Sets: Hash
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SHA1HashTo
The SHA1 hash of (or a reference to) a commit in the current repository.
If omitted, the HEAD commit is used.

```yaml
Type: String
Parameter Sets: Hash
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

[System.String[]]

Accepts string objects via the SHA1Hash parameter. The output of Get-GitLog can be piped into Get-GitCommit.

## OUTPUTS

[GitCommit]

Returns git diff output.

## NOTES
Author : nmbell

## RELATED LINKS

[Get-GitCommit](Get-GitCommit.md)

[Format-GitDiff](Format-GitDiff.md)

[Get-GitCommitFile](Get-GitCommitFile.md)

[Get-GitFileHistory](Get-GitFileHistory.md)

[Get-GitLog](Get-GitLog.md)

[Get-GitRepo](Get-GitRepo.md)

[about_powdrgit](about_powdrgit.md)



