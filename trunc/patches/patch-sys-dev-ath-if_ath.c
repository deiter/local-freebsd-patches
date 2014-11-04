--- sys/dev/ath/if_ath.c.orig	2014-11-04 04:12:53.533779964 +0300
+++ sys/dev/ath/if_ath.c	2014-11-04 04:13:08.380778579 +0300
@@ -3706,7 +3706,7 @@
 		if_ath_alq_post(&sc->sc_alq, ATH_ALQ_STUCK_BEACON, 0, NULL);
 #endif
 
-	if_printf(ifp, "stuck beacon; resetting (bmiss count %u)\n",
+	DPRINTF(sc, ATH_DEBUG_RESET, "stuck beacon; resetting (bmiss count %u)\n",
 		sc->sc_bmisscount);
 	sc->sc_stats.ast_bstuck++;
 	/*
