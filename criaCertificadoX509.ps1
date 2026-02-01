cls
$RootCA = Read-Host "Nome do seu ROOT CA (ex: Exercicio05)"
$GatewayFQDN = Read-Host "FQDN do Azure VPN Gateway (ex: vpn.leosantos.seg.br)"
$ClientName = Read-Host "Nome do certificado do CLIENTE (ex: cliente01)"
$SenhaCert = Read-Host "Senha para exportar os certificados" -AsSecureString

Write-Host "`nCriando ROOT CA..." -ForegroundColor Cyan

$rootParams = @{
    Type = 'Custom'
    Subject = "CN=$RootCA"
    KeySpec = 'Signature'
    KeyExportPolicy = 'Exportable'
    KeyUsage = 'CertSign'
    KeyUsageProperty = 'Sign'
    KeyLength = 2048
    HashAlgorithm = 'sha256'
    NotAfter = (Get-Date).AddYears(5)
    CertStoreLocation = 'Cert:\CurrentUser\My'
}

$certROOT = New-SelfSignedCertificate @rootParams
$myROOTThumbprint = $certROOT.Thumbprint

Write-Host "`nCriando certificado de SERVIDOR..." -ForegroundColor Cyan

$serverParams = @{
    Type = 'Custom'
    Subject = "CN=$GatewayFQDN"
    DnsName = $GatewayFQDN
    KeySpec = 'Signature'
    KeyExportPolicy = 'Exportable'
    KeyLength = 2048
    HashAlgorithm = 'sha256'
    NotAfter = (Get-Date).AddYears(2)
    CertStoreLocation = 'Cert:\CurrentUser\My'
    Signer = $certROOT
    TextExtension = @(
        # EKU: Server Authentication
        '2.5.29.37={text}1.3.6.1.5.5.7.3.1'
    )
}

$certServer = New-SelfSignedCertificate @serverParams
$certServerThumbprint = $certServer.Thumbprint

Write-Host "`nCriando certificado de CLIENTE..." -ForegroundColor Cyan

$clientParams = @{
    Type = 'Custom'
    Subject = "CN=$ClientName"
    DnsName = $ClientName
    KeySpec = 'Signature'
    KeyExportPolicy = 'Exportable'
    KeyLength = 2048
    HashAlgorithm = 'sha256'
    NotAfter = (Get-Date).AddYears(2)
    CertStoreLocation = 'Cert:\CurrentUser\My'
    Signer = $certROOT
    TextExtension = @(
        # EKU: Client Authentication
        '2.5.29.37={text}1.3.6.1.5.5.7.3.2'
    )
}

$certClient = New-SelfSignedCertificate @clientParams
$certClientThumbprint = $certClient.Thumbprint
Write-Host "`nExportando certificados PFX..." -ForegroundColor Cyan

Export-PfxCertificate -Cert "Cert:\CurrentUser\My\$myROOTThumbprint" -FilePath "$RootCA.pfx" -Password $SenhaCert
Export-PfxCertificate -Cert "Cert:\CurrentUser\My\$certServerThumbprint" -FilePath "Server-$GatewayFQDN.pfx" -Password $SenhaCert
Export-PfxCertificate -Cert "Cert:\CurrentUser\My\$certClientThumbprint" -FilePath "$ClientName.pfx" -Password $SenhaCert


Write-Host "`nExportando certificados CER..." -ForegroundColor Cyan

Export-Certificate -Cert "Cert:\CurrentUser\My\$myROOTThumbprint" -FilePath "$RootCA.cer"
Export-Certificate -Cert "Cert:\CurrentUser\My\$certServerThumbprint" -FilePath "Server-$GatewayFQDN.cer"
Export-Certificate -Cert "Cert:\CurrentUser\My\$certClientThumbprint" -FilePath "$ClientName.cer"


Write-Host "`nConcluído! Arquivos gerados:" -ForegroundColor Green
Write-Host " - Root CA: $RootCA.pfx / $RootCA.cer"
Write-Host " - Server Certificate: Server-$GatewayFQDN.pfx / Server-$GatewayFQDN.cer"
Write-Host " - Client Certificate: $ClientName.pfx / $ClientName.cer"
Write-Host "`nUse o arquivo Server-$GatewayFQDN.cer no Azure como Server Certificate."
Write-Host "Use o arquivo $RootCA.cer no Azure como Root Certificate."