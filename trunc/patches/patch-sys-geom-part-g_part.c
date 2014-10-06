--- sys/geom/part/g_part.c.orig	2014-10-06 08:25:42.503211072 +0400
+++ sys/geom/part/g_part.c	2014-10-06 08:25:54.283210217 +0400
@@ -365,7 +365,7 @@
 		}
 	}
 	if (failed != 0) {
-		printf("GEOM_PART: integrity check failed (%s, %s)\n",
+		DPRINTF("integrity check failed (%s, %s)\n",
 		    pp->name, table->gpt_scheme->name);
 		if (check_integrity != 0)
 			return (EINVAL);
