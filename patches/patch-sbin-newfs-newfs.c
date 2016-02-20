--- sbin/newfs/newfs.c.orig	2016-02-21 02:18:20.949022000 +0300
+++ sbin/newfs/newfs.c	2016-02-21 02:23:15.397553000 +0300
@@ -149,10 +149,10 @@
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
