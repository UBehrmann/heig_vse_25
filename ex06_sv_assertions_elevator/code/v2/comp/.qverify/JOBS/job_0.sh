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

/opt/mentor/questaformal/${ZI_PLATFORM}/bin/qverifypm --monitor --host reds-vmeda --port 37991 --wd /media/sf_share_folder/vse/heig_vse_25/ex06_sv_assertions_elevator/code/v2/comp --type master --binary /opt/mentor/questaformal/${ZI_PLATFORM}/bin/qverifyfk --id 0 -tool prove -import_db propcheck.db/formal_verify.db -od . -hidden_dir ./.qverify -netcache /tmp/propcheck.8791_640 -gui -pm_host reds-vmeda -pm_port 37991   
