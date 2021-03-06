SUBROUTINE input(qdfile, xsfile, srcfile, mtfile,inflow_file,phi_file)

!-------------------------------------------------------------
!
!    Read the input from the input file
!
!    Comments below demonstrate order of the reading
!
!    Dependency: 
!           angle   = gets the angular quadrature data
!           readmt  = reads the material map from file
!           readxs  = reads the cross sections
!           readsrc = reads the source distribution
!           check   = input check on all the values
!
!    Allows for dynamic allocation. Uses module to hold all 
!      input variables: invar
!
!-------------------------------------------------------------

USE invar
IMPLICIT NONE
INTEGER :: i, j, k, n
! File Names
CHARACTER(30), INTENT(OUT) :: qdfile, xsfile, srcfile, mtfile,inflow_file,&
                             phi_file
LOGICAL :: ex1, ex2, ex3, ex4
REAL*8 :: wtsum

! Read the title of the case
READ(7,103) title
103 FORMAT(A80)

! Read Problem Size Specification:
!   lambda => LAMDBA, the AHOT spatial order
!   meth  => = 0/1 = AHOT-N/AHOT-N-ITM
!   qdord => Angular quadrature order
!   qdtyp => Angular quadrature type = 0/1/2 = TWOTRAN/EQN/Read-in
!   nx    => Number of 'x' cells
!   ny    => Number of 'y' cells
!   nz    => Number of 'z' cells
!   ng    => Number of groups
!   nm    => Number of materials

READ(7,*) lambda, meth
READ(7,*) qdord, qdtyp

! Check that the order given greater than zero and is even
IF (qdord <= 0) THEN
   WRITE(8,'(/,3x,A)') "ERROR: Illegal value for qdord. Must be greater than zero."
   STOP
ELSE IF (MOD(qdord,2) /= 0) THEN
   WRITE(8,'(/,3x,A)') "ERROR: Illegal value for the quadrature order. Even #s only."
   STOP
END IF

! Finish reading problem size
READ(7,*) nx, ny, nz
READ(7,*) ng, nm

! Set sizes for spatial mesh, read mesh sizes
!   dx  => cell x-dimension
!   dy  => cell y-dimension
!   dz  => cell z-dimension
ALLOCATE(dx(nx), dy(ny), dz(nz))

READ(7,*) (dx(i), i = 1, nx)
READ(7,*) (dy(j), j = 1, ny)
READ(7,*) (dz(k), k = 1, nz)

! Read the boundary conditions
!   *bc = 0/1/2 = Vacuum/Reflective/fixed inflow
READ(7,*) xsbc, xebc
READ(7,*) ysbc, yebc
READ(7,*) zsbc, zebc

! Read the names of files with cross sections and source distribution
READ(7,104) mtfile
READ(7,104) qdfile
READ(7,104) xsfile
READ(7,104) srcfile
READ(7,104) inflow_file
READ(7,104) phi_file
!write(6,*) mtfile
!write(6,*) xsfile
!write(6,*) srcfile
104 FORMAT(A)
! Perform quick checks on the files
INQUIRE(FILE = mtfile, EXIST = ex4)
INQUIRE(FILE = xsfile, EXIST = ex1)
INQUIRE(FILE = srcfile, EXIST = ex2)
IF (ex1 .eqv. .FALSE. .OR. ex2 .eqv. .FALSE. .OR. ex4 .eqv. .FALSE.) THEN
   WRITE(8,'(/,3x,A)') "ERROR: File does not exist for reading."
   STOP
END IF

! Read the iteration parameters
!   err    => Pointwise relative convergence criterion
!   itmx   => Maximum number of iterations
!   iall   => Scalar Flux Spatial Moments Converged [0->LAMBDA]
!   tolr   => Tolerence for Convergence Check: determine whether abs or rel difference
READ(7,*) err, itmx, iall, tolr

! Read the Solution Check Control:
!   ichk    => Frequency of check, 0 implies skip check
!   tchk    => Tolerence of solution check
READ(7,*) ichk, tchk

! Read the optional editing parameters
!   momp   => highest moment to be printed, [0->LAMBDA]
!   momsum => flag to say whether the moments should be summed and printed for cell-center, 0 or 1
!   mompt  => flag to initiate an interactive mode that allows the user to retrieve pt data, non-center, 0 or 1
!   qdflx  => flag to indicate if the volume average scalar flux for the four quadrants should be given
READ(7,*) momp, momsum, mompt
READ(7,*) qdflx

! Set up the extra needed info from the read input
apo = (qdord*(qdord+2))/8
dofpc = (lambda+3)*(lambda+2)*(lambda+1)/6

! Material map
CALL readmt(mtfile)
 
! Angular quadrature
ALLOCATE(ang(apo,3), w(apo))
IF (qdtyp == 2) THEN
   INQUIRE(FILE=qdfile, EXIST=ex3)
   IF (qdfile == '        ' .OR. (ex3 .eqv. .FALSE.)) THEN
      WRITE(8,'(/,3x,A)') "ERROR: illegal entry for the qdfile name."
      STOP
   END IF
   OPEN(UNIT=10, FILE=qdfile)
   READ(10,*)
   READ(10,*) (ang(n,1),ang(n,2),w(n),n=1,apo)
   ! Renormalize all the weights
   wtsum = SUM(w)
   DO n = 1, apo
      w(n) = w(n) * 0.125/wtsum
   END DO
ELSE
   CALL angle
END IF

IF (qdtyp == 2) CLOSE(UNIT=10)

   ! Call for the input check
CALL check
   ! Call to read the cross sections and source; do their own input check
CALL readxs(xsfile)
CALL readsrc(srcfile)
IF (xsbc .eq. 2) CALL read_inflow(inflow_file)
RETURN
END SUBROUTINE input
