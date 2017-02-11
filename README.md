# CommandBox Host Updater

If you're like me, you prefer host names over IP addresses for your local development. This module will save you the trouble of firing up an editor as administrator and edit the hosts file manually. It will add the host name you assigned to your server to the hosts file and assign a local ip address to that host name.

## Supported Operating Systems

The module works on Windows, Linux, and OS-X

## Installation

You can install the module from within CommandBox by executing the install command:
```bash
CommandBox> install commandbox-hostupdater
```

### Usage
*In order for the module to be able to modify your hosts file you need to start CommandBox with administrator privileges.*

Just provide a host name for your server.

```bash
CommandBox> server start host=myproject.local
```
The module will first remove any host names that you previously assigned *to the same server* and then add the host name (here 'myproject.local') to your hosts file. All entries added by the module will be marked with a comment `# CommandBox <Server-ID> <current timestamp>`.

### Location of the hosts file

The module assumes the following paths to the hosts file 

OS | Path
---|-----
Windows | C:\Windows\System32\drivers\etc\hosts
Linux | /etc/hosts
OS-X | /private/etc/hosts

### IP addresses

In order to avoid conflicts with other IP addresses you may assign manually, the module only uses IP addresses in the range 127.127.0.1 to 127.127.255.255.

It detects the highest used IP address in that range and increase that by 1. That gives you 255 x 255 = 65.025 IP addresses to use. 

### Forgetting a server

If you tell CommandBox to forget a server ```bash
CommandBox> server forget my-fancy-server
```, the module will remove any host name that you may have assigned to that server from the hosts file.

