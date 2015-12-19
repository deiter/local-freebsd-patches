--- sys/boot/common/part.c.orig	2015-12-19 20:05:53.655447000 +0300
+++ sys/boot/common/part.c	2015-12-19 20:06:01.871973000 +0300
@@ -650,7 +650,7 @@
 			goto out;
 		}
 #ifdef LOADER_GPT_SUPPORT
-		if (dp[i].dp_typ == DOSPTYP_PMBR) {
+		if (dp[i].dp_typ == DOSPTYP_PMBR || dp[i].dp_typ == DOSPTYP_EFI) {
 			table->type = PTABLE_GPT;
 			DEBUG("PMBR detected");
 		}
