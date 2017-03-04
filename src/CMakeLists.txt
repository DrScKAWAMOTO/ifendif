
include_directories(${CMAKE_CURRENT_BINARY_DIR})


add_definitions(-D_GNU_SOURCE)


link_directories(${LIBCONFIG_LIBRARY_DIRS})
add_executable(ifendif
    AtExitUnlink.cc
    Expanded.cc
    FillTheSkips.cc
    LineBuffer.cc
    RegionDetector.cc
    Source.cc
    ifendif.cc)
set_target_properties(ifendif PROPERTIES
    COMPILE_DEFINITIONS "SERVER")
include_directories(${LIBCONFIG_INCLUDE_DIRS})

include(GNUInstallDirs)
install(TARGETS ifendif
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
