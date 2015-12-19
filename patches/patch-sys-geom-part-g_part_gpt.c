--- sys/geom/part/g_part_gpt.c.orig	2015-12-19 20:05:54.565625000 +0300
+++ sys/geom/part/g_part_gpt.c	2015-12-19 20:06:01.888411000 +0300
@@ -924,10 +924,12 @@
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
@@ -943,8 +945,10 @@
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
