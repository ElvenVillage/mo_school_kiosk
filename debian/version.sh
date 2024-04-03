#!/bin/bash

version=$(grep "version:" pubspec.yaml | cut -d ' ' -f2)
versionNumber=${version:0:5}
prefix="const kPackageVersion ="
datePrefix="const kBuildDate = "
buildDate=$(date +'%m.%d %H:%M')
version="${prefix} \"${versionNumber}\";${datePrefix} \"${buildDate}\";"
echo $version | tee lib/consts.dart
echo $versionNumber | tee debian/version

debVersion="  Version: ${versionNumber}"
file="debian/debian.yaml"
sed -i '9s/.*/'"${debVersion}"'/' $file