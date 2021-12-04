# pipexec

**pipexec** is a tool for running a predefined set of custom scripts using named pipes. This can be useful in certain scenarios:

- Execute scripts/commands as root, but ran by other nonroot users
- Execute scripts/commands (as root or any other user), from a Docker container

For the first example (execute script as root, triggered by nonroot user), the workflow is the following:

- root user runs "pipexec_server" in background
- nonroot user runs "pipexec_client mycommand"
- pipexec_client sends "mycommand" to a pipe
- pipexec_server, running in background as root, reads the pipe and receives the "mycommand" message
- pipexec_server runs the "mycommand" script (considering that the script exists, is owned by root - and should only be modified by root!)

**This project is experimental and might have undesirable effects. Use it under your responsability!**

## Getting started

### 1. Creating the pipe

First of all, create a new FIFO pipe by running:

```bash
mkfifo /tmp/mypipe
```

The pipe permissions are important, as they will determine which users can write on the pipe, thus trigger the scripts.
The ownership and permissions of the pipe are like those with any other common Linux file.
The pipe is owned by the user that ran the mkfifo command, and can only be written by it (and root).

For the first example (execute script as root, triggered by nonroot user), a way to go could be:

- Create a group e.g. "piperoot"; users in this group are allowed to trigger the scripts using the pipe
- Add the desired users to the group
- Create the pipe as root, change its group ownership to the new "piperoot" group, and allow the owner group writing on this pipe

### 2. Running the server

Then, run the pipexec "server" as the user that should run the scripts:

```bash
# Considering current directory is the pipexec repository...
PIPE_PATH="/tmp/mypipe" SCRIPT_PATH="script_examples" ./pipexec_server.sh
```

Two environment variables are used:

- `PIPE_PATH` determines the path of the pipe file
- `SCRIPT_PATH` determines the directory that contains the scripts

Other optional environment variables are:

- `PURGE_PIPE`: if set to `1`, will empty the pipe before starting listening (to avoid running stalled orders) (disabled by defaul)

### 3. Running a command as a client

Finally, you can run any of the scripts contained on the `SCRIPT_PATH` by writing its name on the pipe. You can do so using the given "client" script, or directly.
For example, for running the `date.sh` script:

```bash
# Using the script
PIPE_PATH="/tmp/mypipe" ./pipexec_client.sh date

# Directly
echo date > /tmp/mypipe &
```

For running .sh scripts, it is not required to specify the extension. On the examples above, running `date` will actually run the `date.sh` script.

## TODO

- Security analysis (possible risks)
- Allow sending args to the scripts
- Add tests
