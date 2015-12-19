--- sys/geom/part/g_part.c.orig	2015-03-01 02:39:05.186514497 +0300
+++ sys/geom/part/g_part.c	2015-03-01 02:39:15.610513485 +0300
@@ -367,7 +367,7 @@
 		}
 	}
 	if (failed != 0) {
-		printf("GEOM_PART: integrity check failed (%s, %s)\n",
+		DPRINTF("integrity check failed (%s, %s)\n",
 		    pp->name, table->gpt_scheme->name);
 		if (check_integrity != 0)
 			return (EINVAL);
