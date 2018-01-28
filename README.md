# Carp
An easy, clean language that transpiles to C#.

## What is Carp?
Carp is a new, clean coding language that transpiles to C# code.
It is inspired by languages such as Red, Python and Kotlin.

## Why is Carp?
Carp is intended to be an easier language for those getting into mid-tier programming.

## Using the Carp transpiler:
The Carp transpiler is the program that turns Carp code into C# code.
You can download it from the releases page, or get the latest version by building from the source.

Once you have the transpiler program, simply open a terminal and type: `carp.exe --help`. The program will then tell you the accepted arguments and what they do.

If you would like to transpile a file, you give it the file argument and then the file you want, by entering: `carp.exe --file=file.carp` or `carp.exe -f=file.carp`, where "file.carp" is your Carp script.

## Building from source:
To build the transpiler from source, you will need:
- Python 3.6
- ANTLR4
- PyInstaller

After installing those, you just need to run `carp.bat` to generate the ANTLR lexer and parser, and then run `build.bat` to build the binary with PyInstaller.

### Inspired By:
- Python
- Kotlin
- Red
