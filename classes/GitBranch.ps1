class GitBranch
{

	[String]$RepoName
	[String]$RepoPath
	[String]$SHA1Hash
	[String]$BranchName
	[Bool]  $IsCheckedOut
	[Bool]  $IsRemote
	[String]$BranchLeafName
	[String]$BranchFullName
	[String]$Upstream
	[String]$UpstreamFullName
	[String]$RemoteName

	[String]ToString(){ Return $this.BranchName }

}
