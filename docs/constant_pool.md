### Constant Pool

Since all instruction operands must be integers / convertible to integers, we
run into a problem with strings. Strings cannot fit in the space of an integer,
so we must store them outside of the code.

Bytecode interpreters store these non-integer constants in a `constant pool`,
in which we use an `index` to access the `constant pool`.

These non-integer constants can be: `strings`, `floats`, and even `function descriptions`.

### Function Descriptions

Descriptions of functions are stored in the constant pool with relative information
about their arity, and how many local variables they need.

```
  sconst "hello"
  call f()
  halt
.def f: args=1, locals=0
  load 0
  print
  ret
```

This assembly gets converted, and the function descriptor is stored as:

```
sconst 0 ; points to 0 in the constant pool
call 1   ; points to 1 in the constant pool
halt
print
ret
```

```
------------------------------
|       CONSTANT POOL         |
|-----------------------------|
|0    |         "hello"       |
|-----------------------------|
|1    |   FunctionDescriptor  |
|     |   name="f", args=1,   |
|     |   locals=0, addr=11   |
|_____________________________|
```
