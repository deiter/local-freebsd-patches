--- sys/dev/wbwd/wbwd.c.orig	2013-08-25 01:28:42.359369504 +0400
+++ sys/dev/wbwd/wbwd.c	2013-08-25 01:40:26.738315431 +0400
@@ -185,6 +185,12 @@
 		.device_rev	= 0x33,
 		.descr		= "Nuvoton WPCM450RA0BX",   
 	},
+	{
+		.vendor_id	= 0x5ca3,
+		.device_id	= 0x60,
+		.device_rev	= 0x12,
+		.descr		= "Winbond W83697HF/F/HG",
+	},
 };
 
 static void
