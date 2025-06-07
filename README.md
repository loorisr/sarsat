# Tools to generate IQ signal of Sarsat beacon

This tool generate a Sarsat packet from position and aircraft ID.
It generates a 144 bits long trame using Standard Location Protocol.

Specifications C/S T.001 are here: https://sar.mot.go.th/document/THMCC/T001-MAR-26-2021%20SPECIFICATION%20FOR%20COSPAS-SARSAT%20406%20MHz%20DISTRESS%20BEACONS.pdf

The example generates the following packet: FFFED08E3301E240298056CF99F61503780B

Decoded: https://decoder2.herokuapp.com/decoded/FFFED08E3301E240298056CF99F61503780B

It also generated the IQ signals at a 40Khz sampling frequency.

IQ:

![iq](https://github.com/user-attachments/assets/194759ad-e668-41cd-8ec9-f634c4fbe4c6)

Notes:
- symbol rate is 400 bds
- 160ms of carrier at the beginning of the signal
- 360ms of modulated signal
- 144 bits message
- 15 sync bits = 38ms
- 9 frame sync bits = 38ms
- error correcting code is BCH (21 bits and 12 bits)
- country is coded on 10 bits
- aircraft ID is coded on 24 bits
- 0.25°-accurate position is coded on 21 bits = +/- 34km
- 4 seconds-accurate position offset is coded on 20 bits = +/- 150m
- transmission is repeated at 50s +/-5s

To send the IQ sample you can use a SDR with TX capability or a Raspberry Pi with https://github.com/F5OEO/rpitx and this command: `sudo ./sendiq -i beacon_signal_V3.iq -s 40000 -f 432000000 -t float  -l`

***Never send signals on 406Mhz frequencies as it can trigger a false alarm, leading to costly search and rescue efforts and potential penalties***
