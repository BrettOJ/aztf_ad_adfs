$ConfigContext = ([ADSI]"LDAP://RootDSE").ConfigurationNamingContext
$ADSI = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext"

#Create the certificate 
$NewCert = $ADSI.Create("pKICertificateTemplate", "CN=ADFS")
$NewCert.put("distinguishedName","CN=ADFS,CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext")

# Add Certificate attributes that are required 
$NewCert.put("flags","131680")
$NewCert.put("displayName","System Health Authentication6")
$NewCert.put("revision","100")
$NewCert.put("pKIDefaultKeySpec","1")
$NewCert.put("pKIMaxIssuingDepth","0")
$NewCert.put("pKICriticalExtensions","2.5.29.15")
$NewCert.put("pKIExtendedKeyUsage","1.3.6.1.4.1.311.47.1.1, 1.3.6.1.5.5.7.3.2")
$NewCert.put("pKIDefaultCSPs","1,Microsoft RSA SChannel Cryptographic Provider")
$NewCert.put("msPKI-RA-Signature","0")
$NewCert.put("msPKI-Enrollment-Flag","32")
$NewCert.put("msPKI-Private-Key-Flag","67371264")
$NewCert.put("msPKI-Certificate-Name-Flag","134217728")
$NewCert.put("msPKI-Minimal-Key-Size","2048")
$NewCert.put("msPKI-Template-Schema-Version","4")
$NewCert.put("msPKI-Template-Minor-Revision","0")
$NewCert.put("msPKI-Cert-Template-OID","1.3.6.1.4.1.311.21.8.7638725.13898300.1985460.3383425.7519116.119.16408497.1716 293")
$NewCert.put("msPKI-Certificate-Application-Policy","1.3.6.1.4.1.311.47.1.1, 1.3.6.1.5.5.7.3.2")

#Finally Set the certificate 
$NewCert.SetInfo()

