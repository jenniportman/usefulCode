! Read in vasp input file and generate new file with nLayers vertically stacked copies of original unit cell with random displacement in plane
program shiftedLayers
implicit none

integer, parameter :: nLayers=6

character(20) :: fileIn, fileOut
character(50) :: string

integer, dimension(2) :: nAtoms
integer :: i, j, k, n, iLayer, totalAtoms
integer, allocatable :: seed(:)

real :: posA
real, dimension(3) :: a,b,c, newPosition
real, dimension(3,nLayers) :: shiftVector 
real, allocatable :: atomPositions(:,:)

write(fileIn,*) 'POSCAR'
write(fileOut,*) 'POSCAR_layers.vasp'

open(30,file=fileIn,status='old',recl=320)
open(35,file=fileOut,status='unknown',recl=320)

! read first two lines which are useless
read(30,'(a)') string
write(35,'(a)') string
read(30,'(a)') string
write(35,'(a)') string

! lattice constants
read(30,*) a
write(35,*) a
read(30,*) b
write(35,*) b
read(30,*) c
write(35,*) nLayers*c

! names of atoms
read(30,'(a)') string
write(35,'(a)') string

! numbers of atoms
read(30,*) nAtoms
write(35,*) nAtoms*nLayers

! type of coordinates (cartesian or fractional)
read(30,*) string
write(35,*) string
if(string(1:1) == "C") then
	write(*,*) "ERROR!! This program only works with fractional coordinates!!"
	stop
endif

! read atomPositions
totalAtoms=nAtoms(1)+nAtoms(2)
write(*,*) "total number of atoms",totalAtoms
allocate(atomPositions(totalAtoms,3))
do i=1,totalAtoms
	read(30,*) atomPositions(i,:)
end do
! z fractional coordinates get scaled to take into account the layers
atomPositions(:,3)=atomPositions(:,3)/real(nLayers)

! initialize random number generator
call random_seed(size = n)
allocate(seed(n))
seed(:)=780781
call random_seed(put=seed)
deallocate(seed)
call random_number(shiftVector)
shiftVector=shiftVector/2.0
! first layer = no change
shiftVector(:,1) = 0.0
shiftVector(3,2:)=(/ (i,i=1,nLayers-1) /)
shiftVector(3,2:)=shiftVector(3,2:)/real(nLayers)
write(*,*) "sift",shiftVector

! loop over atom types
do i=1,2
	do iLayer=1,nLayers
		do j=1,nAtoms(i)
			k=j+(i-1)*nAtoms(1)
			newPosition(:)=atomPositions(k,:)+shiftVector(:,iLayer)
			newPosition(:)=newPosition(:)-floor(newPosition(:))
			write(35,*) newPosition(:)
		end do
	end do
end do

deallocate(atomPositions)
close(30)
close(35)
end program shiftedLayers
