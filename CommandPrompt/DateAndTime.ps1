## Enable ExecutionPolicy

Set-ExecutionPolicy -ExecutionPolicy Unrestricted

## Timezone for Computer:

Set-TimeZone -name "Turkey Standard Time"

## Starts w32time service and register time service to run as a service:

Start-Service w32time
w32tm /register

## Add all ntp.pool.org ntp servers:

w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org"

## Force resync:

w32tm /resync /force
