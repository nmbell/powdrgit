# Format-GitDiff

## SYNOPSIS
Formats GitCommitDiff objects as a readable diff.

## SYNTAX

```
Format-GitDiff [-InputObject] <GitCommitDiff[]> [-NoSummary] [-NoLines] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
Formats GitCommitDiff objects as a readable diff.
The diff contains two parts: the summary and the diff lines.
The summary contains the following:
- An overall summary of all changed files, inserted lines, deleted lines e.g:
```
3 files changed, 78 insertions(+), 18 deletions(-)
```
- A summary of each changed file in the format "\<Type\> : \<delete lines count\>- : \<added lines count\>+ : \<filepath\>", e.g.:
```
Add      :   0- :  55+ : MyFolder/MyFirstFile.txt
Delete   :   1- :   0+ : MyFolder/MySecondFile.txt
Modify   :  17- :  23+ : MyFolder/MyThirdFile.txt
```
The diff lines contains the following for each file in the diff:
- A summary of the changed file, similar to that included in the summary information
- A series of lines showing the line changes for the file in the format "\<old line number\>→\<new line number\> \<change type indicator\> \<line text\>".
  Removed lines have an old line number but no new line number, and a "-" indicator.
  Added lines have a new line number but no old line number, and a "+" indicator.
  Changed lines are represented as a removed lined and an added line.
  E.g.:
```
Modify   : 2- : 2+ : MyFile.txt
1→1   The first line of text
2→  - This line needs to be updated
3→  - This line needs to be removed
 →2 + This line was updated
4→3   This line shouldn't be changed
 →4 + This line was added
```
The colors that summary, old, new, and unchanged lines in the diff appear with when outputting to the console host can be controlled by setting the following module variable values:
```
$Powdrgit.DiffLineColorNew     = 'Cyan'
$Powdrgit.DiffLineColorOld     = 'Magenta'
$Powdrgit.DiffLineColorSame    = 'DarkGray'
$Powdrgit.DiffLineColorSummary = 'Gray'
```
Any color values recognized by Write-Host as a foreground color can be used.
To output the text as string objects (e.g. to write to a file), use the PassThru switch parameter.

## EXAMPLES

### EXAMPLE 1
```
## Get formatted summary and line diff information for a diff ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\Project2> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq "Update Mary's bio" | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
PS C:\PowdrgitExamples\Project2> $diff = Get-GitDiff -SHA1HashFrom $commitHash
PS C:\PowdrgitExamples\Project2> $diff | Format-GitDiff

2 files changed, 2 insertions(+), 2 deletions(-)
Add      : 0- : 2+ : Jack.txt
Delete   : 2- : 0+ : Mary.txt

Add      : 0- : 2+ : Jack.txt
→1 + Little Jack Horner
→2 + Sat in the corner

Delete   : 2- : 0+ : Mary.txt
1→  - Mary had a little lamb
2→  - It's fleece was white as snow

# Summary and line diff information is shown for all files in the diff.
```

### EXAMPLE 2
```
## Get formatted summary information only for a diff ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\Project2> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq "Update Mary's bio" | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
PS C:\PowdrgitExamples\Project2> $diff = Get-GitDiff -SHA1HashFrom $commitHash
PS C:\PowdrgitExamples\Project2> $diff | Format-GitDiff -NoLines

2 files changed, 2 insertions(+), 2 deletions(-)
Add      : 0- : 2+ : Jack.txt
Delete   : 2- : 0+ : Mary.txt

# Only summary information is shown for all files in the diff.
```

### EXAMPLE 3
```
## Get formatted line diff information only for a diff ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\Project2> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq "Update Mary's bio" | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
PS C:\PowdrgitExamples\Project2> $diff = Get-GitDiff -SHA1HashFrom $commitHash
PS C:\PowdrgitExamples\Project2> $diff | Format-GitDiff -NoSummary

Add      : 0- : 2+ : Jack.txt
→1 + Little Jack Horner
→2 + Sat in the corner

Delete   : 2- : 0+ : Mary.txt
1→  - Mary had a little lamb
2→  - It's fleece was white as snow

# Only line diff information is shown for all files in the diff.
```

### EXAMPLE 4
```
## Write formatted summary and line diff information to a text file ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project2' # to ensure the repository paths are defined
PS C:\> Set-GitBranch -Repo Project2 -BranchName main -SetLocation # move to the repository directory and checkout the main branch
PS C:\PowdrgitExamples\Project2> $commitHash = Get-GitLog -NoMerges | Where-Object Subject -eq "Update Mary's bio" | Select-Object -ExpandProperty SHA1Hash # pick a commit from the log
PS C:\PowdrgitExamples\Project2> $diff = Get-GitDiff -SHA1HashFrom $commitHash
PS C:\PowdrgitExamples\Project2> $file = New-TemporaryFile
PS C:\PowdrgitExamples\Project2> $diff | Format-GitDiff -PassThru | Add-Content -Path $file
PS C:\PowdrgitExamples\Project2> Get-Content -Path $file

2 files changed, 2 insertions(+), 2 deletions(-)
Add      : 0- : 2+ : Jack.txt
Delete   : 2- : 0+ : Mary.txt

Add      : 0- : 2+ : Jack.txt
→1 + Little Jack Horner
→2 + Sat in the corner

Delete   : 2- : 0+ : Mary.txt
1→  - Mary had a little lamb
2→  - It's fleece was white as snow
```

## PARAMETERS

### -InputObject
GitCommitDiff object from e.g. Get-GitDiff.

```yaml
Type: GitCommitDiff[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -NoLines
Suppresses the diff line information.

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

### -NoSummary
Suppresses the diff summary information.

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

### -PassThru
Outputs the formatted diff as an array of strings.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS


## OUTPUTS

System.String

## NOTES
Author : nmbell

## RELATED LINKS

[Get-GitCommit](Get-GitCommit.md)

[Get-GitDiff](Get-GitDiff.md)

[Get-GitCommitFile](Get-GitCommitFile.md)

[Get-GitFileHistory](Get-GitFileHistory.md)

[Get-GitLog](Get-GitLog.md)

[Get-GitRepo](Get-GitRepo.md)

[about_powdrgit](about_powdrgit.md)



