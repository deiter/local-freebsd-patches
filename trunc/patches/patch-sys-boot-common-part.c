--- sys/boot/common/part.c.orig	2013-08-24 17:07:50.506795983 +0400
+++ sys/boot/common/part.c	2013-08-24 17:17:19.007746802 +0400
@@ -637,7 +637,7 @@
 			break;
 		}
 #ifdef LOADER_GPT_SUPPORT
-		if (dp[i].dp_typ == DOSPTYP_PMBR) {
+		if (dp[i].dp_typ == DOSPTYP_PMBR || dp[i].dp_typ == DOSPTYP_LENOVO) {
 			table->type = PTABLE_GPT;
 			DEBUG("PMBR detected");
 		}
