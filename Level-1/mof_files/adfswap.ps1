Configuration AdfsWapInit
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node localhost
    {
        LocalConfigurationManager            
        {            
            DebugMode = 'All'
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true
        }

	    WindowsFeature WebAppProxy
        {
            Ensure = "Present"
            Name = "Web-Application-Proxy"
        }

        WindowsFeature Tools 
        {
            Ensure = "Present"
            Name = "RSAT-RemoteAccess"
            IncludeAllSubFeature = $true
        }

        WindowsFeature MoreTools 
        {
            Ensure = "Present"
            Name = "RSAT-AD-PowerShell"
            IncludeAllSubFeature = $true
        }

        WindowsFeature Telnet
        {
            Ensure = "Present"
            Name = "Telnet-Client"
        }
    }
}

$config=@{
    AllNodes=@(
      @{
        
        NodeName="vm-adfswap"
        AdminUserName = 'bojadmin'
        DomainAdminPassword = "Password@1234"
        DomainName='bojdomain.com'
        DomainNetBiosName = 'bojdomain'
        PSDscAllowPlainTextPassword = $true
        PSDscAllowDomainUser = $true
    }
    )
  }


  ADFSInit -ConfigurationData $config -OutputPath "C:\repos\azuread_adfs_jwt_token\Level-1\mof_files\ADFSInit"
