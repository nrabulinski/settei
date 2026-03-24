# Generated Cmake Pico project file

cmake_minimum_required(VERSION 3.13)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Initialise pico_sdk from installed location
# (note this can come from environment, CMake cache etc)

# == DO NOT EDIT THE FOLLOWING LINES for the Raspberry Pi Pico VS Code Extension to work ==
if(WIN32)
    set(USERHOME $ENV{USERPROFILE})
else()
    set(USERHOME $ENV{HOME})
endif()
set(sdkVersion 2.0.0)
set(toolchainVersion 13_2_Rel1)
set(picotoolVersion 2.0.0)
set(picoVscode ${USERHOME}/.pico-sdk/cmake/pico-vscode.cmake)
if (EXISTS ${picoVscode})
    include(${picoVscode})
endif()
# ====================================================================================
set(PICO_BOARD pico CACHE STRING "Board type")

# Pull in Raspberry Pi Pico SDK (must be before project)
include(pico_sdk_import.cmake)

project(jetkvm-atx C CXX ASM)

# Initialise the Raspberry Pi Pico SDK
pico_sdk_init()

# Add executable. Default name is the project name, version 0.1

add_executable(jetkvm-atx jetkvm-atx.c )

pico_set_program_name(jetkvm-atx "jetkvm-atx")
pico_set_program_version(jetkvm-atx "0.1")

# Modify the below lines to enable/disable output over UART/USB
pico_enable_stdio_uart(jetkvm-atx 0)
pico_enable_stdio_usb(jetkvm-atx 1)

# Add the standard library to the build
target_link_libraries(jetkvm-atx
        pico_stdlib)

# Add the standard include files to the build
target_include_directories(jetkvm-atx PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}
)

# Add any user requested libraries
target_link_libraries(jetkvm-atx 
        hardware_watchdog
        )

pico_add_extra_outputs(jetkvm-atx)

#The default XOSC startup time is 1ms, which is too short for our XOSC
add_compile_definitions(
    PICO_XOSC_STARTUP_DELAY_MULTIPLIER=64
)