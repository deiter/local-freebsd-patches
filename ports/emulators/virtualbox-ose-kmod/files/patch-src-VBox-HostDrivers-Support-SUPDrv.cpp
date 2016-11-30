--- src/VBox/HostDrivers/Support/SUPDrv.cpp.orig	2016-11-30 23:27:52.817479000 +0300
+++ src/VBox/HostDrivers/Support/SUPDrv.cpp	2016-11-30 23:33:16.098611000 +0300
@@ -4924,7 +4924,6 @@
     }
     if (RT_SUCCESS(rc))
     {
-        SUPR0Printf("vboxdrv: %p %s\n", pImage->pvImage, pImage->szName);
         pReq->u.Out.uErrorMagic = 0;
         pReq->u.Out.szError[0]  = '\0';
     }
