--- sys/dev/ath/if_ath.c.orig	2013-08-23 16:58:18.490855134 +0400
+++ sys/dev/ath/if_ath.c	2013-08-23 16:59:15.493828138 +0400
@@ -6439,7 +6439,7 @@
 	 * Immediately punt.
 	 */
 	if (! an->an_is_powersave) {
-		device_printf(sc->sc_dev,
+		DPRINTF(sc, ATH_DEBUG_NODE_PWRSAVE,
 		    "%s: %6D: not in powersave?\n",
 		    __func__,
 		    ni->ni_macaddr,
