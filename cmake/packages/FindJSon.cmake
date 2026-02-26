# Package Info.
set(JSON_NAME "JSon")
set(JSON_FOUND FALSE)

if(USE_BOOST)
    set(JSON_DESCRIPTION "A C++11 or library for parsing and serializing JSON to and from a DOM container in memory based on Boost.")
else()
    set(JSON_DESCRIPTION "A C++ library for interacting with JSON.")
endif()

# Pakcage option.
option(USE_JSON ${JSON_DESCRIPTION} TRUE)
if (USE_JSON)
    add_definitions(-DUSE_JSON)
    # Define the repository URL and tag for jsoncpp.
    set(JSON_URL "https://github.com/open-source-parsers/jsoncpp.git")
if(FORCE_UPGRADED_LIBS)
    set(JSON_TAG "master")
else()
    set(JSON_TAG "1.9.5")
endif()
    set(JSON_LIB_LIST "jsoncpp_lib" CACHE STRING "List of modules (separated by a semicolon)")
endif()

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
    pkg_search_module(${JSON_NAME} QUIET jsoncpp jsoncpp_lib json)
endif()

if(${JSON_NAME}_FOUND)
    set(JSON_FOUND TRUE)
    list(APPEND LIB_TARGET_INCLUDE_DIRECTORIES ${${JSON_NAME}_INCLUDE_DIRS})
    list(APPEND LIB_TARGET_LIBRARY_DIRECTORIES ${${JSON_NAME}_LIBRARY_DIRS})
    list(APPEND LIB_TARGET_LINK_DIRECTORIES ${${JSON_NAME}_LIBRARY_DIRS})
    if(${JSON_NAME}_LINK_LIBRARIES)
        list(APPEND LIB_MODULES ${${JSON_NAME}_LINK_LIBRARIES})
    else()
        list(APPEND LIB_MODULES jsoncpp)
    endif()
endif()

if(NOT JSON_FOUND)
    find_path(JSON_INCLUDE_DIR NAMES json/json.h jsoncpp/json/json.h)
    find_library(JSON_LIBRARY NAMES jsoncpp jsoncpp_lib)
    if(JSON_INCLUDE_DIR AND JSON_LIBRARY)
        set(JSON_FOUND TRUE)
        get_filename_component(JSON_LIBRARY_DIR "${JSON_LIBRARY}" DIRECTORY)
        list(APPEND LIB_TARGET_INCLUDE_DIRECTORIES "${JSON_INCLUDE_DIR}")
        list(APPEND LIB_TARGET_LIBRARY_DIRECTORIES "${JSON_LIBRARY_DIR}")
        list(APPEND LIB_TARGET_LINK_DIRECTORIES "${JSON_LIBRARY_DIR}")
        list(APPEND LIB_MODULES "${JSON_LIBRARY}")
    endif()
endif()

if(USE_JSON AND (NOT JSON_FOUND OR FORCE_UPGRADED_LIBS))
    set(FETCHCONTENT_QUIET off)
    get_filename_component(json_base "${CMAKE_CURRENT_SOURCE_DIR}/${THIRD_PARTY}/${PLATFORM_FOLDER_NAME}/${JSON_NAME}"
        REALPATH BASE_DIR "${CMAKE_BINARY_DIR}")
    set(FETCHCONTENT_BASE_DIR ${json_base})
    FetchContent_Declare(
        json
        GIT_REPOSITORY      ${JSON_URL}
        GIT_TAG             ${JSON_TAG}
        GIT_PROGRESS   TRUE
        )
    FetchContent_MakeAvailable(json)
    include_directories(${json_SOURCE_DIR}/include)
    set(JSON_FOUND TRUE)
    foreach(module IN LISTS JSON_LIB_LIST)
        list(APPEND LIB_MODULES ${module})
    endforeach()
endif()

if(NOT JSON_FOUND)
    return()
endif()
