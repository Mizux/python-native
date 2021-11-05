if(NOT BUILD_EXAMPLES)
  return()
endif()

file(GLOB CXX_SRCS "*.cc")
foreach(FILE_NAME IN LISTS CXX_SRCS)
  add_cxx_example(${FILE_NAME})
endforeach()

file(GLOB PYTHON_SRCS "*.py")
foreach(FILE_NAME IN LISTS PYTHON_SRCS)
  add_python_example(${FILE_NAME})
endforeach()
