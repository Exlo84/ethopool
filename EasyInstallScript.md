# Open Etho Pool Script Setup and Install

This repo will help you to install ethopool
# Feautures
  - Setting up the dependencies
  - Will help in configuration for the pool
  - Running the [app][www]

# Recommended OS
  Ubuntu 16.04 or later

### Steps

Install the dependencies. It will take time --64 flag is for the system architecture
```sh
$ chmod +x dependencies.sh
```

```sh
$ sudo ./dependencies.sh --64
```

Must open a new terminal because the dependencies are recently installed and golang is needed to build the pool. After opening the new terminal. One thing need to be carefully checked the configs in the [configuration.sh][config] according to your pool. 

```sh
$ chmod +x configuration.sh
```

```sh
$ sudo ./configuration.sh
```

Wait for the buliding of the project to be complete and when it will complete it will run the open-ethereum-pool then open a new terminal and run the front end without sudo

```sh
$ chmod +x frontend.sh
```

```sh
$ ./frontend.sh
```

Reply with y if prompted

The script works under my environment when no dependencies are installed and geth is not synced.However, it can still be improved and under devleopment.
