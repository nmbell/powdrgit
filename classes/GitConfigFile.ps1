class GitConfigFile
{

	[String]            $Scope
	[System.IO.FileInfo]$ConfigFile

	[String]ToString(){ Return $this.ConfigFile.FullName }

}
