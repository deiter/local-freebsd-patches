--- sys/net80211/ieee80211_output.c.orig	2013-08-22 01:26:56.026193185 +0400
+++ sys/net80211/ieee80211_output.c	2013-08-22 01:28:40.685177777 +0400
@@ -458,6 +458,16 @@
 	m->m_flags &= ~(M_80211_TX - M_PWR_SAV - M_MORE_DATA);
 
 	/*
+	 * Complain if m->m_nextpkt is set.
+	 *
+	 * The caller should've pulled this apart for us.
+	 */
+	if (m->m_nextpkt != NULL) {
+		/* printf("%s: m_nextpkt not NULL?!\n", __func__); */
+		m->m_nextpkt = NULL;
+	}
+
+	/*
 	 * Bump to the packet transmission path.
 	 * The mbuf will be consumed here.
 	 */
