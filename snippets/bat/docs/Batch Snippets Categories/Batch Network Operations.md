## Overview

This category covers snippets for network-related operations in Batch scripting. The prefix for these snippets is `bn` (Batch Network).

## Snippets

### bnping - Ping a Host

```batch
ping -n 4 %HOST%
````

Mnemonic: "bn" (Batch Network) + "ping" (ping command)

### bnip - Get IP Configuration

```batch
ipconfig /all
```

Mnemonic: "bn" (Batch Network) + "ip" (IP configuration)

### bnnslookup - DNS Lookup

```batch
nslookup %DOMAIN%
```

Mnemonic: "bn" (Batch Network) + "nslookup" (DNS lookup command)

### bnnetstat - Network Statistics

```batch
netstat -an
```

Mnemonic: "bn" (Batch Network) + "netstat" (network statistics command)

### bndownload - Download File

```batch
bitsadmin /transfer mydownloadjob /download /priority normal %URL% %DESTINATION%
```

Mnemonic: "bn" (Batch Network) + "download" (download operation)

### bnshare - List Network Shares

```batch
net share
```

Mnemonic: "bn" (Batch Network) + "share" (network shares)

### bnuser - List Network Users

```batch
net user
```

Mnemonic: "bn" (Batch Network) + "user" (network users)

### bnroute - Display Routing Table

```batch
route print
```

Mnemonic: "bn" (Batch Network) + "route" (routing table)

### bnfirewall - Firewall Status

```batch
netsh advfirewall show allprofiles
```

Mnemonic: "bn" (Batch Network) + "firewall" (firewall status)

### bnwifi - List WiFi Networks

```batch
netsh wlan show networks
```

Mnemonic: "bn" (Batch Network) + "wifi" (WiFi networks)

## Best Practices

1. Always run network-altering commands with appropriate permissions.
2. Be cautious when using commands that modify network settings.
3. Consider adding error handling for network operations.
4. Use variables to make network scripts more flexible and reusable.
