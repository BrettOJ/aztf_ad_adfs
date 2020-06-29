Configuration aadcinit {



    Import-DscResource -ModuleName PSDesiredStateConfiguration, xComputerManagement
    
Node $AllNodes.NodeName {

    
   Script InstallAADConnect
{
    SetScript = {
        $AADConnectDLUrl="https://download.microsoft.com/download/B/0/0/B00291D0-5A83-4DE7-86F5-980BC00DE05A/AzureADConnect.msi"

        $exe="$env:SystemRoot\system32\msiexec.exe"

        $tempfile = [System.IO.Path]::GetTempFileName()
        $folder = [System.IO.Path]::GetDirectoryName($tempfile)

        $webclient = New-Object System.Net.WebClient
        $webclient.DownloadFile($AADConnectDLUrl, $tempfile)

        Rename-Item -Path $tempfile -NewName "AzureADConnect.msi"
        $MSIPath = $folder + "\AzureADConnect.msi"

        Invoke-Expression "& `"$exe`" /i $MSIPath /qn /passive /forcerestart"
    }

    GetScript =  { @{} }
    TestScript = { 
        return Test-Path "$env:TEMP\AzureADConnect.msi" 
    }
}
}
}
$config=@{
    AllNodes=@(
      @{
        NodeName="vm-aadc"
        DomainName='bojdomain.com'
        AdminUserName = 'bojadmin'
        DomainAdminPassword = "Password@1234"
        PSDscAllowPlainTextPassword = $true
      }
    )
  }

  aadcinit -ConfigurationData $config -OutputPath "C:\repos\azuread_adfs_jwt_token\Level-1\mof_files\AADCInit"
