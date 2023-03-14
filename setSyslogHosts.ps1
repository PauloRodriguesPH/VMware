$vcenter = "vcenter.lab.local"
$syslog = "tcp://192.168.0.1:514"

Import-Module -Name VMware.PowerCLI
connect-viserver –server $vcenter

#Habilita regra firewall syslog
Get-VMHost | Get-VMHostFirewallException | where {$_.Name -eq "syslog"} | Set-VMHostFirewallException -Enabled $true -Confirm:$false

#Configura syslog em todos os hosts do vCenter
Get-VmHost | Set-VMHostSysLogServer -SysLogServer $syslog

#Restarta o serviço do syslog
Get-VmHost | Get-VMHostService | where {$_.Key -eq "vmsyslogd"} | Restart-VMHostService -Confirm:$false