# IEEEICHI2025
Repository for macro and micro simulation for the ICHI conference 2025.

## TO CLONE THE REPOSITORY

git clone  [URL of the repo]

### In the repository

In this repository you will find:

**Macro:**
In this directory there is:
-   A pdf with the instruction to install GreatSPN on your PC depending on the operating system.
-  The SIR (Susceptible Infected Recovered) model. In the ReadME file you will find a description of the model. 


**Micro:**
In this directory there are the example we will use in this tutorial and a presentation of all the details of the application.

## Docker Compose

To use both the application of this tutorial (F4F and FLAME GPU 2) you must utilize Docker Compose. The user must download the YAML file [here](https://github.com/qBioTurin/FORGE4FLAME/blob/main/inst/Compose/docker-compose.yml). To start both F4F and FLAME GPU 2 containers, navigate to the directory containing the YAML file and run the following Bash command; if running on a server, ensure that port 3839 is exposed and accessible via http://<server-hostname>:3839; if running locally, access to http://localhost:3839.
```
docker compose up -d --build
```
To run a FLAME GPU 2 simulation using Docker Compose, the user must use the Run page of F4F. Results will be saved in a directory named `results/NameOfTheModel` within the current directory, where \texttt{NameOfTheModel} is the name selected by the user when clicking on the *Run* button in the **Run** page. To stop the containers, run the following Bash command:
```
docker compose down
```
