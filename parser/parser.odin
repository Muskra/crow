package parser

import "core:fmt"
import "core:os"
//import "core:slice"
import "../config"

// aliases of tokenizer's structs
Token :: config.Token
Token_type :: config.Token_type
cmd_list :: config.init_commands
Command :: config.Command

//background :: commands.background()
//and :: commands.and()
//sequence :: commands.sequence()
//dot :: commands.dot()
//dotdot :: commands.dotdot()
//pipe :: commands.pipe()
//or :: commands.or()

/*
// examples from Ian and Jacob
My_Enum :: enum {
    foo,
    bar,
    baz,
}

// version A
arr: [3]int
arr[int(My_Enum.foo)] = 123

// version B with enumerated array
arr: [My_Enum]int
arr[.foo] = 12

// version C as an empty array
proc_table: [Token_Type]proc(...)
// then add new values
proc_table[.foo] = foo()
*/

parse :: proc(tk_list: []Token) {
    
    for i in tk_list {
        fmt.print(i.text, "")
    }
    fmt.println("\n")
    splitted: [dynamic][]Token
    step: int

    for tk, index in tk_list[:] {
        if tk.type == .SEMICOLON || tk.type == .EOF {
            if step == 0 {
                append(&splitted, tk_list[:index])
                step = index
            } else {
                append(&splitted, tk_list[step:index])
                step = index
            }
        }
    }

    for list in splitted {
        to_reverse_polish_notation(list[:])
    }
}

@(private)
to_reverse_polish_notation :: proc(tk_list: []Token) {
    cmds := cmd_list()
    operands := make([dynamic]Token)
    stack := make([dynamic]Token)

    for tk in tk_list {
        #partial switch tk.type {
            case .EOF, .SEMICOLON:
                break
            case .AND, .OR:
                if len(operands) == 0 {
                    append(&operands, tk)
                } else {
                    #reverse for op, index in operands {
                        if op.type == .REDIRECT_FORWARD || op.type == .REDIRECT_BACKWARD {
                            if index == 0 {
                                append(&stack, op)
                                shrink(&operands, index)
                                append(&operands, tk)
                            } else {
                                append(&stack, op)
                            }
                        } else {
                            shrink(&operands, index)
                            append(&operands, tk)
                            break
                        }
                    }
                }
            case .REDIRECT_FORWARD, .REDIRECT_BACKWARD:
                append(&operands, tk)
            case:
                append(&stack, tk)
        }
    }
    #reverse for op in operands {
        append(&stack, op)
    }
    for tk in stack {
        fmt.printf("%s ", tk.text)
    }
    fmt.println("\n")
}

@(private)
peek_command :: proc(commands: [Token_type]Command, tk: Token) -> Command #no_bounds_check {
    return commands[tk.type]
}

@(private)
abort :: proc(s: string) {
    fmt.eprintf("\nParser error!\t%s\n", s)
    os.exit(1)
}
