# Install script for directory: C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Debug")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/build/x64-Debug/flutter/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/build/x64-Debug/runner/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/build/x64-Debug/plugins/flutter_webrtc/cmake_install.cmake")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug/scmeet.exe")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug" TYPE EXECUTABLE FILES "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/build/x64-Debug/runner/scmeet.exe")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug/data/icudtl.dat")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug/data" TYPE FILE FILES "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/flutter/ephemeral/icudtl.dat")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug/flutter_windows.dll")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug" TYPE FILE FILES "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/flutter/ephemeral/flutter_windows.dll")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug/flutter_webrtc_plugin.dll;C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug/libwebrtc.dll")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug" TYPE FILE FILES
    "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/build/x64-Debug/plugins/flutter_webrtc/flutter_webrtc_plugin.dll"
    "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/flutter/ephemeral/.plugin_symlinks/flutter_webrtc/windows/../third_party/libwebrtc/lib/win/x64/libwebrtc.dll"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  
  file(REMOVE_RECURSE "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug/data/flutter_assets")
  
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug/data/flutter_assets")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug/data" TYPE DIRECTORY FILES "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/build//flutter_assets")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee]|[Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug/data/app.so")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/install/x64-Debug/data" TYPE FILE FILES "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/build/windows/app.so")
  endif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee]|[Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "C:/Users/Gizem/Desktop/Proje 496/CheatClassification/scmeet/windows/out/build/x64-Debug/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
