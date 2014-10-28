--- drivers/apcsmart.c.orig	2014-10-28 19:04:12.938574407 +0300
+++ drivers/apcsmart.c	2014-10-28 19:04:39.892572134 +0300
@@ -824,7 +824,7 @@
 	if (tag && name)
 		upslogx(LOG_WARNING, "%s [%s] - %s invalid", name, prtchr(cmd), tag);
 	else
-		upslogx(LOG_WARNING, "[%s] unrecognized", prtchr(cmd));
+		upsdebugx(1, "[%s] unrecognized", prtchr(cmd));
 }
 
 static void var_string_setup(apc_vartab_t *vt)
