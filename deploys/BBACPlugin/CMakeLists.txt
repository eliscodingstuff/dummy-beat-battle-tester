cmake_minimum_required(VERSION 3.15)
project(BBACPlugin VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# VST3 SDK path
set(VST3_SDK_ROOT "C:/Users/16514/Documents/myStuff/CSF/VST_SDK/vst3sdk")

# Python path
set(PYTHON_ROOT "C:/Users/16514/AppData/Local/Programs/Python/Python312")

# Add VST3 SDK
add_subdirectory(${VST3_SDK_ROOT} ${CMAKE_CURRENT_BINARY_DIR}/vst3sdk)

# Plugin target
set(target BBACPlugin)

add_library(${target} MODULE
    BBACPlugin.h
    BBACPlugin.cpp
)

target_include_directories(${target} PRIVATE
    ${VST3_SDK_ROOT}
    ${PYTHON_ROOT}/include
)

target_link_libraries(${target} PRIVATE
    sdk
    ${PYTHON_ROOT}/libs/python312.lib
)

# VST3 settings
smtg_target_configure_version_file(${target})

if(SMTG_MAC)
    smtg_target_set_bundle(${target}
        BUNDLE_IDENTIFIER com.yourcompany.bbacplugin
        COMPANY_NAME "Your Company"
    )
elseif(SMTG_WIN)
    target_sources(${target} PRIVATE
        ${VST3_SDK_ROOT}/public.sdk/source/main/dllmain.cpp
    )
endif()

# Set output name
set_target_properties(${target} PROPERTIES
    OUTPUT_NAME "BBACPlugin"
    SUFFIX ".vst3"
)
