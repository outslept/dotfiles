## Overview

This category covers snippets for system-level operations in Batch scripting. The prefix for these snippets is `by` (Batch sYstem).

## Snippets

### bysysinfo - System Information

```batch
systeminfo
````

Mnemonic: "by" (Batch sYstem) + "sysinfo" (system information)

### byproc - List Processes

```batch
tasklist
```

Mnemonic: "by" (Batch sYstem) + "proc" (processes)

### bykill - Terminate Process

```batch
taskkill /F /IM %PROCESS_NAME%
```

Mnemonic: "by" (Batch sYstem) + "kill" (terminate process)

### byservice - List Services

```batch
sc query
```

Mnemonic: "by" (Batch sYstem) + "service" (services)

### bystart - Start Service

```batch
sc start %SERVICE_NAME%
```

Mnemonic: "by" (Batch sYstem) + "start" (start service)

### bystop - Stop Service

```batch
sc stop %SERVICE_NAME%
```

Mnemonic: "by" (Batch sYstem) + "stop" (stop service)

### byreboot - Reboot System

```batch
shutdown /r /t 0
```

Mnemonic: "by" (Batch sYstem) + "reboot" (reboot system)

### byshutdown - Shutdown System

```batch
shutdown /s /t 0
```

Mnemonic: "by" (Batch sYstem) + "shutdown" (shutdown system)

### bydate - Current Date

```batch
echo %date%
```

Mnemonic: "by" (Batch sYstem) + "date" (current date)

### bytime - Current Time

```batch
echo %time%
```

Mnemonic: "by" (Batch sYstem) + "time" (current time)

### bydisk - Disk Information

```batch
wmic logicaldisk get size,freespace,caption
```

Mnemonic: "by" (Batch sYstem) + "disk" (disk information)

### byenv - Environment Variables

```batch
set
```

Mnemonic: "by" (Batch sYstem) + "env" (environment variables)

## Best Practices

1. Always run system-altering commands with appropriate permissions.
2. Be cautious when using commands that modify system settings or terminate processes.
3. Consider adding confirmation prompts for potentially dangerous operations.
4. Use variables to make system scripts more flexible and reusable.
