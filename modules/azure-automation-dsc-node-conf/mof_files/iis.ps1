Configuration ConfigureWeb
{ 
    
Import-DscResource -ModuleName 'PSDesiredStateConfiguration' 

 node ("localhost")
 { 
  WindowsFeature InstallWebServer 
  { 
   Ensure = "Present"
   Name = "Web-Server" 
  } 
 } 
}

ConfigureWeb