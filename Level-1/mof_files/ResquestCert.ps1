$CN = "vm-adca-sub"
$SAN = "vm-adca-sub.bojdomain.com"
$TemplateName = "DomainComputer"
$CAName = "vm-adca-sub"

Write-Verbose "Generating request inf file"
    $file = @"
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
"@
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
        $file += @"

[Extensions]
2.5.29.17 = "{text}"
"@

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
