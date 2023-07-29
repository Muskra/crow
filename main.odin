package main

import "core:fmt"
import "core:os"
import "tokenizer"
import "parser"
/*

TODO: user input when the interpreter flag is used, is conflicting with the --file
	buf: [256]byte
	fmt.println("Please enter some text:")
	n, err := os.read(os.stdin, buf[:])
	if err < 0 {
		// Handle error
		return
	}
	str := string(buf[:n])
	fmt.println("Outputted text:", str)
*/

main :: proc() {

    file_path: string
    seen_path: bool
    arguments := os.args

    if len(arguments) == 1 {argument_help()}

    index := 0
    for ; index < len(arguments) ; index += 1 {
        if seen_path == true {break}
        if index != 0 {
            switch arguments[index] {
                case "--file":
                    if index < len(arguments)-1 {
                        file_path = arguments[index+1]
                        seen_path = true
                    } else {
                        fmt.eprintln(fmt.tprintf("error: '%s' require path.\nTry '--help' for more informations.\n", arguments[index]))
                        os.exit(1)
                    }
                case "--help":
                    argument_help()
                case:
                    argument_error(arguments[index])
            }
        }
    }
    file_scanner(file_path)
}

file_scanner :: proc(path: string) {
    bytes, ok := os.read_entire_file_from_filename(path)
    if !ok {
        fmt.eprintf("'%s': No such file or directory\nTry '--help' for more informations.\n", path)
        os.exit(1)
    }
    defer delete(bytes)
    
    lexer := tokenizer.lexer_init(bytes)
    defer tokenizer.destroy_lexer(&lexer)
    
    tokenizer.scan_tokens(&lexer)
    parser.parse(lexer.tokens[:])
    /*for tk in lexer.tokens[:] {
        fmt.println(tk)
    }*/
}

argument_help :: proc() {
    help_message := `crow [OPTION]...
crow compiler.

--file      file path for the program to read.
--help      display this help message then quit.`
    fmt.eprintln(help_message)
    os.exit(1)
}

argument_error :: proc(arg: string) {
    fmt.eprintln(fmt.tprintf("basic: invalid option %s\nTry '--help' for more informations.\n", arg))
    os.exit(1)
}
