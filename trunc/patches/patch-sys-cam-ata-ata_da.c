--- sys/cam/ata/ata_da.c.orig	2014-10-06 08:25:43.012211661 +0400
+++ sys/cam/ata/ata_da.c	2014-10-06 08:25:54.270210292 +0400
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
@@ -355,6 +360,14 @@
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
