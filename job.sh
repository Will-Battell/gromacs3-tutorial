#!/bin/bash
#SBATCH --job-name=mpro-ligand-simulation
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=8
#SBATCH --time=20:00:00

#SBATCH --account=e793-

#SBATCH --partition=standard
#SBATCH --qos=standard

# Load the GROMACS module (meaning we can run GROMACS commands)

module load gromacs/2022.4

# Define the number of threads to use for the simulation (required for parallel simulations)

export OMP_NUM_THREADS=1

# Run our simulations

# Energy Minimisation - Make a directory for EM and run the simulation

mkdir EM
cd ./EM

gmx grompp -f ../mdp-files/em.mdp -c ../mpro-nirmatrelvir-final.gro -r ../mpro-nirmatrelvir-final.gro -p ../topol.top -o em.tpr  -maxwarn 5
srun gmx_mpi mdrun -s em.tpr -c mpro-em.gro 

cd ../

# NVT simulation - This is used to quickly equilibrate our system

mkdir NVT
cd ./NVT

gmx grompp -f ../mdp-files/nvt.mdp -c ../EM/mpro-em.gro -r ../EM/mpro-em.gro -p ../topol.top -o nvt.tpr -maxwarn 5 
srun gmx_mpi mdrun -s nvt.tpr -c mpro-nvt.gro

cd ../

# NPT simulation - This is used to give us the correct box size/volume (therefore a density that matches physical reality)

mkdir NPT
cd ./NPT

gmx grompp -f ../mdp-files/npt.mdp -c ../NVT/mpro-nvt.gro -r ../NVT/mpro-nvt.gro -p ../topol.top -o npt.tpr -maxwarn 5
srun gmx_mpi mdrun -s npt.tpr -c mpro-npt.gro

cd ../

# Long NPT production simulation - Long simulation used for data collection 

mkdir MD
cd ./MD

gmx grompp -f ../mdp-files/md.mdp -c ../NPT/mpro-npt.gro -r ../NPT/mpro-npt.gro -p ../topol.top -o md.tpr -maxwarn 5
srun gmx_mpi mdrun -s md.tpr -c mpro-nirma-md.gro

cd ../
