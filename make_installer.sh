#!/usr/bin/env bash

#
# make_installer.sh
#
# Copyright (C) 2018 James Joseph Balamuta <balamut2@illinois.edu>
#
# Version 1.0.0 -- 03/22/18
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
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#

#### Build Installer

# Make sure file permissions for postinstall is set
chmod a+x scripts/*

# Version of installer
INSTALLER_VERSION=1.0.0

# Create a payload-free package

# Generally, this means --nopayload, but I want a receipt
# So, we have to include an empty directory
mkdir empty

# Build macOS installer
pkgbuild --root empty \
	     --scripts scripts \
         --identifier com.rbinaries.rtools \
         --version $INSTALLER_VERSION \
         macos-rtools-temp.pkg

# Create a distribution file to allow for customization
productbuild --synthesize --package ./macos-rtools-temp.pkg distribution.xml

echo "Writing in additional configuration options..."

# Helper function that adds a line 1 before the last one
#1 New XML contents
#2 Path to distribution.xml file
add_line_1before_last(){
	# TODO: 
	# Figure out a better way to remove the last line of the file....
	sed -i '' '/<\/installer-gui-script>/d' $2
	# TODO:
	# Figure out a way to tab the first contents
	cat << EOF >> $2
	$1
</installer-gui-script>
EOF
}

# Add title
add_line_1before_last '<title>macOS R toolchain</title>' distribution.xml

# Add background
add_line_1before_last '<background file="Rlogo.png" mime-type="image/png" />' distribution.xml

# Add a welcome screen
add_line_1before_last '<welcome file="WELCOME_DISPLAY.rtf"/>' distribution.xml

# Add a license file for LLVM
add_line_1before_last '<license file="LICENSE.rtf"/>' distribution.xml

echo "Rebuilding the package archive..."

# Rebuild package with distribution hacks
productbuild --distribution distribution.xml \
	         --resources ./build_files \
			 --sign "Developer ID Installer: James Balamuta" \
		     --package-path ./macos-rtools-temp.pkg macos-rtools.pkg

# Delete the initial build
rm macos-rtools-temp.pkg

