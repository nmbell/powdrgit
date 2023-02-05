class GitCommitDiffLine
{

	[String]$LineNumBefore
	[String]$LineNumAfter
	[String]$LineChange
	[String]$LineText

	[String]ToString(){ Return "$($this.LineChange)$($this.LineText)" }

}

class GitCommitDiffFile
{

	[String]             $Action
	[String]             $Path
	[String]             $PathNew
	[String]             $Similarity
	[String]             $New
	[String]             $Old
	[GitCommitDiffLine[]]$DiffLine

	[String]ToString(){ Return $this.Path }

}


class GitCommitDiff
{

	[String[]]           $Summary
	[GitCommitDiffFile[]]$File

	[String]ToString(){ Return $this.Summary }

}
