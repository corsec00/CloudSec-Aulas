# comandos Bash do Linux
sudo -i
apt update && sudo apt upgrade -y
apt install -y curl apt-transport-https ca-certificates
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
apt update && apt install -y azure-cli
az --version

# Atualização da chave SSH
$myAKV = "akv-exercicio05"
az keyvault secret set --vault-name $myAKV --name SSH-Key --file vm-linux-leoss001_key.pem
az keyvault secret show --name SSH-Key --vault-name $myAKV







az keyvault secret show --name SSH-Key --vault-name "akv-exercicio05"