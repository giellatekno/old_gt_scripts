#!/usr/bin/env python
# -*- coding:utf-8 -*-

#
#   This is a program to move files in a git repository
#   with non ascii chars file names to ascii file names
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this file. If not, see <http://www.gnu.org/licenses/>.
#
#   Copyright 2013 Børre Gaup <borre.gaup@uit.no>
#

import sys
import os
sys.path.append(os.getenv('GTHOME') + '/gt/script/langTools')
import namechanger

for line in sys.stdin:
    nc = NameChanger(line.strip())
    nc.changeName()
