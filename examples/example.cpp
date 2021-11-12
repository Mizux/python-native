#include <iostream>

#include <foo/Foo.hpp>

int main(int /*argc*/, char** /*argv*/) {
  foo::freeFunction(0);
  std::cout << std::endl;

  foo::Foo::staticFunction(int{0});
  std::cout << std::endl;

  return 0;
}
