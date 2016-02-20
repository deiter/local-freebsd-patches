--- sys/dev/ath/if_ath.c.orig	2016-02-21 02:18:19.227656000 +0300
+++ sys/dev/ath/if_ath.c	2016-02-21 02:23:15.408760000 +0300
@@ -3659,7 +3659,7 @@
 		if_ath_alq_post(&sc->sc_alq, ATH_ALQ_STUCK_BEACON, 0, NULL);
 #endif
 
-	device_printf(sc->sc_dev, "stuck beacon; resetting (bmiss count %u)\n",
+	DPRINTF(sc, ATH_DEBUG_RESET, "stuck beacon; resetting (bmiss count %u)\n",
 	    sc->sc_bmisscount);
 	sc->sc_stats.ast_bstuck++;
 	/*
