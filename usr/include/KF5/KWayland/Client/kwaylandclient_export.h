
#ifndef KWAYLANDCLIENT_EXPORT_H
#define KWAYLANDCLIENT_EXPORT_H

#ifdef KWAYLANDCLIENT_STATIC_DEFINE
#  define KWAYLANDCLIENT_EXPORT
#  define KWAYLANDCLIENT_NO_EXPORT
#else
#  ifndef KWAYLANDCLIENT_EXPORT
#    ifdef KF5WaylandClient_EXPORTS
        /* We are building this library */
#      define KWAYLANDCLIENT_EXPORT __attribute__((visibility("default")))
#    else
        /* We are using this library */
#      define KWAYLANDCLIENT_EXPORT __attribute__((visibility("default")))
#    endif
#  endif

#  ifndef KWAYLANDCLIENT_NO_EXPORT
#    define KWAYLANDCLIENT_NO_EXPORT __attribute__((visibility("hidden")))
#  endif
#endif

#ifndef KWAYLANDCLIENT_DEPRECATED
#  define KWAYLANDCLIENT_DEPRECATED __attribute__ ((__deprecated__))
#endif

#ifndef KWAYLANDCLIENT_DEPRECATED_EXPORT
#  define KWAYLANDCLIENT_DEPRECATED_EXPORT KWAYLANDCLIENT_EXPORT KWAYLANDCLIENT_DEPRECATED
#endif

#ifndef KWAYLANDCLIENT_DEPRECATED_NO_EXPORT
#  define KWAYLANDCLIENT_DEPRECATED_NO_EXPORT KWAYLANDCLIENT_NO_EXPORT KWAYLANDCLIENT_DEPRECATED
#endif

#define DEFINE_NO_DEPRECATED 0
#if DEFINE_NO_DEPRECATED
# define KWAYLANDCLIENT_NO_DEPRECATED
#endif

#endif
