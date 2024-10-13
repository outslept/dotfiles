## Overview

This category covers snippets for control structures in Batch scripting. The prefix for these snippets is `bc` (Batch Control).

## Snippets

### bcif - If Statement

```batch
if %CONDITION% (
    REM Commands to execute if condition is true
) else (
    REM Commands to execute if condition is false
)
````

**Mnemonic:** "bc" (Batch Control) + "if" (if statement)

### bcfor - For Loop

```batch
for %%i in (ITEMS) do (
    REM Commands to execute for each item
)
```

**Mnemonic:** "bc" (Batch Control) + "for" (for loop)

### bcforr - For Loop with Range

```batch
for /l %%i in (START,STEP,END) do (
    REM Commands to execute for each number in the range
)
```

**Mnemonic:** "bc" (Batch Control) + "forr" (for range)

### bcforf - For Loop with Files

```batch
for /f "tokens=* delims=" %%i in ('dir /b') do (
    REM Commands to execute for each file
)
```

**Mnemonic:** "bc" (Batch Control) + "forf" (for files)

### bcwhile - While Loop

```batch
:while
if %CONDITION% (
    REM Commands to execute while condition is true
    goto :while
)
```

**Mnemonic:** "bc" (Batch Control) + "while" (while loop)

### bcgoto - Goto Statement

```batch
goto :LABEL
:LABEL
REM Commands to execute
```

**Mnemonic:** "bc" (Batch Control) + "goto" (goto statement)

### bccall - Call Subroutine

```batch
call :SUBROUTINE
exit /b

:SUBROUTINE
REM Subroutine commands
exit /b
```

**Mnemonic:** "bc" (Batch Control) + "call" (call subroutine)

### bcerr - Error Handling

```batch
if errorlevel 1 (
    echo An error occurred
    exit /b 1
)
```

**Mnemonic:** "bc" (Batch Control) + "err" (error handling)

### bcswitch - Switch-like Structure

```batch
if "%VARIABLE%"=="CASE1" (
    REM Commands for CASE1
) else if "%VARIABLE%"=="CASE2" (
    REM Commands for CASE2
) else (
    REM Default case
)
```

**Mnemonic:** "bc" (Batch Control) + "switch" (switch-like structure)

## Best Practices

1. Use parentheses to group commands in control structures.
2. Be mindful of variable expansion in loops and conditionals.
3. Use labels and subroutines to organize complex scripts.
4. Always include error handling in your scripts.
