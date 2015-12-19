--- sys/cam/scsi/scsi_da.c.orig	2015-12-19 20:05:55.146218000 +0300
+++ sys/cam/scsi/scsi_da.c	2015-12-19 20:06:01.875522000 +0300
@@ -740,6 +740,16 @@
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
@@ -1042,6 +1052,14 @@
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
