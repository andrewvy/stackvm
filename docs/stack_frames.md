### Stack Frames / Calling Functions

stack-based and register-based interpreters follow this sort of convention:

```
.def main: args=0 locals=0 ; void main()
  call f()
  halt
.def f: args=0, locals=0 ; void f()
  call g()
  ret
.def g: args=0, locals=0 ; void g()
  ret
```

`main`
-> calls `f()`
   -> calls `g()`

Before `g()` returns, we have three stack frames on the `call stack` (`main`, `f`, and `g`).

A stack frame is an object that tracks information about a function call.

For both types of intepreters (stack/register), these store parameters, local variables and the return address.

After each `call`, the call stack grows by one stack frame.

After each `return`, the call stack shrinks by one stack frame.

---

### Parameters

The `call` instruction expects parameters to be on the operand stack. When `call` pushes
a stack frame, space is created for parameters and local variables. Then, the parameters
are moved from the operand stack into the stack frame, based on the FunctionDescriptor

```
.def main: args=0, locals=0
0001  iconst 10 ; stack=[10]    callstack=[main]
0003  iconst 20 ; stack=[10 20] callstack=[main]
0004  call f()  ; stack=[10 20] callstack=[main f]
0005  print     ; stack=[30]    callstack=[main]
0006  halt
.def f: args=2, locals=0
0007  load 0    ; stack[10]     args[10 20] returnaddress=0005
0009  load 1    ; stack[10 20]  args[10 20] returnaddress=0005
0011  iadd      ; stack[30]     args[10 20] returnaddress=0005
0012  ret
```

---

### Locals

Locals are an allocated space in a call stack frame to store variables.

```
.def main: args=0, locals=0
  iconst 10
  iconst 20
  call f()
  halt
.def f: args=2, locals=1
  load 0
  load 1
  imul
  store 2 ; store in locals [ 0 * 1 ]
  load 2
  iconst 150
  ifgt
  print
  pop
  ret
```

equivalent to

```
main() {
  f(10, 20);
}

f(int a, int b) {
  var c;
  c = a * b;
  if (c < 150) {
    print(c);
  }
}
```
