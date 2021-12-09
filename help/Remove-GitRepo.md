# Remove-GitRepo

## SYNOPSIS
Removes a git repository.

## SYNTAX

```
Remove-GitRepo [[-Repo] <String[]>] [-RemoveGitFilesOnly] [-RemovePowdrgitPath] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Removes a git repository.
The function can remove either the repository directory and all of its files and subdirectories, or just the .git directory.
Optionally, the path can be removed from the $Powdrgit.Path module variable.

## EXAMPLES

### EXAMPLE 1
```
## Call with no parameters ##

PS C:\> Remove-GitRepo
PS C:\>

# When called without any parameters, nothing happens.
```

### EXAMPLE 2
```
## Call for non-existent repository ##

PS C:\> $repoDir = 'C:\NonExistentRepo'
PS C:\> $Powdrgit.Path = $repoDir
PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> Remove-GitRepo -Repo $repoDir -Confirm:$false
WARNING: [Remove-GitRepo]Repository 'C:\NonExistentRepo' not found. Check the repository directory exists and has been added to the $Powdrgit.Path module variable.
```

### EXAMPLE 3
```
## Call from outside a repository ##

PS C:\> $repoDir = 'C:\RemoveMe'
PS C:\> $r = New-GitRepo -Repo $repoDir -AppendPowdrgitPath # first create a repo
PS C:\> Test-Path -Path $repoDir
True
PS C:\> Remove-GitRepo -Repo $repoDir -Confirm:$false
PS C:\> Test-Path -Path $repoDir
False
```

### EXAMPLE 4
```
## Call from inside a repository ##

PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> $repoDir = 'C:\RemoveMe'
PS C:\> $r = New-GitRepo -Repo $repoDir -AppendPowdrgitPath # first create a repo
PS C:\> Test-Path -Path $repoDir
True
PS C:\> Set-Location -Path $repoDir
PS C:\RemoveMe> Remove-GitRepo -Repo $repoDir -Confirm:$false
WARNING: [Remove-GitRepo]Location was changed from inside a repository that was removed. Please check the current location.
PS C:\> Test-Path -Path $repoDir
False

# When calling from inside a repository, the location changes to the parent of the repository.
```

### EXAMPLE 5
```
## Call matching multiple repos ##

PS C:\> $Powdrgit.ShowWarnings = $true # to ensure warnings are visible
PS C:\> $repoDirs = 'C:\RemoveMe1','C:\RemoveMe2'
PS C:\> $r = New-GitRepo -Repo $repoDirs -AppendPowdrgitPath # first create the repos
PS C:\> Test-Path -Path $repoDirs
True
True
PS C:\> Remove-GitRepo -Repo 'C:\RemoveMe' -Confirm:$false
WARNING: [Remove-GitRepo]Repo argument 'C:\RemoveMe' matched multiple repositories. Please confirm any results or actions are as expected.
PS C:\> Test-Path -Path $repoDirs
False
False
```

### EXAMPLE 6
```
## Call with RemovePowdrgitPath ##

PS C:\> $repoDir = 'C:\RemoveMe'
PS C:\> $Powdrgit.Path = $null
PS C:\> $r = New-GitRepo -Repo $repoDir -AppendPowdrgitPath # first create a repo
PS C:\> Test-Path -Path $repoDir
True
PS C:\> $Powdrgit.Path
C:\RemoveMe
PS C:\> Remove-GitRepo -Repo $repoDir -RemovePowdrgitPath -Confirm:$false
PS C:\> Test-Path -Path $repoDir
False
PS C:\> $Powdrgit.Path
PS C:\>
```

### EXAMPLE 7
```
## Call with RemoveGitFilesOnly ##

PS C:\> $repoDir = 'C:\KeepMe'
PS C:\> $r = New-GitRepo -Repo $repoDir -AppendPowdrgitPath # first create a repo
PS C:\> $f = New-Item -Path "$repoDir\SomeFile.txt" -ItemType File -Value 'Some text.' # create a file in the repo
PS C:\> Test-Path -Path $repoDir
True
PS C:\> Test-Path -Path "$repoDir\.git"
True
PS C:\> Test-Path -Path $f.FullName
True
PS C:\> Remove-GitRepo -Repo $repoDir -RemoveGitFilesOnly -Confirm:$false
PS C:\> Test-Path -Path $repoDir
True
PS C:\> Test-Path -Path "$repoDir\.git"
False
PS C:\> Test-Path -Path "$repoDir\SomeFile.txt"
True
```

### EXAMPLE 8
```
## Pipe from Get-GitRepo ##

PS C:\> $repoDir = 'C:\RemoveMe'
PS C:\> $r = New-GitRepo -Repo $repoDir -AppendPowdrgitPath # first create a repo
PS C:\> Test-Path -Path $repoDir
True
PS C:\> Get-GitRepo -Repo $repoDir | Remove-GitRepo -Confirm:$false
PS C:\> Test-Path -Path $repoDir
False
```

## PARAMETERS

### -RemoveGitFilesOnly
When applied to a regular (not bare) repository, removes only the .git directory, leaving the working files intact.
Note: Bare repositories will always have the repository directory and all of its files and subdirectories removed.

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

### -RemovePowdrgitPath
Removes the path of the deleted repository from the $Powdrgit.Path module variable.

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

### -Repo
The name, or a relative or absolute path, to the git repository to remove.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: FullName, Path, RepoName, RepoPath

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
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

[System.String[]]

Accepts string objects via the Repo parameter.

## OUTPUTS

[System.Void]

The function does not return anything.

## NOTES
Author : nmbell

## RELATED LINKS

[Find-GitRepo](Find-GitRepo.md)

[Get-GitRepo](Get-GitRepo.md)

[Set-GitRepo](Set-GitRepo.md)

[New-GitRepo](New-GitRepo.md)

[Invoke-GitClone](Invoke-GitClone.md)

[Add-PowdrgitPath](Add-PowdrgitPath.md)

[Remove-PowdrgitPath](Remove-PowdrgitPath.md)

[Test-PowdrgitPath](Test-PowdrgitPath.md)

[about_powdrgit](about_powdrgit.md)



