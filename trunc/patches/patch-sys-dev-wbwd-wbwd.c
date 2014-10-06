--- sys/dev/wbwd/wbwd.c.orig	2014-10-06 08:25:42.388211381 +0400
+++ sys/dev/wbwd/wbwd.c	2014-10-06 08:25:54.282210095 +0400
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
