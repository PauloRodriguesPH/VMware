<#
Example list.csv
vmname,cpu,cores,mem
VM001,2,2,8
VM002,2,2,8
VM003,2,2,8
#>

#Import_VMs-List
$vmlist = Import-CSV -Path C:\Scripts\list.csv

# Shutdown-VM
foreach ($item in $vmlist) {
    $vmname = Get-VM -Name $item.vmname
    If ($vmname.Guest.State -eq "Running") {
        Shutdown-VMGuest -VM $vmname -Confirm:$false
    }
    Else {
        Stop-VM -VM $vmname -Confirm:$false
    }
}   

#Wait-VM-ShutDown
Sleep -Seconds 120

# Check State
foreach ($item in $vmlist) {
    $vmname = Get-VM -Name $item.vmname
    If ($vmname.Guest.State -ne "NotRunning") {
        Get-VM -Name $item.vmname
    }
} 

#Resize-VM
foreach ($item in $vmlist) {
    $vmname = $item.vmname
    $cpu = $item.cpu
    $cores = $item.cores
    $mem = [int]$item.mem * 1024
    Set-VM -VM $vmname -CoresPerSocket $cores -NumCpu $cpu -MemoryMB $mem -RunAsync -Confirm:$false
}

#Start-VM
foreach ($item in $vmlist) {
    $vmname = $item.vmname
    Start-VM -VM $vmname -RunAsync -Confirm:$false
}