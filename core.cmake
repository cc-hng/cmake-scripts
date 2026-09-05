include(${CMAKE_CURRENT_LIST_DIR}/c++-standards.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/c-standards.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/compiler-options.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/link-time-optimization.cmake)

c_99()
set(CMAKE_POSITION_INDEPENDENT_CODE TRUE) # -fPIC

# Default to -O2 on release builds.
# if(CMAKE_CXX_FLAGS_RELEASE MATCHES "-O3")
#   message(STATUS "Replacing -O3 in CMAKE_C_FLAGS_RELEASE with -O2")
#   string(REPLACE "-O3" "-O2" CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")
#   string(REPLACE "-O3" "-O2" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
# endif()

if (CMAKE_CXX_FLAGS_RELWITHDEBINFO MATCHES " -g ")
  string(REPLACE " -g " " -g1 " CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}")
  string(REPLACE " -g " " -g1 " CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
endif()

# being a cross-platform target, we enforce standards conformance on MSVC all compile:
# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_ID.html
if (LINUX)
  if (NOT CMAKE_CROSSCOMPILING)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native -mtune=native -Wno-narrowing")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=native -mtune=native -Wno-narrowing")
  endif()

  # set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ftree-vectorize -funroll-loops")
  # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ftree-vectorize -funroll-loops")

  foreach(v EXE SHARED MODULE)
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      set(CMAKE_${v}_LINKER_FLAGS "${CMAKE_${v}_LINKER_FLAGS} -static-libstdc++ -static-libgcc")
    endif()
  endforeach()

elseif(MSVC)
  set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} /permissive-")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /permissive-")

endif()

if((CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    AND NOT CMAKE_CXX_COMPILER MATCHES "zig$")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
endif()

# 去重编译器 flags
function(my_dedup_flags VAR)
    if(NOT DEFINED ${VAR})
        return()
    endif()

    # 取出原始变量内容
    set(_raw "${${VAR}}")

    # 拆成 list
    separate_arguments(_list UNIX_COMMAND "${_raw}")

    # 去重
    list(REMOVE_DUPLICATES _list)

    # 拼回字符串
    string(REPLACE ";" " " _clean "${_list}")

    # 写回原变量（PARENT_SCOPE 确保写回调用者作用域）
    set(${VAR} "${_clean}" PARENT_SCOPE)
endfunction()

my_dedup_flags(CMAKE_C_FLAGS)
my_dedup_flags(CMAKE_CXX_FLAGS)
my_dedup_flags(CMAKE_EXE_LINKER_FLAGS)
my_dedup_flags(CMAKE_MODULE_LINKER_FLAGS)
my_dedup_flags(CMAKE_STATIC_LINKER_FLAGS)
my_dedup_flags(CMAKE_SHARED_LINKER_FLAGS)
