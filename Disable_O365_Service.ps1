# Disables a service within subscriptiption FOR ALL USERS!!! Modify accordingly. 

Connect-MSOLService

#set your account SKU ( get-msolaccountSKU ) 

$AccountSKU = "ORGNAME:ENTERPRISEPREMIUM"
$Plan = "KAIZALA_STANDALONE"

#Set license option you want to disable

$licenseoption = New-MsolLicenseOptions -AccountSkuId $AccountSKU  -DisabledPlans $Plan

# get users with service provisioned or waiting for provisioning

(Get-MsolUser -all) |where {(foreach {$_.licenses.servicestatus} | where {$_.serviceplan.servicename -eq $Plan}).ProvisioningStatus -in ("success","PendingProvisioning")} 

# Disable the service for all users
(Get-MsolUser -all) |where {(foreach {$_.licenses.servicestatus} | where {$_.serviceplan.servicename -eq $Plan}).ProvisioningStatus -in ("success","PendingProvisioning")} |Set-MsolUserLicense -LicenseOptions $licenseoption

Find users who has the service in 
(Get-MsolUser -all) |where {(foreach {$_.licenses.servicestatus} | where {$_.serviceplan.servicename -eq $Plan}).ProvisioningStatus -notin ("disabled",$null}
