az login
$RG = "rg-exercicio6a"
$NomeACR = "acr-exercicio6a"
$local = 'westus'
az acr create --location $local --sku Standard --admin-enabled true --resource-group $RG --name $NomeACR 
