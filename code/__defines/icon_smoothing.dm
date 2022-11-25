/* smoothing internals */
#define NORTH_JUNCTION     NORTH //(1<<0)
#define SOUTH_JUNCTION     SOUTH //(1<<1)
#define EAST_JUNCTION      EAST  //(1<<2)
#define WEST_JUNCTION      WEST  //(1<<3)
#define NORTHEAST_JUNCTION (1<<4)
#define SOUTHEAST_JUNCTION (1<<5)
#define SOUTHWEST_JUNCTION (1<<6)
#define NORTHWEST_JUNCTION (1<<7)

#define DEFAULT_UNDERLAY_ICON 'icons/turf/floors.dmi'
#define DEFAULT_UNDERLAY_ICON_STATE "plating"

/**SMOOTHING GROUPS
 * Groups of things to smooth with.
 * * Contained in the `list/smoothing_groups` variable.
 * * Matched with the `list/canSmoothWith` variable to check whether smoothing is possible or not.
 */

///Not any different from the number itself, but kept this way in case someone wants to expand it by adding stuff before it.
#define S_TURF(num) ((24 * 0) + num)
/* /turf only */

//! empty for now
///Always match this value with the one above it.
#define MAX_S_TURF S_TURF(0)
#define S_OBJ(num) (MAX_S_TURF + 1 + num)
/* /obj included */

//! empty for now
///Always match this value with the one above it.
#define MAX_S_OBJ S_OBJ(0)
