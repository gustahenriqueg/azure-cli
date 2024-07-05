$table = New-Object System.Data.DataTable

$table.Columns.Add("AppName")
$table.Columns.Add("ResourceGroup")
$table.Columns.Add("OS")
$table.Columns.Add("Runtime")
$table.Columns.Add("Version")
$table.Columns.Add("AppType")

$appListArray = @()

$resourceGroups = Get-AzResourceGroup
foreach ($resourceGroup in $resourceGroups) {
	$webApps = Get-AzWebApp -ResourceGroupName $resourceGroup.ResourceGroupName
    foreach($webapp in $webApps){
        $appName = $webapp.Name
        $group = $resourceGroup.ResourceId

        #URIs to retrieve Stack and Version using rest api calls
        $stackUri = "$group/providers/Microsoft.Web/sites/$appName/config/metadata/list?api-version=2020-10-01"
        $stackVersionUri = "$group/providers/Microsoft.Web/sites/$appName/config?api-version=2020-10-01"
        $appTypeUri = "$group/providers/Microsoft.Web/sites/$appName`?api-version=2023-01-01"

        #Calling Config properties
        $stackProperties = Invoke-AzRestMethod -Path $stackUri -Method POST
        $stackVersionProperties = Invoke-AzRestMethod -Path $stackVersionUri -Method GET
        $appType = Invoke-AzRestMethod -Path $appTypeUri -Method GET

        #convert response to JSON
        $stackJson = $stackProperties.Content | ConvertFrom-Json
        $stackVersionJson = $stackVersionProperties.Content | ConvertFrom-Json
        $appTypeJson = $appType.Content | ConvertFrom-Json

        if($stackVersionJson.value[0].properties.linuxFxVersion){
            #$image = $stackVersionJson.value[0].properties.linuxFxVersion
            $runtime = $stackVersionJson.value[0].properties.linuxFxVersion.split("|")[0]
            $version = $stackVersionJson.value[0].properties.linuxFxVersion.split("|")[1]
            $os = "Linux"
            $type = $appTypeJson.kind
            }
        else{
            $runtime = $stackJson.properties.CURRENT_STACK
            switch($runtime = $stackJson.properties.CURRENT_STACK)
            {
                python {$version = $stackVersionJson.value[0].properties.pythonVersion}
                node {$version = $stackVersionJson.value[0].properties.nodeVersion}
                php {$version = $stackVersionJson.value[0].properties.phpVersion}
                java {$version = $stackVersionJson.value[0].properties.javaVersion}
                dotnet {$version = $stackVersionJson.value[0].properties.netFrameworkVersion}
                dotnetcore {$version = $stackVersionJson.value[0].properties.netFrameworkVersion}
                default {$version = "No stack version found. This could be a LogicApp standard or function app edge case. Please manually check"}
            }
            $os = "Windows"
            $type = $appTypeJson.kind
        }

        #create the array for CSV
        $obj = [PSCustomObject]@{
            AppName = "$appName"
            ResourceGroup = "$group"
            OS = "$os"
            Runtime = "$runtime"
            Version = "$version"
            AppType = "$type"
        }

        $appListArray += $obj

        #append to the table 
        $table.Rows.Add($appName,$group,$os,$runtime,$version,$type)
        Write-Host("--------------------")
   }
}
#create the CSV
$appListArray | Export-Csv -Path C:\temp\output.csv -NoTypeInformation

#create a JSON object
$json = ConvertTo-Json $appListArray