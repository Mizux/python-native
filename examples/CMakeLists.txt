if(NOT BUILD_EXAMPLES)
  return()
endif()

file(GLOB PYTHON_SRCS "*.py")
foreach(FILE_NAME IN LISTS PYTHON_SRCS)
  add_python_example(${FILE_NAME})
endforeach()
