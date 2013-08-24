--- sys/geom/part/g_part.c.orig	2013-08-24 17:08:17.331798602 +0400
+++ sys/geom/part/g_part.c	2013-08-24 17:17:19.147756776 +0400
@@ -353,7 +353,7 @@
 		}
 	}
 	if (failed != 0) {
-		printf("GEOM_PART: integrity check failed (%s, %s)\n",
+		DPRINTF("integrity check failed (%s, %s)\n",
 		    pp->name, table->gpt_scheme->name);
 		if (check_integrity != 0)
 			return (EINVAL);
