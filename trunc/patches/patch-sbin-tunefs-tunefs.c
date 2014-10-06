--- sbin/tunefs/tunefs.c.orig	2014-10-06 08:25:44.099211269 +0400
+++ sbin/tunefs/tunefs.c	2014-10-06 08:25:54.267210371 +0400
@@ -183,11 +183,11 @@
 			found_arg = 1;
 			name = "volume label";
 			Lvalue = optarg;
-			i = -1;
-			while (isalnum(Lvalue[++i]));
+			i = strspn(Lvalue,
+			    "-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz");
 			if (Lvalue[i] != '\0') {
 				errx(10,
-				"bad %s. Valid characters are alphanumerics.",
+				"bad %s. Valid characters are [0-9A-Za-z._-].",
 				    name);
 			}
 			if (strlen(Lvalue) >= MAXVOLLEN) {
