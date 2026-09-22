# Copyright 2023-2024 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

find_library(Libatomic_LIBRARY
  NAMES atomic libatomic.so.1
  HINTS
    $ENV{LIBATOMIC_ROOT}/lib
    $ENV{LIBATOMIC_ROOT}/lib64
    ${CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES}
  PATHS
    /lib
    /lib64
    /usr/lib
    /usr/lib64)

mark_as_advanced(Libatomic_LIBRARY)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Libatomic
  REQUIRED_VARS Libatomic_LIBRARY
)

if (Libatomic_FOUND AND NOT TARGET Libatomic::Libatomic)
    add_library(Libatomic::Libatomic UNKNOWN IMPORTED)
    set_target_properties(Libatomic::Libatomic PROPERTIES
      IMPORTED_LOCATION "${Libatomic_LIBRARY}")
endif()

