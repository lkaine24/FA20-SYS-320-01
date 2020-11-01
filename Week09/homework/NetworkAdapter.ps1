# Storyline: Grab the network adapter information using the WMI class

# Gets network configuration including the IP address, default gateway, DNS servers, and DHCP server for Network adapter in use, e1i65x64.
Get-WmiObject -Class Win32_NetworkAdapterConfiguration | where {$_.ServiceName -eq "e1i65x64"} | Select IPAddress, DefaultIPGateway, DNSServerSearchOrder, DHCPServer