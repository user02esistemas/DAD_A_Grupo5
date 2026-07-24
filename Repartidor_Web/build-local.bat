@echo off
set JAVA_HOME=C:\Program Files\Java\jdk-25.0.3
set CATALINA_HOME=C:\apache-tomcat-10.1.49
"C:\Program Files\NetBeans-30\extide\ant\bin\ant.bat" -f "%~dp0build.xml" -Dlibs.CopyLibs.classpath="C:\Program Files\NetBeans-30\java\ant\extra\org-netbeans-modules-java-j2seproject-copylibstask.jar" %*
