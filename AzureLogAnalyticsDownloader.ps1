<## Set an app principle and provide rights 
according to https://dev.loganalytics.io/oms/documentation/1-Tutorials/1-Direct-API
The version do not incorporate checks and erro handling yet. 
##>

#region Phase0: initialize settings

    $clientID = ## Found in app settings for your app principle 

    $ClientKey = ## Generate in Certificates and secrets settings of the app principle

    $RedirectURI = "http://localhost:3000" ## Provided on the app registration phase. change if you set your own Redirect URI there

    $TenantID = ## Found on overview tab of your app registration

    $WorkSpaceID = ## found on overview tab of your Azure Log Analytics Workspace

    $Query = "OfficeActivity"  ## insert your KQL Query here

    $TimeSpan = "PT12H" ## insert your value for time period in ISO8601 format https://en.wikipedia.org/wiki/ISO_8601

#endregion

#region Phase1:acquire access token

    ## Setting URI for auth token request
    $AuthUri = "https://login.microsoftonline.com/$TenantID/oauth2/token/"

    # Set web request header for auth token request
    $authReqHeader = @{
        'Content-Type'='application/x-www-form-urlencoded'
        }

    ##  The auth request body contains data required to authenticate client  
    $AuthReqBody = "grant_type=client_credentials&client_id=$clientID&redirect_uri=$RedirectURI&resource=https://api.loganalytics.io&client_secret=$ClientKey"

    ## Issuing web request to get bearer. It is returned in responce to web request
    $AuthRequest = Invoke-WebRequest -Uri $AuthUri -Method Post -Headers $authReqHeader -Body $AuthReqBody

    #Getting AuthBearer from authentication response
    $AuthBearer = ($AuthRequest.Content | ConvertFrom-Json)

#endregion

#region Phase2:quering AzureLogAnalytics API for data

    ## From request body consisting of KQL query and timespan for requested data
    ## The body should be formatred as JSON object
    $LogQuery = @{
    'query'= $Query;
    'timespan'= $TimeSpan
    } | ConvertTo-Json

    ## Setting URI for quiring Log Analytics API for specific workspace
    $QueryURi = "https://api.loganalytics.io/v1/workspaces/$WorkSpaceID/query"

    ## Form header for REST request. It should contain auth bearer ackquired on the rpevios phase
    $QueryHeader = @{
                'Content-Type'='application/json';
                'Authorization' = "Bearer " + $AuthBearer.access_token;
                'ExpiresOn'=$authBearer.Expires_On;
                }
    ## Invoking REST request to API. The quiry result should be returned in responce            
    $Result = Invoke-RestMethod -Uri $QueryURi -Method Post -Headers $QueryHeader -Body $LogQuery
    
    ## Writing our result: table with columns and rows in JSON format
    $Result

#endregion    