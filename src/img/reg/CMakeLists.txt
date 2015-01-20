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

configure_file (${CMAKE_SOURCE_DIR}/src/img/reg/Config.vala.cmake ${CMAKE_BINARY_DIR}/src/img/reg/Config.vala)
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/apollo.img.reg.pc ${CMAKE_CURRENT_BINARY_DIR}/apollo.img.reg.pc)
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/apollo.img.reg.deps ${CMAKE_CURRENT_BINARY_DIR}/apollo.img.reg.deps)
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
set (APP_SOURCES ${APP_SOURCES} interp.vala)
set (APP_SOURCES ${APP_SOURCES} interp_type.vala)
set (APP_SOURCES ${APP_SOURCES} landmarks.vala)
set (APP_SOURCES ${APP_SOURCES} optimizer.vala)
set (APP_SOURCES ${APP_SOURCES} params.vala)
set (APP_SOURCES ${APP_SOURCES} pix_type.vala)
set (APP_SOURCES ${APP_SOURCES} util.vala)
set (APP_SOURCES ${APP_SOURCES} volume.vala)
set (APP_SOURCES ${APP_SOURCES} xform.vala)
set (APP_SOURCES ${APP_SOURCES} xform_methods.vala)

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
set (COMPILE_OPTIONS ${COMPILE_OPTIONS} --library=apollo.img.reg --gir apollo.img.reg-1.0.gir )

vala_precompile(VALA_C apollo.img.reg
	${APP_SOURCES}
PACKAGES
	${VALA_PACKAGES}
OPTIONS
	${COMPILE_OPTIONS}
GENERATE_VAPI
	apollo.img.reg
GENERATE_HEADER
	apollo.img.reg
)

set (VALA_C ${VALA_C} volume_funcs.c)

add_library(apollo.img.reg SHARED ${VALA_C})

target_link_libraries( apollo.img.reg m )
set_target_properties( apollo.img.reg PROPERTIES
VERSION
	1.0.0
SOVERSION
	1 )

install(TARGETS
	apollo.img.reg
LIBRARY DESTINATION
	${CMAKE_INSTALL_LIBDIR}/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.img.reg.h
DESTINATION
	${CMAKE_INSTALL_INCLUDEDIR}/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.img.reg.vapi
DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/vala/vapi/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.img.reg.deps
DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/vala/vapi/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.img.reg-1.0.gir
DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/gir-1.0/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/apollo.img.reg.pc
DESTINATION
	${CMAKE_INSTALL_LIBDIR}/pkgconfig/
)
if(HAVE_VALADOC)
	valadoc(apollo.img.reg
		${CMAKE_BINARY_DIR}/valadoc/apollo.img.reg
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

install(CODE "MESSAGE (\"
************************************************
* Run 'sudo ldconfig' to complete installation *
************************************************

\") " )