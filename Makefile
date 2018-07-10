## ********************************************************************* ##
##                                                                       ##
## Derived from Matt Boelkins' Active Calculus                           ##
##                                                                       ##
## ********************************************************************* ##

#######################
# DO NOT EDIT THIS FILE
#######################

#   1) Make a copy of Makefile.paths.original
#      as Makefile.paths, which git will ignore.
#   2) Edit Makefile.paths to provide full paths to the root folders 
#      of your local clones of the project repository and the mathbook
#      repository as described below.
#   3) The files Makefile and Makefile.paths.original
#      are managed by git revision control and any edits you make to 
#      these will conflict. You should only be editing Makefile.paths.

##############
# Introduction
##############

# This is not a "true" makefile, since it does not
# operate on dependencies.  It is more of a shell
# script, sharing common configurations

######################
# System Prerequisites
######################

#   install         (system tool to make directories)
#   xsltproc        (xml/xsl text processor)
#   xmllint         (only to check source against DTD)
#   <helpers>       (PDF viewer, web browser, pager, Sage executable, etc)

#####
# Use
#####

#	A) Navigate to the location of this file
#	B) At command line:  make <some-target-from-the-options-below>

# The included file contains customized versions
# of locations of the principal components of this
# project and names of various helper executables
include Makefile.paths

# These paths are subdirectories of
# the project distribution
PRJSRC    = $(PRJ)/src
TMP       = $(PRJ)/tmp
OUT       = $(PRJ)/output
STYLE     = $(PRJ)/style
BIN       = $(PRJ)/bin
IMAGESSRC = $(PRJSRC)/images
JSSRC     = $(PRJSRC)/jslibrary

# The project's main hub file
MAINFILE  = $(PRJSRC)/ula.xml

# These paths are subdirectories of
# the Mathbook XML distribution
# DAUSR is where extension files get copied
# so relative paths work properly
USRXSL = $(USR)/xsl
USRUSR = $(USR)/user
DTD   = $(USR)/schema/dtd

# These paths are subdirectories of
# the scratch directory
PGTMP      = $(TMP)/pg
HTMLTMP    = $(TMP)/html
PDFTMP     = $(TMP)/pdf
IMAGESTMP  = $(TMP)/images

PGOUT      = $(OUT)/pg
HTMLOUT    = $(OUT)/html
PDFOUT     = $(OUT)/pdf
IMAGESOUT  = $(OUT)/images

#  HTML output 
#  Output lands in the subdirectory:  $(HTMLOUT)
html:
	install -d $(HTMLTMP)
	-rm $(HTMLTMP)/*html
	-rm -rf $(HTMLTMP)/knowl/
	-rm -rf $(HTMLTMP)/images/
	install -d $(HTMLTMP)/knowl
	install -d $(HTMLTMP)/images
	install -d $(HTMLOUT)
	-rm $(HTMLOUT)/*.html
	-rm -rf $(HTMLOUT)/knowl/
	-rm -rf $(HTMLOUT)/images/
	-rm -rf $(HTMLOUT)/jslibrary/
	install -d $(HTMLOUT)/knowl/
	install -d $(HTMLOUT)/images/
	install -d $(HTMLOUT)/jslibrary/
	cp -a $(IMAGESOUT) $(HTMLOUT)
	cp -a $(IMAGESSRC) $(HTMLOUT)
	cd $(HTMLTMP); \
	xsltproc -xinclude \
	--stringparam html.knowl.exercise.inline no \
	--stringparam html.knowl.example no \
	--stringparam exercise.text.solution no \
	--stringparam exercise.text.answer no \
	--stringparam exercise.backmatter.statement no \
	--stringparam project.text.hint no \
	--stringparam project.text.answer no \
	--stringparam project.text.solution no \
	--stringparam html.css.file mathbook-4.css \
	$(USRXSL)/mathbook-html.xsl $(MAINFILE)
	python $(BIN)/postprocess.py -h $(HTMLTMP) $(HTMLOUT) $(PRJSRC)/inserts
	cp $(HTMLTMP)/knowl/* $(HTMLOUT)/knowl/
	cp $(JSSRC)/*js $(HTMLOUT)/jslibrary

# LaTeX for print
# see prerequisite just above
# the "webwork-tex" directory must be given here
# [note trailing slash (subject to change)]
latex:
	install -d $(PDFTMP)
	-rm $(PDFTMP)/*.tex
	install -d $(PDFOUT)
	-rm $(PDFOUT)/*.tex
	cp -a $(IMAGESSRC) $(PDFOUT)
	cd $(PDFTMP); \
	xsltproc -xinclude \
	--stringparam exercise.text.solution no \
	--stringparam exercise.text.answer no \
	--stringparam project.text.answer no \
	--stringparam project.text.solution no \
	--stringparam webwork.server.latex $(PDFOUT)/webwork-tex/ \
	$(USRXSL)/mathbook-latex.xsl $(MAINFILE)
	python $(BIN)/postprocess.py -l $(PDFTMP) $(PDFOUT) $(PRJSRC)/inserts
	cp $(PDFTMP)/images/* $(PDFOUT)/images


###########
# Utilities
###########

# Verify Source integrity
#   Leaves "dtderrors.txt" in OUTPUT
#   can then grep on, e.g.
#     "element XXX:"
#     "does not follow"
#     "Element XXXX content does not follow"
#     "No declaration for"
#   Automatically invokes the "less" pager, could configure as $(PAGER)
check:
	install -d $(OUT)
	-rm $(OUT)/dtderrors.*
	-xmllint --xinclude --postvalid --noout --dtdvalid $(DTD)/mathbook.dtd $(MAINFILE) 2> $(OUT)/dtderrors.txt
	less $(OUT)/dtderrors.txt
