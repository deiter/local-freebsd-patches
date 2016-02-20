--- sys/boot/common/part.c.orig	2016-02-21 02:18:18.719545000 +0300
+++ sys/boot/common/part.c	2016-02-21 02:23:15.400075000 +0300
@@ -650,7 +650,7 @@
 			goto out;
 		}
 #ifdef LOADER_GPT_SUPPORT
-		if (dp[i].dp_typ == DOSPTYP_PMBR) {
+		if (dp[i].dp_typ == DOSPTYP_PMBR || dp[i].dp_typ == DOSPTYP_EFI) {
 			table->type = PTABLE_GPT;
 			DEBUG("PMBR detected");
 		}
