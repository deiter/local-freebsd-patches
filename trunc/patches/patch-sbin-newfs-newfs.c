--- sbin/newfs/newfs.c.orig	2014-11-04 04:12:55.075779841 +0300
+++ sbin/newfs/newfs.c	2014-11-04 04:13:08.369778420 +0300
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
