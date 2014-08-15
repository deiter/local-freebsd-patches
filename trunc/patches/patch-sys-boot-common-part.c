--- sys/boot/common/part.c.orig	2014-08-15 02:23:59.000000000 +0400
+++ sys/boot/common/part.c	2014-08-15 02:24:11.000000000 +0400
@@ -637,7 +637,7 @@
 			goto out;
 		}
 #ifdef LOADER_GPT_SUPPORT
-		if (dp[i].dp_typ == DOSPTYP_PMBR) {
+		if (dp[i].dp_typ == DOSPTYP_PMBR || dp[i].dp_typ == DOSPTYP_LENOVO) {
 			table->type = PTABLE_GPT;
 			DEBUG("PMBR detected");
 		}
