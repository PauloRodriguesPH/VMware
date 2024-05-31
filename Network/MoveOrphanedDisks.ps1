# Conectar ao vCenter
$vCenterServer = "vcenter.lab.local"
$vCenterUser = "paulo.rodrigues@vsphere.local"
$vcPassword = "P@ssw0rd"

# Carregar o módulo PowerCLI
Import-Module VMware.PowerCLI

# Carregar o módulo Posh-SSH
Import-Module Posh-SSH

# Conectar ao vCenter
Connect-VIServer -Server $vcenterServer -User $vcUser -Password $vcPassword

# Parâmetros
$esxiHostName = "host01.lab.local" # Nome do host ESXi
$sshUsername = "root" # Substitua pelo seu usuário SSH
$sshPassword = "P@ssw0rd" # Substitua pela sua senha SSH

# Obter o host ESXi
$esxiHost = Get-VMHost -Name $esxiHostName

if ($esxiHost) {
    # Listar todos os datastores associados ao host ESXi
    $datastores = Get-Datastore -VMHost $esxiHost

    # Exibir os datastores
    $datastores | Format-Table -Property Name, FreeSpaceGB, CapacityGB, Type
} else {
    Write-Host "Host ESXi '$esxiHostName' não encontrado."
    exit
}

# Criar PSDrive
$datastore = Get-Datastore "Datastore_001"
New-PSDrive -Location $datastore -Name ds -PSProvider VimDatastore -Root ""

# Navegar até a nova unidade
Set-Location ds:

# Ler o CSV
$csvPath = "c:\scripts\list.csv"
$entries = Import-Csv -Path $csvPath

# Estabelecer conexão SSH
$sshSession = New-SSHSession -ComputerName $esxiHostName -Credential (New-Object PSCredential ($sshUsername, (ConvertTo-SecureString $sshPassword -AsPlainText -Force)))

# Copiar os arquivos VMDK conforme especificado no CSV
foreach ($entry in $entries) {
    $sourceVMDK = $entry.path
    $vmdkName = [System.IO.Path]::GetFileName($sourceVMDK)
    $destinationFolder = "_QUARANTINE"
    $destinationPath = "$destinationFolder/$vmdkName"

    # Imprimir valores das variáveis
    Write-Host "Source VMDK: $sourceVMDK"
    Write-Host "VMDK Name: $vmdkName"
    Write-Host "Destination Folder: $destinationFolder"
    Write-Host "Destination Path: $destinationPath"

    # Verificar se a pasta de destino existe e criar se necessário
    if (-not (Test-Path $destinationFolder)) {
        Write-Host "Creating destination folder: $destinationFolder"
        New-Item -ItemType Directory -Path $destinationFolder
    }

    # Copiar o arquivo VMDK
    Write-Host "Copying $sourceVMDK to $destinationPath"
    Copy-Item -Path $sourceVMDK -Destination $destinationPath

    # Remover o arquivo VMDK de origem após a cópia usando SSH
    Write-Host "Removing source VMDK using SSH: $sourceVMDK"
    $sshCommand = "rm -f /vmfs/volumes/DS_VX_SEC/$sourceVMDK"
    Invoke-SSHCommand -SessionId $sshSession.SessionId -Command $sshCommand

    Write-Host "--------------------------------------------"
}

# Remover o PSDrive
Remove-PSDrive -Name ds -Confirm:$false

# Fechar a sessão SSH
Remove-SSHSession -SessionId $sshSession.SessionId

# Desconectar do vCenter
Disconnect-VIServer -Confirm:$false
