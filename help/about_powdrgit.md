﻿# Powdrgit 1.3.0

[SHORT DESCRIPTION](#short-description)

[LONG DESCRIPTION](#long-description)

- [The module functions](#the-module-functions)

[QUICK START GUIDE](#quick-start-guide)

1. [Install the module.](#1-install-the-module)

2. [Configure Powdrgit.](#2-configure-powdrgit)

3. [Check the configuration.](#3-check-the-configuration)

4. [Run your first command.](#4-run-your-first-command)

[LEARNING THE COMMANDS](#learning-the-commands)

[FURTHER CONFIGURATION](#further-configuration)

[EXAMPLES](#examples)

[GIT DOCUMENTATION](#git-documentation)

[RELEASE HISTORY](#release-history)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## SHORT DESCRIPTION
**Powershell Driven Git**

Powdrgit is a PowerShell module that makes it easy to work across repositories and branches.

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## LONG DESCRIPTION
**Powershell Driven Git**

Powdrgit is a PowerShell module that makes it easy to work across repositories and branches.

Rather than providing wrappers around existing git functionality, the module is centered around functions that handle repositories and branches as PowerShell objects, and can therefore leverage the PowerShell pipeline for gathering information or making changes to many repositories or branches at once. The module also includes functions that allow object handling for commits and tags, and other functions related to git and Powdrgit configuration.

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
- [Get-GitDiff](Get-GitDiff.md)
- [Format-GitDiff](Format-GitDiff.md)

For repository management and Powdrgit configuration:
- [New-GitRepo](New-GitRepo.md)
- [Invoke-GitClone](Invoke-GitClone.md)
- [Find-GitRepo](Find-GitRepo.md)
- [Remove-GitRepo](Remove-GitRepo.md)
- [Get-GitConfigFile](Get-GitConfigFile.md)
- [Add-PowdrgitPath](Add-PowdrgitPath.md)
- [Remove-PowdrgitPath](Remove-PowdrgitPath.md)
- [Test-PowdrgitPath](Test-PowdrgitPath.md)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## QUICK START GUIDE
### 1. Install the module.
   The [module](https://www.powershellgallery.com/packages/powdrgit/1.3.0) is available through the [PowerShell Gallery](https://docs.microsoft.com/en-us/powershell/scripting/gallery/getting-started).
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

   To see a list of aliases:
   ```
   Get-Alias | Where-Object ModuleName -eq powdrgit | Select-Object Name,ResolvedCommand
   ```

### 2. Configure Powdrgit.
   Powdrgit needs to know which repositories you're interested in working with. It does this by storing a list of paths to those repositories in a module variable `$Powdrgit.Path`. Powdrgit will only 'see' repos that are in that list. There are a number of ways to populate the list:
   - Plain ol' variable assignment:
     - Once the module is loaded, simply add the paths you want, e.g.:
       ```
       $Powdrgit.Path = 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1'
       ```
     - `$Powdrgit.Path` can also be updated using any standard Powershell technique.
   - Use the Find-GitRepo function:
     - `Find-GitRepo` can help you find git repositories on your computer. Using the `-SetPowdrgitPath` switch will replace the existing list with a list of all of the repository paths it just found. Using the `-AppendPowdrgitPath` switch will add any of the paths it just found to the list (if they're not already there). E.g.:
       ```
       Find-GitRepo -Path 'C:\' -SetPowdrgitPath
       ```
       This will set `$Powdrgit.Path` to the list of all repositories on your C drive.
   - Use the Add-PowdrgitPath and Remove-PowdrgitPath functions:
     - Paths can be added and removed using `Add-PowdrgitPath` and `Remove-PowdrgitPath`. Also, some module functions have switches that will update `$Powdrgit.Path` for you. E.g.:
       ```
       Add-PowdrgitPath -Path 'C:\PowdrgitExamples\MyToolbox;C:\PowdrgitExamples\Project1'
       ```

   To have the configuration available whenever a console window is opened, put the commands into your [PowerShell profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles).

### 3. Check the configuration.
   Run:
   ```
   Test-PowdrgitPath
   ```
   If a path that was added is not actually git repository (i.e. doesn't have a .git subdirectory or is not a bare .git directory), or doesn't exist, a warning is generated. It's safe to leave them in the list, however, as Powdrgit will just ignore them. Whether or not any warnings were generated, `Test-PowdrgitPath` will also output a number, which shows the number of valid paths in the list.

### 4. Run your first command.
   You're good to go! Simply run:
   ```
   Get-GitRepo
   ```
   You should see the valid repositories that you just added to `$Powdrgit.Path`.
   The Powdrgit module always takes the name of the top-level repository directory as the repository name. It does not use values from a repository's config or origin URL as the name.

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## LEARNING THE COMMANDS
Each function has numerous examples to help you understand how the function can be used and what results it provides. To view the help for any function, use PowerShell's built-in Get-Help function, e.g.:
```
Get-Help -Full Get-GitRepo
```
Many of the examples refer to repositories in the `C:\PowdrgitExamples` directory. If you'd like to follow along with the examples verbatim, you can use the following script to create the example repositories:

[Powdrgit Help Examples - Setup Script](https://gist.github.com/nmbell/10dad7587ef640618036461c7d212981)

The script is also available in the module folder at `powdrgit\scripts\PowdrgitHelpExampleSetup.ps1`.

Note: the SHA1Hash values in the examples will be different to the ones you see on your own computer.

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## FURTHER CONFIGURATION
Powdrgit has a module variable, `$Powdrgit`, that has various properties that can customize the behavior of Powdrgit:
- **.AutoCompleteFullPaths**:
  - When set to `$true`, autocompletion values for any `-Repo` parameter will always show the full path of the repository. When set to `$false`, if the repository name is unique within Powdrgit, then only the name of the repository is shown. If a repository name is not unique within Powdrgit, the full path is always shown.
  - Default is `$false`.
- **.BranchExcludes**:
  - PowerShell object array that contains filters used to limit the branches displayed with Get-Gitbranch.
  - Default is an empty object: [PSCustomObject]@{ RepoPattern = ''; BranchPattern = ''; ApplyTo = '' }.
- **.BranchExcludesNoWarn**:
  - Suppresses the warning message shown by Get-GitBranch when branches have been excluded by a filter.
  - Default is `$false`.
- **.DebugIndentChar**:
  - Debug output is indented to match the nested depth of the function. The first character of `$Powdrgit.DebugIndentChar` is used as the first character of the indent.
  - Default is `>`.
- **.DefaultCloneUrl**:
  - When frequently cloning repositories from the same collection, the only part of the URL that may change is the name of the repository. `$Powdrgit.DefaultCloneUrl` can hold the URL, with a placeholder, `<RepoName>`, for the repository name. Then, when using `Invoke-GitClone`, only the repository name needs to be provided. A full URL can always be used regardless of the value of `$Powdrgit.DefaultCloneUrl`.
  - Default is `$null`.
- **.DefaultDir**:
  - When working with many repositories, if they are kept in the same parent directory, it can be useful to set `$Powdrgit.DefaultDir` to this directory. This then allows using the UseDefaultDir switch instead of having to explicitly specify the path.
  - Default is `$null`.
- **.DefaultGitScriptSeparator**:
  - Contains the default script separator for commands passed to the `-GitScript` parameter of `Set-GitBranch`. If required, the `-GitScriptSeparator` parameter can be used to override this default at the time the command is run.
  - Default is `;`.
- **.DefaultInitialCommit**:
  - When creating new repositories, it may be desirable to make an initial commit to the repository before any further changes are made. `New-GitRepo` allows the message for the initial commit to be specified. If the same message is always required for the initial commit, the message can be specified in `$Powdrgit.DefaultInitialCommit` and applied using the `-UseDefaultInitialCommit` switch.
  - Default is `'Initial commit'`.
- **.DiffLineColorNew**:
  - Color to use for displaying new (added) lines in a diff with Format-GitDiff.
  - Default is `'Cyan'`.
- **.DiffLineColorOld**:
  - Color to use for displaying old (removed) lines in a diff with Format-GitDiff.
  - Default is `'Magenta'`.
- **.DiffLineColorSame**:
  - Color to use for displaying unchanged lines in a diff with Format-GitDiff.
  - Default is `'DarkGray'`.
- **.DiffLineColorSame**:
  - Color to use for displaying file summary information in a diff with Format-GitDiff.
  - Default is `'Gray'`.
- **.Path**:
  - As described earlier, `$Powdrgit.Path` holds a semicolon separated list of repository paths. A repository's path needs to be in `$Powdrgit.Path` for the repository to be visible in Powdrgit.
  - Default is `$null`.
- **.ShowWarnings**:
  - Controls whether Powdrgit generates warnings.
  - Default is `$true`.

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

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


View a nicely formatted diff of changes since the previous commit:
```
Get-GitDiff | Format-GitDiff
```


Capture all the output from a git command in a variable:
```
$results = Invoke-GitExpression -Command 'git status'
```

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## GIT DOCUMENTATION
Git reference documentation can be found [here](https://git-scm.com/docs).

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## RELEASE HISTORY
### 1.3.0 (2023-02-04)
- New functions:
	- Get-GitDiff
	- Format-GitDiff
- Update functions:
	- Find-GitRepo:
		- Handle literal paths that look like wildcard paths
	- Get-GitBranch:
		- Update BranchName to show (what would be) the local name of remote only branches
		- Populate Upstream and UpstreamFullName for remote branches
		- Add RemoteName property
		- Generate separate warnings for local and remote branches excluded by filtering
		- Add -Force switch to override filtering
	- Set-GitBranch
		- Allow checking out remote branches with (what would be) the local branch name
		- Add -Force switch to override filtering


### 1.2.0 (2022-11-06)
- Update functions:
	- Find-GitRepo:
		- Include RecurseJunction switch to control recursion into junction points
	- Get-GitCommit:
		- Update commit message handling to tolerate special characters
	- Get-GitBranch:
		- Update BranchName to show the complete branch name when the branch name includes slashes
		- Include BranchLeafName in output, which has only the part of the branch name after the last slash
		- Update branch name handling to tolerate special characters
		- Include two new module variable attributes to control filtering of results:
			- $Powdrgit.BranchExcludes allows branches to be excluded from results
			- $Powdrgit.BranchExcludesNoWarn controls suppression of warning messages about the number of branches excluded due to filtering
- Update array handling for performance


### 1.1.2 (2022-06-11)
- Update logo file path for PowerShellGallery.com.
- Update functions:
  - Invoke-GitClone:
    - Fix logic bug for determining RepoName when it contains '.git'


### 1.1.1 (2021-12-09)
- Add wide and list formats and separate format definitions into one file per class.
- Update manifest so PowdrgitArgumentCompleters.ps1 does not appear in Get-Module results.
- Add LicenseUri, ProjectUri, IconUri, and ReleaseNotes values to manifest.
- Add logo file for PowerShellGallery.com.
- Add contents listing and section dividers to about_powdrgit file.
- Add link to online version of about_powdrgit in each function's help as a workaround for [16452](https://github.com/PowerShell/PowerShell/issues/16452).
- Add .INPUTS and .OUTPUTS sections in each function's help.
- Add OutputType declaration to each function.
- Add call to ScrollDisplayDownLine in Write-GitBranchOut as a workaround for [15130](https://github.com/PowerShell/PowerShell/issues/15130).
- Updates to .md files from Platyps.
- Other minor code alterations.


### 1.1.0 (2021-10-01)
- Add support for multiple repositories with the same name:
	- Replace RepoName parameter with Repo parameter (with RepoName as an alias)
	- Repo parameter accepts an array of repository names or paths
	- Update existing Powdrgit classes to have both a RepoName and RepoPath property
	- *Add a GitRepo class, which wraps the System.IO.DirectoryInfo object of the repository directory (breaking change)
- Add support for bare repositories.
- Add aliases for all functions.
- Add format.ps1xml file.
- Separate argument completer logic from function definitions to consolidate and centralize logic.
- *Replace module variables with a hash table variable "$Powdrgit" (breaking change). See about_powdrgit for details.
- Reduce Verbose output to be less, um, verbose.
- Add custom logic to implement correct "-WarningAction Ignore" behavior (see PowerShell issues [4120](https://github.com/PowerShell/PowerShell/issues/4120), [1759](https://github.com/PowerShell/PowerShell/issues/1759)).
- Add custom logic to turn on Verbose output with Debug output.
- Update location handling because location stacks are currently unclearable (see PowerShell issues [4643](https://github.com/PowerShell/PowerShell/issues/4643)).
- New functions:
  - Add-PowdrgitPath
  - Invoke-GitClone
  - New-GitRepo
  - Remove-GitRepo
  - Remove-PowdrgitPath
  - Test-PowdrgitPath (replaces Test-GitRepoPath)
- Remove functions:
  - *Test-GitRepoPath (replaced with Test-PowdrgitPath) (breaking change)
- Update functions:
  - Find-GitRepo:
    - Add alias fgr
    - *Rename RootDirectory parameter to Path (breaking change)
    - Add a Recurse parameter
  - Get-GitBranch:
    - Add alias ggb
    - Replace RepoName parameter with Repo parameter
    - Add BranchName parameter
  - Get-GitCommit:
    - Add alias ggc
    - Replace RepoName parameter with Repo parameter
  - Get-GitCommitFile:
    - Add alias ggcf
    - Replace RepoName parameter with Repo parameter
  - Get-GitConfigFile:
    - Add alias ggcfg
    - Replace RepoName parameter with Repo parameter
    - Add Portable parameter
    - Add Worktree parameter
  - Get-GitFileHistory:
    - Add alias ggfh
    - Replace RepoName parameter with Repo parameter
    - Rename Path parameter to FilePath with Path as an alias
  - Get-GitFileHistory:
    - Add alias ggl
    - Replace RepoName parameter with Repo parameter
  - Get-GitRepo:
    - Add alias ggr
    - Replace RepoName parameter with Repo parameter
    - *Update output to a GitRepo object, which has the System.IO.DirectorInfo object of the repository as a member (breaking change)
  - Get-GitTag:
    - Add alias ggt
    - Replace RepoName parameter with Repo parameter
  - Invoke-GitExpression:
    - Add alias ige
    - Update Verbose and Debug output handling
  - Set-GitBranch:
    - Add alias sgb
    - Replace RepoName parameter with Repo parameter
    - Add WhatIf/Confirm support
  - Set-GitRepo:
    - Add alias sgr
  	- Replace RepoName parameter with Repo parameter

### 1.0.2 (2021-04-27)
  - Update help links

### 1.0.1 (2021-04-26)
  - Update help and add online help files

### 1.0.0 (2021-04-12)
  - Initial release
