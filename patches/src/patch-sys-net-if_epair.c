Index: sys/net/if_epair.c
===================================================================
--- sys/net/if_epair.c	(revision 309105)
+++ sys/net/if_epair.c	(working copy)
@@ -724,6 +724,8 @@
 		ifp = scb->ifp;
 		/* Assign a hopefully unique, locally administered etheraddr. */
 		eaddr[0] = 0x02;
+		eaddr[1] = (uint8_t)(arc4random() % 0xff);
+		eaddr[2] = (uint8_t)(arc4random() % 0xff);
 		eaddr[3] = (ifp->if_index >> 8) & 0xff;
 		eaddr[4] = ifp->if_index & 0xff;
 		eaddr[5] = 0x0b;
@@ -834,6 +836,8 @@
 	ifp->if_snd.ifq_maxlen = ifqmaxlen;
 	/* Assign a hopefully unique, locally administered etheraddr. */
 	eaddr[0] = 0x02;
+	eaddr[1] = (uint8_t)(arc4random() % 0xff);
+	eaddr[2] = (uint8_t)(arc4random() % 0xff);
 	eaddr[3] = (ifp->if_index >> 8) & 0xff;
 	eaddr[4] = ifp->if_index & 0xff;
 	eaddr[5] = 0x0a;
