#! /bin/bash 
ZI_PLATFORM="" 

if [[ `uname` -eq "Linux" ]] ; then 
  case `uname -m` in 
    x86_64) 
      ZI_PLATFORM="linux_x86_64" 
    ;; 
    aarch64) 
      ZI_PLATFORM="linux_aarch64" 
    ;; 
  esac 
fi 


export QHOME="/opt/mentor/questaformal/${ZI_PLATFORM}"
export HOME_0IN="/opt/mentor/questaformal/${ZI_PLATFORM}"

/opt/mentor/questaformal/${ZI_PLATFORM}/bin/qverifypm --monitor --host reds-vmeda --port 41309 --wd /media/sf_share_folder/vse/heig_vse_25/ex06_sv_assertions_elevator/code/v2/comp --type slave --binary /opt/mentor/questaformal/${ZI_PLATFORM}/bin/qverifyfk --id 1 -netcache /media/sf_share_folder/vse/heig_vse_25/ex06_sv_assertions_elevator/code/v2/comp/propcheck.db/FORMAL/NET -tool prove -auto_constraint_off -hd .qverify -import_db ./propcheck.db/formal_compile.db -slave_mode -mpiport reds-vmeda:34579 -slave_id 1 
