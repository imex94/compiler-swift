# Compiler, implemented in Swift 2

*Under Development*

A small compiler, implemented in Swift 2, with regular expressions implemented for the Lexer, using Brzozowski derivatives and Sulzmann tokeniser. For Parser it uses Parser Combinators. 

The compiler generates Java Byte Code and runs on the JVM.

## An example program

```Swift
write "factorial";
read n;
fact := 1;
while (n > 1) do {
  fact := fact * n;
  n := n - 1
}
write "result";
write fact
```
