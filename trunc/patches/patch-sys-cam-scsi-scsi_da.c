--- sys/cam/scsi/scsi_da.c.orig	2014-11-04 04:12:52.994779828 +0300
+++ sys/cam/scsi/scsi_da.c	2014-11-04 04:13:08.375778479 +0300
@@ -728,6 +728,16 @@
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
@@ -1030,6 +1040,14 @@
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
