# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# User specific environment and startup programs
if [ -d /usr/local/bin ]; then
  PATH=/usr/local/bin:$PATH
fi

## These are only Homebrew
if type brew > /dev/null 2>&1; then
  ## GNU coreutils
  if brew list | grep "coreutils" > /dev/null; then
    PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
  fi
	## Hadoop and HBase
	if brew list | grep "hadoop" > /dev/null; then
		PATH="$(brew --prefix hadoop)/sbin:$PATH"
		HADOOP_COMMON_HOME="$(brew --prefix hadoop)/libexec"
		HADOOP_HDFS_HOME=$HADOOP_COMMON_HOME
		HADOOP_MAPRED_HOME=$HADOOP_COMMON_HOME
		HADOOP_YARN_HOME=$HADOOP_COMMON_HOME
	fi
fi
export HADOOP_COMMON_HOME HADOOP_HDFS_HOME HADOOP_MAPRED_HOME HADOOP_YARN_HOME PATH 

## Java
if [ -x /usr/libexec/java_home ]; then
  JAVA_HOME="$(/usr/libexec/java_home)"
elif [ -s /usr/bin/java ]; then
  JAVA_HOME='/usr/java/default'
elif [ -d /usr/local/java ]; then
  JAVA_HOME='/usr/local/java'
fi
export JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH

## Ruby and Gems managed under Rbenv
if [ -d "$HOME/.rbenv" ]; then
	PATH=$HOME/.rbenv/shims:$PATH
	JRUBY_OPTS=--2.0
fi
export PATH JRUBY_OPTS

## My default editor.
export EDITOR=vim


