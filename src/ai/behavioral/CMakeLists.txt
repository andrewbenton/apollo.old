### CMakeLists automatically created with AutoVala
### Do not edit

set (DATADIR "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}")
set (PKGDATADIR "${DATADIR}/apollo")
set (GETTEXT_PACKAGE "apollo")
set (RELEASE_NAME "apollo")
set (CMAKE_C_FLAGS "")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (VERSION "1.0.0")
set (TESTSRCDIR "${CMAKE_SOURCE_DIR}")
set (DOLLAR "$")

configure_file (${CMAKE_SOURCE_DIR}/src/ai/behavioral/Config.vala.cmake ${CMAKE_BINARY_DIR}/src/ai/behavioral/Config.vala)
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/apollo.ai.behavioral.pc ${CMAKE_CURRENT_BINARY_DIR}/apollo.ai.behavioral.pc)
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/apollo.ai.behavioral.deps ${CMAKE_CURRENT_BINARY_DIR}/apollo.ai.behavioral.deps)
set (VERSION "1.0.0")
add_definitions (${DEPS_CFLAGS})
link_libraries ( ${DEPS_LIBRARIES} )
link_directories ( ${DEPS_LIBRARY_DIRS} )
find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.26" MINIMUM)
include (ValaPrecompile)

set (VALA_PACKAGES ${VALA_PACKAGES} gio-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} gmodule-2.0)

set (APP_SOURCES ${APP_SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/Config.vala)
set (APP_SOURCES ${APP_SOURCES} behavioral_tree_set.vala)
set (APP_SOURCES ${APP_SOURCES} bt_error.vala)
set (APP_SOURCES ${APP_SOURCES} dynamic_node.vala)
set (APP_SOURCES ${APP_SOURCES} node.vala)
set (APP_SOURCES ${APP_SOURCES} node_context.vala)
set (APP_SOURCES ${APP_SOURCES} status_value.vala)
set (APP_SOURCES ${APP_SOURCES} tree_context.vala)

if (DEBUG)
	set (COMPILE_OPTIONS ${COMPILE_OPTIONS} -D DEBUG)
endif ()
if (USE_CUDA)
	set (COMPILE_OPTIONS ${COMPILE_OPTIONS} -D USE_CUDA)
endif ()
if (USE_PHI)
	set (COMPILE_OPTIONS ${COMPILE_OPTIONS} -D USE_PHI)
endif ()
if (USE_OMP)
	set (COMPILE_OPTIONS ${COMPILE_OPTIONS} -D USE_OMP)
endif ()
set (COMPILE_OPTIONS ${COMPILE_OPTIONS} --library=apollo.ai.behavioral --gir apollo.ai.behavioral-1.0.gir )

vala_precompile(VALA_C apollo.ai.behavioral
	${APP_SOURCES}
PACKAGES
	${VALA_PACKAGES}
OPTIONS
	${COMPILE_OPTIONS}
GENERATE_VAPI
	apollo.ai.behavioral
GENERATE_HEADER
	apollo.ai.behavioral
)

add_library(apollo.ai.behavioral SHARED ${VALA_C})

set_target_properties( apollo.ai.behavioral PROPERTIES
VERSION
	1.0.0
SOVERSION
	1 )

install(TARGETS
	apollo.ai.behavioral
LIBRARY DESTINATION
	${CMAKE_INSTALL_LIBDIR}/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.ai.behavioral.h
DESTINATION
	${CMAKE_INSTALL_INCLUDEDIR}/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.ai.behavioral.vapi
DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/vala/vapi/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.ai.behavioral.deps
DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/vala/vapi/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.ai.behavioral-1.0.gir
DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/gir-1.0/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.ai.behavioral.pc
DESTINATION
	${CMAKE_INSTALL_LIBDIR}/pkgconfig/
)
if(HAVE_VALADOC)
	valadoc(apollo.ai.behavioral
		${CMAKE_BINARY_DIR}/valadoc/apollo.ai.behavioral
		${APP_SOURCES}
	PACKAGES
		${VALA_PACKAGES}
	CUSTOM_VAPIS
		${CUSTOM_VAPIS_LIST}
	)
	install(DIRECTORY
		${CMAKE_BINARY_DIR}/valadoc
	DESTINATION
		${CMAKE_INSTALL_DATAROOTDIR}/doc/apollo
	)
endif()
