aux_source_directory(. DIR_LIB_SRCS)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include_directories(.)
add_compile_options(-faligned-new -march=native -mtune=native -O0 -march=native -Wall -Wextra -fopenmp -ltbb -g -mcx16 -latomic -Wno-invalid-offsetof -g -W -Wall -O3 -fPIC  -lpthread -lm -MD -MF -MP)


add_library (ARTLIB ${DIR_LIB_SRCS})