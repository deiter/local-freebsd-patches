--- sys/dev/ath/if_ath_tx.c.orig	2016-09-02 11:22:11.919728000 +0300
+++ sys/dev/ath/if_ath_tx.c	2016-09-02 11:22:22.106260000 +0300
@@ -1674,7 +1674,7 @@
 			flags |= HAL_TXDESC_NOACK;
 		break;
 	default:
-		device_printf(sc->sc_dev, "bogus frame type 0x%x (%s)\n",
+		DPRINTF(sc, ATH_DEBUG_SW_TX, "bogus frame type 0x%x (%s)\n",
 		    wh->i_fc[0] & IEEE80211_FC0_TYPE_MASK, __func__);
 		/* XXX statistic */
 		/* XXX free tx dmamap */
