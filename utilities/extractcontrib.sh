#!/bin/sh
#
# Extracts Contributions from the main latex document and transforms
# them to generate an list of citations indicating who contributed a
# given figure, table, or I suppose section.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, you can access it online at
# http://www.gnu.org/licenses/gpl-2.0.html.
#
# Copyright (C) IBM Corporation, 2008
#
# Authors: Paul E. McKenney <paulmck@linux.ibm.com>

sed -n -e '/^\\ContributedBy{/p' |
sed -e 's/^\\ContributedBy{/\\ContribItem{/'
