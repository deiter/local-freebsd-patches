--- sys/sys/diskmbr.h.orig	2013-08-24 17:07:45.450787468 +0400
+++ sys/sys/diskmbr.h	2013-08-24 17:17:19.214740429 +0400
@@ -57,6 +57,7 @@
 #define	DOSPTYP_LINUX	0x83	/* Linux partition */
 #define	DOSPTYP_LINLVM	0x8e	/* Linux LVM partition */
 #define	DOSPTYP_PMBR	0xee	/* GPT Protective MBR */
+#define	DOSPTYP_LENOVO	0xef	/* GPT Protective MBR for Lenovo UEFI */
 #define	DOSPTYP_VMFS	0xfb	/* VMware VMFS partition */
 #define	DOSPTYP_VMKDIAG	0xfc	/* VMware vmkDiagnostic partition */
 #define	DOSPTYP_LINRAID	0xfd	/* Linux raid partition */
