cmake_minimum_required(VERSION 3.16 FATAL_ERROR)

# Pure QML package: nothing is compiled, so no compiler is required.
project(plasma-applet-resources-monitor LANGUAGES NONE)

find_package(ECM 6.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)

find_package(KF6Package REQUIRED)

# Same as plasma_install_package(): installs to share/plasma/plasmoids/<id>
kpackage_install_package(package org.kde.resourcesMonitor plasmoids plasma)
