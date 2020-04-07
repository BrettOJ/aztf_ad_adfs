get-windowsfeature






install-windowsfeature AD-Domain-Services

Import-Module ADDSDeployment

Install-ADDSForest
-CreateDnsDelegation:$false
-DatabasePath “C:\Windows\NTDS”
-DomainMode “Win2012R2”
-DomainName “testdomain.com”
-DomainNetbiosName “TESTDC”
-ForestMode “Win2016”
-InstallDns:$true
-LogPath “C:\Windows\NTDS”
-NoRebootOnCompletion:$false
-SysvolPath “C:\Windows\SYSVOL”
-Force:$true

Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath “C:\Windows\NTDS” -DomainMode “WinThreshold” -DomainName “testdomain.com” -DomainNetbiosName “TESTDC” -ForestMode “WinThreshold” -LogPath “C:\Windows\NTDS” -NoRebootOnCompletion:$false -SysvolPath “C:\Windows\SYSVOL” -Force:$true -SafeModeAdministratorPassword "BrettJewell@1"