
Configuration CASubInit {

    Import-DscResource -Module xActiveDirectory, xPendingReboot, xComputerManagement, xAdcsDeployment, xPSDesiredStateConfiguration
    Import-DscResource -ModuleName PSDesiredStateConfiguration

Node $AllNodes.NodeName {
    # Assemble the Local Admin Credentials
    If ($Node.LocalAdminPassword) {
        [PSCredential]$LocalAdminCredential = New-Object System.Management.Automation.PSCredential ("bojadmin", (ConvertTo-SecureString $Node.LocalAdminPassword -AsPlainText -Force))
    }
    If ($Node.DomainAdminPassword) {
        [PSCredential]$DomainAdminCredential = New-Object System.Management.Automation.PSCredential ("$($Node.DomainNetBiosName)\bojadmin", (ConvertTo-SecureString $Node.DomainAdminPassword -AsPlainText -Force))
    }
# Install the RSAT PowerShell Module which is required by the xWaitForResource
WindowsFeature RSATADPowerShell
{ 
    Ensure = "Present"
    Name = "RSAT-AD-PowerShell"
} 
#Install  Management Tools
WindowsFeature WebMgmtConsole  
{
    Ensure = 'Present'
    Name = 'Web-Mgmt-Console'
}
WindowsFeature AdcsManagement  
{
    Ensure = 'Present'
    Name = 'RSAT-ADCS-Mgmt'
}

WindowsFeature ACdcsORTools  
{
    Ensure = 'Present'
    Name = 'RSAT-Online-Responder'
}

# Install the CA Service
WindowsFeature ADCSCA {
    Name = 'ADCS-Cert-Authority'
    Ensure = 'Present'
    DependsOn = "[WindowsFeature]RSATADPowerShell"
}
 
# Install the Web Enrollment Service
WindowsFeature WebEnrollmentCA {
    Name = 'ADCS-Web-Enrollment'
    Ensure = 'Present'
    DependsOn = "[WindowsFeature]ADCSCA"
}
 
# Install the Online Responder Service
WindowsFeature OnlineResponderCA {
    Name = 'ADCS-Online-Cert'
    Ensure = 'Present'
    DependsOn = "[WindowsFeature]WebEnrollmentCA"
}


# Wait for the Domain to be available so we can join it.
xWaitForADDomain DscDomainWait
{
    DomainName = $Node.DomainName
    DomainUserCredential = $DomainAdminCredential
    RetryCount = 60 
    RetryIntervalSec = 30 
    DependsOn = "[WindowsFeature]OnlineResponderCA"
}
 
# Join this Server to the Domain so that it can be an Enterprise CA.
xComputer JoinDomain 
{ 
    Name          = $Node.NodeName
    DomainName    = $Node.DomainName
    Credential    = $DomainAdminCredential
    JoinOU = $Node.DomainOUName
    DependsOn = "[xWaitForADDomain]DscDomainWait"
} 

# Create the CAPolicy.inf file that sets basic parameters for certificate issuance for this CA.
File CAPolicy
{
    Ensure = 'Present'
    DestinationPath = 'C:\Windows\CAPolicy.inf'
    Contents = "[Version]`r`n Signature= `"$Windows NT$`"`r`n[Certsrv_Server]`r`n RenewalKeyLength=2048`r`n RenewalValidityPeriod=Years`r`n RenewalValidityPeriodUnits=10`r`n LoadDefaultTemplates=1`r`n AlternateSignatureAlgorithm=1`r`n"
    Type = 'File'
    DependsOn = '[xComputer]JoinDomain'
}

# Make a CertEnroll folder to put the Root CA certificate into.
# The CA Web Enrollment server would also create this but we need it now.
File CertEnrollFolder
{
    Ensure = 'Present'
    DestinationPath = 'C:\Windows\System32\CertSrv\CertEnroll'
    Type = 'Directory'
    DependsOn = '[File]CAPolicy'
}

# Wait for the RootCA Web Enrollment to complete so we can grab the Root CA certificate
# file.
WaitForAny RootCA
{
    ResourceName = '[xADCSWebEnrollment]ConfigWebEnrollment'
    NodeName = $Node.RootCAName
    RetryIntervalSec = 30
    RetryCount = 60
    DependsOn = "[File]CertEnrollFolder"
}
 
# Download the Root CA certificate file.
xRemoteFile DownloadRootCACRTFile
{
    DestinationPath = "C:\Windows\System32\CertSrv\CertEnroll\$($Node.RootCAName)_$($Node.RootCACommonName).crt"
    Uri = "http://$($Node.RootCAName)/CertEnroll/$($Node.RootCAName)_$($Node.RootCACommonName).crt"
    DependsOn = '[WaitForAny]RootCA'
}
 
# Download the Root CA certificate revocation list.
xRemoteFile DownloadRootCACRLFile
{
    DestinationPath = "C:\Windows\System32\CertSrv\CertEnroll\$($Node.RootCACommonName).crl"
    Uri = "http://$($Node.RootCAName)/CertEnroll/$($Node.RootCACommonName).crl"
    DependsOn = '[xRemoteFile]DownloadRootCACRTFile'
}
# Install the Root CA Certificate to the LocalMachine Root Store
Script InstallRootCACert
{
    PSDSCRunAsCredential = $DomainAdminCredential
    SetScript = {
        Write-Verbose "Registering the Root CA Certificate C:\Windows\System32\CertSrv\CertEnroll\$($Using:Node.RootCAName)_$($Using:Node.RootCACommonName).crt in DS..."
       & "$($ENV:SystemRoot)\system32\certutil.exe" -f -dspublish "C:\Windows\System32\CertSrv\CertEnroll\$($Using:Node.RootCAName)_$($Using:Node.RootCACommonName).crt" RootCA
        Write-Verbose "Registering the Root CA CRL C:\Windows\System32\CertSrv\CertEnroll\$($Node.RootCACommonName).crl in DS..."
       & "$($ENV:SystemRoot)\system32\certutil.exe" -f -dspublish "C:\Windows\System32\CertSrv\CertEnroll\$($Node.RootCACommonName).crl" "$($Using:Node.RootCAName)"
        Write-Verbose "Installing the Root CA Certificate C:\Windows\System32\CertSrv\CertEnroll\$($Using:Node.RootCAName)_$($Using:Node.RootCACommonName).crt..."
       & "$($ENV:SystemRoot)\system32\certutil.exe" -addstore -f root "C:\Windows\System32\CertSrv\CertEnroll\$($Using:Node.RootCAName)_$($Using:Node.RootCACommonName).crt"
        Write-Verbose "Installing the Root CA CRL C:\Windows\System32\CertSrv\CertEnroll\$($Node.RootCACommonName).crl..."
       & "$($ENV:SystemRoot)\system32\certutil.exe" -addstore -f root "C:\Windows\System32\CertSrv\CertEnroll\$($Node.RootCACommonName).crl"
    }
    GetScript = {
        Return @{
            Installed = ((Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object -FilterScript { ($_.Subject -Like "CN=$($Using:Node.RootCACommonName),*") -and ($_.Issuer -Like "CN=$($Using:Node.RootCACommonName),*") } ).Count -EQ 0)
        }
    }
    TestScript = { 
        If ((Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object -FilterScript { ($_.Subject -Like "CN=$($Using:Node.RootCACommonName),*") -and ($_.Issuer -Like "CN=$($Using:Node.RootCACommonName),*") } ).Count -EQ 0) {
            Write-Verbose "Root CA Certificate Needs to be installed..."
            Return $False
        }
        Return $True
    }
    DependsOn = '[xRemoteFile]DownloadRootCACRTFile'
}

File IISPubFolder
{
    Ensure = 'Present'
    DestinationPath = 'C:\inetpub\wwwRoot\CertEnroll'
    Type = 'Directory'
    DependsOn = '[Script]InstallRootCACert'
}


# Configure the Subordinate CA which will create the Certificate request file that Root CA will use
# to issue a certificate for this Subordinate CA.
Script ConfigCA
{
    SetScript = {
        If (-not (Test-Path -Path "C:\Windows\System32\CertSrv\CertEnroll\$($Using:Node.NodeName).req")) {
        $CACommonName = $Using:Node.CACommonName
        $CADistinguishedNameSuffix = $Using:Node.CADistinguishedNameSuffix
        $OutputCertRequestFile = "c:\inetpub\wwwRoot\CertEnroll\$($Using:Node.NodeName).req"
        
        #INstall the CA and generate the certificate request to be issued be the root CA
        Install-ADcsCertificationAuthority -CACommonName $CACommonName -CADistinguishedNameSuffix $CADistinguishedNameSuffix -CAType EnterpriseSubordinateCA -OutputCertRequestFile $OutputCertRequestFile
        }
    }
    GetScript = {
        Return @{
            'Generated' = (Test-Path -Path "C:\Windows\System32\CertSrv\CertEnroll\$($Using:Node.NodeName).req");
        }
    }
    TestScript = { 
        If (-not (Test-Path -Path "C:\Windows\System32\CertSrv\CertEnroll\$($Using:Node.NodeName).req")) {
            # SubCA Cert not created
            Return $False
        }
        # SubCA Cert created
        Return $True
    }
}


# Set the IIS Mime Type to allow the REQ request to be downloaded by the Root CA
Script SetREQMimeType
{
    SetScript = {
        Add-WebConfigurationProperty -PSPath IIS:\ -Filter //staticContent -Name "." -Value @{fileExtension='.req';mimeType='application/pkcs10'}
    }
    GetScript = {
        Return @{
            'MimeType' = ((Get-WebConfigurationProperty -Filter "//staticContent/mimeMap[@fileExtension='.req']" -PSPath IIS:\ -Name *).mimeType);
        }
    }
    TestScript = { 
        If (-not (Get-WebConfigurationProperty -Filter "//staticContent/mimeMap[@fileExtension='.req']" -PSPath IIS:\ -Name *)) {
            # Mime type is not set
            Return $False
        }
        # Mime Type is set
        Return $True
    }
    DependsOn = '[Script]InstallRootCACert'
}

# Wait for the Root CA to have completed issuance of the certificate for this SubCA.
WaitForAny SubCACer
{
    ResourceName = "[Script]IssueCert_$($Node.NodeName)"
    NodeName = $Node.RootCAName
    RetryIntervalSec = 30
    RetryCount = 240
    DependsOn = "[Script]SetREQMimeType"
}
 
# Download the Certificate for this SubCA.
xRemoteFile DownloadSubCACERFile
{
    DestinationPath = "C:\Windows\System32\CertSrv\CertEnroll\$($Node.NodeName).cer"
    Uri = "http://$($Node.RootCAName)/CertEnroll/$($Node.NodeName).crt"
    DependsOn = '[WaitForAny]SubCACer'

}

# Configure the Web Enrollment Feature
xAdcsWebEnrollment ConfigWebEnrollment {
    Ensure = 'Present'
    #CAConfig = 'ConfigWebEnrollment'
    Credential = $LocalAdminCredential
    IsSingleInstance = 'yes'
    DependsOn = '[xRemoteFile]DownloadSubCACERFile'
    
}
xAdcsOnlineResponder OnlineResponder
{
    Ensure           = 'Present'
    IsSingleInstance = 'Yes'
    Credential       = $LocalAdminCredential
    DependsOn = '[xAdcsWebEnrollment]ConfigWebEnrollment'
}
# Register the Sub CA Certificate with the Certification Authority
Script RegisterSubCA
{
    PSDSCRunAsCredential = $DomainAdminCredential
    SetScript = {
        If (-not (Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('CACertHash')) {
        Write-Verbose "Registering the Sub CA Certificate with the Certification Authority C:\Windows\System32\CertSrv\CertEnroll\$($Node.NodeName).crt..."
        & "$($ENV:SystemRoot)\system32\certutil.exe" -installCert "C:\Windows\System32\CertSrv\CertEnroll\$($Using:Node.NodeName).cer"
        }
    }
    GetScript = {
        Return @{
        }
    }
    TestScript = { 
        If (-not (Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('CACertHash')) {
            Write-Verbose "Sub CA Certificate needs to be registered with the Certification Authority..."
            Return $False
        }
        Return $True
    }
    DependsOn = '[xAdcsOnlineResponder]OnlineResponder'
}

# Perform final configuration of the CA which will cause the CA service to startup
# It should be able to start up once the SubCA certificate has been installed.
Script ADCSAdvConfig
{
    PSDSCRunAsCredential = $DomainAdminCredential
    SetScript = {
        If ($Using:Node.CADistinguishedNameSuffix) {
           & "$($ENV:SystemRoot)\system32\certutil.exe" -setreg CA\DSConfigDN "CN=Configuration,$($Using:Node.CADistinguishedNameSuffix)"
           & "$($ENV:SystemRoot)\system32\certutil.exe" -setreg CA\DSDomainDN "$($Using:Node.CADistinguishedNameSuffix)"
        }
        If ($Using:Node.CRLPublicationURLs) {
          &  "$($ENV:SystemRoot)\System32\certutil.exe" -setreg CA\CRLPublicationURLs $($Using:Node.CRLPublicationURLs)
        }
        If ($Using:Node.CACertPublicationURLs) {
           & "$($ENV:SystemRoot)\System32\certutil.exe" -setreg CA\CACertPublicationURLs $($Using:Node.CACertPublicationURLs)
        }
        & "$($ENV:SystemRoot)\System32\certutil.exe" -installdefaulttemplates -dc $($Using:Node.DomainController)
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
        If (($Using:Node.CRLPublicationURLs) -and ((Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('CRLPublicationURLs') -ne $Using:Node.CRLPublicationURLs)) {
            Return $False
        }
        If (($Using:Node.CACertPublicationURLs) -and ((Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('CACertPublicationURLs') -ne $Using:Node.CACertPublicationURLs)) {
            Return $False
        }
        Return $True
    }
    DependsOn = '[Script]RegisterSubCA'
}
xPendingReboot AfterADCSAdvConfig
{
    Name      = 'FinalReboot'
    DependsOn = '[Script]ADCSAdvConfig'
}

#Create the ADFS Certificate Template on the Subordinate CA
Script CreateADFSCert 
{
    PSDSCRunAsCredential = $DomainAdminCredential
    SetScript = {
     
    
        $ConfigContext = ([ADSI]"LDAP://RootDSE").ConfigurationNamingContext 
        $ADSI = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext" 

        $NewCert = $ADSI.Create("pKICertificateTemplate", "CN=deploy-WebServer") 
        $NewCert.put("distinguishedName","CN=deploy-WebServer,CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext") 
        # and put other atributes that you need 

        $NewCert.put("flags","131649")
        $NewCert.put("displayName","deploy-WebServer")
        $NewCert.put("revision","100")
        $NewCert.put("pKIDefaultKeySpec","1")
        $NewCert.SetInfo()

        $NewCert.put("pKIMaxIssuingDepth","0")
        $NewCert.put("pKICriticalExtensions","2.5.29.15")
        $NewCert.put("pKIExtendedKeyUsage","1.3.6.1.5.5.7.3.1")
        $NewCert.put("pKIDefaultCSPs","1,Microsoft RSA SChannel Cryptographic Provider")
        $NewCert.put("msPKI-RA-Signature","0")
        $NewCert.put("msPKI-Enrollment-Flag","8")
        $NewCert.put("msPKI-Private-Key-Flag","16842768")
        $NewCert.put("msPKI-Certificate-Name-Flag","1")
        $NewCert.put("msPKI-Minimal-Key-Size","2048")
        $NewCert.put("msPKI-Template-Schema-Version","2")
        $NewCert.put("msPKI-Template-Minor-Revision","2")
        $NewCert.put("msPKI-Cert-Template-OID","1.3.6.1.4.1.311.21.8.7183632.6046387.16009101.13536898.4471759.164.5869043.12046343")
        $NewCert.put("msPKI-Certificate-Application-Policy","1.3.6.1.5.5.7.3.1")

        $NewCert.SetInfo()

        $WATempl = $ADSI.psbase.children | Where-Object {$_.displayName -match "Subordinate Certification Authority"}

        #before
        $NewCert.pKIExpirationPeriod = $WATempl.pKIExpirationPeriod
        $NewCert.pKIOverlapPeriod = $WATempl.pKIOverlapPeriod
        $NewCert.SetInfo()

        $WATempl2 = $ADSI.psbase.children | Where-Object  {$_.displayName -match "Web Server"}

        $NewCert.pKIKeyUsage = $WATempl2.pKIKeyUsage
        $NewCert.SetInfo()

    }
    GetScript = {
            $ConfigContext = ([ADSI]"LDAP://RootDSE").ConfigurationNamingContext
            $ADSI = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext"
        Return @{
           
            'CertExists' = $ADSI.psbase.children | Where-Object {$_.displayName -match "ADFS"}
        }
    }
    TestScript = { 
        $ConfigContext = ([ADSI]"LDAP://RootDSE").ConfigurationNamingContext
        $ADSI = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext"
        $certexist = $ADSI.psbase.children | Where-Object {$_.displayName -match "ADFS"}

        if ($certexist) {
            Return $True
        }
        Return $False

    }
    DependsOn = '[xPendingReboot]AfterADCSAdvConfig'
}

Script RequestWebCert 
{
    PSDSCRunAsCredential = $DomainAdminCredential
SetScript = {
$CN = "vm-adca-sub"
$SAN = "vm-adca-sub.bojdomain.com"
$TemplateName = "DomainComputer"
$CAName = "vm-adca-sub"

Write-Verbose "Generating request inf file"
    $file = @'

[NewRequest]
Subject = "CN=$CN,DC=BOJDOMAIN,DC=COM"
MachineKeySet = TRUE
KeyLength = 2048
KeySpec=1
Exportable = TRUE
RequestType = PKCS10
ProviderName = "Microsoft Enhanced Cryptographic Provider v1.0"
[RequestAttributes]
CertificateTemplate = "$TemplateName"
'@
    #check if SAN certificate is requested
    if ($PSBoundParameters.ContainsKey('SAN')) {
        #each SAN must be a array element
        #if the array has ony one element then split it on the commas.
        if (($SAN).count -eq 1) {
            $SAN = @($SAN -split ',')
            Write-Verbose "Requesting SAN certificate with subject $CN and SAN: $($SAN -join ',')" #ForegroundColor Green
            Write-Verbose "Parameter values: CN = $CN, TemplateName = $TemplateName, CAName = $CAName, SAN = $($SAN -join ' ')"
        }
        Write-Verbose "A value for the SAN is specified. Requesting a SAN certificate."
        Write-Verbose "Add Extension for SAN to the inf file..."
        $file += @'
[Extensions]
2.5.29.17 = "{text}"
'@

foreach ($an in $SAN) {
            $file += "_continue_ = `"$($an)&`"`n"
        }
    }
    try    {
        #create temp files
        $inf = [System.IO.Path]::GetTempFileName()
        $req = [System.IO.Path]::GetTempFileName()
        $cer = Join-Path -Path $env:TEMP -ChildPath "$CN.cer"
        
        #create new request inf file
        Set-Content -Path $inf -Value $file

        #show inf file if -verbose is used
        Get-Content -Path $inf | Write-Verbose

        Invoke-Expression -Command "certreq -new `"$inf`" `"$req`""
        if (!($LastExitCode -eq 0)) {
            throw "certreq -new command failed"
        }

        if (!$PSBoundParameters.ContainsKey('CAName')) {
            $rootDSE = [System.DirectoryServices.DirectoryEntry]'LDAP://RootDSE'
            $searchBase = [System.DirectoryServices.DirectoryEntry]"LDAP://$($rootDSE.configurationNamingContext)"
            $CAs = [System.DirectoryServices.DirectorySearcher]::new($searchBase,'objectClass=pKIEnrollmentService').FindAll()

            if($CAs.Count -eq 1){
                $CAName = "$($CAs[0].Properties.dnshostname)\$($CAs[0].Properties.cn)"
            }
            else {
                $CAName = ""
            }
        }

        if (!$CAName -eq "") {
            $CAName = " -config `"$CAName`""
        }
        #Submit Certificate request
        Write-Verbose "certreq -submit$CAName `"$req`" `"$cer`""
        Invoke-Expression -Command "certreq -submit $CAName `"$req`" `"$cer`""

        Write-Verbose "request was successful. Result was saved to `"$cer`""
        
        #retrieve and install the certificate
        write-verbose "retrieve and install the certificate"
        Invoke-Expression -Command "certreq -accept `"$cer`""
    }
    catch {
        #show error message (non terminating error so that the rest of the pipeline input get processed)
        Write-Error $_
    }

}
    GetScript = {

        Return @{
            'CertExists' = Get-ChildItem -Path Cert:\localMachine\My | Test-Certificate -Policy SSL -DNSName "dns=bojdomain.com"
        }
    }
    TestScript = { 
        $certexist = Get-ChildItem -Path Cert:\localMachine\My | Test-Certificate -Policy SSL -DNSName "dns=bojdomain.com"

        if ($certexist) {
            Return $True
        }
        Return $False
    }
    DependsOn = '[Script]CreateADFSCert'    
    }   
    }
}       

$config=@{
    AllNodes=@(
      @{
        NodeName = 'vm-adca-sub'
        #Thumbprint = '8F43288AD272F3103B6FB1428485EA3014C0BCFE'
        AdminUserName = 'bojadmin'
        LocalAdminPassword = 'Password@1234'
        DomainName = "BOJDOMAIN.COM"
        DomainNetBiosName = 'bojdomain'
        DomainAdminPassword = "Password@1234"
        PSDscAllowDomainUser = $True
        CACommonName = "BOJDOMAIN.COM Issuing-CA"
        CADistinguishedNameSuffix = "DC=BOJDOMAIN,DC=COM"
        CRLPublicationURLs = "65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl\n79:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10\n6:http://pki.bojdomain.com/CertEnroll/%3%8%9.crl"
        CACertPublicationURLs = "1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt\n2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11\n2:http://pki.bojdomain.com/CertEnroll/%1_%3%4.crt"
        RootCAName = "vm-adca-root"
        RootCACRTName = "vm-adca-root_BOJDOMAIN.COM Root-CA.crt"
        RootCACommonName = "BOJDOMAIN.COM Root-CA"
        PSDscAllowPlainTextPassword = $true
        DomainController = "vm-adds.bojdomain.com"
        DomainOUName = "OU=servers,DC=bojdomain,DC=com"
    
      }
    )
  }

  CAsubInit -ConfigurationData $config -OutputPath "C:\repos\azuread_adfs_jwt_token\Level-1\mof_files\CASubInit"

