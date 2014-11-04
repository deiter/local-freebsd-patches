--- sys/boot/common/part.c.orig	2014-11-04 04:12:53.063779956 +0300
+++ sys/boot/common/part.c	2014-11-04 04:13:08.371778454 +0300
@@ -645,7 +645,7 @@
 			goto out;
 		}
 #ifdef LOADER_GPT_SUPPORT
-		if (dp[i].dp_typ == DOSPTYP_PMBR) {
+		if (dp[i].dp_typ == DOSPTYP_PMBR || dp[i].dp_typ == DOSPTYP_LENOVO) {
 			table->type = PTABLE_GPT;
 			DEBUG("PMBR detected");
 		}
