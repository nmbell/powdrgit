# powdrgit

## SHORT DESCRIPTION
**Powershell Driven Git**

Powdrgit is a PowerShell module that makes it easy to work across repositories and branches.

## LONG DESCRIPTION
**Powershell Driven Git**

Powdrgit is a PowerShell module that makes it easy to work across repositories and branches.

Rather than providing wrappers around existing git functionality, the module is centered around four functions that handle repositories and branches as PowerShell objects, and can therefore leverage the PowerShell pipeline for gathering information or making changes to many repositories or branches at once. The module also includes functions that allow object handling for commits and tags, and other functions related to git and powdrgit configuration.


### The module functions

For working across repositories and branches:
- [Get-GitRepo](Get-GitRepo.md)
- [Set-GitRepo](Set-GitRepo.md)
- [Get-GitBranch](Get-GitBranch.md)
- [Set-GitBranch](Set-GitBranch.md)

For working inside a repository:
- [Get-GitCommit](Get-GitCommit.md)
- [Get-GitCommitFile](Get-GitCommitFile.md)
- [Get-GitFileHistory](Get-GitFileHistory.md)
- [Get-GitLog](Get-GitLog.md)
- [Get-GitTag](Get-GitTag.md)
- [Invoke-GitExpression](Invoke-GitExpression.md)

For repositories and config:
- [Find-GitRepo](Find-GitRepo.md)
- [Test-GitRepoPath](Test-GitRepoPath.md)
- [Get-GitConfigFile](Get-GitConfigFile.md)

## QUICK START GUIDE
### 1. Install the module.
   The [module](https://www.powershellgallery.com/packages/powdrgit/1.0.0) is available through the [PowerShell Gallery](https://docs.microsoft.com/en-us/powershell/scripting/gallery/getting-started).
   Run the following command in a PowerShell console to install the module:
   ```
   Install-Module -Name powdrgit -Force
   ```
   Run the following to import the module into the current session:
   ```
   Import-Module -Name powdrgit
   ```
   To see the list of available commands:
   ```
   Get-Command -Module powdrgit
   ```
   If you see a list of functions similar to those above, your install was successful.

### 2. Configure powdrgit.
   Powdrgit needs to know which repositories you're interested in working with. It does this by storing a list of paths to those repositories in a module variable `$GitRepoPath`. Powdrgit will only 'see' repos that are in that list. There are two ways to populate the list:
   - Plain ol' variable assignment:
     - Once the module is loaded, simply add the paths you want, e.g:
       ```
       $GitRepoPath = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1'
       ```
     - Paths can be added, removed, or changed using any standard Powershell technique.
   - Use the Find-GitRepo function:
     - Find-GitRepo can help you find git repositories on your computer. Using the SetGitRepoPath switch will replace the existing list with a list of all of the repository paths it just found. Using the AppendGitRepoPath switch will add any of the paths it just found to the list (if they're not already there). E.g.:
       ```
       Find-GitRepo -RootDirectory 'C:\' -SetGitRepoPath
       ```
       This will set `$GitRepoPath` to the list of all repositories on your C drive.
   If you don't want to have to do this every time you open a console window, you can put the commands that populate the list into your [PowerShell profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles).

### 3. Check the configuration.
   Run:
   ```
   Test-GitRepoPath
   ```
   If a path that was added is not actually git repository (i.e. doesn't have a .git subdirectory), or doesn't exist, a warning is generated. It's safe to leave them in the list, however, as powdrgit will just ignore them. Whether or not any warnings were generated, Test-GitRepoPath will also output a number, which shows the number of valid paths in the list.

### 4. Run your first command.
   You're good to go! Simply run:
   ```
   Get-GitRepo
   ```
   You should see the list of the valid repositories that you just added to `$GitRepoPath`.


## LEARNING THE COMMANDS
Each function has numerous examples to help you understand how the function can be used and what results it provides. To view the help for any function, use PowerShell's built-in Get-Help function, e.g.:
```
Get-Help -Full Get-GitRepo
```
Many of the examples refer to repositories in the `C:\PowdrgitExamples` directory. If you'd like to follow along with the examples verbatim, you can use the following script to create the example repositories:

[Powdrgit Help Examples - Setup Script](https://gist.github.com/nmbell/10dad7587ef640618036461c7d212981)

Note: the SHA1Hash values in the examples will be different to the ones you see on your own computer.

## EXAMPLES
Get a list of every local branch for every repository:
```
Get-GitRepo | Get-GitBranch
```


Get the git status for every local branch in every repository:
```
Get-GitRepo | Get-GitBranch | Set-GitBranch -GitScript 'git status'
```


Run a git pull on every currently checked out branch of every repository:
```
Get-GitRepo | Get-GitBranch -Current | Set-GitBranch -GitScript 'git pull'
```


View all the unmerged files in a given branch:
```
Get-GitLog -InRef feature -NotInRef main | Get-GitCommitFile
```


Capture all the output from a git command in a variable:
```
$results = Invoke-GitExpression -Command 'git status'
```
