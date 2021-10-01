class GitRepo
{

	       [String]                 $RepoName
	       [String]                 $RepoPath
	       [System.IO.DirectoryInfo]$DirectoryInfo
	hidden [Bool]                   $IsNameUnique
	hidden [Bool]                   $IsBare

	[String]ToString(){ return $this.RepoPath }

}