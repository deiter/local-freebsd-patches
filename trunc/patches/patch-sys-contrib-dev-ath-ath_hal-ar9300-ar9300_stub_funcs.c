--- sys/contrib/dev/ath/ath_hal/ar9300/ar9300_stub_funcs.c.orig	2014-10-06 08:25:42.568211243 +0400
+++ sys/contrib/dev/ath/ath_hal/ar9300/ar9300_stub_funcs.c	2014-10-06 08:25:54.274210308 +0400
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
 
