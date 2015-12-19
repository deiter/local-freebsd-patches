--- sbin/tunefs/tunefs.c.orig	2015-12-19 20:05:48.751423000 +0300
+++ sbin/tunefs/tunefs.c	2015-12-19 20:06:01.870818000 +0300
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
