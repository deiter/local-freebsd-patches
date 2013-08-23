--- sys/dev/ath/if_ath_tx.c.orig	2013-08-23 16:39:49.695905776 +0400
+++ sys/dev/ath/if_ath_tx.c	2013-08-23 17:02:56.512887543 +0400
@@ -1481,7 +1481,7 @@
 		 * Other control/mgmt frame; bypass software queuing
 		 * for now!
 		 */
-		device_printf(sc->sc_dev,
+		DPRINTF(sc, ATH_DEBUG_NODE_PWRSAVE,
 		    "%s: %6D: Node is asleep; sending mgmt "
 		    "(type=%d, subtype=%d)\n",
 		    __func__,
@@ -3831,7 +3831,6 @@
 		}
 
 		if (t == 0) {
-			ath_tx_tid_drain_print(sc, an, "norm", tid, bf);
 			t = 1;
 		}
 
@@ -3847,7 +3846,6 @@
 			break;
 
 		if (t == 0) {
-			ath_tx_tid_drain_print(sc, an, "filt", tid, bf);
 			t = 1;
 		}
 
@@ -6026,7 +6024,7 @@
 	/* !? */
 	if (an->an_is_powersave == 0) {
 		ATH_TX_UNLOCK(sc);
-		device_printf(sc->sc_dev,
+		DPRINTF(sc, ATH_DEBUG_NODE_PWRSAVE,
 		    "%s: an=%p: node was already awake\n",
 		    __func__, an);
 		return;
