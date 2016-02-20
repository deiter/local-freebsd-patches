--- sys/geom/part/g_part.c.orig	2016-02-21 02:18:19.672387000 +0300
+++ sys/geom/part/g_part.c	2016-02-21 02:23:15.415279000 +0300
@@ -377,7 +377,7 @@
 		}
 	}
 	if (failed != 0) {
-		printf("GEOM_PART: integrity check failed (%s, %s)\n",
+		DPRINTF("integrity check failed (%s, %s)\n",
 		    pp->name, table->gpt_scheme->name);
 		if (check_integrity != 0)
 			return (EINVAL);
