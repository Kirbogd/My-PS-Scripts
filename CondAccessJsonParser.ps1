
<##
The script takes a Conditional Access Policies object in JSON notation acquired via Graph API.
Afterwards it displays policies one by one in a human-readable style. 

To get the policy make a request to graph with
   
    $uri = "https://graph.microsoft.com/beta/conditionalAccess/policies/"

    $UriResult = Invoke-RestMethod -Method get -Uri $uri -Headers $authHeader

    $UriResult

    $UriResult |Export-Clixml   # to save the policy to disk in required format 
    
    or just modify script accordingly to set $CAPolicy = $UriResult



##>

function enumerate-CASettings {
  <##
  Recursive function takes PSObject for input and goes through it
  to display setting-value pairs while the value is not $null.
    if the value is a PSObject itself, it iterates one level deeper
  ##>  
    
    param(
        [parameter(Position=0, Mandatory=$true)]
                [PSObject]
                $SettingName    
        )
        
    foreach ($item in $SettingName.PSObject.Properties)
        { #read properties of the object one by one
        
            $Header = $Item.Name
        
            $Value = $item.Value
    
    
            if ($null -ne $Value)
            {
                if ($Value.GetType().Name -eq "PSCustomObject")
                {
            
                    enumerate-CASettings $Value
           
                }
        
                else 
                {
        
                    Write-host $Header.Padleft($PadLeft).ToUpperInvariant() -ForegroundColor Cyan
        
                    if ($Value.GetType().Name -eq "ArrayList")
                    {
        
                        $Value | ForEach-Object 
                        {
        
                            $pad = $_.Length+5
         
                            Write-host $_.PadLeft($Pad+$PadLeft)
                        }
                    }
        
                    elseif ($Value.GetType().Name -eq "Boolean")
                    {
        
                        Write-host " ".Padleft(10)$Value
        
                    }
        
                    else
                    {

                        $pad = $_.Length+10
        
                        Write-host $Value.PadLeft($Pad)
        
                    }
        
                }   
            }
        }
      
    }
    
    
    Write-host "Please provide path to clixml file containing Conditional Access Policies"
    
    $CAclixmlPath = Read-Host "Set path to file:"

    try 
    {

        $ConditionalAccess = import-clixml -Path $CAclixmlPath

    }
    catch 
    {

        Write-host $Error
    
        break
    }
    
    $i = 0
    
    foreach ($CAPolicy in $ConditionalAccess.value)
    {

        if ($CAPolicy. state -eq "enabled") #filters out only enabled policies. modify (or remove) according to your needs
        { 
    
            $i++
        
            Write-Host "============================="
        
            Write-host "Policy number"$i
        
            enumerate-CASettings $CAPolicy
        
            Write-host "";"";""
        }
    
    }