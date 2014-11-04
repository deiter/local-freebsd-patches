--- sys/contrib/dev/ath/ath_hal/ar9300/ar9300_stub_funcs.c.orig	2014-11-04 04:12:54.000779844 +0300
+++ sys/contrib/dev/ath/ath_hal/ar9300/ar9300_stub_funcs.c	2014-11-04 04:13:08.377778467 +0300
@@ -430,7 +430,9 @@
 ar9300_Stub_GetAntennaSwitch(struct ath_hal *ah)
 {
 
+/*
 	ath_hal_printf(ah, "%s: called\n", __func__);
+*/
 	return (HAL_ANT_VARIABLE);
 }
 
@@ -526,7 +528,9 @@
 ar9300_Stub_GetCTSTimeout(struct ath_hal *ah)
 {
 
+/*
 	ath_hal_printf(ah, "%s: called\n", __func__);
+*/
 	return (0);
 }
 
