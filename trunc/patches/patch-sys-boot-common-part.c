--- sys/boot/common/part.c.orig	2014-02-26 20:12:46.000000000 +0400
+++ sys/boot/common/part.c	2014-02-26 20:12:58.000000000 +0400
@@ -637,7 +637,7 @@
 			break;
 		}
 #ifdef LOADER_GPT_SUPPORT
-		if (dp[i].dp_typ == DOSPTYP_PMBR) {
+		if (dp[i].dp_typ == DOSPTYP_PMBR || dp[i].dp_typ == DOSPTYP_LENOVO) {
 			table->type = PTABLE_GPT;
 			DEBUG("PMBR detected");
 		}
