Configuration ADFSInit
{ 
 
    #Import the required DSC Resources
    Import-DscResource -Module xActiveDirectory, xPendingReboot, xComputerManagement, CertificateDsc
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    Node $AllNodes.NodeName {

        # Assemble the Admin Credentials
        [PSCredential]$DomainAdminCredential = New-Object System.Management.Automation.PSCredential ("$($Node.DomainNetBiosName)\bojadmin", (ConvertTo-SecureString $Node.DomainAdminPassword -AsPlainText -Force))

        xWaitForADDomain DscForestWait 
        { 
            DomainName = $Node.DomainName;
            DomainUserCredential= $DomainAdminCredential
            RetryCount = 30 
            RetryIntervalSec = 60
        }
         
        xComputer JoinDomain
        {
            Name          = $Node.ADFSMachineName 
            DomainName    = $Node.DomainName;
            Credential    = $DomainAdminCredential 
            JoinOU = $Node.DomainOUName
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }

        xPendingReboot Reboot1
        { 
            Name = "RebootServer"
            DependsOn = "[xComputer]JoinDomain"
        }

        WindowsFeature installADFS 
        {
            Ensure = "Present"
            Name   = "ADFS-Federation"
            DependsOn = "[xPendingReboot]Reboot1"
        }

#Wait for all the CA's to be setup 
WaitForAny RootCA
{
    ResourceName = '[Script]ShutdownRootCA'
    NodeName = $Node.RootCAName
    RetryIntervalSec = 30
    RetryCount = 60
    DependsOn = "[WindowsFeature]installADFS"
}

#First Request the ADFS Certificate

      }
    }

$config=@{
    AllNodes=@(
      @{
        
        NodeName="vm-adfs"
        AdminUserName = 'bojadmin'
        DomainAdminPassword = "Password@1234"
        DomainName='bojdomain.com'
        DomainNetBiosName = 'bojdomain'
        PSDscAllowPlainTextPassword = $true
        PSDscAllowDomainUser = $true
        ADFSMachineName = 'vm-adfs'
        RootCAName = "vm-adca-root"
        DomainOUName = "OU=servers,DC=bojdomain,DC=com"
    }
    )
  }


  ADFSInit -ConfigurationData $config -OutputPath "C:\repos\azuread_adfs_jwt_token\Level-1\mof_files\ADFSInit"
