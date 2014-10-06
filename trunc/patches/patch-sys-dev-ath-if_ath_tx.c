--- sys/dev/ath/if_ath_tx.c.orig	2014-10-06 08:25:42.363211341 +0400
+++ sys/dev/ath/if_ath_tx.c	2014-10-06 08:25:54.279210237 +0400
@@ -1691,7 +1691,7 @@
 			flags |= HAL_TXDESC_NOACK;
 		break;
 	default:
-		if_printf(ifp, "bogus frame type 0x%x (%s)\n",
+		DPRINTF(sc, ATH_DEBUG_SW_TX, "bogus frame type 0x%x (%s)\n",
 			wh->i_fc[0] & IEEE80211_FC0_TYPE_MASK, __func__);
 		/* XXX statistic */
 		/* XXX free tx dmamap */
