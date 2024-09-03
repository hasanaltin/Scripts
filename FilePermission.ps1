$OutFile = "C:\NTFSPermissions.csv" #Output file location
$Header = "Folder Path,IdentityReference,AccessControlType,IsInherited,InheritanceFlags,PropagationFlags"
$FileExist = Test-Path $OutFile 
If ($FileExist -eq $True) {Del $OutFile} 
Add-Content -Value $Header -Path $OutFile 
$RootPath = "\\server\sharedfolder\" #share path
$Folders = dir $RootPath -recurse | where {$_.psiscontainer -eq $true} 
		foreach ($Folder in $Folders){
		$ACLs = get-acl $Folder.fullname | ForEach-Object { $_.Access  }
		Foreach ($ACL in $ACLs){
		$OutInfo = $Folder.Fullname + "," + $ACL.IdentityReference  + "," + $ACL.AccessControlType + "," + $ACL.IsInherited + "," + $ACL.InheritanceFlags + "," + $ACL.PropagationFlags
		Add-Content -Value $OutInfo -Path $OutFile 
}}
