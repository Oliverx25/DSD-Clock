# DSD-Clock
Development of a clock by implementing state machines, memory usage and counters in VHDL leanguage for FPGA.

## Project features
Development of a clock with the DE2-115 card that does the following:
- Display the hour, minutes and seconds.

> [!NOTE]
> The seconds are shown in turn with an LED (8 - Green).

- Hour and minute setting.
- Assigning an alarm.
- The alarm must activate a sequence on the LED's.

## Planning of project
- [x] Generate a clock with a frequency of one second.
- [x] Create counters for hours, minutes and seconds.
- [x] Show the counters on the different 7-segment displays.
  - Also, show the seconds on a green LED (That can be done with a clock pulse).
- [x] Reset the counters on the next state if:
  - Hours equals 23.
  - Minutes is equal to 59.
  - Seconds is equal to 59.

> [!NOTE]
> This is because the next counter is incremented after the reset of each one respectively.
> If seconds reaches 59 and minutes is at 0, seconds will be 0 and minutes will change to 1, and so on taking into account the limits on each counter.

- [x] Design a module for the alarm.
- [x] Comparative between time on clock and alarm, if the times are the same, activate a sequence.
  - The sequence function with state machines.
- [x] Set a modification status for the hour and minute counter, to enter these parameters manually.
  - That can be made whit one switch for enable editing that counters; 5 bits for hours and 6 bits for minutes.
- [x] Implementation of alarm storage in FLASH memory.

## Use of memory FLASH
- [x] Signals that we need are: Alarm_Minute and Alarm_Hour, on that signals we write the values of the memory FLASH, that values are inputs by ports.
- [x] The values are pre-saved on the memory FLASH, so we only need to read the values of the memory FLASH and assign it to the signals Alarm_Minute and Alarm_Hour.
  - To do that, we need to use the following ports of the memory FLASH: Chip Enable (CE -> set on 0), Output Enable (OE -> set on 0), Address (A, 22 to 0), Data Input/Output (DQ, 7 to 0).
  - We don't use the following ports: Write Enable (WE), Reset (RST); because we only need to read the values of the memory FLASH. Maybe we need to use the port RST, but we dont know yet.
- [x] Manage of the address of the memory FLASH will be done with the sentence case, since we need 2 addresses, one for the Alarm_Minute and the other for the Alarm_Hour.
  - That addresses are: 0x00000000000000000000000 for the Alarm_Minute and 0x00000000000000000000001 for the Alarm_Hour. The mount of addresses are 8MB, so we need 23 bits for the address (2^23 = 8MB).
  - Each byte have 8 bits, so we need 2 addresses for the values of the alarm.
- [x] Chip Enable (CE) and Output Enable (OE) are set on 0, because we need to read the values of the memory FLASH.
- [x] Data Input/Output (DQ) are the values that we need to read, so we need to assign it to the signals Alarm_Minute and Alarm_Hour. That port are the only one that will be declarade by input, the other are output.

We only access to set the alarm when the Enable is inactive (0), because we need to set the alarm when the clock is running. and the signal are rewrited only when the Alarm_Save is active (0). That in case we have many alarms, we only need to save the last alarm or the alarm that we need to set usign the sitwitches (Modify_Minute and Modify_Hour) to select the address of the memory FLASH for each alarm.

## Design diagram