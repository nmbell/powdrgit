# Set the location of the root folder
$rootFolder = 'C:\PowdrgitExamples'
$tempFolder = $Env:TEMP

If (!(Test-Path -Path $rootFolder))
{
	# Create the root folder if necessary
	New-Item -Path $rootFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null

	# Create a non-git folder
	New-Item -Path "$rootFolder\NotAGitRepo"-ItemType Directory -Force -ErrorAction Stop | Out-Null

	# Create the git repositories
	$startLocation = $PWD.Path # store our current location

	git init "$tempFolder\MyToolbox_FakeRemote" --initial-branch=main 2>&1 | Out-Null
	Set-Location -Path "$tempFolder\MyToolbox_FakeRemote"
	git commit -m "Initial commit" --allow-empty 2>&1 | Out-Null
	git checkout -b feature1 2>&1 | Out-Null
	git commit -m "feature1 commit" --allow-empty 2>&1 | Out-Null
	git checkout -b release 2>&1 | Out-Null
	git commit -m "release commit" --allow-empty 2>&1 | Out-Null
	git checkout main 2>&1 | Out-Null

	git clone "$tempFolder\MyToolbox_FakeRemote" "$rootFolder\MyToolbox" 2>&1 | Out-Null
	Set-Location -Path "$rootFolder\MyToolbox"
	git checkout feature1 2>&1 | Out-Null
	git branch feature1 --set-upstream-to="remotes/origin/feature1" 2>&1 | Out-Null
	New-Item -Path "$rootFolder\MyToolbox\feature1_File1.txt" -ItemType File | Out-Null
	git add . 2>&1 | Out-Null
	git commit -m "Add feature1_File1.txt" 2>&1 | Out-Null
	git tag lightweightTag 2>&1 | Out-Null
	git checkout release 2>&1 | Out-Null
	git branch release --set-upstream-to="remotes/origin/release" 2>&1 | Out-Null
	git tag -a annotatedTag -m "This is an annotated tag" 2>&1 | Out-Null
	git checkout main 2>&1 | Out-Null
	git branch main --set-upstream-to="remotes/origin/main" 2>&1 | Out-Null
	git merge feature1 -m "Merging from feature1" --no-ff 2>&1 | Out-Null

	Set-Location -Path "$tempFolder\MyToolbox_FakeRemote"
	git checkout -b feature2 2>&1 | Out-Null
	git checkout main 2>&1 | Out-Null
	Set-Location -Path "$rootFolder\MyToolbox"
	git fetch 2>&1 | Out-Null

	Set-Location -Path "$rootFolder\MyToolbox"
	git checkout main 2>&1 | Out-Null
	git checkout -b feature3 2>&1 | Out-Null
	New-Item -Path "$rootFolder\MyToolbox\feature3_FileA.txt" -ItemType File | Out-Null
	git add . 2>&1 | Out-Null
	git commit -m "Add feature3_FileA.txt" 2>&1 | Out-Null
	git checkout main 2>&1 | Out-Null

	git init "$rootFolder\Project1" 2>&1 --initial-branch=main | Out-Null
	Set-Location -Path "$rootFolder\Project1"
	git commit -m "Initial commit" --allow-empty 2>&1 | Out-Null
	git checkout -b newfeature 2>&1 | Out-Null
	git tag lightweightTag 2>&1 | Out-Null

	Set-Location -Path $startLocation # move back to our original location
}

<# # Clean up
Remove-Item -Path $rootFolder -Recurse -Force
Remove-Item -Path "$tempFolder\MyToolbox_FakeRemote" -Recurse -Force
#>
