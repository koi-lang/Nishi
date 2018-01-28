# Nishi
An easy, clean language that transpiles to C#.

## What is Nishi?
Nishi is a new, clean coding language that transpiles to C# code.
It is inspired by languages such as Red, Python and Kotlin.

## Why is Nishi?
The name "Nishi" is a slice of the name of a type of Koi, called "Nishikigoi".

Nishi is intended to be an easier language for those getting into mid-tier programming.

## Using the Nishi transpiler
The Nishi transpiler is the program that turns Nishi code into C# code.
You can download it from the releases page, or get the latest version by building from the source.

Once you have the transpiler program, simply open a terminal and type: `nishi.exe --help`. The program will then tell you the accepted arguments and what they do.

If you would like to transpile a file, you give it the file argument and then the file you want, by entering: `nishi.exe --file=file.nishi` or `nishi.exe -f=file.nishi`, where "file.nishi" is your Nishi script.

## Building from source
To build the transpiler from source, you will need:
- Python 3.6
- ANTLR4
- PyInstaller

After installing those, you just need to run `nishi.bat` to generate the ANTLR lexer and parser, and then run `build.bat` to build the binary with PyInstaller.

### File Extensions:
- `.nishi`
- `.nish`
- `.kigoi`
- `.goi`
- `.lel`

### Inspired By:
- Python
- Kotlin
- Red
