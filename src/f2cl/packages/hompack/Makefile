HOMPACK_SRC = \
	dcpose.f \
	divp.f \
	f.f \
	ffunp.f \
	fixpdf.f \
	fixpds.f \
	fixpnf.f \
	fixpns.f \
	fixpqf.f \
	fixpqs.f \
	fjac.f \
	fode.f \
	fodeds.f \
	gfunp.f \
	gmfads.f \
	hfun1p.f \
	hfunp.f \
	initp.f \
	mainf.f \
	mainp.f \
	mains.f \
	mfacds.f \
	mulp.f \
	multds.f \
	otputp.f \
	pcgds.f \
	pcgns.f \
	pcgqs.f \
	polsys.f \
	polyp.f \
	powp.f \
	qimuds.f \
	qrfaqf.f \
	qrslqf.f \
	r1upqf.f \
	rho.f \
	rhoa.f \
	rhojac.f \
	root.f \
	rootnf.f \
	rootns.f \
	rootqf.f \
	rootqs.f \
	sclgnp.f \
	sintrp.f \
	solvds.f \
	stepds.f \
	stepnf.f \
	stepns.f \
	stepqf.f \
	stepqs.f \
	steps.f \
	strptp.f \
	tangnf.f \
	tangns.f \
	tangqf.f \
	tangqs.f \
	upqrqf.f

BLAS = \
	../blas/daxpy.f \
	../blas/dcopy.f \
	../blas/ddot.f \
	../blas/dnrm2.f \
	../blas/dscal.f \
	../blas/idamax.f \


mainf : mainf.o d1mach.o libhompack.a libblas.a 
	$(F77) -o mainf $^

ref-mainf.txt : mainf
	mainf | tee ref-mainf.txt

mainp : mainp.o d1mach.o libhompack.a libblas.a 
	$(F77) -o mainp $^

ref-mainp.txt : mainp
	$(RM) -f OUTHP.DAT
	mainp
	mv OUTHP.DAT ref-mainp.txt

# Not working.
mains : mains.o rhojs.o d1mach.o libhompack.a libblas.a 
	$(F77) -o mains $^

ref-mains.txt : mains
	mains | tee ref-mains.txt

d1mach.o : ../toms/717/d1mach.f
	$(F77) -c -o d1mach.o $^

libblas.a : $(BLAS:.f=.o)
	ar -r libblas.a $^
	ranlib libblas.a

libhompack.a : $(HOMPACK_SRC:.f=.o)
	ar -r libhompack.a $^
	ranlib libhompack.a

tests: ref-mainf.txt ref-mainp.txt ref-mains.txt

clean :
	$(RM) *.o
	$(RM) mainf mainp mains
