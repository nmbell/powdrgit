# Find-GitRepo

## SYNOPSIS
Finds all git repositories that exist under the specifed directory.

## SYNTAX

### AppendPowdrgitPath (Default)
```
Find-GitRepo [[-Path] <String[]>] [-Recurse] [-AppendPowdrgitPath] [<CommonParameters>]
```

### SetPowdrgitPath
```
Find-GitRepo [[-Path] <String[]>] [-Recurse] [-SetPowdrgitPath] [<CommonParameters>]
```

## DESCRIPTION
Finds all git repositories that exist under the specifed directory.
Searches the specifed directory and, optionally, its subdirectories and returns a set of directory objects, each of which is a git repository.

## EXAMPLES

### EXAMPLE 1
```
## Find git repositories under a specifed directory ##

PS C:\> Find-GitRepo -Path 'C:\PowdrgitExamples' | Select-Object -ExpandProperty FullName
C:\PowdrgitExamples\MyToolbox
C:\PowdrgitExamples\Project1
```

### EXAMPLE 2
```
## Find git repositories under the default directory ##

PS C:\> $Powdrgit.DefaultDir = 'C:\PowdrgitExamples'
PS C:\> Find-GitRepo -Path $Powdrgit.DefaultDir | Select-Object -ExpandProperty FullName
C:\PowdrgitExamples\MyToolbox
C:\PowdrgitExamples\Project1

# PowerShell does not currently support multiple optional mutually exlusive parameter sets, which would allow a DefaultDir parameter.
# To work around this, the $Powdrgit.DefaultDir module variable is instead passed to the Path parameter.
```

### EXAMPLE 3
```
## Populate the $Powdrgit.Path module variable with SetPowdrgitPath parameter ##

PS C:\> $Powdrgit.Path = $null
PS C:\> Find-GitRepo -Path 'C:\PowdrgitExamples' -SetPowdrgitPath | Out-Null
PS C:\> $Powdrgit.Path
C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1
```

### EXAMPLE 4
```
## Populate the $Powdrgit.Path module variable with function output ##

PS C:\> $Powdrgit.Path = $null
PS C:\> $Powdrgit.Path = (Find-GitRepo -Path 'C:\PowdrgitExamples' | Select-Object -ExpandProperty FullName) -join ';'
PS C:\> $Powdrgit.Path
C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1

# This example uses the output of Find-GitRepo to populate the $Powdrgit.Path module variable.
# It is equivalent to the previous example, however, this method may be preferred when filtering is required e.g.:
# $Powdrgit.Path = (Find-GitRepo -Path 'C:\PowdrgitExamples' | Where-Object Name -ne 'MyToolbox' | Select-Object -ExpandProperty FullName) -join ';'
```

### EXAMPLE 5
```
## Use AppendPowdrgitPath to add new repositories to the $Powdrgit.Path module variable ##

PS C:\> $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox' # to ensure the existing repository paths are defined
PS C:\> Find-GitRepo -Path 'C:\PowdrgitExamples\Project1' -AppendPowdrgitPath | Out-Null
PS C:\> $Powdrgit.Path
C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1'
```

### EXAMPLE 6
```
## Find git repositories by piping objects ##

PS C:\> 'C:\PowdrgitExamples' | Find-GitRepo | Select-Object -ExpandProperty FullName
C:\PowdrgitExamples\MyToolbox
C:\PowdrgitExamples\Project1

# Strings can be piped directly into the function.

PS C:\> Get-Item -Path 'C:\PowdrgitExamples' | Find-GitRepo | Select-Object -ExpandProperty FullName
C:\PowdrgitExamples\MyToolbox
C:\PowdrgitExamples\Project1

# FullName is an alias for the Path parameter, allowing directory objects to be piped to Find-GitRepo.
```

## PARAMETERS

### -AppendPowdrgitPath
Appends the list of paths for all found repositories to the $Powdrgit.Path module variable.
Paths that are already in the $Powdrgit.Path module variable will not be duplicated.

```yaml
Type: SwitchParameter
Parameter Sets: AppendPowdrgitPath
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
An array of directory paths to be searched.
Paths that do not exist will be ignored.
If the parameter is omitted, or null, or an empty string, all fixed drives will be searched.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: FullName

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Recurse
Search subdirectories of the specifed directory.

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

### -SetPowdrgitPath
Populates the $Powdrgit.Path module variable with a list of the paths for all found repositories.

```yaml
Type: SwitchParameter
Parameter Sets: SetPowdrgitPath
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

[System.IO.DirectoryInfo]

Accepts directory objects.

## OUTPUTS

[System.IO.DirectoryInfo]

Returns directory objects.

## NOTES
Author : nmbell

## RELATED LINKS

[Get-GitRepo](Get-GitRepo.md)

[Set-GitRepo](Set-GitRepo.md)

[New-GitRepo](New-GitRepo.md)

[Remove-GitRepo](Remove-GitRepo.md)

[Invoke-GitClone](Invoke-GitClone.md)

[Add-PowdrgitPath](Add-PowdrgitPath.md)

[Remove-PowdrgitPath](Remove-PowdrgitPath.md)

[Test-PowdrgitPath](Test-PowdrgitPath.md)

[about_powdrgit](about_powdrgit.md)



