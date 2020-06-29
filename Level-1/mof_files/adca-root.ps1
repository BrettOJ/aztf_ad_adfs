Configuration CArootInit {

    Import-DscResource -Module xAdcsDeployment
    Import-DscResource -Module xPSDesiredStateConfiguration
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

Node $AllNodes.NodeName {
    # Assemble the Local Admin Credentials
    If ($Node.LocalAdminPassword) {
        [PSCredential]$LocalAdminCredential = New-Object System.Management.Automation.PSCredential ($Node.AdminUserName, (ConvertTo-SecureString $Node.LocalAdminPassword -AsPlainText -Force))
    }
# Install the ADCS Certificate Authority
WindowsFeature ADCSCA {
    Name = 'ADCS-Cert-Authority'
    Ensure = 'Present'
}

# Install ADCS Web Enrollment - only required because it creates the CertEnroll virtual folder
# Which we use to pass certificates to the Issuing/Sub CAs       
WindowsFeature ADCSWebEnrollment
{
    Ensure = 'Present'
    Name = 'ADCS-Web-Enrollment'
    DependsOn = '[WindowsFeature]ADCSCA'
}

# Create the CAPolicy.inf file which defines basic properties about the ROOT CA certificate
File CAPolicy
{
    Ensure = 'Present'
    DestinationPath = 'C:\Windows\CAPolicy.inf'
    Contents = "[Version]`r`n Signature= `"$Windows NT$`"`r`n[Certsrv_Server]`r`n RenewalKeyLength=4096`r`n RenewalValidityPeriod=Years`r`n RenewalValidityPeriodUnits=20`r`n CRLDeltaPeriod=Days`r`n CRLDeltaPeriodUnits=0`r`n[CRLDistributionPoint]`r`n[AuthorityInformationAccess]`r`n"
    Type = 'File'
    DependsOn = '[WindowsFeature]ADCSWebEnrollment'
}

# Configure the CA as Standalone Root CA
xAdcsCertificationAuthority ConfigCA
{
    Ensure = 'Present'
    Credential = $LocalAdminCredential
    CAType = 'StandaloneRootCA'
    CACommonName = $Node.CACommonName
    CADistinguishedNameSuffix = $Node.CADistinguishedNameSuffix
    ValidityPeriod = 'Years'
    ValidityPeriodUnits = 20
    DependsOn = '[File]CAPolicy'

}
 
# Configure the ADCS Web Enrollment
xAdcsWebEnrollment ConfigWebEnrollment {
    Ensure = 'Present'
    #Name = 'ConfigWebEnrollment'
    Credential = $LocalAdminCredential
    IsSingleInstance = 'yes' 
    DependsOn = '[xAdcsCertificationAuthority]ConfigCA'

}
#Set the DNS Suffix on the adapter
Script SetDNSSuffix  
{
    SetScript = 
    {
        Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name SearchList -Value $($Using:Node.dnssuffix)
    }   
    TestScript = 
    {
        $currentSuffix = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name SearchList -ErrorAction SilentlyContinue).SearchList

        if ($currentSuffix -ne $($Using:Node.dnssuffix)){
            return $false
        }
        return $true
    }   
    GetScript = 
    {
        $currentSuffix = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name SearchList -ErrorAction SilentlyContinue).SearchList

        return $currentSuffix
    }     
}



# Set the advanced CA properties
Script ADCSAdvConfig
{
    SetScript = {
        If ($Node.CADistinguishedNameSuffix) {
            & "$($ENV:SystemRoot)\system32\certutil.exe" -setreg CA\DSConfigDN "CN=Configuration,$($Using:Node.CADistinguishedNameSuffix)"
            & "$($ENV:SystemRoot)\system32\certutil.exe" -setreg CA\DSDomainDN "$($Using:Node.CADistinguishedNameSuffix)"
        }
        If ($Node.CRLPublicationURLs) {
            & "$($ENV:SystemRoot)\System32\certutil.exe" -setreg CA\CRLPublicationURLs "$($Using:Node.CRLPublicationURLs)"
        }
        If ($Node.CACertPublicationURLs) {
            & "$($ENV:SystemRoot)\System32\certutil.exe" -setreg CA\CACertPublicationURLs "$($Using:Node.CACertPublicationURLs)"
        }
        Restart-Service -Name CertSvc
        Add-Content -Path 'c:\windows\setup\scripts\certutil.log' -Value "Certificate Service Restarted ..."
    }
    GetScript = {
        Return @{
            'DSConfigDN' = (Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('DSConfigDN');
            'DSDomainDN' = (Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('DSDomainDN');
            'CRLPublicationURLs'  = (Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('CRLPublicationURLs');
            'CACertPublicationURLs'  = (Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('CACertPublicationURLs')
        }
    }
    TestScript = { 
        If (((Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('DSConfigDN') -ne "CN=Configuration,$($Using:Node.CADistinguishedNameSuffix)")) {
            Return $False
        }
        If (((Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('DSDomainDN') -ne "$($Using:Node.CADistinguishedNameSuffix)")) {
            Return $False
        }
        If (($Node.CRLPublicationURLs) -and ((Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('CRLPublicationURLs') -ne "$($Using:Node.CRLPublicationURLs)")) {
            Return $False
        }
        If (($Node.CACertPublicationURLs) -and ((Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('CACertPublicationURLs') -ne "$($Using:Node.CACertPublicationURLs)")) {
            Return $False
        }
        Return $True
    }
    DependsOn = '[xAdcsWebEnrollment]ConfigWebEnrollment'
}


# Generate Issuing certificates for any SubCAs
Foreach ($SubCA in $Node.SubCAs) {

    # Wait for SubCA to generate REQ
WaitForAny "WaitForSubCA_$SubCA"
{  
    ResourceName = '[Script]InstallRootCACert'
    NodeName = $SubCA
    RetryIntervalSec = 30
    RetryCount = 60
    DependsOn = '[Script]ADCSAdvConfig'
}

# Wait for SubCA to add mime type to the Web enrollment
WaitForAny "WaitForScript_$SubCA"
{
    ResourceName = '[Script]SetREQMimeType'
    NodeName = $SubCA
    RetryIntervalSec = 30
    RetryCount = 120
    DependsOn = "[WaitForAny]WaitForSubCA_$SubCA"
}
  
# Download the REQ from the SubCA
xRemoteFile "DownloadSubCA_$SubCA"
{
    DestinationPath = "C:\Windows\System32\CertSrv\CertEnroll\$SubCA.req"
    Uri = "http://$SubCA.bojdomain.com/CertEnroll/$SubCA.req"
    DependsOn = "[WaitForAny]WaitForScript_$SubCA"
}

# Generate the Issuing Certificate from the REQ
Script "IssueCert_$SubCA"
{
    SetScript = {
        Write-Verbose "Submitting C:\Windows\System32\CertSrv\CertEnroll\$Using:SubCA.req to $($Using:Node.CACommonName)"
        [String]$RequestResult = & "$($ENV:SystemRoot)\System32\Certreq.exe" -Config ".\$($Using:Node.CACommonName)" -Submit "C:\Windows\System32\CertSrv\CertEnroll\$Using:SubCA.req"
        $Matches = [Regex]::Match($RequestResult, 'RequestId:\s([0-9]*)')
        If ($Matches.Groups.Count -lt 2) {
            Write-Verbose "Error getting Request ID from SubCA certificate submission."
            Throw "Error getting Request ID from SubCA certificate submission."
        }
        [int]$RequestId = $Matches.Groups[1].Value
        Write-Verbose "Issuing $RequestId in $($Using:Node.CACommonName)"
        [String]$SubmitResult = & "$($ENV:SystemRoot)\System32\CertUtil.exe" -Resubmit $RequestId
        If ($SubmitResult -notlike 'Certificate issued.*') {
            Write-Verbose "Unexpected result issuing SubCA request."
            Throw "Unexpected result issuing SubCA request."
        }
        Write-Verbose "Retrieving C:\Windows\System32\CertSrv\CertEnroll\$Using:SubCA.req from $($Using:Node.CACommonName)"
        [String]$RetrieveResult = & "$($ENV:SystemRoot)\System32\Certreq.exe" -Config ".\$($Using:Node.CACommonName)" -Retrieve $RequestId "C:\Windows\System32\CertSrv\CertEnroll\$Using:SubCA.crt"
    }
    GetScript = {
        Return @{
            'Generated' = (Test-Path -Path "C:\Windows\System32\CertSrv\CertEnroll\$Using:SubCA.crt");
        }
    }
    TestScript = { 
        If (-not (Test-Path -Path "C:\Windows\System32\CertSrv\CertEnroll\$Using:SubCA.crt")) {
            # SubCA Cert is not yet created
            Return $False
        }
        # SubCA Cert has been created
        Return $True
    }
    DependsOn = "[xRemoteFile]DownloadSubCA_$SubCA"
}

# Wait for SubCA to install the CA Certificate
WaitForAny "WaitForComplete_$SubCA"
{
    ResourceName = '[Script]RegisterSubCA'
    NodeName = $SubCA
    RetryIntervalSec = 30
    RetryCount = 120
    DependsOn = "[Script]IssueCert_$SubCA"
}
 
# Shutdown the Root CA - it is no longer needed because it has issued all SubCAs
Script ShutdownRootCA
        {
            SetScript = {
               # Stop-Computer
            }
            GetScript = {
                Return @{
                }
            }
            TestScript = { 
                # SubCA Cert is not yet created
                Return $False
            }
            DependsOn = "[WaitForAny]WaitForComplete_$SubCA"
        }
        }
    }
}
$config=@{
    AllNodes=@(
      @{
        NodeName = 'vm-adca-root'
        #Thumbprint = 'CDD4EEAE6000AC7F40C3802C171E30148030C072'
        AdminUserName = 'bojadmin'
        LocalAdminPassword = 'Password@1234'
        CACommonName = "BOJDOMAIN.COM Root-CA"
        CADistinguishedNameSuffix = "DC=BOJDOMAIN,DC=COM"
        CRLPublicationURLs = "1:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl\n10:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10\n2:http://pki.bojdomain.com/CertEnroll/%3%8%9.crl"
        CACertPublicationURLs = "1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt\n2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11\n2:http://pki.bojdomain.com/CertEnroll/%1_%3%4.crt"
        SubCAs = @('vm-adca-sub')
        PSDscAllowPlainTextPassword = $true
        dnssuffix = 'bojdomain.com'
      }
    )
  }


  CArootInit -ConfigurationData $config -OutputPath "C:\repos\azuread_adfs_jwt_token\Level-1\mof_files\CARootInit"



