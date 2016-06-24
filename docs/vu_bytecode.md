### vuscript bytecode
---

vy's unnamed scripting language

Instruction Set
---

| instruction    | opcode | operands             | description                         |
| -------------- | ------ | -------------------- | ----------------------------------- |
| iconst         | 0      | 1: value             | adds integer to stack               |
| iadd           |        | 0                    | pops 2 integers from the stack and pushes the added result on the stack |
| halt           | 0      | 0                    | halts                               |
| print          | 0      | 0                    | prints the top value from the stack |
| pop            | 0      | 0                    | pops the top value from the stack   |
| jump           | 0      | 1: address           | jumps to the given address          |
| is_eq          | 0      | 0                    | pops 2 integers, compare if equal, pushes result on stack |
| branch_if_true | 0      | 1: address           | pop stack, check if is 1 -> goes to given address |
| call           | 0      | 2: address, argcount | calls the given address, and pushes 'argcount' values from the stack onto the new callstack |
| return         | 0      | 0                    | returns from a call, pushes last value from the stack |
| loadstring     | 0      | 1: charlist          | loads given string into constant pool and puts reference onto the stack |
| printstring    | 0      | 0                    | pop stack, check referenced string in constant pool and prints it to stdio |
| debugprint     | 0      | 0                    | dumps the current CPU state |
