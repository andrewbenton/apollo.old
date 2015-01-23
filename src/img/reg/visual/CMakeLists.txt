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

configure_file (${CMAKE_SOURCE_DIR}/src/img/reg/visual/Config.vala.cmake ${CMAKE_BINARY_DIR}/src/img/reg/visual/Config.vala)
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/apollo.img.reg.visual.pc ${CMAKE_CURRENT_BINARY_DIR}/apollo.img.reg.visual.pc)
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/apollo.img.reg.visual.deps ${CMAKE_CURRENT_BINARY_DIR}/apollo.img.reg.visual.deps)
set (VERSION "1.0.0")
add_definitions (${DEPS_CFLAGS})
include_directories ( ${CMAKE_BINARY_DIR}/src/img/reg )
link_libraries ( ${DEPS_LIBRARIES} -lapollo.img.reg )
link_directories ( ${DEPS_LIBRARY_DIRS} ${CMAKE_BINARY_DIR}/src/img/reg )
find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.27" MINIMUM)
include (ValaPrecompile)

set (VALA_PACKAGES ${VALA_PACKAGES} gdk-3.0)
set (VALA_PACKAGES ${VALA_PACKAGES} gdk-pixbuf-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} gio-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} gmodule-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} gtk+-3.0)

set (APP_SOURCES ${APP_SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/Config.vala)
set (APP_SOURCES ${APP_SOURCES} mview_group.vala)
set (APP_SOURCES ${APP_SOURCES} mview_page.vala)
set (APP_SOURCES ${APP_SOURCES} mview_window.vala)

set (CUSTOM_VAPIS_LIST ${CUSTOM_VAPIS_LIST} ${CMAKE_BINARY_DIR}/src/img/reg/apollo.img.reg.vapi)

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
set (COMPILE_OPTIONS ${COMPILE_OPTIONS} --library=apollo.img.reg.visual --gir apollo.img.reg.visual-1.0.gir )
if (DEBUG)
	set (COMPILE_OPTIONS ${COMPILE_OPTIONS} -g )
endif ()


if (DEBUG)
	set (CMAKE_C_FLAGS ${CMAKE_C_FLAGS} " -O0 -g " )
else ()
	set (CMAKE_C_FLAGS ${CMAKE_C_FLAGS} " -O3 " )
endif ()


vala_precompile(VALA_C apollo.img.reg.visual
	${APP_SOURCES}
PACKAGES
	${VALA_PACKAGES}
CUSTOM_VAPIS
	${CUSTOM_VAPIS_LIST}
OPTIONS
	${COMPILE_OPTIONS}
GENERATE_VAPI
	apollo.img.reg.visual
GENERATE_HEADER
	apollo.img.reg.visual
)

add_library(apollo.img.reg.visual SHARED ${VALA_C})

set_target_properties( apollo.img.reg.visual PROPERTIES
VERSION
	1.0.0
SOVERSION
	1 )

install(TARGETS
	apollo.img.reg.visual
LIBRARY DESTINATION
	${CMAKE_INSTALL_LIBDIR}/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.img.reg.visual.h
DESTINATION
	${CMAKE_INSTALL_INCLUDEDIR}/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.img.reg.visual.vapi
DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/vala/vapi/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.img.reg.visual.deps
DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/vala/vapi/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.img.reg.visual-1.0.gir
DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/gir-1.0/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.img.reg.visual.pc
DESTINATION
	${CMAKE_INSTALL_LIBDIR}/pkgconfig/
)
if(HAVE_VALADOC)
	valadoc(apollo.img.reg.visual
		${CMAKE_BINARY_DIR}/valadoc/apollo.img.reg.visual
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
