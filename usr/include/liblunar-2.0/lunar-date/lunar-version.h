/* vi: set sw=4 ts=4: */
/*
 * lunar-version.h: This file is part of lunar-date.
 *
 * Copyright (C) 2009-2011 yetist <yetist@gmail.com>
 *
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * */

#ifndef __LUNAR_VERSION_H__
#define __LUNAR_VERSION_H__  1

#include <glib.h>

G_BEGIN_DECLS

/**
 * LUNAR_DATE_MAJOR_VERSION:
 *
 * The major version number of the LunarDate library
 * (e.g. in version 2.4.0 this is 2).
 *
 * Since: 2.4.0
 */
#define LUNAR_DATE_MAJOR_VERSION	2

/**
 * LUNAR_DATE_MINOR_VERSION:
 *
 * The minor version number of the LunarDate library
 * (e.g. in version 2.4.0 this is 4).
 *
 * Since: 2.4.0
 */
#define LUNAR_DATE_MINOR_VERSION	4

/**
 * LUNAR_DATE_MICRO_VERSION:
 *
 * The macro version number of the LunarDate library
 * (e.g. in version 2.4.0 this is 0).
 *
 * Since: 2.4.0
 */
#define LUNAR_DATE_MICRO_VERSION	0

/**
 * lunar_date_major_version:
 *
 * The major version number of the LunarDate library
 * (e.g. in version 2.4.0 this is 2). Used for runtime.
 *
 * Since: 2.4.0
 */
extern const guint lunar_date_major_version;

/**
 * lunar_date_minor_version:
 *
 * The minor version number of the LunarDate library
 * (e.g. in version 2.4.0 this is 4). Used for runtime.
 *
 * Since: 2.4.0
 */
extern const guint lunar_date_minor_version;

/**
 * lunar_date_micro_version:
 *
 * The micro version number of the LunarDate library
 * (e.g. in version 2.4.0 this is 0). Used for runtime.
 *
 * Since: 2.4.0
 */
extern const guint lunar_date_micro_version;

const gchar * lunar_date_check_version (guint required_major,
		guint required_minor,
		guint required_micro);

/**
 * LUNAR_DATE_CHECK_VERSION:
 * @major: required major version
 * @minor: required minor version
 * @micro: required micro version
 *
 * Checks the version of the LunarDate library.
 *
 * Checking the version of the LunarDate library:
 * |[
 *   if (!LUNAR_DATE_CHECK_VERSION (2, 4, 0))
 *       g_error ("LunarDate version 2.4.0 or above is needed");
 * ]|
 *
 * Returns: %TRUE if the version of the LunarDate header files is the same
 * as or newer than the passed-in version.
 *
 * Since: 2.4.0
 */
#define LUNAR_DATE_CHECK_VERSION(major,minor,micro)    \
	(LUNAR_MAJOR_VERSION > (major) || \
	 (LUNAR_MAJOR_VERSION == (major) && LUNAR_MINOR_VERSION > (minor)) || \
	 (LUNAR_MAJOR_VERSION == (major) && LUNAR_MINOR_VERSION == (minor) && \
	  LUNAR_MICRO_VERSION >= (micro)))


#ifndef LIBLUNAR_DISABLE_DEPRECATED
void            lunar_init   (int *argc, char ***argv) G_GNUC_DEPRECATED;
#endif

G_END_DECLS

#endif /* __LUNAR_VERSION_H__ */

/*
vi:ts=4:wrap:ai:
*/
