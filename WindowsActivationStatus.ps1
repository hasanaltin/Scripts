Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | where { $_.PartialProductKey } | select LicenseFamily, LicenseStatus > "C:\Program Files\Zabbix\WindowsActivationLog.txt"
