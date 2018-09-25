#!/bin/bash

if [[ $# -gt 0 ]] && ( [[ $# -lt 4 ]] || [[ $# -gt 4 ]] ); then
  echo "Usage: $0 <ADK_ROOT> <JAVA_HOME> <GUAVA_VERSION> <DX_VERSION>"
  echo "Example: $0 \"/Users/wtchoi/Library/Android/sdk\" \"/Library/Java/JavaVirtualMachines/jdk1.7.0_71.jdk/Contents/Home\" \"17.0\" \"21.1.2\""
  exit
fi

# WARNING: Please assign proper contents and uncomment following four export statements.
export ADK_ROOT=${1:-"/Users/wtchoi/Library/Android/sdk"}
export JAVA_HOME=${2:-"/Library/Java/JavaVirtualMachines/jdk1.7.0_71.jdk/Contents/Home"}
export GUAVA_VERSION=${3:-"17.0"}
export DX_VERSION=${4:-"21.1.2"}

###############################################################################

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SWIFT_ROOT=${DIR}


IS="inst.sh"
TS="test.sh"


cd ${SWIFT_ROOT}/src
mvn package
(($? > 0)) && print "[build.sh] Maven build script failed" && exit 2
cd ..

# create execution script
FRONT_END_PATH="src/front-end/target/front-end-0.1-jar-with-dependencies.jar"
KEY_PATH="src/front-end/resource/swifthand.keystore"
SHARED_PATH="src/shared/target/shared-0.1.jar"

BACK_END_PATH="src/back-end/target/back-end-0.1-jar-with-dependencies.jar"


echo "[build.sh] Generating \"${IS}\" instrumentation script"

echo "#!/bin/sh" > ${IS}
echo "set -x" >> ${IS}
# echo "if ((\$? -ne 1));then" >>${TS}
# echo "	echo \"./${TS} <TARGET.apk>\"" >> ${TS}
# echo "	exit 1" >> ${TS}
# echo "fi" >> ${TS}
echo "export ADK_ROOT=${ADK_ROOT}" >> ${IS}
echo "export JAVA_HOME=${JAVA_HOME}" >> ${IS}
echo "java -jar ${SWIFT_ROOT}/${FRONT_END_PATH} \$1 ${SWIFT_ROOT}/${KEY_PATH} ${SWIFT_ROOT}/${SHARED_PATH}" >> ${IS}
chmod 700 ${IS}


echo "[build.sh] Generating \"${TS}\" GUI testing script"

echo "#!/bin/sh" > ${TS}
echo "set -x" >> ${TS}
# echo "if ((\$? -ne 5));then" >>${TS}
# echo "  echo \"./${TS} <TARGET.apk> <MODE> <TIME> <SEED> <OUTPUT_DIR>\"" >> ${TS}
# echo "	exit 1" >> ${TS}
# echo "fi" >> ${TS}
echo "export ADK_ROOT=$ADK_ROOT" >> ${TS}
echo "export JAVA_HOME=$JAVA_HOME" >> ${TS}
echo "java -jar ${SWIFT_ROOT}/${BACK_END_PATH} \$@" >> ${TS}
echo "if ((\$? > 0));then" >> ${TS}
echo "	cat USAGE" >> ${TS}
echo "fi" >> ${TS}
chmod 700 ${TS}
