#
# Makefile for a Video Disk Recorder plugin
#
# $Id$

# The official name of this plugin.
# This name will be used in the '-P...' option of VDR to load the plugin.
# By default the main source file also carries this name.
#
PLUGIN = reelbox

### The object files (add further files here):

OBJS = $(PLUGIN).o ac3.o AudioDecoder.o AudioDecoderIec60958.o AudioDecoderMpeg1.o \
	AudioDecoderNull.o AudioDecoderPcm.o AudioOut.o \
	AudioPacketQueue.o AudioPlayer.o AudioPlayerBsp.o AudioPlayerHd.o \
	BspCommChannel.o BspOsd.o BspOsdProvider.o BkgPicPlayer.o \
	bspchannel.o bspshmlib.o dts.o fs453settings.o iec60958.o  MpegPes.o \
	hdchannel.o hdshmlib.o HdCommChannel.o \
	Reel.o ReelBoxDevice.o ReelBoxMenu.o \
	VideoPlayer.o VideoPlayerBsp.o VideoPlayerHd.o \
	VideoPlayerPip.o VideoPlayerPipBsp.o VideoPlayerPipHd.o \
	VdrXineMpIf.o HdOsd.o HdOsdProvider.o HdTrueColorOsd.o HdFbTrueColorOsd.o setupmenu.o

# Use package data if installed...otherwise assume we're under the VDR source directory:
PKGCFG = $(if $(VDRDIR),$(shell pkg-config --variable=$(1) $(VDRDIR)/vdr.pc),$(shell pkg-config --variable=$(1) vdr || pkg-config --variable=$(1) ../../../vdr.pc))
LIBDIR = $(call PKGCFG,libdir)
LOCDIR = $(call PKGCFG,locdir)
PLGCFG = $(call PKGCFG,plgcfg)
#
TMPDIR ?= /tmp

### The compiler options:

export CFLAGS   = $(call PKGCFG,cflags)
export CXXFLAGS = $(call PKGCFG,cxxflags)

### The version number of VDR's plugin API:

APIVERSION = $(call PKGCFG,apiversion)

### Allow user defined options to overwrite defaults:

-include $(PLGCFG)

### The name of the distribution archive:

ARCHIVE = $(PLUGIN)-$(VERSION)
PACKAGE = vdr-$(ARCHIVE)

### The name of the shared object file:

SOFILE = libvdr-$(PLUGIN).so

### Includes and Defines (add further entries here):

BSPSHM = ../bspshm
HDSHM = ../hdshm3/src

INCLUDES += -I$(BSPSHM) -I$(HDSHM) $(shell freetype-config --cflags)

DEFINES += -D__LINUX__

DEFINES += -DNOT_THEME_LIKE
LIBS += -lasound -lmad -lpng -lavcodec -lswscale

DEFINES  += -D_GNU_SOURCE

DEFINES += -D__STDC_CONSTANT_MACROS

ifdef DEBUG
  DEFINES += -DDEBUG
  CXXFLAGS += -g
endif

### The main target:

all: $(SOFILE) i18n

### Implicit rules:

%.o: %.c
	$(CXX) $(CXXFLAGS) -c $(DEFINES) $(INCLUDES) -o $@ $<

### Dependencies:

MAKEDEP = $(CXX) -MM -MG
DEPFILE = .dependencies
$(DEPFILE): Makefile
	@$(MAKEDEP) $(DEFINES) $(INCLUDES) $(OBJS:%.o=%.c) > $@

-include $(DEPFILE)

### Internationalization (I18N):

PODIR     = po
I18Npo    = $(wildcard $(PODIR)/*.po)
I18Nmo    = $(addsuffix .mo, $(foreach file, $(I18Npo), $(basename $(file))))
I18Nmsgs  = $(addprefix $(DESTDIR)$(LOCDIR)/, $(addsuffix /LC_MESSAGES/vdr-$(PLUGIN).mo, $(notdir $(foreach file, $(I18Npo), $(basename $(file))))))
I18Npot   = $(PODIR)/$(PLUGIN).pot

%.mo: %.po
	msgfmt -c -o $@ $<

$(I18Npot): $(wildcard *.c)
	xgettext -C -cTRANSLATORS --no-wrap --no-location -k -ktr -ktrNOOP --package-name=vdr-$(PLUGIN) --package-version=$(VERSION) --msgid-bugs-address='<see README>' -o $@ `ls $^`

%.po: $(I18Npot)
	msgmerge -U --no-wrap --no-location --backup=none -q -N $@ $<
	@touch $@

$(I18Nmsgs): $(DESTDIR)$(LOCDIR)/%/LC_MESSAGES/vdr-$(PLUGIN).mo: $(PODIR)/%.mo
	install -D -m644 $< $@

.PHONY: i18n
i18n: $(I18Nmo) $(I18Npot)

install-i18n: $(I18Nmsgs)

### Targets:

$(SOFILE): $(OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -shared $(OBJS) $(LIBS) -o $@

install-lib: $(SOFILE)
	install -D $^ $(DESTDIR)$(LIBDIR)/$^.$(APIVERSION)

install: install-lib install-i18n

dist: distclean
	@rm -rf $(TMPDIR)/$(ARCHIVE)
	@mkdir $(TMPDIR)/$(ARCHIVE)
	@cp -a * $(TMPDIR)/$(ARCHIVE)
	@rm -f $(TMPDIR)/$(ARCHIVE)/$(PLUGIN).kdevelop
	@rm -f $(TMPDIR)/$(ARCHIVE)/$(PLUGIN).kdevelop.filelist
	@rm -f $(TMPDIR)/$(ARCHIVE)/$(PLUGIN).kdevelop.pcs
	@rm -f $(TMPDIR)/$(ARCHIVE)/$(PLUGIN).kdevses
	@rm -rf $(TMPDIR)/$(ARCHIVE)/CVS
	@rm -rf $(TMPDIR)/$(ARCHIVE)/Examples/CVS
	@rm -rf $(TMPDIR)/$(ARCHIVE)/Patch/CVS
	@ln -s $(ARCHIVE) $(TMPDIR)/$(PLUGIN)
	@tar czf $(PACKAGE).tgz -C $(TMPDIR) $(ARCHIVE) $(PLUGIN)
	@rm -rf $(TMPDIR)/$(ARCHIVE) $(TMPDIR)/$(PLUGIN)
	@echo Distribution package created as $(PACKAGE).tgz

clean:
	@-rm -f $(PODIR)/*.mo
	@-rm -f $(OBJS) $(MAIN) $(DEPFILE) *.so *.tgz core* *~
	@-rm -f $(LIBDIR)/libvdr-$(PLUGIN).so.$(APIVERSION)

distclean: clean
	@-rm -f $(PODIR)/*.pot

useless-target-for-compatibility-with-vanilla-vdr:
	$(LIBDIR)/$@.$(APIVERSION)
