## Overview

This category covers snippets for variable manipulation in Batch scripting. The prefix for these snippets is `bv` (Batch Variable).

## Snippets

### bvset - Set Variable

```batch
set "VARIABLE_NAME=VALUE"
````

Mnemonic: "bv" (Batch Variable) + "set" (set)

### bvsetd - Set Variable with Delayed Expansion

```batch
setlocal enabledelayedexpansion
set "VARIABLE_NAME=VALUE"
echo !VARIABLE_NAME!
```

Mnemonic: "bv" (Batch Variable) + "setd" (set delayed)

### bvapp - Append to Variable

```batch
set "VARIABLE_NAME=%VARIABLE_NAME%%VALUE_TO_APPEND%"
```

Mnemonic: "bv" (Batch Variable) + "app" (append)

### bvmath - Perform Math Operation

```batch
set /a "RESULT=EXPRESSION"
```

Mnemonic: "bv" (Batch Variable) + "math" (math)

### bvenv - Get Environment Variable

```batch
set "VARIABLE_NAME=%ENVIRONMENT_VARIABLE%"
```

Mnemonic: "bv" (Batch Variable) + "env" (environment)

### bvfor - For Loop Variable

```batch
for %%i in (VALUES) do (
    echo %%i
)
```

Mnemonic: "bv" (Batch Variable) + "for" (for loop)

### bvarg - Command Line Argument

```batch
set "ARG1=%1"
set "ARG2=%2"
```

Mnemonic: "bv" (Batch Variable) + "arg" (argument)

### bvif - Check If Variable Is Defined

```batch
if defined VARIABLE_NAME (
    echo Variable is defined
) else (
    echo Variable is not defined
)
```

Mnemonic: "bv" (Batch Variable) + "if" (if check)

## Best Practices

1. Always use quotes when setting string variables to avoid issues with spaces.
2. Use /a flag with set for arithmetic operations.
3. Remember to use delayed expansion when modifying variables within loops or conditional blocks.
