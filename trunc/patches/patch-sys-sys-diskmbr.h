--- sys/sys/diskmbr.h.orig	2014-02-26 20:12:46.000000000 +0400
+++ sys/sys/diskmbr.h	2014-02-26 20:12:58.000000000 +0400
@@ -57,6 +57,7 @@
 #define	DOSPTYP_LINUX	0x83	/* Linux partition */
 #define	DOSPTYP_LINLVM	0x8e	/* Linux LVM partition */
 #define	DOSPTYP_PMBR	0xee	/* GPT Protective MBR */
+#define	DOSPTYP_LENOVO	0xef	/* GPT Protective MBR for Lenovo UEFI */
 #define	DOSPTYP_VMFS	0xfb	/* VMware VMFS partition */
 #define	DOSPTYP_VMKDIAG	0xfc	/* VMware vmkDiagnostic partition */
 #define	DOSPTYP_LINRAID	0xfd	/* Linux raid partition */
