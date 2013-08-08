--- sys/geom/part/g_part.c.orig	2013-08-08 05:26:51.000000000 +0000
+++ sys/geom/part/g_part.c	2013-08-08 05:27:39.000000000 +0000
@@ -353,7 +353,7 @@
 		}
 	}
 	if (failed != 0) {
-		printf("GEOM_PART: integrity check failed (%s, %s)\n",
+		DPRINTF("integrity check failed (%s, %s)\n",
 		    pp->name, table->gpt_scheme->name);
 		if (check_integrity != 0)
 			return (EINVAL);
