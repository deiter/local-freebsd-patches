--- common/common.c.orig	2014-10-28 19:01:41.911589407 +0300
+++ common/common.c	2014-10-28 19:02:47.363581752 +0300
@@ -238,7 +238,7 @@
 
 	pidf = fopen(pidfn, "r");
 	if (!pidf) {
-		upslog_with_errno(LOG_NOTICE, "fopen %s", pidfn);
+		upsdebug_with_errno(LOG_DEBUG, "fopen %s", pidfn);
 		return -1;
 	}
 
@@ -260,7 +260,6 @@
 	ret = kill(pid, 0);
 
 	if (ret < 0) {
-		perror("kill");
 		fclose(pidf);
 		return -1;
 	}
