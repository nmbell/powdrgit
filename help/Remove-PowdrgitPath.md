# Remove-PowdrgitPath

## SYNOPSIS
Removes a path from the $Powdrgit.Path module variable.

## SYNTAX

```
Remove-PowdrgitPath [-Path] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Removes a path from the $Powdrgit.Path module variable.
When a path is removed, $Powdrgit.Path is (re)written as a unique sorted list of paths.
If there are no paths in $Powdrgit.Path, it is set to $null.

## EXAMPLES

### EXAMPLE 1
```
## Remove empty, whitespace, or null paths ##

PS C:\> $Powdrgit.Path = 'C:\Temp\a;C:\Temp\b;C:\Temp\c'
PS C:\> Remove-PowdrgitPath -Path $null
PS C:\> Remove-PowdrgitPath -Path ''
PS C:\> Remove-PowdrgitPath -Path ';'
PS C:\> $Powdrgit.Path
C:\Temp\a;C:\Temp\b;C:\Temp\c

# Empty paths are ignored.
```

### EXAMPLE 2
```
## Remove valid paths ##

PS C:\> $Powdrgit.Path = 'C:\Temp\a;C:\Temp\b;C:\Temp\c'
PS C:\> Remove-PowdrgitPath -Path 'C:\Temp\b;C:\Temp\a'
PS C:\> $Powdrgit.Path
C:\Temp\c
PS C:\> Remove-PowdrgitPath -Path 'C:\Temp\c','C:\Temp\b'
PS C:\> $null -eq $Powdrgit.Path
True

# When all paths are removed from $Powdrgit.Path, it is set to $null.
```

### EXAMPLE 3
```
## Pipe into Remove-PowdrgitPath ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\Project1'
PS C:\> Get-ChildItem -Path 'C:\PowdrgitExamples' -Directory | Remove-PowdrgitPath
PS C:\> $null -eq $Powdrgit.Path
True

# Get-ChildItem is used here by way of example. Repository paths can also be retrieved using Get-GitRepo or Test-PowdrgitPath.
```

## PARAMETERS

### -Path
The paths to be removed.
Can be an array of strings, or a string containing a semicolon-separated list of paths.
Empty, whitespace, or null paths are ignored.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: FullName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

[Add-PowdrgitPath](Add-PowdrgitPath.md)

[Test-PowdrgitPath](Test-PowdrgitPath.md)

[Find-GitRepo](Find-GitRepo.md)

[Get-GitRepo](Get-GitRepo.md)

[Set-GitRepo](Set-GitRepo.md)

[New-GitRepo](New-GitRepo.md)

[Remove-GitRepo](Remove-GitRepo.md)

[Invoke-GitClone](Invoke-GitClone.md)

[about_powdrgit](about_powdrgit.md)



