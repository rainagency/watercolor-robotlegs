#!/bin/sh
mvn install:install-file -Dfile=robotlegs-framework-v1.1.2.swc -DgroupId=org.robotlegs -DartifactId=robotlegs-framework -Dversion=1.1.2 -Dpackaging=swc
mvn install:install-file -Dfile=as3crypto.swc -DgroupId=com.hurlant -DartifactId=as3crypto -Dversion=1.3 -Dpackaging=swc
