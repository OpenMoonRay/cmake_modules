# Copyright 2024 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

# ================================================
# Convenience variables for checking the platform
# ================================================

set(UnixPlatforms Linux Darwin)
if(CMAKE_SYSTEM_NAME IN_LIST UnixPlatforms)
    set(IsUnixPlatform TRUE)
endif()

set(LinuxPlatforms Linux)
if(CMAKE_SYSTEM_NAME IN_LIST LinuxPlatforms)
    set(IsLinuxPlatform TRUE)
endif()

set(DarwinPlatforms Darwin)
if(CMAKE_SYSTEM_NAME IN_LIST DarwinPlatforms)
    set(IsDarwinPlatform TRUE)
endif()

set(WindowsPlatforms Windows)
if(CMAKE_SYSTEM_NAME IN_LIST WindowsPlatforms)
    set(IsWindowsPlatform TRUE)
endif()

# ================================================
# Platform-specific globals
# ================================================
include(CheckLanguage)

if(IsUnixPlatform)
    list(APPEND GLOBAL_COMPILE_DEFINITIONS PLATFORM_UNIX)
endif()

if(IsLinuxPlatform)
    list(APPEND GLOBAL_COMPILE_DEFINITIONS PLATFORM_LINUX)
endif()

if(IsDarwinPlatform)
    list(APPEND GLOBAL_COMPILE_DEFINITIONS PLATFORM_APPLE)
endif()

if(IsWindowsPlatform)
    list(APPEND GLOBAL_COMPILE_DEFINITIONS PLATFORM_WINDOWS)
endif()

if(IsDarwinPlatform)
    check_language(OBJCXX)

    if(CMAKE_OBJCXX_COMPILER)
        enable_language(OBJCXX)
    endif()

    if (CMAKE_CXX_COMPILER_ID STREQUAL Clang)
        set(CMAKE_CXX_STANDARD 17)
    endif()

    # Ignore Homebrew packages
    set(CMAKE_IGNORE_PATH /opt/homebrew)
    set(CMAKE_IGNORE_PREFIX_PATH /opt/homebrew)

    set(ISPC_COMPILER $ENV{ISPC} CACHE STRING "Path to ISPC compiler")
    set(CMAKE_XCODE_ATTRIBUTE_OTHER_CODE_SIGN_FLAGS "-o linker-signed")
    set(GLOBAL_LINK_FLAGS "-Wl,-ld_classic")
    set(GLOBAL_INSTALL_RPATH "@loader_path/" "@loader_path/../lib")
    set(GLOBAL_ISPC_FLAGS -D__aarch64__ -D__APPLE__ -D__ARM_NEON__)
    set(GLOBAL_ISPC_INSTRUCTION_SETS neon-i32x4)
    set(CMAKE_OSX_ARCHITECTURES arm64)

    # scene_rdl2's Platform.h defines __SSE3__/__SSE4_2__ etc on aarch64 to
    # drive sse2neon emulation, which makes OIIO's headers include x86 intrinsics headers.
    # Manually disable these headers here, instead of having to add this in every file that includes OIIO.
    list(APPEND GLOBAL_COMPILE_DEFINITIONS
        __IMMINTRIN_H=
        __NMMINTRIN_H=
        OIIO_NO_SSE=1
        OIIO_NO_AVX=1
        OIIO_NO_AVX2=1
    )

else() # Linux/Windows
    set(GLOBAL_CPP_FLAGS __AVX__)
    set(GLOBAL_LINK_FLAGS "-Wl,--enable-new-dtags")
    set(GLOBAL_INSTALL_RPATH "$ORIGIN" "$ORIGIN/../lib64" "${COMPILER_LIBRARY_DIR}")
    set(GLOBAL_ISPC_INSTRUCTION_SETS avx2-i32x8)
endif()

# ================================================
# Options
# ================================================
if(IsLinuxPlatform)
    option(MOONRAY_USE_OPTIX "Whether to enable XPU mode and Optix denoising" YES)
elseif(IsDarwinPlatform)
    option(MOONRAY_USE_METAL "Whether to enable XPU mode and OIDN Metal denoising" YES)
endif()



