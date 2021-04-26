# Invoke-GitExpression

## SYNOPSIS
Runs the provided git command on the local computer.

## SYNTAX

```
Invoke-GitExpression [-Command] <String> [-SuppressGitSuccessStream] [-SuppressGitErrorStream] [<CommonParameters>]
```

## DESCRIPTION
Runs the provided git command on the local computer.
Both git output streams (success (1) and error (2)) are redirected to the Powershell success (1) output stream.
This provides behavior consistent with other Powershell commands, and means that piping to commands such as Out-Null will behave as expected.
The output from either (or both) git streams can be suppressed with optional switches.
The function will also accept non-git commands, but the output from non-git commands will be returned as strings.

## EXAMPLES

### EXAMPLE 1
```
## Native git command vs Invoke-GitExpression - output to console ##

# This example assumes commands are run against the main branch of an existing git repository, which is tracking a remote repository branch and is up to date.

C:\MyRepo\> git checkout main
Already on 'main'
Your branch is up to date with 'origin/main'.
C:\MyRepo\>

# Although not obvious, the first line of the above output from the native git command is from the error stream, and the second is from the success stream.

C:\MyRepo\> Invoke-GitExpression -Command 'git checkout main'
Already on 'main'
Your branch is up to date with 'origin/main'.
C:\MyRepo\>

# The same results appear in the console. Also not obvious, but this time both lines of output are coming from Powershell's success stream.
```

### EXAMPLE 2
```
## Native git command vs Invoke-GitExpression - output to Out-Null ##

# This example assumes commands are run against the main branch of an existing git repository, which is tracking a remote repository branch and is up to date.

C:\MyRepo\> git checkout main | Out-Null
Already on 'main'
C:\MyRepo\>

# Piping to Out-Null usually results in nothing returned to the console. However, here we see a message returned, coming from git's error stream.

C:\MyRepo\> Invoke-GitExpression -Command 'git checkout main' | Out-Null
C:\MyRepo\>

# This time, all output is suppressed, as expected.
```

### EXAMPLE 3
```
## Invoke-GitExpression - suppressing output ##

# This example assumes commands are run against the main branch of an existing git repository, which is tracking a remote repository branch and is up to date.

C:\MyRepo\> Invoke-GitExpression -Command 'git checkout main' -SuppressGitErrorStream
Your branch is up to date with 'origin/main'.
C:\MyRepo\>

# The message coming from git's error stream has been omitted.

C:\MyRepo\> Invoke-GitExpression -Command 'git checkout main' -SuppressGitSuccessStream
Already on 'main'
C:\MyRepo\>

# The message coming from git's success stream has been omitted.

C:\MyRepo\> Invoke-GitExpression -Command 'git checkout main' -SuppressGitSuccessStream -SuppressGitErrorStream
C:\MyRepo\>

# Using both switches suppresses all output, equivalent to piping to Out-Null.
```

## PARAMETERS

### -Command
The git command to be run.

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

### -SuppressGitErrorStream
When true, the output from the git error (2) stream will be suppressed.

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

### -SuppressGitSuccessStream
When true, the output from the git success (1) stream will be suppressed.

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

[System.String]

Accepts string objects via the Command parameter.

## OUTPUTS

[System.String]

Returns String objects.


## NOTES
Author : nmbell

## RELATED LINKS

[about_powdrgit](about_powdrgit.md)

[Set-GitBranch](Set-GitBranch.md)



