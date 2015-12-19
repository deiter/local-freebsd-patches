--- sys/dev/ath/if_ath_tx.c.orig	2015-12-19 20:05:54.189627000 +0300
+++ sys/dev/ath/if_ath_tx.c	2015-12-19 20:06:01.883151000 +0300
@@ -1673,7 +1673,7 @@
 			flags |= HAL_TXDESC_NOACK;
 		break;
 	default:
-		device_printf(sc->sc_dev, "bogus frame type 0x%x (%s)\n",
+		DPRINTF(sc, ATH_DEBUG_SW_TX, "bogus frame type 0x%x (%s)\n",
 		    wh->i_fc[0] & IEEE80211_FC0_TYPE_MASK, __func__);
 		/* XXX statistic */
 		/* XXX free tx dmamap */
