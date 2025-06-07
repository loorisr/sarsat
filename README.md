# Tools to generate IQ signal of Sarsat beacon

This tool generate a Sarsat packet from position and aircraft ID.
It generates a 144 bits long trame using Standard Location Protocol.

The example generates the following packet: FFFED08E3301E240298056CF99F61503780B

Decoded: https://decoder2.herokuapp.com/decoded/FFFED08E3301E240298056CF99F61503780B

It also generated the IQ signals at a 40Khz sampling frequency.

IQ:

![iq](https://github.com/user-attachments/assets/24c31d38-3430-4246-893b-fd1365964c3c)

To send the IQ sample you can use a SDR with TX capability or a Raspberry Pi with https://github.com/F5OEO/rpitx and this command: `sudo ./sendiq -i beacon_signal_V3.iq -s 40000 -f 432000000 -t float  -l`

***Never send signals on 406Mhz frequencies as it can trigger a false alarm, leading to costly search and rescue efforts and potential penalties***
