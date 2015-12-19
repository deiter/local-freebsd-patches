--- m4/nut_check_libwrap.m4.orig	2014-10-28 18:38:35.193686451 +0300
+++ m4/nut_check_libwrap.m4	2014-10-28 18:39:21.810696105 +0300
@@ -13,7 +13,6 @@
 	LIBS=""
 
 	AC_CHECK_HEADERS(tcpd.h, [nut_have_libwrap=yes], [nut_have_libwrap=no], [AC_INCLUDES_DEFAULT])
-	AC_SEARCH_LIBS(yp_get_default_domain, nsl, [], [nut_have_libwrap=no])
 
 	dnl The line below does not work on Solaris 10.
 	dnl AC_SEARCH_LIBS(request_init, wrap, [], [nut_have_libwrap=no])
