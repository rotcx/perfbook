#!/usr/bin/perl
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Extract "VerbatimL" source from code sample with labels to lines
#
# Usage:
#
# $ utilities/fcvextract.pl <code sample file> <snippet identifier>
#
# Example:
#
# $ utilities/fcvextract.pl CodeSamples/api-pthreads/api-pthreads.h \
#        api-pthreads:waitall
#
# Example of a snippet in <code sample file>:
#
# ---
# /*
#  * Wait on all child processes.
#  */
# static __inline__ void waitall(void)
# {
# // \begin{snippet}[labelbase=ln:toolsoftrade:api-pthreads:waitall,commandchars=\%\[\]]
# 	int pid;
# 	int status;
#
# 	for (;;) {				//\lnlbl{loopa}
# 		pid = wait(&status);		//\lnlbl{wait}
# 		if (pid == -1) {
# 			if (errno == ECHILD)	//\lnlbl{ECHILD}
# 				break;		//\lnlbl{break}
# 			perror("wait");		//\lnlbl{perror}
# 			exit(EXIT_FAILURE);	//\lnlbl{exit}
# 		}
# 		poll(NULL, 0, 1);		//\fcvexclude
# 	}					//\lnlbl{loopb}
# // \end{snippet}
# }
# ---
#
# VerbatimL source extracted from above (VerbatimL is a customized
# Verbatim environment of fancyvrb package):
#
# ---
# \renewcommand{\lnlblbase}{ln:toolsoftrade:api-pthreads:waitall}
# \begin{VerbatimL}[commandchars=\%\[\]]
# 	int pid;
# 	int status;
#
# 	for (;;) {%lnlbl[loopa]
# 		pid = wait(&status);%lnlbl[wait]
# 		if (pid == -1) {
# 			if (errno == ECHILD)%lnlbl[ECHILD]
# 				break;%lnlbl[break]
# 			perror("wait");%lnlbl[perror]
# 			exit(EXIT_FAILURE);%lnlbl[exit]
# 		}
# 	}%lnlbl[loopb]
# \end{VerbatimL}
# ---
#
# <snippet identifier> corresponds to a meta command embedded in
# a code sample.
#
# 2nd argument to this script can match the tail part of labelbase string.
# In the above example, any of "waitall", "api-pthreads:waitall", or
# "toolsoftrace:api-pthreads:waitall" match the <snippet identifier>
#
# The meta command can have a "commandchars" option to specify an escape-
# character set for the escape-to-LaTeX feature. The option looks like:
#
# // \begin{snippet}[...,commandchars=\%\[\]]
#
# This directs "%" -> "\", "[" -> "{", and "[" -> "}" conversions to
# be done in the "VerbatimL" environment.
# In a code sample, a label to a particular line of code can be put
# as a meta command \lnlbl{} in comment as shown above.
# This script converts the \lnlbl{} commands with these charcters
# reverse-converted.
#
# To make the actual labels to have the full form of:
#
#     "ln:<chapter>:<file name>:<function>:<line label>"
#
# in LaTeX processing, this script will generate a \renewcommand{}
# command as shown above. The macro is used within \lnlbl{} command.
#
# To omit a line in extracted snippet, put "\fcvexclude" in comment
# on the line.
#
# Copyright (C) Akira Yokosawa, 2018
#
# Authors: Akira Yokosawa <akiyks@gmail.com>

use strict;
use warnings;

my $line;
my $edit_line;
my $extract_labelbase;
my $begin_re;
my $end_re;
my $extracting = 0;
my $esc_char;
my $esc_bsl;
my $esc_open;
my $esc_close;
my $dir_name;
my $file_name;
my $func_name;
my $label;

$extract_labelbase = $ARGV[1];

$begin_re = '\\\begin\\{snippet\\}.*labelbase=[^,\\]]*' . $extract_labelbase . '[,\\]]' ;
$end_re = '\\\end\\{snippet\\}';

#print $begin_re;
#print "\n";

while($line = <>) {
    if ($line =~ /$begin_re/) {
	$extracting = 1;
    }
    if (eof) {
	last;
    }
    if ($extracting == 2) {
	if (($line =~ /$end_re/) && ($extracting == 2)) {
	    last;
	}
	if ($line =~ /\\fcvexclude/) {
	    # skip this line
	} elsif ($line =~ m!(.*?)(\s*//\s*)\\lnlbl\{(.*)}\s*$!) {
	    $edit_line = $1 . $esc_bsl . "lnlbl" . $esc_open . $3 . $esc_close ;
	    print $edit_line . "\n" ;
	} else {
	    print $line ;
        }
    }
    if ($extracting == 1) {
	if ($line =~ /labelbase=([^,]+)/) {
	    print "\\renewcommand\{\\lnlblbase\}\{$1\}\n" ;
	}
	print "\\begin\{VerbatimL\}" ;
	if ($line =~ /commandchars=([^,]+).*\]$/) {
	    $esc_char = $1 ;
	    print "\[commandchars=" . $esc_char . "\]\n" ;
	    $esc_bsl = substr $esc_char, 1, 1;
	    $esc_open = substr $esc_char, 3, 1;
	    $esc_close = substr $esc_char, 5, 1;
	} else {
	    $esc_bsl = "\\" ;
	    $esc_open = "\{" ;
	    $esc_close = "\}" ;
	    print "\n" ;
	}
	$extracting = 2;
    }
}
if ($extracting == 2) {
    print "\\end\{VerbatimL\}\n" ;
    exit 0;
} else {
    exit 1;
}
