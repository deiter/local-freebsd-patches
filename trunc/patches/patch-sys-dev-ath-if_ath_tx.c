--- sys/dev/ath/if_ath_tx.c.orig	2014-11-04 04:12:53.509780175 +0300
+++ sys/dev/ath/if_ath_tx.c	2014-11-04 04:13:08.382778546 +0300
@@ -1691,7 +1691,7 @@
 			flags |= HAL_TXDESC_NOACK;
 		break;
 	default:
-		if_printf(ifp, "bogus frame type 0x%x (%s)\n",
+		DPRINTF(sc, ATH_DEBUG_SW_TX, "bogus frame type 0x%x (%s)\n",
 			wh->i_fc[0] & IEEE80211_FC0_TYPE_MASK, __func__);
 		/* XXX statistic */
 		/* XXX free tx dmamap */
