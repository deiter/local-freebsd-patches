--- sys/cam/ata/ata_da.c.orig	2015-12-19 20:05:55.149568000 +0300
+++ sys/cam/ata/ata_da.c	2015-12-19 20:06:01.873494000 +0300
@@ -178,6 +178,11 @@
 		/*quirks*/ADA_Q_4K
 	},
 	{
+		/* Seagate NAS HDD Advanced Format (4k) drives */
+		{ T_DIRECT, SIP_MEDIA_FIXED, "*", "ST????VN*", "*" },
+		/*quirks*/ADA_Q_4K
+	},
+	{
 		/* Seagate Barracuda Green Advanced Format (4k) drives */
 		{ T_DIRECT, SIP_MEDIA_FIXED, "*", "ST????DL*", "*" },
 		/*quirks*/ADA_Q_4K
@@ -370,6 +375,14 @@
 	},
 	{
 		/*
+		 * Intel 520 Series SSDs
+		 * 4k optimised & trim only works in 4k requests + 4k aligned
+		 */
+		{ T_DIRECT, SIP_MEDIA_FIXED, "*", "INTEL SSDSC2CW*", "*" },
+		/*quirks*/ADA_Q_4K
+	},
+	{
+		/*
 		 * Intel X25-M Series SSDs
 		 * 4k optimised & trim only works in 4k requests + 4k aligned
 		 */
