/*
 * eping.c - simple ping-like program with libevent
 *
 * Copyright (c) 2009-2016 Rocco Carbone <rocco@tecsiel.it>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


/* Operating System header file(s) */
#include <stdio.h>
#include <string.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <signal.h>

/* Libevent header file(s) */
#include "event2/event.h"
#include "event2/ping.h"


static struct event_base * base = NULL;
static struct evping_base * ping = NULL;


/* What should be done when the program execution is interrupted by a signal */
static void on_signal (int sig)
{
  printf ("\n");

  /* Print statistics at the execution end */
  evping_stats (ping);

  /* Immediately exit the event loop */
  event_base_loopbreak (base);
}


/* Callback when a PING request for a given host has been completed/elapsed */
static void callback (int result, int bytes, char * fqname, char * dotname,
		      int seq, int ttl, struct timeval * elapsed, void * arg)
{
  switch (result)
    {
    case PING_ERR_NONE:
      printf ("%d bytes from %s (%s): icmp_seq=%d ttl=%d time=%.3f ms\n",
	      bytes, fqname, dotname, seq, ttl, (float) tvtousecs (elapsed) / 1000);
      break;

    case PING_ERR_TIMEOUT:
      printf ("time out with %s (%s): icmp_seq=%d time=%3.f ms\n", fqname, dotname, seq, (float) tvtousecs (elapsed) / 1000);
      break;

    default:
      break;
    }
}


/* Sirs and Ladies, here to you... eping!!! */
int main (int argc, char * argv [])
{
  /* Notice the program name */
  char * progname = strrchr (argv [0], '/');
  progname = ! progname ? * argv : progname + 1;

  /* Set unbuffered stdout */
  setvbuf (stdout, NULL, _IONBF, 0);

  signal (SIGINT,  on_signal);         /* terminate ^C */
  signal (SIGQUIT, on_signal);         /* quit */
  signal (SIGTERM, on_signal);         /* terminate */

  /* Move pointer to arguments (if any) passed on the command line */
  argv ++;

  /* Check for at least one mandatory parameter */
  if (! argv || ! * argv)
    printf ("%s: missing argument(s)\n", progname);
  else
    {
      /* Initialize the Libevent with a new main base */
      base = event_base_new ();

      /* Initialize the PING library */
      ping = evping_base_new (base);
      if (! ping)
	printf ("sorry, it can only be run by root, or it must be setuid root\n");
      else
	{
	  unsigned n = 0;

	  /* Process all the command line arguments */
	  while (argv && * argv)
	    {
	      /* One more host to ping */
	      evping_base_host_add (ping, * argv);
	      argv ++;
	      n ++;
	    }

	  printf ("#%d host%s being pinged\n", evping_base_count_hosts (ping), n > 1 ? "s" : "");

	  /* Begin sending ICMP ECHO_REQUEST to network hosts */
	  evping_ping (ping, callback, NULL);

	  /* Event dispatching loop */
	  event_base_dispatch (base);
	}
    }

  /* Shut down the PING library and discard all active requests */
  if (ping)
    evping_base_free (ping, 0);

  /* Terminate the main base event */
  if (base)
    event_base_free (base);

  return 0;
}
