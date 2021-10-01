class GitConfigFile
{

	[String]            $Scope
	[String]            $Path
	[Boolean]           $Exists
	[System.IO.FileInfo]$FileInfo

	[String]ToString(){ return $this.FileInfo.FullName }

}
