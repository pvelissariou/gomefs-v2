#!/bin/bash

files="forecast* functions* *env* *.*sh* hosts*
       g2ctl* grib2ctl* nc2cdo* *.ncl*
       wps/*namelist* wps/*.*sh* wps/functions*
       wps/*.ncl* wps/*env* wps/*_Tables
       matlab idl Include *coupling* *ocean* *namelist*
       Registry* parallel*" 

tar_file="fcast-files-`date "+%m%d%Y"`.tar.bz2"
if [ -f ${tar_file} ]; then
  echo "Removing old archive: ${tar_file}"
  rm -f ${tar_file}
fi

tar --exclude=forecasts -jcf fcast-files-`date "+%m%d%Y"`.tar.bz2 ${files}

exit 0
