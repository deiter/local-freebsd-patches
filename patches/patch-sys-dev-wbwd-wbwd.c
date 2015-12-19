--- sys/dev/wbwd/wbwd.c.orig	2015-12-19 20:05:54.124339000 +0300
+++ sys/dev/wbwd/wbwd.c	2015-12-19 20:06:01.885614000 +0300
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
