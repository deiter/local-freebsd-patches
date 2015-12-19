--- sys/geom/part/g_part.c.orig	2015-12-19 20:05:54.567221000 +0300
+++ sys/geom/part/g_part.c	2015-12-19 20:06:01.887071000 +0300
@@ -370,7 +370,7 @@
 		}
 	}
 	if (failed != 0) {
-		printf("GEOM_PART: integrity check failed (%s, %s)\n",
+		DPRINTF("integrity check failed (%s, %s)\n",
 		    pp->name, table->gpt_scheme->name);
 		if (check_integrity != 0)
 			return (EINVAL);
