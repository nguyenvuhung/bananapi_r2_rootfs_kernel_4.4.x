# - Find gperf executable and provides a macro to generate custom build rules
#
# The module defines the following variables:
#  GPERF_FOUND - true is gperf executable is found
#  GPERF_EXECUTABLE - the path to the gperf executable
#  GPERF_VERSION - the version of gperf
#  GPERF_LIBRARIES - The gperf libraries
#
# The minimum required version of gperf can be specified using the
# standard syntax, e.g. FIND_PACKAGE(GPERF 2.5.13)
#
#
# If gperf is found on the system, the module provides the macro:
#  GPERF_TARGET(Name GperfInput GperfOutput [COMPILE_FLAGS <string>])
# which creates a custom command  to generate the <GperfOutput> file from
# the <GperfInput> file.  If  COMPILE_FLAGS option is specified, the next
# parameter is added to the gperf  command line. Name is an alias used to
# get  details of  this custom  command.  Indeed the  macro defines  the
# following variables:
#  GPERF_${Name}_DEFINED - true is the macro ran successfully
#  GPERF_${Name}_OUTPUTS - the source file generated by the custom rule, an
#  alias for GperfOutput
#  GPERF_${Name}_INPUT - the gperf source file, an alias for ${GperfInput}
#
# Gperf scanners oftenly use tokens  defined by Bison: the code generated
# by Gperf  depends of the header  generated by Bison.   This module also
# defines a macro:
#  ADD_GPERF_BISON_DEPENDENCY(GperfTarget BisonTarget)
# which  adds the  required dependency  between a  scanner and  a parser
# where  <GperfTarget>  and <BisonTarget>  are  the  first parameters  of
# respectively GPERF_TARGET and BISON_TARGET macros.
#
#  ====================================================================
#  Example:
#
#   find_package(GPERF)
#
#   GPERF_TARGET(MyHash hash.gperf  ${CMAKE_CURRENT_BINARY_DIR}/hash.c)
#
#  ====================================================================

#=============================================================================
# Copyright 2009 Kitware, Inc.
# Copyright 2006 Tristan Carel
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# * Neither the names of Kitware, Inc., the Insight Software Consortium,
#   nor the names of their contributors may be used to endorse or promote
#   products derived from this software without specific prior written
#   permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

cmake_minimum_required(VERSION 2.8.4)

FIND_PROGRAM(GPERF_EXECUTABLE gperf DOC "path to the gperf executable")
MARK_AS_ADVANCED(GPERF_EXECUTABLE)

FIND_LIBRARY(FL_LIBRARY NAMES fl
  DOC "path to the fl library")
MARK_AS_ADVANCED(FL_LIBRARY)
SET(GPERF_LIBRARIES ${FL_LIBRARY})

IF(GPERF_EXECUTABLE)

  EXECUTE_PROCESS(COMMAND ${GPERF_EXECUTABLE} --version
    OUTPUT_VARIABLE GPERF_version_output
    ERROR_VARIABLE GPERF_version_error
    RESULT_VARIABLE GPERF_version_result
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  SET(ENV{LC_ALL} ${_Bison_SAVED_LC_ALL})

  IF(NOT ${GPERF_version_result} EQUAL 0)
    MESSAGE(SEND_ERROR "Command \"${GPERF_EXECUTABLE} --version\" failed with output:\n${GPERF_version_error}")
  ELSE() 
    STRING(REGEX REPLACE "^GNU gperf ([^\n]+)\n.*" "\\1"
      GPERF_VERSION "${GPERF_version_output}")
  ENDIF()

  #============================================================
  # GPERF_TARGET (public macro)
  #============================================================
  #
  MACRO(GPERF_TARGET Name Input Output)
    SET(GPERF_TARGET_usage "GPERF_TARGET(<Name> <Input> <Output> [COMPILE_FLAGS <string>]")
    IF(${ARGC} GREATER 3)
      IF(${ARGC} EQUAL 5)
        IF("${ARGV3}" STREQUAL "COMPILE_FLAGS")
          SET(GPERF_EXECUTABLE_opts  "${ARGV4}")
          SEPARATE_ARGUMENTS(GPERF_EXECUTABLE_opts)
        ELSE()
          MESSAGE(SEND_ERROR ${GPERF_TARGET_usage})
        ENDIF()
      ELSE()
        MESSAGE(SEND_ERROR ${GPERF_TARGET_usage})
      ENDIF()
    ENDIF()

    ADD_CUSTOM_COMMAND(OUTPUT ${Output}
      COMMAND ${GPERF_EXECUTABLE}
      ARGS ${GPERF_EXECUTABLE_opts} < ${Input} > ${Output}
      DEPENDS ${Input}
      COMMENT "[GPERF][${Name}] Building hash with gperf ${GPERF_VERSION}"
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

    SET(GPERF_${Name}_DEFINED TRUE)
    SET(GPERF_${Name}_OUTPUTS ${Output})
    SET(GPERF_${Name}_INPUT ${Input})
    SET(GPERF_${Name}_COMPILE_FLAGS ${GPERF_EXECUTABLE_opts})
  ENDMACRO(GPERF_TARGET)
  #============================================================


  #============================================================
  # ADD_GPERF_BISON_DEPENDENCY (public macro)
  #============================================================
  #
  MACRO(ADD_GPERF_BISON_DEPENDENCY GperfTarget BisonTarget)

    IF(NOT GPERF_${GperfTarget}_OUTPUTS)
      MESSAGE(SEND_ERROR "Gperf target `${GperfTarget}' does not exists.")
    ENDIF()

    IF(NOT BISON_${BisonTarget}_OUTPUT_HEADER)
      MESSAGE(SEND_ERROR "Bison target `${BisonTarget}' does not exists.")
    ENDIF()

    SET_SOURCE_FILES_PROPERTIES(${GPERF_${GperfTarget}_OUTPUTS}
      PROPERTIES OBJECT_DEPENDS ${BISON_${BisonTarget}_OUTPUT_HEADER})
  ENDMACRO(ADD_GPERF_BISON_DEPENDENCY)
  #============================================================

ENDIF(GPERF_EXECUTABLE)

INCLUDE(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(GPERF REQUIRED_VARS GPERF_EXECUTABLE
                                       VERSION_VAR GPERF_VERSION)

# FindGPERF.cmake ends here
