--- sys/boot/common/part.c.orig	2016-11-09 20:39:23.419068000 +0300
+++ sys/boot/common/part.c	2016-11-09 20:39:31.833602000 +0300
@@ -651,7 +651,7 @@
 			goto out;
 		}
 #ifdef LOADER_GPT_SUPPORT
-		if (dp[i].dp_typ == DOSPTYP_PMBR) {
+		if (dp[i].dp_typ == DOSPTYP_PMBR || dp[i].dp_typ == DOSPTYP_EFI) {
 			table->type = PTABLE_GPT;
 			DEBUG("PMBR detected");
 		}
