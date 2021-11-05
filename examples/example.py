import pythonnative.Foo.pyFoo as foo
print(f'pyFoo: ${dir(foo)}')

p = foo.IntPair(3, 5)
print(f"class IntPair: {dir(p)}")
print(f"p: {p}")

foo.free_function(2147483647) # max int
foo.free_function(2147483647+1) # max int + 1

f = foo.Foo()
print(f'class Foo: ${dir(f)}')
f.static_function(1)
f.static_function(2147483647)
f.static_function(2147483647+1)

f.set_int(13)
assert(f.get_int() == 13)

f.set_int64(31)
assert(f.get_int64() == 31)
