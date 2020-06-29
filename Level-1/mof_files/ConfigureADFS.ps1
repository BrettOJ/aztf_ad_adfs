#Next configure the ADFS Server
Script "ConfigureADFS"
    {
    SetScript = {
        Write-Verbose "Configuring ADFS on Server -  $($Using:Node.CACommonName)"
       
    }
    GetScript = {
        Return @{
            'Generated' = 
        }
    }
    TestScript = { 
        If (-not (Test-Path -Path "C:\Windows\System32\CertSrv\CertEnroll\$Using:SubCA.crt")) {
            # ADFS Not installed correctly
            Return $False
        }
        # ADFS Installed
        Return $True
    }
    DependsOn = "[WindowsFeature]installADFS"
}
