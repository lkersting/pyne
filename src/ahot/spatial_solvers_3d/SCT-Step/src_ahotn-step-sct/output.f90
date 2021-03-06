SUBROUTINE output

!-------------------------------------------------------------
!
!    Echo the flux output
!
!-------------------------------------------------------------

USE invar
USE solvar
IMPLICIT NONE
INTEGER :: i, j, k, t, u, v, g

! First check if sum is going to be printed
IF (momsum == 1) THEN
   ALLOCATE(phisum(nx,ny,nz,ng))
   phisum = 0.0
END IF

! Start the echo of the output for each group
DO g = 1, ng   
   ! Check if the flux converged
   IF (cnvf(g) == 1) THEN
      WRITE (8,*)
      WRITE (8,112) "========== Group ", g, " Converged Scalar Flux Zero Moment =========="
      t = 0
      u = 0
      v = 0
      DO k = 1, nz
         DO j = 1, ny
            WRITE (8,*) " Plane(z) : ", k, " Row(j) : ", j
            WRITE (8,113) (f(i,j,k,g), i = 1, nx)
         END DO
      END DO
      ! Call for the sum of the scalar flux moments if requested by momsum = 1
   !    IF (momsum == 1) THEN
   !      CALL fluxsum(g)
   !       WRITE (8,*)
   !       WRITE (8,115) "---------- Group ", g, " Cell-Center Scalar Flux Moments Sum ----------"
   !       DO j = 1, ny
   !          WRITE (8,*) " Row(j) : ", j
   !          WRITE (8,113) (phisum(i,j,g), i = 1, nx)
   !       END DO
   !    END IF
   END IF
END DO

! Determine if the user wants the flux at specific points
! IF (mompt == 1) THEN
   ! Call for the subroutine that operates the scalar flux at a point computations
! NOT READY YET
!    CALL fluxpoint
! END IF

! Determine if the user wants the flux from the four quadrants
! IF (qdflx == 1) THEN
!    CALL qdrntflux
! END IF

112 FORMAT(1X, A, I4, A)
113 FORMAT(2X, 8ES14.6)
114 FORMAT(1X, A, I3, A, I3, A, I3, A, I3, A)
115 FORMAT(1X, A, I4, A)

! Report the number of warnings
WRITE (8,'(//,1X,I2,A,/)') warn, " warnings have been issued"
      
! End the input echo
WRITE (8,*)
WRITE (8,*) "-------------------------- END SOLUTION ----------------------------------"
WRITE (8,*)

RETURN
END SUBROUTINE output
