cmake_minimum_required(VERSION 3.15)
project(BBACPlugin VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)



# VST3 SDK path
set(VST3_SDK_ROOT "C:/Users/16514/Documents/myStuff/CSF/VST_SDK/vst3sdk")

# Python path
set(PYTHON_ROOT "C:/Users/16514/AppData/Local/Programs/Python/Python312")

# ImGui path
set(IMGUI_ROOT "C:/Users/16514/Documents/myStuff/CSF/imgui")

# Add VST3 SDK
add_subdirectory(${VST3_SDK_ROOT} ${CMAKE_CURRENT_BINARY_DIR}/vst3sdk)

# Create ImGui static library
set(IMGUI_SOURCES
    ${IMGUI_ROOT}/imgui.cpp
    ${IMGUI_ROOT}/imgui_demo.cpp
    ${IMGUI_ROOT}/imgui_draw.cpp
    ${IMGUI_ROOT}/imgui_tables.cpp
    ${IMGUI_ROOT}/imgui_widgets.cpp
    ${IMGUI_ROOT}/backends/imgui_impl_win32.cpp
    ${IMGUI_ROOT}/backends/imgui_impl_dx11.cpp
)

add_library(imgui STATIC ${IMGUI_SOURCES})

target_include_directories(imgui PUBLIC
    ${IMGUI_ROOT}
    ${IMGUI_ROOT}/backends
)

# Link DirectX 11
target_link_libraries(imgui PUBLIC d3d11.lib dxgi.lib d3dcompiler.lib)

# Plugin target
set(target BBACPlugin)

add_library(${target} MODULE
    BBACPlugin.h
    BBACPlugin.cpp
)

target_include_directories(${target} PRIVATE
    ${VST3_SDK_ROOT}
    ${PYTHON_ROOT}/include
    ${IMGUI_ROOT}
    ${IMGUI_ROOT}/backends
)

target_link_libraries(${target} PRIVATE
    sdk
    imgui
    ${PYTHON_ROOT}/libs/python312.lib
    d3d11.lib
    dxgi.lib
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
