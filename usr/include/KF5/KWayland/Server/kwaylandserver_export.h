
#ifndef KWAYLANDSERVER_EXPORT_H
#define KWAYLANDSERVER_EXPORT_H

#ifdef KWAYLANDSERVER_STATIC_DEFINE
#  define KWAYLANDSERVER_EXPORT
#  define KWAYLANDSERVER_NO_EXPORT
#else
#  ifndef KWAYLANDSERVER_EXPORT
#    ifdef KF5WaylandServer_EXPORTS
        /* We are building this library */
#      define KWAYLANDSERVER_EXPORT __attribute__((visibility("default")))
#    else
        /* We are using this library */
#      define KWAYLANDSERVER_EXPORT __attribute__((visibility("default")))
#    endif
#  endif

#  ifndef KWAYLANDSERVER_NO_EXPORT
#    define KWAYLANDSERVER_NO_EXPORT __attribute__((visibility("hidden")))
#  endif
#endif

#ifndef KWAYLANDSERVER_DEPRECATED
#  define KWAYLANDSERVER_DEPRECATED __attribute__ ((__deprecated__))
#endif

#ifndef KWAYLANDSERVER_DEPRECATED_EXPORT
#  define KWAYLANDSERVER_DEPRECATED_EXPORT KWAYLANDSERVER_EXPORT KWAYLANDSERVER_DEPRECATED
#endif

#ifndef KWAYLANDSERVER_DEPRECATED_NO_EXPORT
#  define KWAYLANDSERVER_DEPRECATED_NO_EXPORT KWAYLANDSERVER_NO_EXPORT KWAYLANDSERVER_DEPRECATED
#endif

#define DEFINE_NO_DEPRECATED 0
#if DEFINE_NO_DEPRECATED
# define KWAYLANDSERVER_NO_DEPRECATED
#endif

#endif
