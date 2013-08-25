--- sys/geom/part/g_part.c.orig	2013-08-25 14:00:22.165863476 +0400
+++ sys/geom/part/g_part.c	2013-08-25 14:07:34.010820057 +0400
@@ -353,7 +353,7 @@
 		}
 	}
 	if (failed != 0) {
-		printf("GEOM_PART: integrity check failed (%s, %s)\n",
+		DPRINTF("integrity check failed (%s, %s)\n",
 		    pp->name, table->gpt_scheme->name);
 		if (check_integrity != 0)
 			return (EINVAL);
