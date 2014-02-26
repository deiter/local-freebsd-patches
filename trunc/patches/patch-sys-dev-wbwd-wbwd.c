--- sys/dev/wbwd/wbwd.c.orig	2014-02-26 20:12:47.000000000 +0400
+++ sys/dev/wbwd/wbwd.c	2014-02-26 20:12:58.000000000 +0400
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
