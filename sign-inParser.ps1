## script to parse Azure AD sign-in logs exported in json format

$signins = @()

#set path to downloaded sign-in logs in json format

$path = "C:\Temp\SignIns_2020-03-30_2020-04-01.json"


#Read content into $signins array

$Signins = (Get-Content -Path $path | ConvertFrom-Json)


# Example to output username, service, IP address, device platform and failed policy name for every attempt failed due to a policy

$signins | Where-Object {$_.conditionalaccessstatus -eq "Failure"} | ForEach-Object {

write-host "User:" $_.UserPrincipalName
write-host "Service: "$_.AppDisplayName
write-host "IP: "$_.ipAddress
write-host "AgentString: "($_.userAgent.split(";")[1])
write-host "device: " $_.deviceDetail.operatingSystem

foreach ($Condition in $_.appliedConditionalAccessPolicies) {
    if ($Condition.result -eq "failure"){
        Write-host "PolicyName: " $Condition.displayName
        
        }

    }
Write-Host "=========================="
}
