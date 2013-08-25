--- sys/dev/ath/if_ath.c.orig	2013-08-25 14:00:48.647845509 +0400
+++ sys/dev/ath/if_ath.c	2013-08-25 14:07:33.782821876 +0400
@@ -3199,7 +3199,7 @@
 		if_ath_alq_post(&sc->sc_alq, ATH_ALQ_STUCK_BEACON, 0, NULL);
 #endif
 
-	if_printf(ifp, "stuck beacon; resetting (bmiss count %u)\n",
+	DPRINTF(sc, ATH_DEBUG_RESET, "stuck beacon; resetting (bmiss count %u)\n",
 		sc->sc_bmisscount);
 	sc->sc_stats.ast_bstuck++;
 	/*
@@ -6439,7 +6439,7 @@
 	 * Immediately punt.
 	 */
 	if (! an->an_is_powersave) {
-		device_printf(sc->sc_dev,
+		DPRINTF(sc, ATH_DEBUG_NODE_PWRSAVE,
 		    "%s: %6D: not in powersave?\n",
 		    __func__,
 		    ni->ni_macaddr,
