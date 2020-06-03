configuration DomainInit {
  Param(
    [Parameter(Position=0)]
    [String]$DomainMode='WinThreshold',

    [Parameter(Position=1)]
    [String]$ForestMode='WinThreshold',

    [Parameter(Position=2,Mandatory=$true)]
    [PSCredential]$DomainCredential,

    [Parameter(Position=3,Mandatory=$true)]
    [PSCredential]$SafemodePassword

 
  )
  
    #$SafemodePassword = Get-AzureAutomationCredential -AutomationAccountName "bojtest-aza-acc" -Name "DomainInstall"
   # $DomainCredential = Get-AzureAutomationCredential -AutomationAccountName "bojtest-aza-acc" -Name "DomainInstall"

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName NetworkingDsc
    
    Node ("localhost") {
        WindowsFeature ADDSFeatureInstall {
          Ensure = 'Present';
          Name = 'AD-Domain-Services';
        }
        $domainContainer="DC=$($Node.DomainName.Split('.') -join ',DC=')"
    
        xADDomain 'ADDomainInstall' {
          DomainName = $Node.DomainName;
          DomainNetbiosName = $Node.DomainName.Split('.')[0];
          ForestMode = $ForestMode;
          DomainMode = $DomainMode;
          DomainAdministratorCredential = $DomainCredential;
          SafemodeAdministratorPassword = $SafemodePassword;
          DependsOn = '[WindowsFeature]ADDSFeatureInstall';
        }
    
        xWaitForADDomain 'WaitForDomainInstall' {
          DomainName = $Node.DomainName;
          DomainUserCredential = $DomainCredential;
          RebootRetryCount = 2;
          RetryCount = 10;
          RetryIntervalSec = 60;
          DependsOn = '[xADDomain]ADDomainInstall';
        }
    
        xADOrganizationalUnit 'CreateAccountsOU' {
          Name = 'Accounts';
          Path = $DomainContainer;
          Ensure = 'Present';
          Credential = $DomainCredential;
          DependsOn = '[xWaitForADDomain]WaitForDomainInstall';
        }
    
        xADOrganizationalUnit 'AdminOU' {
          Name = 'Admin';
          Path = "OU=Accounts,$DomainContainer";
          Ensure = 'Present';
          Credential = $DomainCredential;
          DependsOn = '[xADOrganizationalUnit]CreateAccountsOU';
        }
        
        xADOrganizationalUnit 'BusinessOU' {
          Name = 'Business';
          Path = "OU=Accounts,$DomainContainer";
          Ensure = 'Present';
          Credential = $DomainCredential;
          DependsOn = '[xADOrganizationalUnit]CreateAccountsOU';
        }
    
        xADOrganizationalUnit 'ServiceOU' {
          Name = 'Service';
          Path = "OU=Accounts,$DomainContainer";
          Ensure = 'Present';
          Credential = $DomainCredential;
          DependsOn = '[xADOrganizationalUnit]CreateAccountsOU';
        }
    
        LocalConfigurationManager {
          RebootNodeIfNeeded = $true;
        }
      }
    }
    $config=@{
        AllNodes=@(
          @{
            NodeName="localhost";
            DomainName='bojdomain.com.au';
            PSDscAllowPlainTextPassword = $true
          }
        )
      }
      
      $domainCred = Get-Credential

      DomainInit -ConfigurationData $config -DomainCredential $domainCred -SafemodePassword $domainCred -OutputPath C:\temp
