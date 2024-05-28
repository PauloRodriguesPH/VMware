# Importar o módulo do PowerCLI
Import-Module VMware.PowerCLI

# Definir o servidor vCenter e credenciais
$vCenterServer = "slap1820.bancobmg.com.br"
$vCenterUser = "paulo.rodrigues@vsphere.local"

# Conectar ao vCenter Server
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true
Connect-VIServer -Server $vCenterServer -User $vCenterUser

# Caminho para o arquivo CSV
$csvPath = "U:\Scripts\lista.csv"

# Importar o arquivo CSV
$vms = Import-Csv -Path $csvPath

# Loop através de cada VM no CSV
foreach ($vm in $vms) {
    $vmName = $vm.VMName
    $networkName = "vPG_HML_HBT_242"

    # Obter a VM
    $vmObject = Get-VM -Name $vmName

    # Adicionar a placa de rede vmxnet3
    $networkAdapter = New-NetworkAdapter -VM $vmObject -NetworkName $networkName -Type Vmxnet3

    # Mensagem de sucesso
    Write-Host "Placa de rede vmxnet3 adicionada à VM: $vmName"
}

# Desconectar do vCenter Server
Disconnect-VIServer -Server $vCenterServer -Confirm:$false