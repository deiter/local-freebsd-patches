Index: sys/netinet/tcp_subr.c
===================================================================
--- sys/netinet/tcp_subr.c	(revision 313106)
+++ sys/netinet/tcp_subr.c	(working copy)
@@ -679,6 +679,10 @@
 	V_sack_hole_zone = uma_zcreate("sackhole", sizeof(struct sackhole),
 	    NULL, NULL, NULL, NULL, UMA_ALIGN_PTR, 0);
 
+#ifdef TCP_RFC7413
+	tcp_fastopen_init();
+#endif
+
 	/* Skip initialization of globals for non-default instances. */
 	if (!IS_DEFAULT_VNET(curvnet))
 		return;
@@ -732,10 +736,6 @@
 #ifdef TCPPCAP
 	tcp_pcap_init();
 #endif
-
-#ifdef TCP_RFC7413
-	tcp_fastopen_init();
-#endif
 }
 
 #ifdef VIMAGE
