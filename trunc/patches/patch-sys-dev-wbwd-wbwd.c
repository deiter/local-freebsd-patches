--- sys/dev/wbwd/wbwd.c.orig	2014-11-04 04:12:53.688779902 +0300
+++ sys/dev/wbwd/wbwd.c	2014-11-04 04:13:08.385778711 +0300
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
