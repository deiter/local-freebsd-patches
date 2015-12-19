--- sys/dev/ath/if_ath.c.orig	2015-03-01 02:39:05.750514626 +0300
+++ sys/dev/ath/if_ath.c	2015-03-01 02:39:15.604513207 +0300
@@ -3709,7 +3709,7 @@
 		if_ath_alq_post(&sc->sc_alq, ATH_ALQ_STUCK_BEACON, 0, NULL);
 #endif
 
-	if_printf(ifp, "stuck beacon; resetting (bmiss count %u)\n",
+	DPRINTF(sc, ATH_DEBUG_RESET, "stuck beacon; resetting (bmiss count %u)\n",
 		sc->sc_bmisscount);
 	sc->sc_stats.ast_bstuck++;
 	/*
