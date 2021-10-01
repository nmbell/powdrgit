class GitBranch
{

	[String]$RepoName
	[String]$RepoPath
	[String]$SHA1Hash
	[String]$BranchName
	[Bool]  $IsCheckedOut
	[Bool]  $IsRemote
	[String]$Upstream
	[String]$BranchFullName
	[String]$UpstreamFullName

	[String]ToString(){ Return $this.BranchName }

}
