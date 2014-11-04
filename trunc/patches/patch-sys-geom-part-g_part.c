--- sys/geom/part/g_part.c.orig	2014-11-04 04:12:53.895779879 +0300
+++ sys/geom/part/g_part.c	2014-11-04 04:13:08.386778641 +0300
@@ -365,7 +365,7 @@
 		}
 	}
 	if (failed != 0) {
-		printf("GEOM_PART: integrity check failed (%s, %s)\n",
+		DPRINTF("integrity check failed (%s, %s)\n",
 		    pp->name, table->gpt_scheme->name);
 		if (check_integrity != 0)
 			return (EINVAL);
