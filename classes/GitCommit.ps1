class GitCommit
{

	[String]  $RepoName
	[String]  $SHA1Hash
	[String]  $TreeHash
	[String[]]$ParentHashes
	[Bool]    $IsMerge
	[DateTime]$AuthorDate
	[String]  $AuthorName
	[String]  $AuthorEmail
	[DateTime]$CommitterDate
	[String]  $CommitterName
	[String]  $CommitterEmail
	[String[]]$RefNames
	[String]  $Subject
	[String]  $Body

	[String]ToString(){ Return ("{0}|{1}|{2}|{3}" -f $this.SHA1Hash, $this.AuthorDate.ToString('yyyy-MM-dd HH:mm:ss'), $this.AuthorName, $this.Subject) }

}
