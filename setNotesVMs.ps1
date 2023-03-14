<#
Example list.csv
vmname,notes
VM1,DC
VM2,SQL
VM3,APP
#>

$vcenter = "vcenter.lab.local"

Import-Module -Name VMware.PowerCLI
connect-viserver –server $vcenter

#Import_VMs-List
$vmlist = Import-CSV -Path C:\Scripts\list.csv

#Set VM Notes
foreach ($item in $vmlist){
    Set-VM -VM $item.vmname -Description $item.notes -RunAsync -Confirm:$false
}