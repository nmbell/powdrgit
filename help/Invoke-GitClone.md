# Invoke-GitClone

## SYNOPSIS
Clones a git repository.

## SYNTAX

### ParentDir (Default)
```
Invoke-GitClone [-RepoURL] <String> [[-ParentDir] <String>] [[-RepoName] <String>] [-AppendPowdrgitPath]
 [-SetLocation] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### UseDefaultDir
```
Invoke-GitClone [-RepoURL] <String> [[-RepoName] <String>] [-UseDefaultDir] [-AppendPowdrgitPath]
 [-SetLocation] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Clones a git repository to the specified directory.

## EXAMPLES

### EXAMPLE 1
```
## Clone a non-existent repository from a URL ##

PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Invoke-GitClone -RepoURL 'https://my.repos.com/MyMissingRepo'
WARNING: [Invoke-GitClone]fatal: repository 'https://my.repos.com/MyMissingRepo/' not found

# Attempting to clone to a non-existent repository generates a warning.
```

### EXAMPLE 2
```
## Clone an existent repository from a URL ##

PS C:\> Invoke-GitClone -RepoURL 'https://my.repos.com/MyToolbox' | Format-Table Name,FullName

Name      FullName
----      --------
MyToolbox C:\MyToolbox

# The repository was cloned to the current directory.
```

### EXAMPLE 3
```
## Clone a repository from a local path ##

PS C:\> Invoke-GitClone -RepoURL 'C:\PowdrgitExamples\MyToolbox' | Format-Table Name,FullName

Name      FullName
----      --------
MyToolbox C:\MyToolbox

# The repository was cloned to the current directory.
```

### EXAMPLE 4
```
## Clone a repository to an existing repository ##

PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Invoke-GitClone -RepoURL 'C:\PowdrgitExamples\MyToolbox'
WARNING: [Invoke-GitClone]fatal: destination path 'C:\MyToolbox' already exists and is not an empty directory.

# Attempting to clone to an existing repository generates a warning.
```

### EXAMPLE 5
```
## Clone a repository with $Powdrgit.DefaultCloneUrl set ##

PS C:\> $Powdrgit.DefaultCloneUrl = 'C:\PowdrgitExamples\\\<RepoURL>'
PS C:\> Invoke-GitClone -RepoURL 'MyToolbox' | Format-Table Name,FullName

Name      FullName
----      --------
MyToolbox C:\MyToolbox

# Equivalent to the previous example
```

### EXAMPLE 6
```
## Clone a repository to a specified directory ##

PS C:\> Invoke-GitClone -RepoURL 'C:\PowdrgitExamples\MyToolbox' -ParentDir 'C:\Temp' | Format-Table Name,FullName

Name      FullName
----      --------
MyToolbox C:\Temp\MyToolbox

# The repository was cloned to the specified directory.
```

### EXAMPLE 7
```
## Clone a repository with a specified name ##

PS C:\> Invoke-GitClone -RepoURL 'C:\PowdrgitExamples\MyToolbox' -RepoName 'MyTools' | Format-Table Name,FullName

Name    FullName
----    --------
MyTools C:\MyTools

# The repository was cloned to the specified directory and given the specified name.
```

### EXAMPLE 8
```
## Clone a repository to the default directory ##

PS C:\> $Powdrgit.DefaultDir = 'C:\Temp'
PS C:\> Invoke-GitClone -RepoURL 'C:\PowdrgitExamples\MyToolbox' -UseDefaultDir | Format-Table Name,FullName

Name      FullName
----      --------
MyToolbox C:\Temp\MyToolbox

# The repository was cloned to the default directory.
```

### EXAMPLE 9
```
## Clone a repository and add the path to $Powdrgit.Path ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\Project1'
PS C:\> Invoke-GitClone -RepoURL 'C:\PowdrgitExamples\MyToolbox' -AppendPowdrgitPath | Out-Null
PS C:\> Test-PowdrgitPath -PassThru
C:\MyToolbox
C:\PowdrgitExamples\Project1

# A [GitRepo] object is returned and the repository path is added to the $Powdrgit.Path module variable.
```

### EXAMPLE 10
```
## Clone a repository and set the location to the repository ##

PS C:\> Invoke-GitClone -RepoURL 'C:\PowdrgitExamples\MyToolbox' -SetLocation | Out-Null
PS C:\MyToolbox>

# The location was changed to the repository top-level folder.
```

## PARAMETERS

### -AppendPowdrgitPath
Appends the path of the cloned repository to the $Powdrgit.Path module variable.

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

### -ParentDir
The parent directory where the git repository will be cloned to.
If the parameter is omitted, and a default parent directory is defined in $Powdrgit.DefaultDir, the repository will be cloned under that directory.
If no directory is specified, the repository is cloned to the current location.

```yaml
Type: String
Parameter Sets: ParentDir
Aliases: FullName, Path

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RepoName
The name to give the repository (the folder name of the top-level directory of the cloned repository).
If the parameter is omitted, the name will be derived from the RepoURL value.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RepoURL
The URL of the git repository to clone.
If a default URL root is defined in $Powdrgit.DefaultCloneUrl, only the repository name is required.
The URL can start with any of the following: http://, https://, ftp://, ftps://, git://, ssh://, [A-Z]:\\, \\\\

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -SetLocation
Sets the location to the top-level directory of the cloned repository.

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

### -UseDefaultDir
Uses the directory stored in the $Powdrgit.DefaultDir variable as the ParentDir value.

```yaml
Type: SwitchParameter
Parameter Sets: UseDefaultDir
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


## NOTES
Author : nmbell

## RELATED LINKS

[Find-GitRepo](Find-GitRepo.md)

[Get-GitRepo](Get-GitRepo.md)

[Set-GitRepo](Set-GitRepo.md)

[New-GitRepo](New-GitRepo.md)

[Remove-GitRepo](Remove-GitRepo.md)

[Add-PowdrgitPath](Add-PowdrgitPath.md)

[Remove-PowdrgitPath](Remove-PowdrgitPath.md)

[Test-PowdrgitPath](Test-PowdrgitPath.md)

[about_powdrgit](about_powdrgit.md)



