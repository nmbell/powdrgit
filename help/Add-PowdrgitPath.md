# Add-PowdrgitPath

## SYNOPSIS
Adds a path to the $Powdrgit.Path module variable.

## SYNTAX

```
Add-PowdrgitPath [-Path] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Adds a path to the $Powdrgit.Path module variable.
When a path is added, $Powdrgit.Path is (re)written as a unique sorted list of paths.
If there are no paths in $Powdrgit.Path, it is set to $null.

## EXAMPLES

### EXAMPLE 1
```
## Add empty, whitespace, or null path to $Powdrgit.Path ##

PS C:\> $Powdrgit.Path = $null
PS C:\> Add-PowdrgitPath -Path $null
PS C:\> Add-PowdrgitPath -Path ''
PS C:\> Add-PowdrgitPath -Path ';'
PS C:\> $null -eq $Powdrgit.Path
True

# Empty paths are ignored.
```

### EXAMPLE 2
```
## Add valid paths to $Powdrgit.Path ##

PS C:\> $Powdrgit.Path = $null
PS C:\> Add-PowdrgitPath -Path 'C:\Temp\b;C:\Temp\a'
PS C:\> Add-PowdrgitPath -Path 'C:\Temp\c','C:\Temp\b'
PS C:\> $Powdrgit.Path
C:\Temp\a;C:\Temp\b;C:\Temp\c

# Paths are always de-duplicated and ordered.
```

### EXAMPLE 3
```
## Pipe values into Add-PowdrgitPath ##

PS C:\> $Powdrgit.Path = $null
PS C:\> Get-ChildItem -Path 'C:\PowdrgitExamples' -Directory | Add-PowdrgitPath
PS C:\> $Powdrgit.Path
C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\NotAGitRepo;C:\PowdrgitExamples\Project1

# Paths can be piped in.
# Get-ChildItem is used here by way of example. The preferred way to add repository paths is with Find-GitRepo, e.g.:
# Find-GitRepo -Path 'C:\PowdrgitExamples' -AppendPowdrgitPath
```

## PARAMETERS

### -Path
The paths to be added.
Can be an array of strings, with each string containing a semicolon-separated list of paths.
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

[System.String[]]

Accepts string objects via the Path parameter.

## OUTPUTS

[System.Void]

The function does not return anything.

## NOTES
Author : nmbell

## RELATED LINKS

[Remove-PowdrgitPath](Remove-PowdrgitPath.md)

[Test-PowdrgitPath](Test-PowdrgitPath.md)

[Find-GitRepo](Find-GitRepo.md)

[Set-GitRepo](Set-GitRepo.md)

[New-GitRepo](New-GitRepo.md)

[Remove-GitRepo](Remove-GitRepo.md)

[Invoke-GitClone](Invoke-GitClone.md)

[about_powdrgit](about_powdrgit.md)



