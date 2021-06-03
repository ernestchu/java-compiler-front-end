# Java Compiler Front End
A Java compiler front end built with 

- Lex, compiled by [Flex](https://ftp.gnu.org/old-gnu/Manuals/flex-2.5.4/html_mono/flex.html)
- Yacc, compiled by [Bison](https://www.gnu.org/software/bison/)

## What is a compiler front end?

In the structure of a compiler, here's what will be implemented in this work.

- [x] Lexical analysis
- [x] Syntax analysis
- [ ] Interpretation
- [ ] Machine independent optimization
- [ ] Storage assignment
- [ ] Code generation
- [ ] Assembly and output

## Prerequisite Knowledge

This work requires **lots of** background knowledge. If you don't familiar with compiler construction tools, checkout the [corresponding section](tree/main/References#compiler-construction-tools) in the references.

Second, this work requires the knowledge of Java's grammar. In the [references](tree/main/References#the-java-programming-language), the BNF grammar and the LALR(1) version disambiguated from it are listed.

