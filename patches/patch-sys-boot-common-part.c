--- sys/boot/common/part.c.orig	2015-03-01 02:39:04.789514364 +0300
+++ sys/boot/common/part.c	2015-03-01 02:39:15.594513625 +0300
@@ -645,7 +645,7 @@
 			goto out;
 		}
 #ifdef LOADER_GPT_SUPPORT
-		if (dp[i].dp_typ == DOSPTYP_PMBR) {
+		if (dp[i].dp_typ == DOSPTYP_PMBR || dp[i].dp_typ == DOSPTYP_EFI) {
 			table->type = PTABLE_GPT;
 			DEBUG("PMBR detected");
 		}
