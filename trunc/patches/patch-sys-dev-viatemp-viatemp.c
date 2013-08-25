--- sys/dev/viatemp/viatemp.c.orig	2013-08-25 14:07:33.923823740 +0400
+++ sys/dev/viatemp/viatemp.c	2013-08-25 14:07:33.929809643 +0400
@@ -0,0 +1,205 @@
+/* 
+Copyright (c) 2012, Aleksandr Mishunin 
+All rights reserved.
+
+Redistribution and use in source and binary forms, with or without
+modification, are permitted provided that the following conditions are met: 
+
+1. Redistributions of source code must retain the above copyright notice, this
+   list of conditions and the following disclaimer. 
+2. Redistributions in binary form must reproduce the above copyright notice,
+   this list of conditions and the following disclaimer in the documentation
+   and/or other materials provided with the distribution. 
+
+THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
+ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
+ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+
+The views and conclusions contained in the software and documentation are those
+of the authors and should not be interpreted as representing official policies, 
+either expressed or implied, of the FreeBSD Project. 
+*/
+/* 
+based on coretemp and linux via-cputemp 
+*/
+#include <sys/cdefs.h>
+#include <sys/param.h>
+#include <sys/bus.h>
+#include <sys/systm.h>
+#include <sys/types.h>
+#include <sys/module.h>
+#include <sys/conf.h>
+#include <sys/kernel.h>
+#include <sys/sysctl.h>
+#include <sys/proc.h>
+#include <sys/sched.h>
+
+#include <machine/specialreg.h>
+#include <machine/cpufunc.h>
+#include <machine/cputypes.h>
+#include <machine/md_var.h>
+
+#define	THERM_VIA					0x1169
+#define	THERM_VIA_NANO				0x1423
+
+struct viatemp_softc {
+	device_t	sc_dev;
+	int		sc_msr;
+};
+
+
+static void	viatemp_identify(driver_t *driver, device_t parent);
+static int	viatemp_probe(device_t dev);
+static int	viatemp_attach(device_t dev);
+static int	viatemp_detach(device_t dev);
+
+static uint64_t	viatemp_get_thermal_msr(int cpu,int msrreg);
+static int	viatemp_get_val_sysctl(SYSCTL_HANDLER_ARGS);
+
+static device_method_t viatemp_methods[] = {
+	DEVMETHOD(device_identify,	viatemp_identify),
+	DEVMETHOD(device_probe,		viatemp_probe),
+	DEVMETHOD(device_attach,	viatemp_attach),
+	DEVMETHOD(device_detach,	viatemp_detach),
+
+	{0, 0}
+};
+
+static driver_t viatemp_driver = {
+	"viatemp",
+	viatemp_methods,
+	sizeof(struct viatemp_softc),
+};
+
+enum therm_info {
+	viaTEMP_TEMP
+};
+
+static devclass_t viatemp_devclass;
+DRIVER_MODULE(viatemp, cpu, viatemp_driver, viatemp_devclass, NULL,
+    NULL);
+
+static void
+viatemp_identify(driver_t *driver, device_t parent)
+{
+	device_t child;
+	if (device_find_child(parent, "viatemp", -1) != NULL)
+		return;
+	if (CPUID_TO_MODEL(cpu_id) < 0xa || cpu_vendor_id != CPU_VENDOR_IDT)
+		return;
+	
+	child = device_add_child(parent, "viatemp", -1);
+	if (child == NULL)
+		device_printf(parent, "add viatemp child failed\n");
+}
+
+static int
+viatemp_probe(device_t dev)
+{
+	if (resource_disabled("viatemp", 0))
+		return (ENXIO);
+
+	device_set_desc(dev, "VIA CPU Thermal Sensor");
+
+	return (BUS_PROBE_GENERIC);
+}
+
+static int
+viatemp_attach(device_t dev)
+{
+	struct viatemp_softc *sc = device_get_softc(dev);
+	device_t pdev;
+	int cpu_model;
+	struct sysctl_oid *oid;
+	struct sysctl_ctx_list *ctx;
+
+	sc->sc_dev = dev;
+	pdev = device_get_parent(dev);
+	cpu_model = CPUID_TO_MODEL(cpu_id);
+	
+	
+	switch (cpu_model) {
+		case 0xA:
+		case 0xD:
+			sc->sc_msr = THERM_VIA; 
+			break;
+		case 0xF:
+			sc->sc_msr = THERM_VIA_NANO;
+			break;
+		default:
+			return (ENXIO);
+			break;
+			}
+
+	ctx = device_get_sysctl_ctx(dev);
+
+	oid = SYSCTL_ADD_NODE(ctx,
+	    SYSCTL_CHILDREN(device_get_sysctl_tree(pdev)), OID_AUTO,
+	    "viatemp", CTLFLAG_RD, NULL, "VIA CPU temperature");
+
+	
+	SYSCTL_ADD_PROC(ctx, SYSCTL_CHILDREN(device_get_sysctl_tree(pdev)),
+	    OID_AUTO, "temperature", CTLTYPE_INT | CTLFLAG_RD, dev,
+	    viaTEMP_TEMP, viatemp_get_val_sysctl, "IK",
+	    "Current temperature");
+	
+	return (0);
+}
+
+static int
+viatemp_detach(device_t dev)
+{
+	return (0);
+}
+
+static uint64_t
+viatemp_get_thermal_msr(int cpu,int msrreg)
+{
+	
+	uint64_t msr;
+	thread_lock(curthread);
+	sched_bind(curthread, cpu);
+	thread_unlock(curthread);
+
+
+	msr = rdmsr(msrreg);
+
+	thread_lock(curthread);
+	sched_unbind(curthread);
+	thread_unlock(curthread);
+
+	return (msr);
+}
+
+static int
+viatemp_get_val_sysctl(SYSCTL_HANDLER_ARGS)
+{
+	device_t dev;
+	uint64_t msr;
+	int val , tmp;
+	struct viatemp_softc *sc;
+	enum therm_info type;
+
+	dev = (device_t) arg1;
+	sc = device_get_softc(dev);
+	tmp = sc->sc_msr;
+	msr = viatemp_get_thermal_msr(device_get_unit(dev), tmp);
+	type = arg2;
+	
+	switch (type) {
+		case viaTEMP_TEMP:
+			val = msr * 10 + 2732;
+			break;
+		}
+
+	
+	return (sysctl_handle_int(oidp, &val, 0, req));
+}
+
