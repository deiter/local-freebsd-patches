--- sys/geom/part/g_part_gpt.c.orig	2014-11-04 04:12:53.897780105 +0300
+++ sys/geom/part/g_part_gpt.c	2014-11-04 04:13:08.387778588 +0300
@@ -920,10 +920,12 @@
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
@@ -939,8 +941,10 @@
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
