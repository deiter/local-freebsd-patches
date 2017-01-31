Index: sys/netinet/tcp_fastopen.c
===================================================================
--- sys/netinet/tcp_fastopen.c	(revision 312971)
+++ sys/netinet/tcp_fastopen.c	(working copy)
@@ -209,6 +209,7 @@
 	rm_init(&V_tcp_fastopen_keylock, "tfo_keylock");
 	callout_init_rm(&V_tcp_fastopen_autokey_ctx.c,
 	    &V_tcp_fastopen_keylock, 0);
+	V_tcp_fastopen_autokey_ctx.v = curvnet;
 	V_tcp_fastopen_keys.newest = TCP_FASTOPEN_MAX_KEYS - 1;
 }
 
