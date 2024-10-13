## File Operations (bf)

- bfcopy: copy "%SOURCE%" "%DEST%"
- bfmove: move "%SOURCE%" "%DEST%"
- bfdel: del "%FILE%"
- bfren: ren "%OLD%" "%NEW%"
- bfdir: dir "%PATH%"
- bfmd: mkdir "%DIR%"
- bfrd: rmdir "%DIR%"

## String Operations (bs)

- bslen: Get string length
- bssub: Extract substring
- bsrep: Replace in string
- bsupp: Convert to uppercase
- bslow: Convert to lowercase
- bstrim: Trim whitespace
- bssplit: Split string

## Variable Operations (bv)

- bvset: set "VAR=VALUE"
- bvsetd: Delayed expansion
- bvapp: Append to variable
- bvmath: set /a "RESULT=EXPR"
- bvenv: Get environment variable
- bvfor: For loop variable
- bvarg: Command line argument

## Control Structures (bc)

- bcif: If statement
- bcfor: For loop
- bcforr: For loop with range
- bcforf: For loop with files
- bcwhile: While loop
- bcgoto: Goto statement
- bccall: Call subroutine
- bcerr: Error handling
- bcswitch: Switch-like structure

## Network Operations (bn)

- bnping: ping -n 4 %HOST%
- bnip: ipconfig /all
- bnnslookup: nslookup %DOMAIN%
- bnnetstat: netstat -an
- bndownload: bitsadmin /transfer
- bnshare: net share
- bnuser: net user
- bnroute: route print
- bnfirewall: netsh advfirewall show allprofiles
- bnwifi: netsh wlan show networks

## System Commands (by)

- bysysinfo: systeminfo
- byproc: tasklist
- bykill: taskkill /F /IM %PROCESS%
- byservice: sc query
- bystart: sc start %SERVICE%
- bystop: sc stop %SERVICE%
- byreboot: shutdown /r /t 0
- byshutdown: shutdown /s /t 0
- bydate: echo %date%
- bytime: echo %time%
- bydisk: wmic logicaldisk get size,freespace,caption
- byenv: set

## Common Syntax

- Comments: REM or ::
- Variables: %VAR% or !VAR! (delayed expansion)
- Command chaining: & (run sequentially) && (run if previous succeeded) || (run if previous failed)
- Redirection: > (output to file) >> (append to file) < (input from file)
- Pipes: command1 | command2

## Tips

- Use "setlocal enabledelayedexpansion" for complex scripts
- Escape special characters with ^
- Use /? after any command for help
