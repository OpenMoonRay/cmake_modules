# Copyright 2026 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

include_guard(GLOBAL)

include(CheckCXXSourceCompiles)

check_cxx_source_compiles([=[
    #include <atomic>
    #include <cstdint>

    int main()
    {
        std::atomic<std::uint64_t> integer{0};
        int value = 0;
        std::atomic<int*> pointer{&value};
        return static_cast<int>(integer.fetch_add(1)) + *pointer.load();
    }
]=] OMR_CXX_ATOMICS_WITHOUT_LIB)

check_cxx_source_compiles([=[
    #include <atomic>
    #include <cstdint>

    struct Atomic128
    {
        std::uint64_t values[2];
    };

    int main()
    {
        std::atomic<Atomic128> value{};
        Atomic128 expected{};
        Atomic128 desired{{1, 2}};

        const bool lock_free = value.is_lock_free();
        const bool exchanged = value.compare_exchange_strong(expected, desired);
        return lock_free && exchanged ? 0 : 1;
    }
]=] OMR_CXX_ATOMIC_16BYTE_OPERATIONS_WITHOUT_LIB)

if(OMR_CXX_ATOMICS_WITHOUT_LIB AND OMR_CXX_ATOMIC_16BYTE_OPERATIONS_WITHOUT_LIB)
    set(OMR_ATOMIC_LIBRARY_REQUIRED FALSE CACHE INTERNAL
        "Whether targets require libatomic")
else()
    find_package(Libatomic REQUIRED)
    set(OMR_ATOMIC_LIBRARY_REQUIRED TRUE CACHE INTERNAL
        "Whether targets require libatomic")
endif()

function(omr_target_link_atomic target visibility)
    if(NOT TARGET ${target})
        message(FATAL_ERROR
            "omr_target_link_atomic called with unknown target '${target}'")
    endif()

    if(NOT visibility MATCHES "^(PRIVATE|PUBLIC|INTERFACE)$")
        message(FATAL_ERROR
            "omr_target_link_atomic visibility must be PRIVATE, PUBLIC, or INTERFACE")
    endif()

    if(OMR_ATOMIC_LIBRARY_REQUIRED)
        target_link_libraries(${target} ${visibility} Libatomic::Libatomic)
    endif()
endfunction()
