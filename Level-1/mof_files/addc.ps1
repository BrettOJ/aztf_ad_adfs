configuration DomainInit {
  Param(
    [Parameter(Position=0)]
    [String]$DomainMode='WinThreshold',

    [Parameter(Position=1)]
    [String]$ForestMode='WinThreshold'

  )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory, xDnsServer
    Import-DscResource -ModuleName NetworkingDsc
    
    Node $AllNodes.NodeName {

      # Assemble the Admin Credentials
      [PSCredential]$DomainAdminCredential = New-Object System.Management.Automation.PSCredential ("$($Node.DomainNetBiosName)\bojadmin", (ConvertTo-SecureString $Node.DomainAdminPassword -AsPlainText -Force))
      [PSCredential]$SafeModePassword = New-Object System.Management.Automation.PSCredential ($Node.AdminUserName, (ConvertTo-SecureString $Node.DomainAdminPassword -AsPlainText -Force))

        WindowsFeature ADDSFeatureInstall {
          Ensure = 'Present';
          Name = 'AD-Domain-Services';
        }

        WindowsFeature adminTools {
          Ensure = 'Present';
          Name = "RSAT-ADDS"

        }

        $domainContainer="DC=$($Node.DomainName.Split('.') -join ',DC=')"
    
        xADDomain 'ADDomainInstall' {
          DomainName = $Node.DomainName;
          DomainNetbiosName = $Node.DomainName.Split('.')[0];
          ForestMode = $ForestMode;
          DomainMode = $DomainMode;
          DomainAdministratorCredential = $DomainAdminCredential;
          SafemodeAdministratorPassword = $SafeModePassword;
          DependsOn = '[WindowsFeature]ADDSFeatureInstall';
        }
    
        xWaitForADDomain 'WaitForDomainInstall' {
          DomainName = $Node.DomainName;
          DomainUserCredential = $DomainAdminCredential;
          RebootRetryCount = 2;
          RetryCount = 30;
          RetryIntervalSec = 30;
          DependsOn = '[xADDomain]ADDomainInstall';
        }

        xDnsRecord "pkiDns" {
          Name = 'pki';
          Zone = 'bojdomain.com';
          Target = '10.110.4.140';
          Type = 'ARecord';
          Ensure = 'Present';
          DependsOn = '[xWaitForADDomain]WaitForDomainInstall';
        }    

        xDnsRecord "vm-adca-root" {
          Name = 'vm-adca-root';
          Zone = 'bojdomain.com';
          Target = '10.110.4.138';
          Type = 'ARecord';
          Ensure = 'Present';
          DependsOn = '[xWaitForADDomain]WaitForDomainInstall';
        }    

        xADOrganizationalUnit 'CreateServersOU' {
          Name = 'Servers';
          Path = $DomainContainer;
          Ensure = 'Present';
          Credential = $DomainAdminCredential;
          DependsOn = '[xWaitForADDomain]WaitForDomainInstall';
        }
    
      
        LocalConfigurationManager {
          RebootNodeIfNeeded = $true;
        }
      }
    }
    $config=@{
        AllNodes=@(
          @{
            NodeName="vm-adds"
            DomainName='bojdomain.com'
            DomainNetBiosName = 'bojdomain'
            AdminUserName = 'bojadmin'
            DomainAdminPassword = "Password@1234"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
          }
        )
      }
      

      DomainInit -ConfigurationData $config -OutputPath "C:\repos\azuread_adfs_jwt_token\Level-1\mof_files\DomainInit"
