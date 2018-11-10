#!/bin/sh
#
# This shell script add the ping protocol to libevent
#
# Rocco Carbone <rocco@tecsiel.it>
# Mon Feb  9 21:07:04 CET 2015
#
# Sat Nov 10 19:02:20 CET 2018
# Ported to latest libevent version cloned from github
#

# Constants
GIT=https://github.com/libevent/libevent.git
EV_ROOT=libevent

#
# Welcome
#
echo "This shell script adds the ping ICMP protocol to libevent"
echo

if [ ! -d $EV_ROOT ]; then
  echo
  git clone $GIT
  echo
fi

#
# Add evping.c to Makefile.am
#
if [ ! -f $EV_ROOT/Makefile.am.ORG ]; then
  echo -n "Patching Makefile.am ... "
  mv $EV_ROOT/Makefile.am $EV_ROOT/Makefile.am.ORG
  line=`grep -n 'SYS_LIBS =' $EV_ROOT/Makefile.am.ORG | tail -1 | cut -d ':' -f1`
  cat $EV_ROOT/Makefile.am.ORG | sed -e 's|EXTRAS_SRC =\(.*\)|EXTRAS_SRC = evping.c \\|' | \
                                 sed -e 's|EVENT1_HDRS =\(.*\)|EVENT1_HDRS = include/evping.h \\|' | \
                                 sed -e 's|SYS_LIBS =|SYS_LIBS = -lm|' > $EV_ROOT/Makefile.am
  echo "Done"
fi

#
# Add evping.h to include/include.am
#
if [ ! -f $EV_ROOT/include/include.am.ORG ]; then
  echo -n "Patching include/include.am ... "
  mv $EV_ROOT/include/include.am $EV_ROOT/include/include.am.ORG
  cat $EV_ROOT/include/include.am.ORG | sed -e 's|EVENT2_EXPORT =\(.*\)|EVENT2_EXPORT = include/evping.h \\|' > $EV_ROOT/include/include.am
  echo "Done"
fi

#
# Add eping.c to sample/include.am
#
if [ ! -f $EV_ROOT/sample/include.am.ORG ]; then
  echo -n "Patching sample/include.am ... "
  mv $EV_ROOT/sample/include.am $EV_ROOT/sample/include.am.ORG
  cat $EV_ROOT/sample/include.am.ORG | sed -e 's|SAMPLES =\(.*\)|SAMPLES = sample/eping \\|' > $EV_ROOT/sample/include.am
  echo "sample_eping_SOURCES = sample/eping.c" >> $EV_ROOT/sample/include.am
  echo "sample_eping_LDADD = \$(LIBEVENT_GC_SECTIONS) libevent.la" >> $EV_ROOT/sample/include.am
  echo "Done"
fi

echo

#
# Copy evping files to their destination location
#
file=evping.c
if [ ! -f $EV_ROOT/$file ]; then
  echo -n "Copying source $file to the libevent source tree ... "
  cp $file $EV_ROOT/
  echo "Done"
fi

file=evping.h
if [ ! -f $EV_ROOT/include/event2/$file ]; then
  echo -n "Copying include $file to the libevent source tree ... "
  cp $file $EV_ROOT/include/
  cp $file $EV_ROOT/include/event2/
  echo "Done"
fi

file=ping.h
if [ ! -f $EV_ROOT/$file ]; then
  echo -n "Copying include $file to the libevent source tree ... "
  cp $file $EV_ROOT/
  echo "Done"
fi

file=eping.c
if [ ! -f $EV_ROOT/sample/$file ]; then
  echo -n "Copying sample $file to the libevent source tree ... "
  cp $file $EV_ROOT/sample/
  echo "Done"
fi

if [ ! -f $EV_ROOT/README.md ]; then
  echo -n "Copying README.md to the libevent source tree ... "
  cp README.md $EV_ROOT/
  echo "Done"
fi

echo

#
# Update autotools files
#
echo -n "Update libevent generated configuration files ... "
(cd $EV_ROOT && ./autogen.sh 1> /dev/null 2>&1)
echo "Done"

#
# Configure
#
echo -n "Configure libevent ... "
(cd $EV_ROOT && ./configure 1> /dev/null 2>&1)
echo "Done"

#
# Compile
#
echo "Compile libevent ... "
(cd $EV_ROOT && make)
echo "Done"

echo
echo "That's all folks!"
