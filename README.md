# Java Compiler Front End
A Java compiler front end built with 

- Lex, compiled by [Flex](https://ftp.gnu.org/old-gnu/Manuals/flex-2.5.4/html_mono/flex.html)
- Yacc, compiled by [Bison](https://www.gnu.org/software/bison/)

## What is a Compiler Front End?

In the structure of a compiler, here's what will be implemented in this work.

- [x] Lexical analysis
- [x] Syntax analysis
- [ ] Interpretation
- [ ] Machine independent optimization
- [ ] Storage assignment
- [ ] Code generation
- [ ] Assembly and output

## Prerequisite Knowledge

This work requires **lots of** background knowledge. If you don't familiar with compiler construction tools, checkout the [corresponding section](References#compiler-construction-tools) in the references.

Second, this work requires the knowledge of Java's grammar. In the [references](References#the-java-programming-language), the BNF grammar and the LALR(1) version disambiguated from it are listed.

## Build

```sh
cd src
make
```

### Debugging Level

Use `make DEBUG=<level>` to enable debugging (default level = 0). For example

```sh
make DEBUG=1
```

- **Level 0:** Print the errors and warnings only.
- **Level 1:** Print the original source code and errors/warnings in the context. This also prints the symbol table.
- **Level 2:** Print the entire parsing process. This sets `yydebug=1` in the Yacc source file and generate `y.output`, which contains all of the states and rules.

## Test

Six testing files are included in the [TestingFiles](src/TestingFiles).

### Testing on a Single File

```sh
./JavaParser < TestingFiles/test1.java
```

### Testing all files by Concatenating Them

```sh
cat TestingFiles/* | ./JavaParser
```

## Using the Utilities

Two utilities generating auxiliary contents are included in [utils](src/utils). First, make them executable if they're not.

```sh
chmod +x utils/*
```
### List Tokens in the Lex Source File
This simply extracts the tokens after the keyword `return` and removes the duplicates.

```sh
./utils/ListTokens.sh B073040018.l
```

### List Optionals

In Yacc, we need to define rules for optionals additionally instead of simply using question mark `?`. This extracts all of the optionals and generates the rules.

```sh
./utils/ListOptionals.sh B073040018.y
```
