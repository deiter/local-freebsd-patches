--- sbin/newfs/newfs.c.orig	2014-10-02 01:01:06.000000000 +0400
+++ sbin/newfs/newfs.c	2014-10-02 01:03:17.000000000 +0400
@@ -152,10 +152,10 @@
 			break;
 		case 'L':
 			volumelabel = optarg;
-			i = -1;
-			while (isalnum(volumelabel[++i]));
+			i = strspn(volumelabel,
+			    "-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz");
 			if (volumelabel[i] != '\0') {
-				errx(1, "bad volume label. Valid characters are alphanumerics.");
+				errx(1, "bad volume label. Valid characters are [0-9A-Za-z._-].");
 			}
 			if (strlen(volumelabel) >= MAXVOLLEN) {
 				errx(1, "bad volume label. Length is longer than %d.",
