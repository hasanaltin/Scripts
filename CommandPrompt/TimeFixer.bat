@echo off
net stop W32Time
net start W32Time
w32tm /resync
echo sync complete
