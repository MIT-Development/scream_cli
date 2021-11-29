# Setup
## Mac
Open your terminal:
- hit: `cmd+space`
- type: `terminal`
- hit: `enter`
In terminal make sure `python3` is installed:
```
python3 --version
```

## Windows
Install Windows Subsystem for Linux (WSL):
- See Docs [here](https://docs.microsoft.com/en-us/windows/wsl/install)
Install `Ubuntu 20.04` in WSL
- You can install this from the microsoft store
Open your WSL instance:
- hit: `win`
- type: `ubuntu`
- hit: `enter`

Follow Ubuntu directions below

## Ubuntu (18.04 or 20.04)
Update your machine and install python3 + pip3
```
sudo apt-get update && sudo apt-get upgrade && sudo apt-get install python3 python3-pip
```

# Installation
- To install the scream_cli, run the following command:
```
bash <(curl -s https://raw.githubusercontent.com/MIT-Development/scream_cli/main/install.sh)
```

- Verify your installation with:
```
scream_cli version
```

- Help getting started:
```
scream_cli help
```


# Configure Your Settings
- Enter the `scream_cli configure-settings` command and follow the cli prompts:
```
scream_cli cs
```

# Pull the data
```
scream_cli gd
```

# Developer Installation
- To install the scream_cli with ssh key repo access, run the following command:
```
bash <(curl -s https://raw.githubusercontent.com/MIT-Development/scream_cli/main/install.sh) --dev
```
