# How to download
## FLAMEGPU2 
To install FLAME GPU 2 dependencies, refer to the official documentation [here](https://github.com/FLAMEGPU/FLAMEGPU2).

## Docker
Users can download the Docker images for FLAME GPU 2 to avoid any potential dependency-related issues. In this context, the user must have Docker installed on their
computer. For more information, refer to [this document](https://docs.docker.com/engine/installation/).

Additionally, the user needs to ensure they have the necessary permissions to run Docker without using sudo. To create the Docker group and add the user on a Unix
system, follow these steps:

• Create the docker group:
```
$ sudo groupadd docker
```

• Add user to the docker group:

```
$ sudo usermod -aG docker $USER
```

• Log out and log back in so that group membership is re-evaluated.

Additionally, the user must have the NVIDIA driver (installation instructions can be found [here](https://www.nvidia.com/en-us/drivers/)) and the NVIDIA container toolkit (installation instructions can be found [here](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)) installed.
To download the Docker images, run the following Bash commands:

```
docker pull qbioturin/flamegpu2
```

## Slurm
To run FLAME GPU 2 simulations on an HPC system, the user must install Slurm on it (more information [here](https://slurm.schedmd.com/quickstart_admin.html)). Generally, Docker cannot be used on HPC systems due to privacy concerns. Therefore, the user must install all necessary FLAME GPU 2 dependencies on the user's system before running simulations.
However, on HPC4AI [1] (more information [here](https://hpc4ai.unito.it/documentation/)), FLAME GPU 2 can also be executed using Docker, thanks to a tool that addresses privacy concerns.

# How to Run
## Without docker
To run FLAME GPU 2 without using Docker, run the following Bash command:

```
# Executing a single run without using the FLAME GPU 2
# 3D visualization:

./abm.sh -expdir NameOfTheModel

#############################################################

# Executing a single run using the FLAME GPU 2
# 3D visualization:

./abm.sh -expdir NameOfTheModel -v ON

#############################################################

# Executing n runs without using the FLAME GPU 2
# 3D visualization:

./abm_ensemble.sh -expdir NameOfTheModel

#############################################################

# Visualize the helper:

./abm.sh -h
./abm_ensemble.sh -h

```

In particular, `NameOfTheModel` must be the name of the desired model and must correspond to a directory within `FLAMEGPU-FORGE4FLAME/resources/f4f` that contains both a JSON file and an RDs file. Results will be saved in `FLAMEGPU-FORGE4FLAME/results/NameOfTheModel`.

## With docker
To run FLAME GPU 2 using Docker, run the following Bash commands:

```
# Executing a single run without using the FLAMEGPU2 3D visualization :

docker run --user $UID:$UID --rm --gpus all --runtime nvidia -v /Absolute/Path/To/The/Directory/With/The/Model/NameOfTheModel:/home/docker/flamegpu2/FLAMEGPU-FORGE4FLAME/resources/f4f/NameOfTheModel -v $(pwd):/home/docker/flamegpu2/FLAMEGPU-FORGE4FLAME/flamegpu2_results qbioturin/flamegpu2/usr/bin/bash -c "/home/docker/flamegpu2/FLAMEGPU-FORGE4FLAME/abm.sh -expdir NameOfTheModel"

######################## ##### ##### ##### ##### ##### ###### ######
# Executing n runs without using the FLAMEGPU2 3D visualization :

docker run --user $UID:$UID --rm --gpus all --runtime nvidia -v /Absolute/Path/To/The/Directory/With/The/Model/NameOfTheModel:/home/docker/flamegpu2/FLAMEGPU-FORGE4FLAME/resources/f4f/NameOfTheModel -v $(pwd):/home/docker/flamegpu2/FLAMEGPU-FORGE4FLAME/flamegpu2_results
qbioturin/flamegpu2/usr/bin/bash -c "/home/docker/flamegpu2/FLAMEGPU-FORGE4FLAME/abm_ensemble.sh -expdir NameOfTheModel"
```

In particular, `/Absolute/Path/To/The/Directory/With/The/Model/NameOfTheModel` represents the absolute path to the local directory that contains the model to run (the JSON and the RDs files). These files will be saved in a
directory named `NameOfTheModel` inside the Docker (in `FLAMEGPU-FORGE4FLAME/resources/f4f`). Results will be saved in a directory named `results/NameOfTheModel` within the current directory. The user must replace the directory name containing the model with `NameOfTheModel`.

## Docker Compose
To use the Docker Compose, the user must download the YAML file [here](https://github.com/qBioTurin/FORGE4FLAME/blob/main/inst/Compose/docker-compose.yml). To start both F4F and FLAME GPU 2 containers, navigate to the directory containing the YAML file and run the following Bash command (if running on a server, ensure that port 3839 is exposed and accessible via http://<server-hostname>:3839; if running locally, access to http://localhost:3839):
```
docker compose up -d --build
```
To run a FLAME GPU 2 simulation using Docker Compose, the user must use the Run page of F4F. Results will be saved in a directory named `results/NameOfTheModel` within the current directory, where \texttt{NameOfTheModel} is the name selected by the user when clicking on the *Run* button in the **Run** page. To stop the containers, run the following Bash command:
```
docker compose down
```

## Slurm
To execute FLAME GPU 2 simulations on HPC systems using Slurm, assuming the necessary drivers are installed, the repository is cloned, and one or more reservations have been made on the HPC system, a Bash script like the one below can be used (this script, named `run_on_slurm.sh`, is included in the repository):
```
#!/bin/bash

# Define arrays
PARTITIONS=("MachineName1-booked", "MachineName2-booked", ..., "MachineNameN-booked")
RESERVATIONS=("Run1", "Run2", ..., "RunN")
GRES=("GPUName1", "GPUName2", ..., "GPUNameN")
MODEL_NAMES=("NameOfTheModel1", "NameOfTheModel2", ..., "NameOfTheModelN")

ARRAY_LENGTH=${#PARTITIONS[@]}

for ((i=0; i<ARRAY_LENGTH; i++)); do
    JOB_SCRIPT="job_script$i.sh"
    
    cat <<EOF > "$JOB_SCRIPT"
#!/bin/bash
#SBATCH --partition=${PARTITIONS[$i]}
#SBATCH --reservation=${RESERVATIONS[$i]}
#SBATCH -N 1
#SBATCH --gres=${GRES[$i]}

./abm_ensemble.sh -expdir ${MODEL_NAMES[$i]}
EOF

    # Submit the job and check if it was successful
    if sbatch "$JOB_SCRIPT"; then
        echo "Submitted: $JOB_SCRIPT"
    else
        echo "Failed to submit: $JOB_SCRIPT" >&2
    fi
done
```

In this script, the user can define a set of partitions, reservations, GPUs, and model names by specifying the four vectors:
- `PARTITIONS` specifies the names of the machines reserved.
- `RESERVATIONS` defines the reservation names chosen by the user at booking time.
- `GRES` determines the name of the GPUs.
- `MODEL_NAMES` specifies the names of the models to run, which must correspond to the folder names within `FLAMEGPU-FORGE4FLAME/resources/f4f`.

Specifically, we run the experiments presented in the main document using Slurm on HPC4AI [1] (more information [here](https://hpc4ai.unito.it/documentation/)).

## How to reproduce the results
To reproduce the results presented in the main document---comparing FLAME GPU 2 and NetLogo using the ITP and the alert scenarios---run the following Bash commands (note that this process may take time, especially for NetLogo):
```
git clone -b School --recurse-submodules https://github.com/qBioTurin/FLAMEGPU-FORGE4FLAME.git

cd FLAMEGPU-FORGE4FLAME

# Reproduce results on comparison
# between FLAME GPU 2 and NetLogo:
./reproduce_comparison.sh

# Reproduce results on alert
# scenarios:
./reproduce_alert.sh
```

# References
- [1] Marco Aldinucci et al. “HPC4AI: an AI-on-demand federated platform endeavour”. In: Proceedings of the 15th ACM International Conference on Computing Frontiers. 2018, pp. 279–286.
