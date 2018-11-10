# evping

<preface>

If you are impatient and not interested in the full story,
here is the download button:

   https://github.com/rcarbone/evping

Please, make sure you have the autotools installed.

```
   1> cd evping
   2> sh add-ping.sh
   3> cd libevent-2.0.22-stable/sample
   4> sudo ./eping tecsiel.it libevent.org

      Warning:
        You need super-user permissions to run the example program because
        using a raw socket for ICMP calls is a privileged operation.
```
</preface>


The project is named evping, that is a hack to the libevent in order
to add the ping protocol in a way very similar to the DNS protocol.

evping, like fping and on the contrary of the traditional ping,
supports any number of targets on the command line.


=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  Hi libeventers,
looking across my dead file systems I recently discovered an old
project I was working on in 2009.  These days I was just so
curious to understand how difficult is to add a new protocol module
to the libevent source tree.


The code was originally wrote for libevent 2.0.X-alpha series I think,
but I recently ported it compile and use the latest libevent-2.0.22-stable.


What I did to add the ping protocol
===================================

  1. wrote ping.h containing the ping protocol definitions
  2. wrote evping.c containing the ping protocol implementation
  3. wrote evping.h as final user include file
  4. wrote eping.c as a programming example to put in sample/
  5. wrote this README
  6. wrote the shell script add-ping.sh
     in the effort to help you while patching your own copy of libevent

What I missed
=============

  1. regress_ping.c regression test program
  2. documentation


Example
=======
```
rocco@home 14> sudo ./eping tecsiel.it libevent.org
#2 hosts being pinged
PING ns.tecsiel.it (78.47.99.151) 68(96) bytes of data.
PING pages.github.com (192.30.252.153) 68(96) bytes of data.
76 bytes from ns.tecsiel.it (78.47.99.151): icmp_seq=1 ttl=46 time=53.788 ms
76 bytes from pages.github.com (192.30.252.153): icmp_seq=1 ttl=53 time=134.062 ms
76 bytes from ns.tecsiel.it (78.47.99.151): icmp_seq=2 ttl=46 time=52.884 ms
76 bytes from pages.github.com (192.30.252.153): icmp_seq=2 ttl=53 time=130.321 ms
76 bytes from ns.tecsiel.it (78.47.99.151): icmp_seq=3 ttl=46 time=52.660 ms
76 bytes from pages.github.com (192.30.252.153): icmp_seq=3 ttl=53 time=130.878 ms
76 bytes from ns.tecsiel.it (78.47.99.151): icmp_seq=4 ttl=46 time=53.101 ms
76 bytes from pages.github.com (192.30.252.153): icmp_seq=4 ttl=53 time=130.950 ms
76 bytes from ns.tecsiel.it (78.47.99.151): icmp_seq=5 ttl=46 time=54.059 ms
76 bytes from pages.github.com (192.30.252.153): icmp_seq=5 ttl=53 time=149.782 ms
76 bytes from ns.tecsiel.it (78.47.99.151): icmp_seq=6 ttl=46 time=53.019 ms
^C
--- ns.tecsiel.it ping statistics ---
6 packets transmitted, 6 received, 0.00% packet loss, time 319.5ms
rtt min/avg/max/sdev = 52.660/53.252/54.059/0.548 ms

--- pages.github.com ping statistics ---
5 packets transmitted, 5 received, 0.00% packet loss, time 676.0ms
rtt min/avg/max/sdev = 130.321/135.199/149.782/8.284 ms
```