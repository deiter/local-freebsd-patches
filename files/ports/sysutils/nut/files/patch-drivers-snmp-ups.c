--- drivers/snmp-ups.c.orig	2016-03-09 14:39:45.000000000 +0300
+++ drivers/snmp-ups.c	2017-03-22 06:58:50.480904000 +0300
@@ -56,11 +56,6 @@
 #include "eaton-ats-mib.h"
 #include "apc-ats-mib.h"
 
-/* Address API change */
-#ifndef usmAESPrivProtocol
-#define usmAESPrivProtocol usmAES128PrivProtocol
-#endif
-
 static mib2nut_info_t *mib2nut[] = {
 	&apc,
 	&mge,
@@ -827,7 +822,7 @@
 		}
 		break;
 	default:
-		upslogx(LOG_ERR, "[%s] unhandled ASN 0x%x received from %s",
+		upsdebugx(2, "[%s] unhandled ASN 0x%x received from %s",
 			upsname?upsname:device_name, pdu->variables->type, OID);
 		return FALSE;
 	}
