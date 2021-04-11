class GitTag
{

		[String]   $RepoName
		[String]   $SHA1Hash
		[String]   $TagHash
		[String]   $TagName
		[String]   $TagFullName
		[String]   $TagType
		[String]   $TagSubject
		[String]   $TagBody
	[Nullable[DateTime]]$TagDate
		[String]   $TaggerName
		[String]   $TaggerEmail

	[String]ToString(){ Return $this.TagName }

}
