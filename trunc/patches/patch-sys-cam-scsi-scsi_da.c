--- sys/cam/scsi/scsi_da.c.orig	2015-03-01 02:39:05.342514543 +0300
+++ sys/cam/scsi/scsi_da.c	2015-03-01 02:39:15.598513565 +0300
@@ -739,6 +739,16 @@
 		/*quirks*/DA_Q_4K
 	},
 	{
+		/* Seagate NAS HDD Advanced Format (4k) drives */
+		{ T_DIRECT, SIP_MEDIA_FIXED, "ATA", "ST????VN*", "*" },
+		/*quirks*/DA_Q_4K
+	},
+	{
+		/* Seagate NAS HDD Advanced Format (4k) drives */
+		{ T_DIRECT, SIP_MEDIA_FIXED, "ST????VN", "*", "*" },
+		/*quirks*/DA_Q_4K
+	},
+	{
 		/* Seagate Barracuda Green Advanced Format (4k) drives */
 		{ T_DIRECT, SIP_MEDIA_FIXED, "ATA", "ST????DL*", "*" },
 		/*quirks*/DA_Q_4K
@@ -1041,6 +1051,14 @@
 	},
 	{
 		/*
+		 * Intel 520 Series SSDs
+		 * 4k optimised & trim only works in 4k requests + 4k aligned
+		 */
+		{ T_DIRECT, SIP_MEDIA_FIXED, "ATA", "INTEL SSDSC2CW*", "*" },
+		/*quirks*/DA_Q_4K
+	},
+	{
+		/*
 		 * Intel X25-M Series SSDs
 		 * 4k optimised & trim only works in 4k requests + 4k aligned
 		 */
