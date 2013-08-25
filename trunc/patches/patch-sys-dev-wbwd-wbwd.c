--- sys/dev/wbwd/wbwd.c.orig	2013-08-25 14:00:57.143854861 +0400
+++ sys/dev/wbwd/wbwd.c	2013-08-25 14:07:33.970817843 +0400
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
