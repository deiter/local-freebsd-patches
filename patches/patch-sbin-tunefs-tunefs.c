--- sbin/tunefs/tunefs.c.orig	2016-09-02 11:22:07.948327000 +0300
+++ sbin/tunefs/tunefs.c	2016-09-02 11:22:22.090573000 +0300
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
