
function enumerate-CASettings {
    param(
        [parameter(Position=0, Mandatory=$true)]
                [PSObject]
                $SettingName    
        )
        
    foreach ($item in $SettingName.PSObject.Properties){
    $Header = $Item.Name
    $Value = $item.Value
    
    if ($null -ne $Value){
          
        
        if ($Value.GetType().Name -eq "PSCustomObject"){
            enumerate-CASettings $Value
            #$PadLeft = $PadLeft+5
        }
        else {
        Write-host $Header.Padleft($PadLeft).ToUpperInvariant() -ForegroundColor Cyan
        if ($Value.GetType().Name -eq "ArrayList"){
        $Value | ForEach-Object {
        $pad = $_.Length+5
         Write-host $_.PadLeft($Pad+$PadLeft)
            }
        }
        elseif ($Value.GetType().Name -eq "Boolean"){
        Write-host " ".Padleft(10)$Value
        }
        else{
        $pad = $_.Length+10
        Write-host $Value.PadLeft($Pad)
        }
        }
    
    
    }
    }
    
    
        
    }
    
    
    
    $ConditionalAccess = import-clixml .\ConditionalAccess.xml
    
    $i = 0
    foreach ($CAPolicy in $ConditionalAccess.value){
        if ($CAPolicy. state -eq "enabled"){
        $i++
        Write-Host "============================="
        Write-host "Policy number"$i
        enumerate-CASettings $CAPolicy
        Write-host "";"";""}
    
    }