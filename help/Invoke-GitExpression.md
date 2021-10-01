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

C:\PowdrgitExamples\MyToolbox\> git checkout main
Already on 'main'
Your branch is ahead of 'origin/main' by 3 commits.
  (use "git push" to publish your local commits)
C:\PowdrgitExamples\MyToolbox\>

# Although not obvious, the first line of the above output from the native git command is from the error stream, and the second and third are from the success stream.

C:\PowdrgitExamples\MyToolbox\> Invoke-GitExpression -Command 'git checkout main'
Already on 'main'
Your branch is ahead of 'origin/main' by 3 commits.
  (use "git push" to publish your local commits)
C:\PowdrgitExamples\MyToolbox\>

# The same results appear in the console. Also not obvious, but this time all lines of output are coming from Powershell's success stream.
```

### EXAMPLE 2
```
## Native git command vs Invoke-GitExpression - output to Out-Null ##

C:\PowdrgitExamples\MyToolbox\> git checkout main | Out-Null
Already on 'main'
C:\PowdrgitExamples\MyToolbox\>

# Piping to Out-Null usually results in nothing returned to the console. However, here we see a message returned, coming from git's error stream.

C:\PowdrgitExamples\MyToolbox\> Invoke-GitExpression -Command 'git checkout main' | Out-Null
C:\PowdrgitExamples\MyToolbox\>

# This time, all output is suppressed, as expected.
```

### EXAMPLE 3
```
## Invoke-GitExpression - suppressing output ##

C:\PowdrgitExamples\MyToolbox\> Invoke-GitExpression -Command 'git checkout main' -SuppressGitErrorStream
Your branch is ahead of 'origin/main' by 3 commits.
  (use "git push" to publish your local commits)
C:\PowdrgitExamples\MyToolbox\>

# The message coming from git's error stream has been omitted.

C:\PowdrgitExamples\MyToolbox\> Invoke-GitExpression -Command 'git checkout main' -SuppressGitSuccessStream
Already on 'main'
C:\PowdrgitExamples\MyToolbox\>

# The message coming from git's success stream has been omitted.

C:\PowdrgitExamples\MyToolbox\> Invoke-GitExpression -Command 'git checkout main' -SuppressGitSuccessStream -SuppressGitErrorStream
C:\PowdrgitExamples\MyToolbox\>

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

[Set-GitBranch](Set-GitBranch.md)

[Invoke-GitClone](Invoke-GitClone.md)

[about_powdrgit](about_powdrgit.md)



