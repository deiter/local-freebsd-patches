--- sys/geom/part/g_part.c.orig	2014-08-15 02:23:59.000000000 +0400
+++ sys/geom/part/g_part.c	2014-08-15 02:24:11.000000000 +0400
@@ -365,7 +365,7 @@
 		}
 	}
 	if (failed != 0) {
-		printf("GEOM_PART: integrity check failed (%s, %s)\n",
+		DPRINTF("integrity check failed (%s, %s)\n",
 		    pp->name, table->gpt_scheme->name);
 		if (check_integrity != 0)
 			return (EINVAL);
