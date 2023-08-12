# crow
Here is everything you'll need to know before reading source code, any help is appreciated, i'm in a phase of testing the parser and it's reliability.

## why "crow" ?
I'm coding it in Odin, named after the God Odin and if you don't know, he always sends crows in Midgard to take informations that they retrieve back to him.
* if you want to learn more about Odinlang: https://odin-lang.org
* if you want to learn more about the crows of odin: https://en.wikipedia.org/wiki/Huginn_and_Muninn

## Introduction
Crow will be a simple shell interpreter that compiles multiple Odin's libraries into one executable that support a custom shell language.
I love shell programs and using them so i'm doing mine. It seem's that everything is related to system needs in every one of them (sh, bash, ash, ...) and everything you do in them could make some interaction with kernel spaces or user spaces. 

So why i'm doing YET ANOTHER one ? 
* I'm doing so because i want a shell that don't need to interact explicitly with an os (you can implement it if you wanted to)
* It also needs to be customizable enought to support any commands i want
* I want to make it Simple Stupid part of that is because i'm learning programming for fun on my spare time

## Goals
It can basically be an HCI where you could:
* interfacing and test two (or more) programs and their interactions with each other
* making some interactive toolsuite for your devs or any other TUI purposes
* isolate an application from a shell if you want to execute it in this third party
* honeypot building

## What's implemented yet
Actually it's in a Work In Progress stage, there is not a lot to play with yet in the program, as far as i know i implemented:
* a "--file" switch to read scripts, interactive usage will come later as it's simpler to test for now this way
* a tokenizer to handle text as instructions
* a parser which prepare the instructions to be executed, the algorithm choosen for this is Reverse Polish Notation, a shell language should not be hard to parse, so i use only simple operations

> Note that the parser is somewhat bugged in some specific cases, i'm in the way of implementing it properly, any help is appreciated :)

### Usage

Token|Description|
|---|---|
|EOF|`is the end of file, no char to describe this special character`|
|NEWLINE|`\n`|
|ANTISLASH|`\`|
|IDENT|`identifier of a keyword, a label or anything that was not tokenized. contain only alphanumeric characters`|
|LABEL|`is a container of either an int or a string`|
|STRING|`abc...xyz or ABC...XYZ`|
|NUMBER|`0123456789`|
|PARENTHESES|`()`|
|CURLY_BRACES|`{}`|
|BRACKETS|`[]`|
|AND|`&`|
|SEMICOLON|`;`|
|OR|`|`|
|DOT|`.`|
|DOTDOT|`..`|
|EQ|`=`|
|REDIRECT_FORWARD|`>`|
|REDIRECT_BACKWARD|`<`|

The `()` and `{}` are containers which encapsulate other commands (not defined yet which one will do what for now) named sub-level commands.
Note that there is also no pipes, everything is pure redirection like `return` does in lots of programming languages, the `<` and `>` will only affect the priority and the direction it will go. There is no `&&` for now, i think it will be the normal case because it's safer, and will be `;` to chain commands.
As i'm only implementing simple things for now, i think `strings` or any other variables "containers" will no be implemented first, i only focused on logical operations.
