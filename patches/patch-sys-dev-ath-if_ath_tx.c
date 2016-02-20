--- sys/dev/ath/if_ath_tx.c.orig	2016-02-21 02:18:19.222877000 +0300
+++ sys/dev/ath/if_ath_tx.c	2016-02-21 02:23:15.411289000 +0300
@@ -1673,7 +1673,7 @@
 			flags |= HAL_TXDESC_NOACK;
 		break;
 	default:
-		device_printf(sc->sc_dev, "bogus frame type 0x%x (%s)\n",
+		DPRINTF(sc, ATH_DEBUG_SW_TX, "bogus frame type 0x%x (%s)\n",
 		    wh->i_fc[0] & IEEE80211_FC0_TYPE_MASK, __func__);
 		/* XXX statistic */
 		/* XXX free tx dmamap */
