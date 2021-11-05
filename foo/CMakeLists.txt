add_library(foo)
target_sources(foo
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/foo/Foo.hpp>
  PRIVATE
    src/Foo.cpp
  )
target_include_directories(foo
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
  )
target_compile_features(foo PUBLIC cxx_std_11)
set_target_properties(foo PROPERTIES
  VERSION ${PROJECT_VERSION}
  PUBLIC_HEADER $<TARGET_PROPERTY:foo,INTERFACE_SOURCES>
  )
#target_link_libraries(foo PUBLIC ...)
add_library(${PROJECT_NAMESPACE}::foo ALIAS foo)

if(BUILD_TESTING)
  add_subdirectory(tests)
endif()

# Install
install(TARGETS foo
  EXPORT ${PROJECT_NAME}Targets
  PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/foo
  )
