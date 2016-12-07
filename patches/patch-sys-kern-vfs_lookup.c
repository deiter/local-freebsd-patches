Index: sys/kern/vfs_lookup.c
===================================================================
--- sys/kern/vfs_lookup.c	(revision 309673)
+++ sys/kern/vfs_lookup.c	(working copy)
@@ -1017,6 +1017,7 @@
 			vput(ndp->ni_dvp);
 		else
 			vrele(ndp->ni_dvp);
+		ndp->ni_pathlen += cnp->cn_namelen;
 		goto dirloop;
 	}
 	if (cnp->cn_flags & ISDOTDOT) {
