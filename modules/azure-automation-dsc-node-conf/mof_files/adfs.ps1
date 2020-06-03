Configuration ADFSInit
{ 
   param
    (
        [Parameter(Mandatory)]
        [string]$ADFSMachineName,
        
        [Parameter(Position=2,Mandatory=$true)]
        [PSCredential]$DomainCredential,
        
        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    )

    #Import the required DSC Resources
    Import-DscResource -Module xActiveDirectory, xPendingReboot, xComputerManagement
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($DomainCredential.UserName)", $DomainCredential.Password)

    Node localhost
    {
        LocalConfigurationManager            
        {            
          
            RebootNodeIfNeeded = $true            
        }

        xWaitForADDomain DscForestWait 
        { 
            DomainName = $Node.DomainName;
            DomainUserCredential= $DomainCreds
            RetryCount = $RetryCount 
            RetryIntervalSec = $RetryIntervalSec
        }
         
        xComputer JoinDomain
        {
            Name          = $ADFSMachineName 
            DomainName    = $Node.DomainName;
            Credential    = $DomainCreds  # Credential to join to domain
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }

        xPendingReboot Reboot1
        { 
            Name = "RebootServer"
            DependsOn = "[xComputer]JoinDomain"
        }

        WindowsFeature installADFS  #install ADFS
        {
            Ensure = "Present"
            Name   = "ADFS-Federation"
            DependsOn = "[xPendingReboot]Reboot1"
        }
    }
}

$config=@{
    AllNodes=@(
      @{
        NodeName="localhost";
        DomainName='bojdomain.com.au';
        PSDscAllowPlainTextPassword = $true
        PSDscAllowDomainUser = $true
      }
    )
  }
  
  $domainCred = Get-Credential

  ADFSInit -ConfigurationData $config -DomainCredential $domainCred -OutputPath C:\temp
