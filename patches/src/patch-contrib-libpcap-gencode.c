diff --git a/gencode.c b/gencode.c
index a887f27..60494e3 100644
--- contrib/libpcap/gencode.c
+++ contrib/libpcap/gencode.c
@@ -523,7 +523,8 @@ static struct block *gen_host6(compiler_state_t *, struct in6_addr *,
     struct in6_addr *, int, int, int);
 #endif
 #ifndef INET6
-static struct block *gen_gateway(const u_char *, bpf_u_int32 **, int, int);
+static struct block *gen_gateway(compiler_state_t *, const u_char *,
+    bpf_u_int32 **, int, int);
 #endif
 static struct block *gen_ipfrag(compiler_state_t *);
 static struct block *gen_portatom(compiler_state_t *, int, bpf_int32);
@@ -690,7 +691,9 @@ pcap_compile(pcap_t *p, struct bpf_program *program,
 	}
 	initchunks(&cstate);
 	cstate.no_optimize = 0;
+#ifdef INET6
 	cstate.ai = NULL;
+#endif
 	cstate.ic.root = NULL;
 	cstate.ic.cur_mark = 0;
 	cstate.bpf_pcap = p;
@@ -4902,11 +4905,8 @@ gen_host6(compiler_state_t *cstate, struct in6_addr *addr,
 
 #ifndef INET6
 static struct block *
-gen_gateway(eaddr, alist, proto, dir)
-	const u_char *eaddr;
-	bpf_u_int32 **alist;
-	int proto;
-	int dir;
+gen_gateway(compiler_state_t *cstate, const u_char *eaddr, bpf_u_int32 **alist,
+    int proto, int dir)
 {
 	struct block *b0, *b1, *tmp;
 
@@ -6470,7 +6470,7 @@ gen_scode(compiler_state_t *cstate, const char *name, struct qual q)
 		alist = pcap_nametoaddr(name);
 		if (alist == NULL || *alist == NULL)
 			bpf_error(cstate, "unknown host '%s'", name);
-		b = gen_gateway(eaddr, alist, proto, dir);
+		b = gen_gateway(cstate, eaddr, alist, proto, dir);
 		free(eaddr);
 		return b;
 #else
