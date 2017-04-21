cmake_minimum_required(VERSION 3.7.1)

project(ifendif)
set(IFENDIF_VERSION "1.0")

set(CPACK_PACKAGE_NAME "ifendif")
set(CPACK_PACKAGE_CONTACT "Dr.Sc.KAWAMOTO,Takuji")
set(CPACK_PACKAGE_VENDOR ${CPACK_PACKAGE_CONTACT})
set(CPACK_PACKAGE_VERSION ${CMDRECPLAY_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "ifendif")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
set(CPACK_RPM_PACKAGE_RELEASE "1%{?dist}")
set(CPACK_RPM_PACKAGE_LICENSE "GPLv3")
set(CPACK_RPM_PACKAGE_GROUP "Development/Tools")
set(CPACK_RPM_PACKAGE_URL "http://kawamoto.mydns.jp/")
set(CPACK_RPM_PACKAGE_DESCRIPTION "Ifendif is a tool for reporting valid lines by #if #endif directives, with C/C++ language source codes. It uses cmdrecplay and clang cc1 as the backend then refers to the macro definitions at compile time to judge validity.")
include(CPack)

find_package(PkgConfig)
pkg_check_modules(LIBCONFIG REQUIRED libconfig>=1.4)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})
find_package(C99 REQUIRED)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${C99_C_FLAGS}")

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif()

include(GNUInstallDirs)
install(FILES LICENSE README.md ChangeLog.md
  DESTINATION ${CMAKE_INSTALL_DOCDIR})

add_subdirectory(src)
add_subdirectory(emacs)
#add_subdirectory(test)
#add_subdirectory(doc)
