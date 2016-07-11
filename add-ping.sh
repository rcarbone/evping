#/bin/sh
#
# This shell script add the ping protocol to libevent 2.0.22-stable
#
# Rocco Carbone <rocco@tecsiel.it>
# Mon Feb  9 21:07:04 CET 2015
#

# Constants
EV_VERSION=2.0.22-stable
EV_ROOT=libevent-$EV_VERSION
EV_SPOOL=/spool/network/Archive
EV_FILE=libevent-$EV_VERSION.tar.gz
EV_TARGZ=$EV_SPOOL/$EV_FILE
EV_URL=http://sourceforge.net/projects/levent/files/libevent/libevent-2.0/$EV_FILE

#
# Welcome
#
echo "This shell script adds the ping ICMP protocol to libevent 2.0.22"
echo

#
# Lookup for a local source tree
#
echo -n "Looking for a local source tree in $EV_ROOT ... "
if [ ! -d $EV_ROOT ]; then
  echo "No"
  echo -n "Looking for a local archive in $EV_TARGZ ... "
  if [ ! -f $EV_TARGZ ]; then
    echo "No"
    echo -n "Downloading $EV_FILE ... "
    wget -q $EV_URL
    if [ ! -f $EV_FILE ]; then
      echo "Failed"
      exit 0
    fi
    gzip -t $EV_FILE
    if [ $? = 0 ]; then
      echo "Ok"
      echo -n "Uncompressing $EV_FILE ... "
      tar xfz $EV_FILE
      echo "Ok"
    else
      echo "Failed"
      exit 0
    fi
  else
    echo "Found"
    echo -n "Uncompresisng $EV_FILE ... "
    tar xfz $EV_TARGZ
    echo "Ok"
  fi
else
  echo "Found"
fi

#
# Add evping.c to Makefile.am
#
if [ ! -f $EV_ROOT/Makefile.am.ORG ]; then
  echo -n "Patching Makefile.am ... "
  mv $EV_ROOT/Makefile.am $EV_ROOT/Makefile.am.ORG
  line=`grep -n 'SYS_LIBS =' $EV_ROOT/Makefile.am.ORG | tail -1 | cut -d ':' -f1`
  cat $EV_ROOT/Makefile.am.ORG | sed -e 's|EXTRA_SRC =\(.*\)|EXTRA_SRC =\1 evping.c|' | \
                                 sed -e 's|EVENT1_HDRS =\(.*\)|EVENT1_HDRS =\1 evping.h|' | \
                                 sed -e 's|SYS_LIBS =|SYS_LIBS = -lm|' > $EV_ROOT/Makefile.am
  echo "Done"
fi

#
# Add eping.c to sample/Makefile.am
#
if [ ! -f $EV_ROOT/sample/Makefile.am.ORG ]; then
  echo -n "Patching sample/Makefile.am ... "
  mv $EV_ROOT/sample/Makefile.am $EV_ROOT/sample/Makefile.am.ORG
  line=`grep -n 'http_server_SOURCES' $EV_ROOT/sample/Makefile.am.ORG | head -1 | cut -d ':' -f1`
  line=`expr $line + 1`
  cat $EV_ROOT/sample/Makefile.am.ORG | sed -e 's|noinst_PROGRAMS =\(.*\)|noinst_PROGRAMS =\1 eping|' | \
                                        sed "$line i eping_SOURCES = eping.c" > $EV_ROOT/sample/Makefile.am
  echo "Done"
fi


#
# Copy evping files to their destination location
#
if [ ! -f $EV_ROOT/evping.c ]; then
  echo -n "Copying source evping.c to the source tree ... "
  cp evping.c $EV_ROOT/
  echo "Done"
fi

if [ ! -f $EV_ROOT/evping.h ]; then
  echo -n "Copying include evping.h to the source tree ... "
  cp evping.h $EV_ROOT/
  echo "Done"
fi

if [ ! -f $EV_ROOT/include/event2/ping.h ]; then
  echo -n "Copying include ping.h to the source tree ... "
  cp ping.h $EV_ROOT/include/event2/
  echo "Done"
fi

if [ ! -f $EV_ROOT/sample/eping.c ]; then
  echo -n "Copying sample eping.c to the source tree ... "
  cp eping.c $EV_ROOT/sample/
  echo "Done"
fi

if [ ! -f $EV_ROOT/README.md ]; then
  echo -n "Copying README.md to the source tree ... "
  cp README.md $EV_ROOT/
  echo "Done"
fi


#
# Update autotools files
#
echo "Update libevent generated configuration files ... "
(cd $EV_ROOT && ./autogen.sh)

#
# Configure
#
echo "Configure libevent ... "
(cd $EV_ROOT && ./configure)

#
# Compile
#
echo "Compile libevent ... "
(cd $EV_ROOT && make)
