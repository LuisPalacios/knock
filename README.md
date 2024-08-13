# knock: A port-knocking implementation

Copyright (c) 2004, Judd Vinet <jvinet@zeroflux.org>.

Modified by LuisPa, fixed compilation warnings, new version of the [./src/knock_helper_ipt.sh](./src/knock_helper_ipt.sh), systemd files, updated documentation.

## ABOUT

This is a port-knocking server/client.  Port-knocking is a method where a
server can sniff one of its interfaces for a special "knock" sequence of
port-hits.  When detected, it will run a specified event bound to that port
knock sequence.  These port-hits need not be on open ports, since we use
libpcap to sniff the raw interface traffic.

## BUILDING

If you have a different version in your system, recommendation is to remove it, i.e.:

```bash
apt remove knockd
```

To build knockd, make sure you have libpcap and the autoconf tools
installed. Then run the following:

```bash
autoreconf -fi
./configure --prefix=/usr/local
make
sudo make install
```

## RUNNING

Run it manually

```bash
/usr/local/sbin/knockd -i ppp0 -d -c /etc/knockd.conf
```

If you have systemd:

- [./etc/default/knockd](./etc/default/knockd)
- [./etc/systemd/knockd.service](./etc/systemd/knockd.service)
- [./etc/systemd/knockd.timer](./etc/systemd/knockd.timer)

## EXAMPLE

The example below could be used to run a strict (DENY policy) firewall that
can only be accessed after a successful knock sequence.

  1. Client sends four TCP SYN packets to Server, at the following ports:
     38281, 29374, 4921, 54918
  2. Server detects this and runs an iptables command to open port 22 to
     Client.
  3. Client connects to Server via SSH and does whatever it needs to do.
  4. Client sends four more TCP SYN packets to Server:  37281, 8529,
     40127, 10100
  5. Server detects this and runs another iptables command to close port
     22 to Client.

See [./etc/knockd.conf](./etc/knockd.conf) for examples.

## TROUBLESHOOTING

Check iptables

```bash
iptables -n -L <NetFilter chain> (INPUT|FORWARD|OUTPUT)
```

## KNOCKING CLIENTS

The accompanying knock client is very basic.  If you want to do more advanced
knocks (eg, setting specific tcp flags) then you should take look at more
powerful clients.

- [knock](./src/knock.c) - Part of this repository, installs under `/usr/local/bin` by default.
- [sendip](http://freshmeat.net/projects/sendip/)

## OTHER IMPLEMENTATIONS

Here are some other implementations of port-knocking:

- [pasmal](http://sourceforge.net/projects/pasmal/)
- [doorman](http://doorman.sourceforge.net/)
