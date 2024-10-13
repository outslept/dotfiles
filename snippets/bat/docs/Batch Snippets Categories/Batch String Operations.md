## Overview

This category covers snippets for string manipulation in Batch scripting. The prefix for these snippets is `bs` (Batch String).

## Snippets

### bslen - Get String Length

```batch
set "str=%STRING_TO_MEASURE%"
set "len=0"
:loop
if defined str (
    set "str=%str:~1%"
    set /a "len+=1"
    goto :loop
)
echo String length: %len%
```

**Mnemonic:** "bs" (Batch String) + "len" (length)

### bssub - Extract Substring

```batch
set "result=%STRING:~START_INDEX,LENGTH%"
```

**Mnemonic:** "bs" (Batch String) + "sub" (substring)

### bsrep - Replace String

```batch
set "result=%STRING:OLD_TEXT=NEW_TEXT%"
```

**Mnemonic:** "bs" (Batch String) + "rep" (replace)

### bsupp - Convert to Uppercase

```batch
set "result=%STRING%"
for %%i in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do call set "result=%%result:%%i=%%i%%"
```

**Mnemonic:** "bs" (Batch String) + "upp" (uppercase)

### bslow - Convert to Lowercase

```batch
set "result=%STRING%"
for %%i in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do call set "result=%%result:%%i=%%i%%"
```

**Mnemonic:** "bs" (Batch String) + "low" (lowercase)

### bstrim - Trim Whitespace

```batch
set "result=%STRING%"
for /f "tokens=* delims= " %%a in ("%result%") do set "result=%%a"
for /l %%a in (1,1,100) do if "!result:~-1!"==" " set "result=!result:~0,-1!"
```

**Mnemonic:** "bs" (Batch String) + "trim" (trim)

### bssplit - Split String

```batch
for %%i in (%STRING%) do (
    echo %%i
)
```

**Mnemonic:** "bs" (Batch String) + "split" (split)

### bsconcat - Concatenate Strings

```batch
set "result=%STRING1%%STRING2%"
```

**Mnemonic:** "bs" (Batch String) + "concat" (concatenate)

## Best Practices

1. Use delayed expansion when working with variables inside loops.
2. Be cautious with special characters in strings; escape them when necessary.
3. Remember that Batch is case-insensitive for commands but preserves case for string content.
   x
