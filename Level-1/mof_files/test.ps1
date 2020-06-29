
$temp = ([ADSI]"LDAP://RootDSE".ConfigurationNamingContext)
$ADSI = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services, CN=Services,$config"

$temp = $ADSI.Create("pKICertificateTemplate","CN=Web Server 2008-2")
$temp.put("distinguishedName","CN=Web Server 2008-2,CM=Certificate Template,CN=Public Key Services,CN=Services.$Config)

$temp.SetInfo()





swapped the order of enter the attributes:

$ConfigContext = ([ADSI]"LDAP://RootDSE").ConfigurationNamingContext 
$ADSI = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext" 

$NewTempl = $ADSI.Create("pKICertificateTemplate", "CN=SystemHealthAuthentication6") 
$NewTempl.put("distinguishedName","CN=SystemHealthAuthentication6,CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext") 
# and put other atributes that you need 

$NewTempl.put("flags","131680")
$NewTempl.put("displayName","System Health Authentication6")
$NewTempl.put("revision","100")
$NewTempl.put("pKIDefaultKeySpec","1")
$NewTempl.SetInfo()

$NewTempl.put("pKIMaxIssuingDepth","0")
$NewTempl.put("pKICriticalExtensions","2.5.29.15")
$NewTempl.put("pKIExtendedKeyUsage","1.3.6.1.4.1.311.47.1.1, 1.3.6.1.5.5.7.3.2")
$NewTempl.put("pKIDefaultCSPs","1,Microsoft RSA SChannel Cryptographic Provider")
$NewTempl.put("msPKI-RA-Signature","0")
$NewTempl.put("msPKI-Enrollment-Flag","32")
$NewTempl.put("msPKI-Private-Key-Flag","67371264")
$NewTempl.put("msPKI-Certificate-Name-Flag","134217728")
$NewTempl.put("msPKI-Minimal-Key-Size","2048")
$NewTempl.put("msPKI-Template-Schema-Version","4")
$NewTempl.put("msPKI-Template-Minor-Revision","0")
$NewTempl.put("msPKI-Cert-Template-OID","1.3.6.1.4.1.311.21.8.7638725.13898300.1985460.3383425.7519116.119.16408497.1716 293")
$NewTempl.put("msPKI-Certificate-Application-Policy","1.3.6.1.4.1.311.47.1.1, 1.3.6.1.5.5.7.3.2")

$NewTempl.SetInfo()

$WATempl = $ADSI.psbase.children | where {$_.displayName -match "Workstation Authentication"}

#before
$NewTempl.pKIKeyUsage = $WATempl.pKIKeyUsage
$NewTempl.pKIExpirationPeriod = $WATempl.pKIExpirationPeriod
$NewTempl.pKIOverlapPeriod = $WATempl.pKIOverlapPeriod
$NewTempl.SetInfo()

$NewTempl | select *






$DSConfigDN = (Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('DSConfigDN');
$DSDomainDN = (Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('DSDomainDN');
$CRLPublicationURLs  = (Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('CRLPublicationURLs');
$CACertPublicationURLs  = (Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration').GetValue('CACertPublicationURLs')

Write-Host $DSConfigDN
Write-Host $DSDomainDN
Write-Host $CRLPublicationURLs
Write-Host $CACertPublicationURLs

& $($ENV:SystemRoot)\system32\certutil.exe -installCert C:\Windows\System32\CertSrv\CertEnroll\vm-adca-sub.cer


Get-ChildItem 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration'.GetValue('CACertHash')




$CACommonName = "BOJDOMAIN.COM Issuing-CA"
$CADistinguishedNameSuffix = "DC=BOJDOMAIN,DC=COM"
$OutputCertRequestFile = "c:\inetpub\wwwRoot\CertEnroll\vm-adca-sub.req"


Install-ADcsCertificationAuthority -OverwriteExistingKey -AllowAdministratorInteraction -CACommonName $CACommonName -CADistinguishedNameSuffix $CADistinguishedNameSuffix -CAType EnterpriseSubordinateCA -OutputCertRequestFile $OutputCertRequestFile