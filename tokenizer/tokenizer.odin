package tokenizer

import "core:fmt"
import "core:os"
import "../config"

/*
to make things more simple, use an array
Token_Type :: enum { EOF, Newline }
tokens : [Token_Type]string = { .EOF = "", .Newline = "\n" }
*/

Token :: config.Token
Token_type :: config.Token_type
Commands_list :: config.init_commands

Lex :: struct {
    data: []u8,
    offset: int,
    tokens: [dynamic]Token,
}

/*
@(test)
test :: proc() {
    input := "a=69420\nmyIdentifier1\nif a != 69420 print \"rofl\"\nelse goto \"myIdentifier1\"/"
    lex := lexer_init(input)
    scan_tokens(&lex)
    for tk in lex.tokens {
        fmt.println(tk)
    }
    destroy_lexer(&lex)
}
*/

lexer_init :: proc(input: []u8) -> Lex {
    lex := Lex{
        data = transmute([]u8)input,
        tokens = make([dynamic]Token),
    }
    return lex
}

destroy_lexer :: proc(l: ^Lex) {
    clear(&l.tokens)
    l.data = {}
    l.offset = 0
}

scan_tokens :: proc(lx: ^Lex) {
    for !is_at_end(lx) { get_token(lx) }
    append(&lx.tokens, Token{offset = lx.offset, type = .EOF})
    labels(lx.tokens[:])
}

@(private)
next :: proc(lx: ^Lex) -> u8 #no_bounds_check {
    next: u8
    if lx.offset < len(lx.data) {
        next = lx.data[lx.offset]
        lx.offset += 1
    }
    return next
}

@(private)
next_token :: proc(tk_list: []Token, idx: ^int) -> Token_type #no_bounds_check {
    last: Token_type
    if idx^ < len(tk_list) {
        last = tk_list[idx^].type
        idx^ += 1
    }
    return last        
}

@(private)
peek :: proc(lx: ^Lex) -> u8 #no_bounds_check {
    if lx.offset + 1 > len(lx.data) {
        return 0
    } else {
    return lx.data[lx.offset]
    }
}

@(private)
get_token :: proc(lx: ^Lex) {
    char := next(lx)
    seen_dot: bool

    if is_whitespace(char) {return} // do nothing it's not a token
    start := lx.offset - 1
    switch char {
        case '\\':
            append(&lx.tokens, Token{start, .ANTISLASH, "\\"})
        case ';':
            append(&lx.tokens, Token{start, .SEMICOLON, ";"})
        case '=':
            append(&lx.tokens, Token{start, .EQ, "="})
        case '<':
            append(&lx.tokens, Token{start, .REDIRECT_BACKWARD, "<"})
        case '>':
            append(&lx.tokens, Token{start, .REDIRECT_FORWARD, ">"})
        case '.':
            if peek(lx) == '.' {
                append(&lx.tokens, Token{start, .DOTDOT, ".."})
                next(lx)
            } else {
                append(&lx.tokens, Token{start, .DOT, "."})
            }
        case '|':
            append(&lx.tokens, Token{start, .OR, "|"})
        case '&':
            append(&lx.tokens, Token{start, .AND, "&"})
        case '"':
            to_end_line(lx, '"')
            append(&lx.tokens, Token{start, .STRING, cast(string)lx.data[start+1:lx.offset]})
            next(lx)
        case '{':
            to_end_line(lx, '}')
            append(&lx.tokens, Token{start, .CURLY_BRACES, cast(string)lx.data[start+1:lx.offset]})
            next(lx)
        case '(':
            to_end_line(lx, ')')
            append(&lx.tokens, Token{start, .PARENTHESES, cast(string)lx.data[start+1:lx.offset]})
            next(lx)
        case '-':
            to_end_line(lx, 32)
            append(&lx.tokens, Token{start, .IDENT, cast(string)lx.data[start:lx.offset]})
            next(lx)
        case '0'..='9':
            for is_digit(peek(lx)) || is_dot(peek(lx)) {
                if is_dot(peek(lx)) == true && seen_dot == true { 
                    abort(fmt.tprintf("Expected ., got .."))
                }
                if is_dot(peek(lx)) == true && seen_dot != true {
                    seen_dot = true
                }
                next(lx)
                if is_at_end(lx) {
                    next(lx)
                    break
                }
            }
            append(&lx.tokens, Token{start, .NUMBER, cast(string)lx.data[start:lx.offset]})
            next(lx)
        case 'a'..='z', 'A'..='Z':
            for is_alphanumeric(peek(lx)) {
                next(lx)
                if is_at_end(lx) {
                    next(lx)
                    break
                }
            }
            append(&lx.tokens, Token{start, tokenize(cast(string)lx.data[start:lx.offset]), cast(string)lx.data[start:lx.offset]})
        // default case
        case: abort(fmt.tprintf("Unknown token: %c", char))
    }
}

@(private)
abort :: proc(s: string) {
    fmt.eprintf("\nLexer error!\t%s\n", s)
    os.exit(1)
}

@(private)
tokenize :: proc(str: string) -> Token_type {
    cmd_list := Commands_list()
    temp: Token_type
    for tk, index in cmd_list {
        if str == tk.name {
            temp = transmute(Token_type)index
        } else {
            temp = .IDENT
        }
    }
    return temp
}

@(private)
is_alpha :: proc(c: u8) -> bool {
    switch c {
        case 'a'..='z', 'A'..='Z': return true
        case: return false
    }
}

@(private)
is_alphanumeric :: proc(c: u8) -> bool {
    return is_digit(c) || is_alpha(c)
}

@(private)
is_whitespace :: proc(c: u8) -> bool {
    return c == ' ' || c == '\n' || c == '\r' || c == '\t'
}

@(private)
is_digit :: proc(c: u8) -> bool {
    for i in '0'..='9' { if cast(rune)c == i {return true} }
    return false
}

@(private)
is_dot :: proc(c: u8) -> bool {
    return cast(rune)c == '.'
}

@(private)
labels :: proc(tk_list: []Token) {
    index: int = 0
    for index < len(tk_list) {
        if tk_list[index].type == .IDENT {
            next_token(tk_list, &index)
            #partial switch tk_list[index].type {
                case .IDENT, .STRING:
                    tk_list[index].type = .PARAMETER
                    next_token(tk_list, &index)
                case .EQ:
                    tk_list[index-1].type = .LABEL
                    next_token(tk_list, &index)
                    if tk_list[index].type == .EOF {
                        abort(fmt.tprintf("Cannot assign '%s' to '%s'.", tk_list[index].type, tk_list[index-1].type))
                    }
                case .REDIRECT_FORWARD, .REDIRECT_BACKWARD, .AND, .OR:
                    break
                case:
                    abort(fmt.tprintf("Invalid expression, got '%s' after '%s'.", tk_list[index].type, tk_list[index-1].type))
            }
        } else {
            break
        }
    }
}

@(private)
to_end_line :: proc(lx: ^Lex, stp: byte) {//rune) {
    for peek(lx) != stp {//cast(u8)stp {
        next(lx)
        if is_at_end(lx) {
            next(lx)
            break
        }
    }
}

@(private)
is_at_end :: proc(lx: ^Lex) -> bool {
    return lx.offset >= len(lx.data)
}
