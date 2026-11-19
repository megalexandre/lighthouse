cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the application ID.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Add dependency libraries. Add any application-specific dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# libgcc_s must be the first library the process loads. The Flutter engine
# (libflutter_linux_gtk.so) exports its own _Unwind_RaiseException, and the
# dynamic loader binds the first definition it finds. When the engine is
# loaded first, a C++ exception thrown by a plugin built against libstdc++
# (flutter_secure_storage_linux throws on every libsecret error) is unwound by
# the engine's incompatible unwinder: no catch block is found and the process
# aborts. Listing libgcc_s first makes libstdc++ use the system unwinder.
# Checked by integration_test/keyring_test.dart.
target_link_options(${BINARY_NAME} PRIVATE
  "LINKER:--push-state,--no-as-needed,-lgcc_s,--pop-state")
