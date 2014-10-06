--- sys/boot/common/part.c.orig	2014-10-06 08:25:43.080211404 +0400
+++ sys/boot/common/part.c	2014-10-06 08:25:54.269210021 +0400
@@ -645,7 +645,7 @@
 			goto out;
 		}
 #ifdef LOADER_GPT_SUPPORT
-		if (dp[i].dp_typ == DOSPTYP_PMBR) {
+		if (dp[i].dp_typ == DOSPTYP_PMBR || dp[i].dp_typ == DOSPTYP_LENOVO) {
 			table->type = PTABLE_GPT;
 			DEBUG("PMBR detected");
 		}
