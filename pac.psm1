function New-Control{

   Param(
     [Parameter(Mandatory = $TRUE)]
	 [String]
	 $Name,
	 [Parameter(Mandatory = $TRUE)]
	 [String]
	 $Namespace,
	 [Parameter(Mandatory = $TRUE)]
	 [String]
	 $ProjectType
   )
   
   $pacPath = Get-Location 
   $controlPath = "$pacPath/Controls/$Name"
   
    if (Test-Path $controlPath) {
		$confirmation = read-host "This folder already exists. Do you want to delete it ? [Y/N]"
		if ($confirmation -eq "Y") {
			rm $controlPath
		}
	}
	if (-NOT (Test-Path $controlPath)) {
	    New-Item -Path $controlPath -ItemType Directory
	}
	
	
	cd $controlPath
		
	$pacPath = "$pacPath\CLI\Microsoft.PowerApps.CLI.0.1.51\tools\pac.exe"
	$arguments = "pcf init --namespace $Namespace --name $Name --template $ProjectType"
	
    write-host $pacPath
	Start-Process -FilePath $pacPath -ArgumentList $arguments -Wait
	Start-Process -FilePath "npm" -ArgumentList "install"
	
	cd ../..
	
}

#New-Control -Name "Test" -Namespace "Test" -ProjectType "field"