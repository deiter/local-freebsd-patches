--- sys/dev/ath/if_ath_tx.c.orig	2016-11-09 20:39:24.098341000 +0300
+++ sys/dev/ath/if_ath_tx.c	2016-11-09 20:39:31.841686000 +0300
@@ -1683,7 +1683,7 @@
 			flags |= HAL_TXDESC_NOACK;
 		break;
 	default:
-		device_printf(sc->sc_dev, "bogus frame type 0x%x (%s)\n",
+		DPRINTF(sc, ATH_DEBUG_SW_TX, "bogus frame type 0x%x (%s)\n",
 		    wh->i_fc[0] & IEEE80211_FC0_TYPE_MASK, __func__);
 		/* XXX statistic */
 		/* XXX free tx dmamap */
