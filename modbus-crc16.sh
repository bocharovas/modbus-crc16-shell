#!/bin/bash

if [ -z "$1" ]; then
  echo "❌ Ошибка: не передана строка данных (в hex)."
  echo "Пример использования: $0 010300500001"
  exit 1
fi

data=$1

modbus_crc() {
  local crc=0xFFFF
  local len=${#1}
  local i j
  for (( i=0; i<$len; i+=2 )); do
    # Получаем байт из двух hex-символов
    byte=$((16#${1:i:2}))
    crc=$((crc ^ byte))
    for (( j=0; j<8; j++ )); do
      if (( crc & 1 )); then
        crc=$(((crc >> 1) ^ 0xA001))
      else
        crc=$((crc >> 1))
      fi
    done
  done
  echo $crc
}

crc=$(modbus_crc $data)

crc_low=$((crc & 0xFF))
crc_high=$(((crc >> 8) & 0xFF))

printf "CRC16: %02X %02X\n" $crc_low $crc_high
printf "Полный пакет с CRC: %s %02x%02x\n" $data $crc_low $crc_high

