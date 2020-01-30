# Find a suitable toolchain at https://github.com/myrootfs/crosstool-ng/releases
TOOLCHAIN         := crosstool-ng-1.23.0-319-gaca85cb

OSNAME            := myLinux
OSRELEASE_ID      := chaos
OSRELEASE          = Chaos Devel `date --iso-8601`
OSVERSION_ID      := 1.0-rc1
OSVERSION         := $(OSVERSION_ID), $(OSRELEASE)
OSID              := "mylinux"
OSPRETTY_NAME     := $(OSNAME) $(OSVERSION_ID)
OSHOME_URL        := https://myrootfs.github.io
SUPPORT_URL       := https://github.com/myrootfs/myLinux
BUG_REPORT_URL    := $(SUPPORT_URL)/issues

qstrip             = $(strip $(subst ",,$(1)))
# "

# System should be configured by this point
-include $(ROOTDIR)/.config

# Check to be sure, CONFIG_DOT_CONFIG only set if include succeeeded
ifeq ($(CONFIG_DOT_CONFIG),y)
ARCH              := $(call qstrip, $(CONFIG_ARCH))
MACH              := $(call qstrip, $(CONFIG_MACH))

IMAGE_NAME        := $(call qstrip, $(CONFIG_IMAGE_NAME))
KERNEL_IMAGE       = $(call qstrip, $(CONFIG_LINUX_IMAGE))
KERNEL_VERSION    := $(call qstrip, $(CONFIG_LINUX_VERSION))
ifdef KERNEL_RC
KERNEL_VERSION     = $(KERNEL_VERSION).0$(KERNEL_RC)
endif
KERNEL_MODULES     = $(wildcard $(ROMFS)/lib/modules/$(KERNEL_VERSION)*)

# Map Qemu archs to Linux kernel archs
KERNEL_ARCH       := $(shell echo $(ARCH) | sed	\
			-e 's/ppc64/powerpc64/'	\
			-e 's/ppc/powerpc/'	\
			-e 's/aarch64/arm64/'   \
			-e 's/x86_64/x86/')

# Include QEMU_ settings for this arch.
include $(ROOTDIR)/arch/$(ARCH)/config.mk

QEMU_APPEND       := $(KERNEL_APPEND) $(call qstrip, $(CONFIG_LINUX_CMDLINE))
KERNEL            ?= $(IMAGEDIR)/$(KERNEL_IMAGE)
ROOTFS            ?= $(IMAGEDIR)/$(IMAGE_NAME)

CROSS_COMPILE     := $(call qstrip, $(CONFIG_TOOLCHAIN_PREFIX))
CROSS_TARGET       = $(CROSS_COMPILE:-=)
CC                 = $(CROSS_COMPILE)gcc
CFLAGS             = -O2
#CPPFLAGS           = -U_FORTIFY_SOURCE -D_DEFAULT_SOURCE -D_GNU_SOURCE
CPPFLAGS           = -I$(STAGING)/include -I$(STAGING)/usr/include
LDLIBS             =
LDFLAGS            = -L$(STAGING)/lib -L$(STAGING)/usr/lib
STRIP              = $(CROSS_COMPILE)strip
endif

PRODDIR            = $(ROOTDIR)/arch/$(ARCH)/$(MACH)
DOWNLOADS         ?= $(shell xdg-helper DOWNLOAD)
QEMU_HOST         ?= $(shell xdg-helper DOCUMENTS)/myLinux
QEMU_MNT          ?= $(QEMU_HOST)/mnt-$(ARCH).jffs2
STAGING            = $(ROOTDIR)/staging
ROMFS              = $(ROOTDIR)/romfs
IMAGEDIR           = $(ROOTDIR)/images
PKG_CONFIG_LIBDIR := $(STAGING)/lib/pkgconfig
SYSROOT           := $(shell $(CROSS_COMPILE)gcc -print-sysroot)

export OSNAME OSRELEASE_ID OSRELEASE OSVERSION_ID OSVERSION
export OSID OSPRETTY_NAME OSHOME_URL
export SUPPORT_URL BUG_REPORT_URL
export ARCH MACH CROSS_COMPILE CROSS_TARGET TOOLCHAIN
export QEMU_APPEND QEMU_DTB QEMU_HOST QEMU_MACH QEMU_MNT QEMU_NIC
export CC CFLAGS CPPFLAGS LDLIBS LDFLAGS STRIP
export PRODDIR DOWNLOADS STAGING ROMFS IMAGEDIR PKG_CONFIG_LIBDIR SYSROOT
export KERNEL ROOTFS
export KERNEL_ARCH KERNEL_VERSION KERNEL_MODULES
