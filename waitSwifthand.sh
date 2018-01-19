#!/bin/bash

if [ $# -ne 2 ] ; then
    echo "Usage: ${0} <outdir> <tooldir>"
    exit 0
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

outdir=${1}
tooldir=${2}

sec=${TIME_TOOL_SEC}
interCov=${TIME_INTERT_COVERAGE}

timer=0
t=1
i=1


# function to really, really check things are booted up
function wait_for_boot_complete {
  # https://gist.github.com/stackedsax/2639601
  local boot_property=$1
  local boot_property_test=$2
  # echo "[emulator] Checking ${boot_property}..."
  local result=`adb shell ${boot_property} 2>/dev/null | grep "${boot_property_test}"`
  s=0
  while [ -z $result ]; do
    sleep 1
    result=`adb shell ${boot_property} 2>/dev/null | grep "${boot_property_test}"`
    # echo "time before start: ${s}"
    if [[ ${s} -eq 120 ]]; then
      kill -9 `ps | grep emulator | awk '{print $1}'` &> /dev/null
    fi
    s=$((${s}+1))
  done
}


while [[ ${timer} -le ${sec} ]]; do

  adb wait-for-device

  # echo  "[emulator] Waiting for emulator to boot completely"
  wait_for_boot_complete "getprop dev.bootcomplete" 1
  wait_for_boot_complete "getprop init.svc.bootanim" "stopped"
  wait_for_boot_complete "getprop sys.boot_completed" 1
  # echo "[emulator] All boot properties succesful"

  timer=$((${timer}+${t}))
  echo "  timer=${timer}"
  sleep ${t}

done

# kill swifthand test.sh script
kill -9 `ps | grep test.sh | awk '{print $1}'` &> /dev/null

exit 0
