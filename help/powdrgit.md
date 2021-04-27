# powdrgit 1.0.2

## Description
Powdrgit is a PowerShell module that makes it easy to work across repositories and branches.

## powdrgit Cmdlets
### [Find-GitRepo](Find-GitRepo.md)
Finds all git repositories that exist under the specifed root directory.

### [Get-GitBranch](Get-GitBranch.md)
Gets a list of branches for the specified repository.

### [Get-GitCommit](Get-GitCommit.md)
Gets information for a given SHA1 commit hash.

### [Get-GitCommitFile](Get-GitCommitFile.md)
Gets the files associated with a commit.

### [Get-GitConfigFile](Get-GitConfigFile.md)
Gets the config file for the given repository or scope.

### [Get-GitFileHistory](Get-GitFileHistory.md)
Gets commit history for a given file.

### [Get-GitLog](Get-GitLog.md)
Gets a list of commits from the git log.

### [Get-GitRepo](Get-GitRepo.md)
Gets the directory objects for valid repositories defined in $GitRepoPath.

### [Get-GitTag](Get-GitTag.md)
Gets a list of tags for the specified repository.

### [Invoke-GitExpression](Invoke-GitExpression.md)
Runs the provided git command on the local computer.

### [Set-GitBranch](Set-GitBranch.md)
Checks out the specified branches for the specified repository.

### [Set-GitRepo](Set-GitRepo.md)
Sets the working directory to the top level directory of the specified repository.

### [Test-GitRepoPath](Test-GitRepoPath.md)
Validates the paths stored in the $GitRepoPath module variable.
