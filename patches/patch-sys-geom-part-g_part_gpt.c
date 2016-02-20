--- sys/geom/part/g_part_gpt.c.orig	2016-02-21 02:18:19.670826000 +0300
+++ sys/geom/part/g_part_gpt.c	2016-02-21 02:23:15.416646000 +0300
@@ -938,10 +938,12 @@
 	}
 
 	if (table->state[GPT_ELT_PRITBL] != GPT_STATE_OK) {
+		if (bootverbose) {
 		printf("GEOM: %s: the primary GPT table is corrupt or "
 		    "invalid.\n", pp->name);
 		printf("GEOM: %s: using the secondary instead -- recovery "
 		    "strongly advised.\n", pp->name);
+		}
 		table->hdr = sechdr;
 		basetable->gpt_corrupt = 1;
 		if (prihdr != NULL)
@@ -957,8 +959,10 @@
 			    "suggested.\n", pp->name);
 			basetable->gpt_corrupt = 1;
 		} else if (table->lba[GPT_ELT_SECHDR] != last) {
+			if (bootverbose) {
 			printf( "GEOM: %s: the secondary GPT header is not in "
 			    "the last LBA.\n", pp->name);
+			}
 			basetable->gpt_corrupt = 1;
 		}
 		table->hdr = prihdr;
