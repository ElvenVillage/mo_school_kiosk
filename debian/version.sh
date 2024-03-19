#!/bin/bash

version=$(grep "version:" ../pubspec.yaml | cut -d ' ' -f2)
versionNumber=${version:0:5}
prefix="const kPackageVersion ="
version="${prefix} \"${versionNumber}\";"
echo $version | tee ../lib/consts.dart
echo $versionNumber | tee version

debVersion="  Version: ${versionNumber}"
file="debian.yaml"
sed -i '' '9s/.*/'"${debVersion}"'/' $file