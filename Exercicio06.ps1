az login
## Exercício 06a
$RG = "rg-exercicio6a"
$NomeACR = "acrexercicio6a"
$local = 'westus'
az group create --name $RG --location $local
az acr create --location $local --sku Standard --admin-enabled true --resource-group $RG --name $NomeACR 
az acr login --name $NomeACR
az acr list --resource-group $RG --query "[].{acrLoginServer:loginServer}" --output table

docker tag mcr.microsoft.com/azuredocs/azure-vote-front:v1 acrexercicio6a.azurecr.io/azure-vote-front:v2
docker push acrexercicio6a.azurecr.io/azure-vote-front:v2
az acr repository list --name $NomeACR --output table
az acr repository show-tags --name $NomeACR --repository azure-vote-front --output table

## Exercício 06b
$myAKS ="aks-exercicio06b"
$RG="rg-exercicio6a"
$NomeACR = "acrexercicio6a"
az group create --name $RG --location $local
az aks create --resource-group $RG --name $myAKS --node-count 2 --generate-ssh-keys --attach-acr $NomeACR --location $local

az aks get-credentials --resource-group $RG --name $myAKS
kubectl get nodes
kubectl config use-context $myAKS 
kubectl apply -f azure-vote-all-in-one-redis.yaml
kubectl get service azure-vote-front
#### Inicio - Diagnóstico se houver erro
kubectl describe pod azure-vote-front-7c5496b688-lpdh6
az acr repository list -n acrexercicio6a
az acr repository show-tags -n acrexercicio6a --repository azure-vote-front
#### Fim - Diagnóstico se houver erro
kubectl get pods
kubectl scale --replicas=5 deployment/azure-vote-front
kubectl get hpa
kubectl delete hpa azure-vote-front
kubectl autoscale deployment azure-vote-front --cpu=70% --min=3 --max=9
az aks scale --resource-group $RG --name $myAKS --node-count 3
docker-compose up --build -d
az aks get-upgrades --resource-group $RG --name $myAKS
az aks upgrade --resource-group $RG --name $myAKS --kubernetes-version 1.34.1

Kubectl delete pods azure-vote-front-5bdc558dcd-6qv58

# Fim do laboratório
az group delete --name $RG --yes --no-wait