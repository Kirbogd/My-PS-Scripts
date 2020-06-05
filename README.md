# My PS Scripts

Different PS scripts primarely to get api access to Azure AD, M365 and Azure services
The vast majority of the scripts assume that you copy it into PS ISE (or VScode) and modify settings and parameters inside

- **ADALAuthGraphChecker.ps1** Script to check authentication with different methods to Azure Graph API
- **AzureLogAnalyticsDownloader.ps1** We were struggling with getting AIP usage logs into local SIEM. I have crafted the script to connect through PowerShell and test quiries and app principle parameters. Can be utilised to download data from Azure Log Analytucs through API
- **CondAccessJsonParser.ps1** It is possible to download and upload Conditional Access Policies through Azure Graph API now. But the vast majority of human are not good at reading nested JSON. So the script can parse through the Conditional Access Policies Json and output data in more readable format
- **DLP_Alerts_Parser.ps1** The script allows to download DLP Alerts through Office 365 Activity Management API.Parses and shows the mutual data from the alerts. Do not forget to provide required rights for DLP.All subscription in API to the app principle and enable subscription to the audit channel. See Office Management Activity API docs for details
- **Disable_O365_Service.ps1** We have had a need to disable specific O365 service for all the users in the tenant, with direct license assignment. The script does exactly the thing, so handle with caution and care. 
- **sign-inParser.ps1** If you need to play with Azure AD sign-in logs and do not have log analytics _(Cmon, azure Monitor log analytics is pretty affordable and gives you the whole power of Azure Data Explorer and Kusto Query Language)_, you can download sign-in logs in JSON format from Azure AD Admin portal or directly from Graph API and parse using the script through. The specific version looks for failed CA policies, but you can get any data you need...
