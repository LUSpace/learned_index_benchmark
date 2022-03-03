cmake_minimum_required (VERSION 3.12)
project (learned_index_benchmark)
set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

include(FetchContent)
include(ExternalProject)

find_package(OpenMP)
# find_package(GTest CONFIG REQUIRED)
find_package(MKL REQUIRED)
find_package(JeMalloc REQUIRED)
find_package(TBB REQUIRED)
# find_package(Gperftools REQUIRED)
# find_package(pmem REQUIRED)

# add_definitions(-DPMEM)
# add_definitions(-DPMDK)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(MKL_LIBRARIES "/opt/intel/mkl/lib/intel64")
set(MKL_INCLUDE_DIRS "/opt/intel/mkl/include")
include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-march=native" COMPILER_SUPPORTS_MARCH_NATIVE)
if (COMPILER_SUPPORTS_MARCH_NATIVE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native -lrt -lpthread -mrtm -msse4.1 -mavx2 -O3 -g -march=native -w -Wfatal-errors")
endif ()

# Set a default build type if none was specified
# https://blog.kitware.com/cmake-and-the-default-build-type/
set(default_build_type "Release")
if(EXISTS "${CMAKE_SOURCE_DIR}/.git")
    set(default_build_type "Debug")
endif()

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
    set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE
            STRING "Choose the type of build." FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
            "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

##################### Epoch Reclaim ####################
#FetchContent_Declare(
#        epoch_reclaimer
#        GIT_REPOSITORY https://github.com/XiangpengHao/epoch-reclaimer.git
#        GIT_TAG master
#)
#if (NOT epoch_reclaimer_POPULATED)
#    FetchContent_Populate(epoch_reclaimer)
#    include_directories(${epoch_reclaimer_SOURCE_DIR})
#endif ()

include_directories(${MKL_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${TBB_INCLUDE_DIRS})
include_directories(${JEMALLOC_INCLUDE_DIR})
# include_directories(${Gperftools_INCLUDE_DIRS})
include_directories(src/competitor)
include_directories(src/competitor/hot/src/hot/commons/include)
include_directories(src/competitor/hot/src/hot/rowex/include)
include_directories(src/competitor/hot/src/hot/single-threaded/include)
include_directories(src/competitor/hot/src/idx/content-helpers/include)
include_directories(src/dependency/epoch_reclaimer-src/)

add_compile_options(-Wall -fmax-errors=5 -faligned-new -march=native -mtune=native -mavx2 )

add_subdirectory(src/competitor/hot)
add_subdirectory(src/competitor/art/src/src)
# add_subdirectory(src/competitor/wormhole)
add_subdirectory(src/competitor/wormhole_u64)
add_subdirectory(src/competitor/masstree)

# microbench
add_executable(microbench
        ${CMAKE_CURRENT_SOURCE_DIR}/src/benchmark/microbench.cpp ${ART_SOURCE}
        )
string(TOLOWER ${CMAKE_BUILD_TYPE} _type)
if (_type STREQUAL release)
    set(default_build_type "Release")
    message(STATUS "Setting build type to '${default_build_type}' ")
    target_compile_definitions(microbench PRIVATE NDEBUGGING)
else()
    message(STATUS "Setting build type to '${default_build_type}' ")
endif()

#list(APPEND libs_to_link ${pmem_LIBRARIES})


target_link_libraries(microbench
        PRIVATE
        mkl_rt
        ARTLIB
        # WORMHOLE
        WORMHOLEU64
        MASSTREE
        -lpthread
        ${JEMALLOC_LIBRARIES}
        ${TBB_LIBRARIES}
        # ${Gperftools_LIBRARIES}
# ${libs_to_link}
)

target_link_libraries(microbench PUBLIC OpenMP::OpenMP_CXX)
