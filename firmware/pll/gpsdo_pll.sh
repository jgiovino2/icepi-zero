#!/bin/bash
set -x
IN_MHZ=${IN_MHZ:-20}
OUT_MHZ=${OUT_MHZ:-200}

script -c "
  echo '/*'
  echo ' *'
  echo ' * WARNING: do not modify!'
  echo ' * This file was automatically generated using: IN_MHZ='${IN_MHZ}' OUT_MHZ='${OUT_MHZ}' '$0 
  echo ' $ 'ecppll -i ${IN_MHZ} -o ${OUT_MHZ} -f tmp_pll.sv -n gpsdo_pll --internal_feedback --feedback_clkout 0
  echo ' *'
  echo ' * Jeffrey D. Giovino'
  echo ' * '`date`
  echo ' *'

  ecppll -i ${IN_MHZ} -o ${OUT_MHZ} -f tmp_pll.sv -n gpsdo_pll --internal_feedback --feedback_clkout 0

  echo '*'
  echo '*/'

  cat tmp_pll.sv
" tmp_log

rm tmp_pll.sv

cat tmp_log | dos2unix | tail -n +2 | head -n -1 > gpsdo_pll.sv

rm tmp_log
