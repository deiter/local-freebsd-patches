--- sys/dev/ath/if_ath_tx.c.orig	2013-08-24 17:08:04.251804637 +0400
+++ sys/dev/ath/if_ath_tx.c	2013-08-24 17:45:49.671700740 +0400
@@ -1481,7 +1481,7 @@
 		 * Other control/mgmt frame; bypass software queuing
 		 * for now!
 		 */
-		device_printf(sc->sc_dev,
+		DPRINTF(sc, ATH_DEBUG_NODE_PWRSAVE,
 		    "%s: %6D: Node is asleep; sending mgmt "
 		    "(type=%d, subtype=%d)\n",
 		    __func__,
@@ -3738,7 +3738,7 @@
 
 	tap = ath_tx_get_tx_tid(an, tid->tid);
 
-	device_printf(sc->sc_dev,
+	DPRINTF(sc, ATH_DEBUG_SW_TX_CTRL,
 	    "%s: %s: %6D: bf=%p: addbaw=%d, dobaw=%d, "
 	    "seqno=%d, retry=%d\n",
 	    __func__,
@@ -3750,7 +3750,8 @@
 	    bf->bf_state.bfs_dobaw,
 	    SEQNO(bf->bf_state.bfs_seqno),
 	    bf->bf_state.bfs_retries);
-	device_printf(sc->sc_dev,
+
+	DPRINTF(sc, ATH_DEBUG_SW_TX_CTRL,
 	    "%s: %s: %6D: bf=%p: txq[%d] axq_depth=%d, axq_aggr_depth=%d\n",
 	    __func__,
 	    pfx,
@@ -3761,7 +3762,7 @@
 	    txq->axq_depth,
 	    txq->axq_aggr_depth);
 
-	device_printf(sc->sc_dev,
+	DPRINTF(sc, ATH_DEBUG_SW_TX_CTRL,
 	    "%s: %s: %6D: bf=%p: tid txq_depth=%d hwq_depth=%d, bar_wait=%d, "
 	      "isfiltered=%d\n",
 	    __func__,
@@ -3773,7 +3774,8 @@
 	    tid->hwq_depth,
 	    tid->bar_wait,
 	    tid->isfiltered);
-	device_printf(sc->sc_dev,
+
+	DPRINTF(sc, ATH_DEBUG_SW_TX_CTRL,
 	    "%s: %s: %6D: tid %d: "
 	    "sched=%d, paused=%d, "
 	    "incomp=%d, baw_head=%d, "
@@ -3789,6 +3791,7 @@
 	     ni->ni_txseqs[tid->tid]);
 
 	/* XXX Dump the frame, see what it is? */
+	if (IFF_DUMPPKTS(sc, ATH_DEBUG_SW_TX_CTRL))
 	ieee80211_dump_pkt(ni->ni_ic,
 	    mtod(bf->bf_m, const uint8_t *),
 	    bf->bf_m->m_len, 0, -1);
@@ -6026,7 +6029,7 @@
 	/* !? */
 	if (an->an_is_powersave == 0) {
 		ATH_TX_UNLOCK(sc);
-		device_printf(sc->sc_dev,
+		DPRINTF(sc, ATH_DEBUG_NODE_PWRSAVE,
 		    "%s: an=%p: node was already awake\n",
 		    __func__, an);
 		return;
