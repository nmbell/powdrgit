# New-GitRepo

## SYNOPSIS
Creates a new git repository and returns the repository or directory object.

## SYNTAX

### InitialCommit (Default)
```
New-GitRepo [[-Repo] <String[]>] [-UseDefaultDir] [[-InitialBranchName] <String>] [[-InitialCommit] <String[]>]
 [[-TemplateDir] <String>] [-AppendPowdrgitPath] [-SetLocation] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Bare
```
New-GitRepo [[-Repo] <String[]>] [-UseDefaultDir] [-Bare] [[-InitialBranchName] <String>]
 [[-TemplateDir] <String>] [-AppendPowdrgitPath] [-SetLocation] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### UseDefaultInitialCommit
```
New-GitRepo [[-Repo] <String[]>] [-UseDefaultDir] [[-InitialBranchName] <String>] [-UseDefaultInitialCommit]
 [[-TemplateDir] <String>] [-AppendPowdrgitPath] [-SetLocation] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a new git repository and returns the repository or directory object.

## EXAMPLES

### EXAMPLE 1
```
## Call with no parameters ##

PS C:\> New-Item -ItemType Directory -Path 'C:\MyEmptyFolder'
PS C:\> Set-Location 'C:\MyEmptyFolder'
PS C:\MyEmptyFolder> $r = New-GitRepo
PS C:\MyEmptyFolder> Get-ChildItem -Hidden | Select-Object -ExpandProperty FullName
C:\MyEmptyFolder\.git

# A repository was created at the current location
```

### EXAMPLE 2
```
## Call with an absolute path ##

PS C:\> $r = New-GitRepo -Repo 'C:\MyNewRepo'
PS C:\> Get-ChildItem -Path 'C:\MyNewRepo' -Hidden | Select-Object -ExpandProperty FullName
C:\MyNewRepo\.git

# A repository was created at the specified location
```

### EXAMPLE 3
```
## Call with a relative path ##

PS C:\> New-Item -ItemType Directory -Path 'C:\MyEmptyFolder'
PS C:\> Set-Location 'C:\MyEmptyFolder'
PS C:\MyEmptyFolder> $r = New-GitRepo -Repo 'MyRepos\MyNewRepo'
PS C:\MyEmptyFolder> Get-ChildItem -Hidden -Recurse | Select-Object -ExpandProperty FullName
C:\MyEmptyFolder\MyRepos\MyNewRepo\.git

# A repository was created relative to the current location
```

### EXAMPLE 4
```
## Call with a repository name ##

PS C:\> New-Item -ItemType Directory -Path 'C:\MyEmptyFolder'
PS C:\> Set-Location 'C:\MyEmptyFolder'
PS C:\MyEmptyFolder> $r = New-GitRepo -Repo 'MyNewRepo'
PS C:\MyEmptyFolder> Get-ChildItem -Hidden -Recurse | Select-Object -ExpandProperty FullName
C:\MyEmptyFolder\MyNewRepo\.git

# A repository with the specified name was created at the current location
```

### EXAMPLE 5
```
## Call with UseDefaultDir ##

PS C:\> $Powdrgit.DefaultDir = 'C:\PowdrgitExamples'
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> $r = New-GitRepo -Repo 'C:\PowdrgitExamples\MyNewRepo' -UseDefaultDir
WARNING: [New-GitRepo]The UseDefaultDir switch cannot be used with an absolute path for Repo: C:\PowdrgitExamples\MyNewRepo.

# A warning is generated for the incompatible parameter values.

PS C:\> $r = New-GitRepo -Repo 'MyNewRepo' -UseDefaultDir
PS C:\> Get-ChildItem -Path "$($Powdrgit.DefaultDir)\MyNewRepo" -Hidden -Recurse | Select-Object -ExpandProperty FullName
C:\PowdrgitExamples\MyNewRepo\.git

# A repository was created in the default directory.
```

### EXAMPLE 6
```
## Call with SetLocation ##

PS C:\> $r = New-GitRepo -Repo 'C:\PowdrgitExamples\MyNewRepo' -SetLocation
PS C:\PowdrgitExamples\MyNewRepo>

# The location changed to the new repository.
```

### EXAMPLE 7
```
## Call with Bare ##

PS C:\> $r = New-GitRepo -Repo 'C:\PowdrgitExamples\MyNewRepo' -Bare
PS C:\> Get-ChildItem -Path 'C:\PowdrgitExamples\MyNewRepo*' -Directory | Select-Object -ExpandProperty FullName
C:\PowdrgitExamples\MyNewRepo.git

# The name of the repository was automatically appended with ".git" to indicate a bare repository.
```

### EXAMPLE 8
```
## Call with AppendPowdrgitPath ##

PS C:\> $Powdrgit.Path = $null
PS C:\> $r = New-GitRepo -Repo 'C:\PowdrgitExamples\MyNewRepo' -AppendPowdrgitPath
PS C:\> $Powdrgit.Path
C:\PowdrgitExamples\MyNewRepo
PS C:\> $r.GetType().FullName
GitRepo

# The name of the repository was appended with ".git" to indicate a bare repository.
# Because the repository exists in the $Powdrgit.Path module variable, New-GitRepo returns a GitRepo object.
```

### EXAMPLE 9
```
## Call with InitialBranchName and InitialCommit ##

PS C:\> $r = New-GitRepo -Repo 'C:\PowdrgitExamples\MyNewRepo' -AppendPowdrgitPath -InitialBranchName 'MyBranch' -InitialCommit 'Initial commit'

# AppendPowdrgitPath is used to make the repo visible to Powdrgit.
# InitialCommit is used to make the branch visible in git.

PS C:\> $r | Get-GitBranch | Select-Object RepoName,BranchName

RepoName   BranchName
--------   ----------
MyNewRepo  MyBranch

PS C:\> $r | Get-GitLog | Select-Object RepoName,SHA1Hash,Subject

RepoName   SHA1Hash                                 Subject
--------   --------                                 -------
MyNewRepo  6ef6fab1a36bd165a898e06e053515ce114a4390 Initial commit
```

### EXAMPLE 10
```
## Call with TemplateDir ##

PS C:\> $t = New-GitRepo -Repo 'C:\PowdrgitExamples\TemplateRepo' # create a template repository
PS C:\> $f = New-Item -Path "$($t.FullName)\TemplateFile.txt" -ItemType File -Value 'This is a template file.' # add a file to the template repository
PS C:\> $r = New-GitRepo -Repo 'C:\PowdrgitExamples\NewRepoFromTemplateRepo' -TemplateDir $t.FullName # create a new repository from the template repository
PS C:\> Get-ChildItem -Path 'C:\PowdrgitExamples\NewRepoFromTemplateRepo' -Force -Recurse -Filter *.txt | Select-Object -ExpandProperty FullName
C:\PowdrgitExamples\NewRepoFromTemplateRepo\.git\TemplateFile.txt

# Note that git copies files from with working directory of the template repository to the git directory of the new repository.
```

## PARAMETERS

### -AppendPowdrgitPath
Appends the path of the new repository to the $Powdrgit.Path module variable.

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

### -Bare
Create a bare repository.

```yaml
Type: SwitchParameter
Parameter Sets: Bare
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -InitialBranchName
Name of the initial branch.
If not specified, the git default will be used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InitialCommit
Make an initial commit against the new repo using the given text.
This commit will associate any existing files in the repository with it and will be the parent to all subsequent commits.
Until an initial commit has been made, the initial branch will not be visible in git.
If multiple strings are passed in, the first string is used as the commit subject.
All remaining strings are used as the commit body.

```yaml
Type: String[]
Parameter Sets: InitialCommit
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Repo
The name, or a relative or absolute path, to the git repository to create.
If the directory does not exist, it will be created.
If RepoPath is not specified, the repository is created at the current location.
If the UseDefaultDir switch is used, then Repo allows a repository name or relative path.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: FullName, Path, RepoName, RepoPath

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -SetLocation
Sets the location to the top-level directory of the new repository.

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

### -TemplateDir
Path to the template directory.
Files and directories in the template directory whose name do not start with a dot will be copied to the new repository after it is created.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UseDefaultDir
Uses the directory stored in the $Powdrgit.DefaultDir variable as the parent directory.

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

### -UseDefaultInitialCommit
Same behavior as the InitialCommit parameter, but the commit message will use the value in $Powdrgit.DefaultInitialCommit.

```yaml
Type: SwitchParameter
Parameter Sets: UseDefaultInitialCommit
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS


## OUTPUTS

If the AppendPowdrgitPath switch was used, then a [GitRepo] object is returned. Otherwise a [System.IO.DirectoryInfo] object is returned.

## NOTES
Author : nmbell

## RELATED LINKS

[Find-GitRepo](Find-GitRepo.md)

[Get-GitRepo](Get-GitRepo.md)

[Set-GitRepo](Set-GitRepo.md)

[Remove-GitRepo](Remove-GitRepo.md)

[Invoke-GitClone](Invoke-GitClone.md)

[Add-PowdrgitPath](Add-PowdrgitPath.md)

[Remove-PowdrgitPath](Remove-PowdrgitPath.md)

[Test-PowdrgitPath](Test-PowdrgitPath.md)

[about_powdrgit](about_powdrgit.md)



