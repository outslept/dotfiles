## Overview

This category covers snippets for common file operations in Batch scripting. The prefix for these snippets is `bf` (Batch File).

## Snippets

### bfcopy - Copy File

```batch
copy "%SOURCE_FILE%" "%DESTINATION_FILE%"
````

Mnemonic: "bf" (Batch File) + "copy" (action)

### bfmove - Move File

```batch
move "%SOURCE_FILE%" "%DESTINATION_FILE%"
```

Mnemonic: "bf" (Batch File) + "move" (action)

### bfdel - Delete File

```batch
del "%FILE_TO_DELETE%"
```

Mnemonic: "bf" (Batch File) + "del" (abbreviated action)

### bfren - Rename File

```batch
ren "%OLD_FILENAME%" "%NEW_FILENAME%"
```

Mnemonic: "bf" (Batch File) + "ren" (abbreviated action)

### bfdir - List Directory Contents

```batch
dir "%DIRECTORY_PATH%"
```

Mnemonic: "bf" (Batch File) + "dir" (command name)

### bfmd - Make Directory

```batch
mkdir "%NEW_DIRECTORY%"
```

Mnemonic: "bf" (Batch File) + "md" (abbreviated command)

### bfrd - Remove Directory

```batch
rmdir "%DIRECTORY_TO_REMOVE%"
```

Mnemonic: "bf" (Batch File) + "rd" (abbreviated command)

### bftype - Display File Contents

```batch
type "%FILE_TO_DISPLAY%"
```

Mnemonic: "bf" (Batch File) + "type" (command name)

### bffc - File Comparison

```batch
fc "%FILE1%" "%FILE2%"
```

Mnemonic: "bf" (Batch File) + "fc" (File Compare)

### bfxcopy - Extended Copy

```batch
xcopy "%SOURCE%" "%DESTINATION%" /E /I /Y
```

Mnemonic: "bf" (Batch File) + "xcopy" (extended copy command)

## Best Practices

1. Always use quotation marks around file and directory names to handle spaces and special characters.
2. Use descriptive variable names for better readability.
3. Consider adding error handling for file operations.
