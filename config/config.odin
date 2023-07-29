package config

import "../commands"

// maybe need to put all those structs in a dedicated package to prevent misunderstands from the user
Command :: struct {
    name: string,
    call: bool,
}

Token :: struct {
    offset: int,
    type: Token_type,
    text: string,
}

Token_type :: enum {
    // the antislash have a priority of 0
    ANTISLASH,
    // the others have no priority
    EOF,
	NEWLINE,
    IDENT,
	LABEL,
    PARAMETER,
    // containers, have no priority
    STRING,
    NUMBER,
    PARENTHESES,
    CURLY_BRACES,
    BRACKETS,
    // Special chars, priority of 1
    AND,
    SEMICOLON,
    OR,
    DOT,
    DOTDOT,
    EQ,
    REDIRECT_FORWARD,
    REDIRECT_BACKWARD,
    // Commands
}

// this is where the user declares the custom commands for the program to execute 
init_commands :: proc() -> [Token_type]Command {
    cmd_list := #partial [Token_type]Command{
        // special characters
        .AND               = {name = "&", call = commands.and()},
        .SEMICOLON         = {name = ";", call = commands.sequence()},
        .OR                = {name = "|", call = commands.or()},
        .REDIRECT_FORWARD  = {name = ">", call = commands.redirect_forward()},
        .REDIRECT_BACKWARD = {name = ">", call = commands.redirect_backward()}, 
        // containers
        .PARENTHESES       = {name = "(", },
        .CURLY_BRACES      = {name = "{", },
        .BRACKETS          = {name = "[", },
        // custom commands
    }
    return cmd_list
}
