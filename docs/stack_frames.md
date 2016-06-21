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
