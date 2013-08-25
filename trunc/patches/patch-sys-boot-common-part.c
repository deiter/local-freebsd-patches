--- sys/boot/common/part.c.orig	2013-08-25 14:01:05.801845582 +0400
+++ sys/boot/common/part.c	2013-08-25 14:07:33.584810760 +0400
@@ -637,7 +637,7 @@
 			break;
 		}
 #ifdef LOADER_GPT_SUPPORT
-		if (dp[i].dp_typ == DOSPTYP_PMBR) {
+		if (dp[i].dp_typ == DOSPTYP_PMBR || dp[i].dp_typ == DOSPTYP_LENOVO) {
 			table->type = PTABLE_GPT;
 			DEBUG("PMBR detected");
 		}
