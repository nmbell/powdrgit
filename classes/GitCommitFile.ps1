class GitCommitFile
{

	[String] $RepoName
	[String] $SHA1Hash
	[String] $Action
	[Bool]   $Exists
	[String] $FullName
	[String] $Directory
	[String] $Name
	[String] $BaseName
	[String] $Extension
	[String] $PreviousFilePath
	[String] $GitPath
	[String] $GitDirectory
	[String] $PreviousGitPath
	[Decimal]$SimilarityPc

	[String]ToString(){ Return $this.GitPath }

}
