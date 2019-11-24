<##
The script allows to download DLP Alerts through Office 365 Activity Management API.
Parses and shows the mutual data from the alerts.
Just set 
##>

<#
.SYNOPSIS


.DESCRIPTION


.PARAMETER Title


.EXAMPLE


.NOTES

#>

## Script auth config. Set actual data in the following variables
## The data can be found in App registration page in azure ad portal: 
## https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps

$ClientID = "Set-clientID here"
$TenantID = "Set tenantID here"
$Secret = "App secret here"


function Get-AuthToken 
    {



        <#
        
        .SYNOPSIS
        
        This function is used to get auth token for use with Graph and other APIs
        
        .DESCRIPTION
        
        The function generates authentication header to use with different APIs using ADAL library. The function can get auth header for client app deligated by user, or service principles using secret key or certificate 
        
        .EXAMPLE
        
        Get-AuthToken -ByUser -ClientId "12345678-90ab-cdef-1234-567890ab" -User "user@domain.name" -TenantID "12345678-90ab-cdef-1234-567890ab" -ResourceAppIDUri "https://graph.microsoft.com" -redirectURI "urn:ietf:wg:oauth:2.0:oob -authroot "https://login.microsoftonline.com"
        Authenticates an app with deligated user credentials 
        
        Get-AuthToken -ByCert -ClientId 12345678-90ab-cdef-1234-567890ab -CertThumbprint 1212412412121  -TenantID 12345678-90ab-cdef-1234-567890ab -ResourceAppIDUri "https://graph.microsoft.com" -authroot "https://login.microsoftonline.com"
        Authenticates service principle with certificate stored in personal store of the running user

        Get-AuthToken -BySecret -ClientId 12345678-90ab-cdef-1234-567890ab -Secret aKEfnwvwqrq  -TenantID 12345678-90ab-cdef-1234-567890ab -ResourceAppIDUri "https://graph.microsoft.com" -redirectURI -authroot "https://login.microsoftonline.com"
        Authenticates service principle with secretkey

        
        .NOTES
        
        NAME: Get-AuthToken
        
        #>
        
        
        
        [cmdletbinding()]
        
        
        
        param(
            [parameter(Position=0,ParameterSetName="ByUser", Mandatory=$true)]
            [switch]
            $ByUser,
            [parameter(Position=0,ParameterSetName="ByCert", Mandatory=$true)]
            [switch]
            $ByCert,
            [parameter(Position=0,ParameterSetName="BySecret", Mandatory=$true)]
            [switch]
            $BySecret,
            [parameter(Position=1, Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $ClientID,
            [parameter()]
            [string]
            $authroot = "https://login.microsoftonline.com",
            [parameter(Mandatory=$true,ParameterSetName="ByUser")]
            [ValidateNotNullOrEmpty()]
            [string]
            $User,
            [parameter(ParameterSetName="ByCert", Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $CertThumbprint,
            [parameter(ParameterSetName="BySecret", Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $Secret,
            [parameter(ParameterSetName="ByUser", Mandatory=$true)]
            [parameter(ParameterSetName="ByCert", Mandatory=$true)]
            [parameter(ParameterSetName="BySecret", Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $TenantID,
            [parameter(ParameterSetName="ByUser", Mandatory=$true)]
            [parameter(ParameterSetName="ByCert", Mandatory=$true)]
            [parameter(ParameterSetName="BySecret", Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $resourceAppIdURI,
            [parameter(ParameterSetName="ByUser")]
            [parameter(ParameterSetName="BySecret")]
            [string]
            $redirectUri = "urn:ietf:wg:oauth:2.0:oob"

            )

        
        $authority = "$authroot/$TenantID"
        

        #region Initialize ADAL
        
            Write-Host "Checking for AzureAD module..."
        
        
        
            $AadModule = Get-Module -Name "AzureAD" -ListAvailable
        
        
        
            if ($null -eq $AadModule) 
            {
            
                Write-Host "AzureAD PowerShell module not found, looking for AzureADPreview"
        
                $AadModule = Get-Module -Name "AzureADPreview" -ListAvailable
            
            }
            
        
            if ($null -eq $AadModule) 
            {
        
                write-host
        
                write-host "AzureAD Powershell module not installed..." -f Red
        
                write-host "Install by running 'Install-Module AzureAD' or 'Install-Module AzureADPreview' from an elevated PowerShell prompt" -f Yellow
        
                write-host "Script can't continue..." -f Red
        
                write-host
        
                exit
        
            }
        
        
        
            # Getting path to ActiveDirectory Assemblies
        
            # If the module count is greater than 1 find the latest version
        
        
        
            if($AadModule.count -gt 1)
            {
        
        
        
                $Latest_Version = ($AadModule | Select-Object version | Sort-Object)[-1]
        
        
        
                $aadModule = $AadModule | Where-Object { $_.version -eq $Latest_Version.version }
        
        
                
                # Checking if there are multiple versions of the same module found
        
        
        
                if($AadModule.count -gt 1)
                {
        
                    $aadModule = $AadModule | Select-Object -Unique
        
                }
        
        
        
                $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        
                $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
        
        
            }
        
        
            else 
            {
        
                $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        
                $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
            
            }
        
        
        
            [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
        
        
        
            [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
        
    
        #endregion
        
        
        
        ######### Switching auth method based on function switch

        
        
        switch($PSCmdlet.ParameterSetName)
            {
                "ByUser" 
                { 
                    try {
        
                            $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
                    
                    
                    
                            # https://msdn.microsoft.com/en-us/library/azure/microsoft.identitymodel.clients.activedirectory.promptbehavior.aspx
                    
                            # Change the prompt behaviour to force credentials each time: Auto, Always, Never, RefreshSession
                    
                    
                    
                            $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Always"
                    
                    
                    
                            $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($User, "OptionalDisplayableId")
                    
                    
                    
                            $authReturn = $authContext.AcquireTokenAsync($resourceAppIdURI,$clientId,$redirectUri,$platformParameters,$userId)


                            $authResult = $authReturn.Result
                    
                            # If the accesstoken is valid then create the authentication header
                    
                    
                            if($authResult.AccessToken)
                            {
                    
                                # Creating header for Authorization token
                    
                    
                    
                                $authHeader = @{
                    
                                'Content-Type'='application/json'
                    
                                'Authorization'="Bearer " + $authResult.AccessToken
                    
                                'ExpiresOn'=$authResult.ExpiresOn
                    
                                }
                    
                    
                                return $authHeader
                    
                            }
                    
                    
                            else 
                            {
                    
                    
                                Write-Host
                    
                                Write-Host "Authorization Access Token is null, please re-run authentication..." -ForegroundColor Red
                                
                                Write-Host
                    
                                break
                    
                            }
                    
                    
                    
                        }
                    
                                
                    catch 
                        {
                                    
                            write-host $_.Exception.Message -f Red
                    
                            write-host $_.Exception.ItemName -f Red
                    
                            write-host
                    
                            break
                    
                        }
                    
                    
                }
                "ByCert" 
                {
                    $clientCertificate = Get-Item -Path Cert:\CurrentUser\My\$CertThumbprint

                    try 
                    {
        
        
                        $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
                    
                    
                        # https://msdn.microsoft.com/en-us/library/azure/microsoft.identitymodel.clients.activedirectory.promptbehavior.aspx
                    
                        # Change the prompt behaviour to force credentials each time: Auto, Always, Never, RefreshSession
                    
                
                        $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Always"
                    
                    
                        $ClientCred = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.ClientAssertionCertificate" -ArgumentList ($ClientId, $clientCertificate)
                    
                        
                    
                        $authReturn = $authContext.AcquireTokenAsync($resourceAppIdURI,$ClientCred)
                    
                        
                        $authResult = $authReturn.Result
                    
                            # If the accesstoken is valid then create the authentication header
                    
                    
                    
                            if($authResult.AccessToken)
                            {
                    
                                # Creating header for Authorization token
                    
                                $authHeader = @{
                    
                                'Content-Type'='application/json'
                    
                                'Authorization'="Bearer " + $authResult.AccessToken
                    
                                'ExpiresOn'=$authResult.ExpiresOn
                    
                                }
                    
                    
                                return $authHeader
                    
                    
                    
                            }
                    
                    
                    
                            else 
                            {
                    
                    
                    
                                Write-Host
                    
                                Write-Host "Authorization Access Token is null, please re-run authentication..." -ForegroundColor Red
                    
                                Write-Host
                    
                                break
                    
                    
                            }
                    
                    
                    }
                    
                    
                    
                    catch 
                    {
                    
                    
                    
                        write-host $_.Exception.Message -f Red
                    
                        write-host $_.Exception.ItemName -f Red
                    
                        write-host
                    
                        break
                    
                    
                    
                    }
                    
                    
                    
                    
                }
                "BySecret" 
                {
                    try 
                    {
        
        
        
                        $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
                    
                    
                        $ClientCred = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential" -ArgumentList ($clientId, $Secret)
                    
                    
                        $authReturn = $authContext.AcquireTokenAsync($resourceAppIdURI,$ClientCred)
                    
                        $authResult = $authReturn.Result
                    
                        # If the accesstoken is valid then create the authentication header
                    
                    
                    
                        if($authResult.AccessToken)
                        {
                    
                    
                    
                            # Creating header for Authorization token
                    
                    
                    
                            $authHeader = @{
                    
                                'Content-Type'='application/json'
                    
                                'Authorization'="Bearer " + $authResult.AccessToken
                    
                                'ExpiresOn'=$authResult.ExpiresOn
                    
                                }
                    
                    
                    
                            return $authHeader
                    
                    
                    
                        }
                    
                    
                    
                        else 
                        {     
                    
                            Write-Host
                    
                            Write-Host "Authorization Access Token is null, please re-run authentication..." -ForegroundColor Red
                    
                            Write-Host
                    
                            break
                    
                        }
                    
                    
                    
                    }
                    
                    
                    
                    catch 
                    {
                    
                    
                        write-host $_.Exception.Message -f Red
                    
                        write-host $_.Exception.ItemName -f Red
                    
                        write-host
                    
                        break
                    
                    }
                    
                    
                }
                    
            }
                    
    }        
    
####################################################


function Invoke-Request
    {
     <#
        .SYNOPSIS
        Invokes Get or POST RESTmethod using $global:authheader and  $uri as an agrument 

        .DESCRIPTION


        .PARAMETER Title
        $URI - uri that is used in request
        -Get / -Post - switch defining the method type
        .EXAMPLE


        .NOTES

    #>
 
    param(
     [parameter(Position=0, Mandatory=$true)]
     [string]
     $Uri,
     [parameter(parameterSetName="Get",Mandatory=$true)]
     [switch]
     $Get,
     [parameter(parameterSetName="Post",Mandatory=$true)]
     [switch]
     $Post
      )
      
      switch($PSCmdlet.ParameterSetName)
      {"Get"{
      $Answer = "$null"
      $Answer = Invoke-RestMethod -Uri $uri –Headers $authToken –Method Get
      Return $Answer
      }
      "Post"{
      $Answer = "$null"
      $Answer = Invoke-RestMethod -Uri $uri –Headers $authToken –Method Post  
      Return $Answer
      }
      }
    
    
    }

    ## Authentication part. Request token for your use case
 

    $Authroot = "https://login.windows.net/$TenantID/OAuth2/token" # or set to https://login.microsoftonline.com for graph api   
    $resourceAppIdURI = "https://manage.office.com" # or set "https://graph.microsoft.com" for graph
    $authority = "$authroot/$TenantID"
    
    $global:authToken = Get-AuthToken -BySecret -ClientID $ClientID -authroot $Authroot -Secret $Secret -TenantID $TenantID -resourceAppIdURI $resourceAppIdURI

    #Initialize variables

    $Return = ""
    $Content = ""
    $result = @()                            

    $BaseURI = "https://manage.office.com/api/v1.0/$TenantID/activity/feed"
    
    # Generate requests for the last 7 days

    for ($i = 0; $i -lt "6";$i++)
    {

        $startday = (Get-Date (Get-Date).AddDays(-$i-1) -UFormat %Y-%m-%d)
        
        $endday = (Get-Date (Get-Date).AddDays(-$i) -UFormat %Y-%m-%d)
        
        $SubURI = "subscriptions/content?contentType=DLP.All&startTime="+$startday+"&endTime="+$endday
        
        # Write-Host $SubURI ##Debug point. uncomment for troubleshooting

        $URI = "$BaseURI/$SubURI"
        
        $Return = Invoke-RestMethod -Uri $URI -Headers $authToken -Method Get 
    
        # Write-host $Return ##Debug point. uncomment for troubleshooting
    
        if ($Return) 
        { 
            $Return | ForEach-Object 
            {
                $Content = Invoke-RestMethod -Uri $_.ContentUri -Headers $authToken -Method get # -Verbose
                    
                $result = $result+$Content  
            }
        }
    }
    
    Write-host "Получено событий: "$result.Count
    
    ## Start parsing the output getting

    foreach ($res in $result)
    {
        Write-Host " "
        
        Write-Host "From: "$res.ExchangeMetaData.From
        
        write-host "Workload: "$res.Workload
        
        write-host "Alert Time: "$res.CreationTime
        
        Write-Host "Детали срабатывания:"
        
        ForEach ($PolicyDet in $res.PolicyDetails)  
        {
            Write-host "   Политика: " ,$PolicyDet.PolicyName
                
            #  Write-host $PolicyDet.Rules ## Debug point
        
            ForEach ($PRule in $PolicyDet.Rules)
            {
                Write-host "Причина срабатывания:"
        
                foreach ($SensInf in $PRule.ConditionsMatched.SensitiveInformation)
                {
                    # Write-host "SensInf" $SensInf     ##Debug point. uncomment for troubleshooting
                    
                    ForEach ($SensDet in $SensInf.SensitiveInformationDetections)
                    {
                        # Write-Host "SensDet" $SensDet     ##Debug point. uncomment for troubleshooting
                    
                        ForEach ($Detval in $SensDet.DetectedValues) 
                        {
                            Write-Host "   Имя сработки: "$DetVal.name
                    
                            Write-Host "   Контекст: "$DetVal.Value
                        }
                    }
                }
            }

        }   
        
        ## If We have SharePoint data (Teams file exchange or Onedrive uplaod)
        
        if ($res.SharePointMetaData)
        {
            Write-host "File Details"

            Write-Host "  FileName: "$res.SharePointMetaData.FileName

            Write-Host "  FilePath: "$res.SharePointMetaData.FilePathUrl

            Write-Host "  Created: "$res.SharePointMetaData.ItemCreationTime

            Write-Host "  Last time modified: "$res.SharePointMetaData.ItemLastModifiedTime

            Write-host "  From: "$res.SharePointMetaData.From    
        }
        
        ## If We have Exchange data (Teams message or email)
        
        if ($res.ExchangeMetaData)
        {
            Write-host "Message details"   
       
            Write-Host "  From: "$res.ExchangeMetaData.From
       
            Write-Host "  To: "$res.ExchangeMetaData.To
       
            Write-Host "  CC: "$res.ExchangeMetaData.CC
       
            Write-Host "  BCC: "$res.ExchangeMetaData.BCC
       
            Write-Host "  Sent: "$res.ExchangeMetaData.Sent
       
            Write-Host "  MessageID: "$res.ExchangeMetaData.MessageId
       
            Write-Host "  Subject: "$res.ExchangeMetaData.Subject
        }

            Write-host "================================================"
    }    
