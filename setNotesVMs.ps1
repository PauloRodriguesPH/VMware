<#
Example plan1.csv
vmname,notes
VM1,DC
VM2,SQL
VM3,APP
#>

#Import_VMs-List
$vmlist = Import-CSV -Path C:\Scripts\plan1.csv

#Set VM Notes
foreach ($item in $vmlist){
    Set-VM -VM $item.vmname -Description $item.notes -RunAsync -Confirm:$false
}