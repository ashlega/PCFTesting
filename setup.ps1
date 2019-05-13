


function Get-NuGetPackages{

	$sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
	$targetNugetExe = ".\nuget.exe"
	Remove-Item .\Tools -Force -Recurse -ErrorAction Ignore
	Invoke-WebRequest $sourceNugetExe -OutFile $targetNugetExe
	Set-Alias nuget $targetNugetExe -Scope Global -Verbose

	##
	##Download Plugin Registration Tool
	##
	./nuget install Microsoft.CrmSdk.XrmTooling.PluginRegistrationTool -O .\Tools
	md .\Tools\PluginRegistration
	$prtFolder = Get-ChildItem ./Tools | Where-Object {$_.Name -match 'Microsoft.CrmSdk.XrmTooling.PluginRegistrationTool.'}
	move .\Tools\$prtFolder\tools\*.* .\Tools\PluginRegistration
	Remove-Item .\Tools\$prtFolder -Force -Recurse

	##
	##Download CoreTools
	##
	./nuget install  Microsoft.CrmSdk.CoreTools -O .\Tools
	md .\Tools\CoreTools
	$coreToolsFolder = Get-ChildItem ./Tools | Where-Object {$_.Name -match 'Microsoft.CrmSdk.CoreTools.'}
	move .\Tools\$coreToolsFolder\content\bin\coretools\*.* .\Tools\CoreTools
	Remove-Item .\Tools\$coreToolsFolder -Force -Recurse

	##
	##Download Configuration Migration
	##
	./nuget install  Microsoft.CrmSdk.XrmTooling.ConfigurationMigration.Wpf -O .\Tools
	md .\Tools\ConfigurationMigration
	$configMigFolder = Get-ChildItem ./Tools | Where-Object {$_.Name -match 'Microsoft.CrmSdk.XrmTooling.ConfigurationMigration.Wpf.'}
	move .\Tools\$configMigFolder\tools\*.* .\Tools\ConfigurationMigration
	Remove-Item .\Tools\$configMigFolder -Force -Recurse

	##
	##Download Package Deployer 
	##
	./nuget install  Microsoft.CrmSdk.XrmTooling.PackageDeployment.WPF -O .\Tools
	
	md .\Tools\PackageDeployment
	$pdFolder = Get-ChildItem ./Tools | Where-Object {$_.Name -match 'Microsoft.CrmSdk.XrmTooling.PackageDeployment.Wpf.'}
	move .\Tools\$pdFolder\tools\*.* .\Tools\PackageDeployment
	Remove-Item .\Tools\$pdFolder -Force -Recurse
	
	##
	##Download CLI 
	##
	./nuget install  Microsoft.PowerApps.CLI -O .\CLI
	##
	##Remove NuGet.exe
	##
	Remove-Item nuget.exe 
}


#The script below is an adaptation of the script you'll find in
#this repo: https://gist.github.com/noelmace/997a2e3d3ced0e1e6086066990036b16
function Get-Nodejs{
	write-host "`n  ## NODEJS INSTALLER ## `n"

	### CONFIGURATION

	# nodejs
	$version = "10.15.3-x64"
	$url = "https://nodejs.org/dist/v10.15.3/node-v$version.msi" 
	$cliUrl = "http://download.microsoft.com/download/D/B/E/DBE69906-B4DA-471C-8960-092AB955C681/powerapps-cli-0.1.51.msi"

	
	# activate / desactivate any install
	$install_node = $TRUE
	$install_cli = $TRUE
		
	write-host "`n----------------------------"
	write-host " system requirements checking  "
	write-host "----------------------------`n"

	### require administator rights

	if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
	   write-Warning "This setup needs admin permissions. Please run this file as admin."     
	   break
	}

	### nodejs version check

	if (Get-Command node -errorAction SilentlyContinue) {
		$current_version = (node -v)
	}
	 
	if ($current_version) {
		write-host "[NODE] nodejs $current_version already installed"
		$confirmation = read-host "Are you sure you want to replace this version ? [y/N]"
		if ($confirmation -ne "y") {
			$install_node = $FALSE
		}
	}

	write-host "`n"

	if ($install_node) {
		
		### download nodejs msi file
		# warning : if a node.msi file is already present in the current folder, this script will simply use it
			
		write-host "`n----------------------------"
		write-host "  nodejs msi file retrieving  "
		write-host "----------------------------`n"

		$filename = "node.msi"
		$node_msi = "$PSScriptRoot\$filename"
		
		$download_node = $TRUE

		if (Test-Path $node_msi) {
			$confirmation = read-host "Local $filename file detected. Do you want to use it ? [Y/n]"
			if ($confirmation -eq "n") {
				$download_node = $FALSE
			}
		}

		if ($download_node) {
			write-host "[NODE] downloading nodejs install"
			write-host "url : $url"
			$start_time = Get-Date
			$wc = New-Object System.Net.WebClient
			$wc.DownloadFile($url, $node_msi)
			write-Output "$filename downloaded"
			write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
		} else {
			write-host "using the existing node.msi file"
		}

		### nodejs install

		write-host "`n----------------------------"
		write-host " nodejs installation  "
		write-host "----------------------------`n"

		write-host "[NODE] running $node_msi"
		Start-Process $node_msi -Wait
		
		$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
		
	} else {
		write-host "Proceeding with the previously installed nodejs version ..."
	}

    
	Start-Process -FilePath "npm" -ArgumentList "config set registry http://registry.npmjs.org/"
	
	
	if ($node_msi -and (Test-Path $node_msi)) {
		rm $node_msi
	}
}

Get-NuGetPackages
Get-Nodejs
