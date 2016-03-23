#
# Makefile for CCS Project
#

#
# Location of the processing programs
#
RASM  = /home/fac/wrc/bin/rasm
RLINK = /home/fac/wrc/bin/rlink

#
# Suffixes to be used or created
#
.SUFFIXES:	.asm .obj .lst .out

#
# Object files
#
OBJFILES = ga_main.obj geomalgebra.obj ga_io.obj

#
# Transformation rule: .asm into .obj
#
.asm.obj:
	$(RASM) -l $*.asm > $*.lst

#
# Transformation rule: .obj into .out
#
.obj.out:
	$(RLINK) -m -o $*.out $*.obj > $*.map

#
# Main target
#
ga_main.out:	$(OBJFILES)
	$(RLINK) -m -o $*.out $(OBJFILES) > $*.map
