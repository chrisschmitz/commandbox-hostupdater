If you're like me, you prefer host names over IP addresses for your local development. This module will save you the trouble of firing up an editor as administrator and edit the hosts file manually. It will add the host name you assigned to your server to the hosts file and assign a local ip address to that host name.  And since the module uses a different IP address for each commandbox server, that means all your local sites can run on port 80 simultaneously!

## Requirements

* **Operating system** - Windows, Linux, or Mac OS
* **CommandBox version** - CommandBox `3.5.0`

## Installation

You can install the module from within CommandBox by executing the install command:
```bash
CommandBox> install commandbox-hostupdater
```

To uninstall the module, switch to the installation folder in Commandbox and run the uninstall command:
```bash
CommandBox> #expandPath /commandbox | cd
CommandBox> list
CommandBox> uninstall commandbox-hostupdater
```

### Usage
&ast;nix users do *not* need to start CommandBox with `sudo` any more! The downside here is that 
*However*, please note that on &ast;nix you can only bind ports >= 1024, if you're not root.
That means if you want to use port 80, you still have to start CommandBox with `sudo`, sorry!
(CommandBox will incorrectly assume that port 80 is taken if you try to start a server on port 80 without being root.)

On Windows you *must* start CommandBoxwith administrator privileges!*

Just provide a host name for your server.

```bash
CommandBox> server start host=myproject.local port=80
```
The module will first remove any host names that you previously assigned *to the same server* and then add the host name (here 'myproject.local') to your hosts file. All entries added by the module will be marked with a comment `# CommandBox <Server-ID> <current timestamp>`.

#### Assigning Multiple Hosts

Often your applicaiton will require multiple hosts to function correctly. This can be the case with multi-tenant and/or multi-portal appilcations.

You have multiple ways of assigning host aliases to a server

1) Pass an alias via the CLI:
```bash
CommandBox> server set web.hostAlias=www.project.local
```

2) Specify the aliases when starting the server:
```bash
>server start name=myserver host=project.local hostAlias=www.project.local,portalA.project.local,portalB.project.local
```

3) Or you can edit your `server.json` to use an array of hostnames.

```bash
{
	"web": {
		"host": "project.local",
		"hostAlias": [
			"www.project.local",
			"portalA.project.local",
			"portalB.project.local"
		]
	}
}
```

*Please note:* If you specify host aliases when starting the server, these aliases will be added to server.json, but *not* in the web section. (That would have required a modification of the core CommandBox files.) In order to keep the flexibility, hostAliases will be recognized both inside and outside of the `web` section. 

### System variables

You can use system variables as a host name, both on the command line
```bash
>server start name=myserver host=${HOST:127.0.0.1}
```

as well as in `server.json`:

```bash
{
	"web": {
		"host": "${HOST:127.0.0.1}"
	}
}
```

The module will evaluate the value of the system variable and add that as a host name to your hosts file.

**Note** Do NOT escape the `$`sign!

### Location of the hosts file

The module assumes the following paths to the hosts file 

* **Windows** - `C:\Windows\System32\drivers\etc\hosts`
* **Linux** - `/etc/hosts`
* **Mac OS** - `/private/etc/hosts`

### IP addresses

In order to avoid conflicts with other IP addresses you may assign manually, the module only uses IP addresses in the range `127.127.0.1` to `127.127.255.255`.

It detects the highest used IP address in that range and increase that by 1. That gives you 255 x 255 = 65.025 IP addresses to use.  This means each server can use port 80 since you can bind more than one server to the same port so long as it's a different IP.  This gets rid of those random ports for local development.  

Please note, this will NOT work if you have another web server such as Apache that has been configured to listen to port 80 on all IPs ( `*.80` ).  You can troubleshoot what other processes are listening to ports with the `netstat` command.
```bash
# On Windows
C:\> netstat -ban | find ":80"
# On Unix
$> netstat -pan | grep :80
```

### Forgetting a server

If you tell CommandBox to forget a server:
```bash
CommandBox> server forget my-fancy-server
```
the module will remove any host name that you may have assigned to that server from the hosts file.

