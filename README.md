# VoCore 2

The goal of this project is to bring the support for the [VoCore 2][0] board to
[barebox][1].

## Use U-Boot first

The first step is to use [u-boot][2] as it already knows how to setup up the
*MT7628* SoC.

### Hello, World u-boot standalone image

The [helloworld](helloworld.c) u-boot standalone image is the very first step
for the board bring-up.

It demonstrates it is possible to run a standalone demo image that prints the
traditional *Hello, World!* string using the *UART Lite* serial which was set up
by u-boot.

*VoCore 2* logs data through the *UARTLITE2* serial port. This serial port is
available at address [0x10000E00](#memory-map-summary).

#### The sources

Hopefully, *MT7628 UARTLITE* has a *16550-compatible* register set; except for
[Divisor Latch register](#uart-dlr). Thus, it is possible to reuse *debug_ll*
headers from *barebox* to write a simple implementation of [puts](puts.c).

- [helloworld.c](helloworld.c): *C* demo that prints `Hello, World!` using
  `puts()`.
- [puts.c](puts.c): basic *C* implementation of `puts()` using `putc()`.
- [putc.h](putc.h): basic *C* implementation of `putc()` using barebox
  `putc_ll()`.
- [include/debug_ll.h](include/debug_ll.h): barebox *C* implementation of
  `putc_ll()` using `PUTC_LL()`.
- [include/mach/debug_ll.h](include/mach/debug_ll.h): *MT7628* header joining
  both *VoCore 2* and *Low-Level NS16550* headers.
- [include/board/debug_ll.h](include/board/debug_ll.h): *VoCore 2* header
  defining `DEBUG_LL_UART_*` macros used by *Low-Level NS16550* header.
- [include/asm/debug_ll_ns16550.h](include/asm/debug_ll_ns16550.h): barebox
  *MIPS assembler* and *C* implementation of `PUTC_LL`.

#### Run it

Connect to the board through USB `picocom -b 115200 /dev/ttyACM0`, then reboot
the system `reboot -f` to enter the boot command line interface by holding the
`4` key at startup.

Copy `helloworld.img` and run it using command `bootm`.

The trace below shows it is possible to run `helloworld.img` u-boot image and
reuse what has been set earlier by u-boot.

```
VoCore2 > tftp ${loadaddr} helloworld.img; bootm ${loadaddr}

 netboot_common, argc= 3 

 KSEG1ADDR(NetTxPacket) = 0xA7FB3240 

 NetLoop,call eth_halt ! 

 NetLoop,call eth_init ! 

 Waitting for RX_DMA_BUSY status Start... done


 ETH_STATE_ACTIVE!! 
Using Eth0 (10/100-M) device
TFTP from server 192.168.1.3; our IP address is 192.168.1.123
Filename 'helloworld.img'.

 TIMEOUT_COUNT=10,Load address: 0x80100000
Loading: checksum bad
checksum bad
Got ARP REQUEST, return our IP
Got ARP REQUEST, return our IP
Got ARP REQUEST, return our IP
Got ARP REQUEST, return our IP
Got ARP REQUEST, return our IP
Got ARP REQUEST, return our IP
Got ARP REQUEST, return our IP
Got ARP REQUEST, return our IP
Got ARP REQUEST, return our IP
Got ARP REQUEST, return our IP
Got ARP REQUEST, return our IP
Got ARP REQUEST, return our IP
Got ARP REQUEST, return our IP
Got ARP REQUEST, return our IP
Got ARP REQUEST, return our IP
Got ARP REPLY, set server/gtwy eth addr (xx:xx:xx:xx:xx:xx)
Got it
#################################################################
	 #################################################################
	 #################################################################
	 #################################################################
	 #################################################################
	 #################################################################
	 #################################################################
	 #################################################################
	 #################################################################
	 #################################################################
	 #################################################################
	 #################################################################
	 ########################################
done
Bytes transferred = 4194600 (400128 hex)
NetBootFileXferSize= 00400128
## Booting image at 80100000 ...
   Image Name:   Standelone Image
   Image Type:   MIPS U-Boot Standalone Program (uncompressed)
   Data Size:    4194536 Bytes =  4 MB
   Load Address: 80000000
   Entry Point:  80000000
   Verifying Checksum ... OK
OK
Hello, World!
VoCore2 > 
```

# Appendix

## [Memory Map Summary](=#memory-map-summary)

|Start|End|Size|Description|
|---:|:---|---:|:---|
|00000000|0FFFFFFF|256 MBytes|DDR 256 MB|
|10000000|100000FF|256 Bytes|SYSCTL|
|10000100|100001FF|256 Bytes|TIMER|
|10000200|100002FF|256 Bytes|INTCTL|
|10000300|100003FF|256 Bytes|EXT_MC_ARB (DDR/DDRII)|
|10000400|100004FF|256 Bytes|Rbus Matrix CTRL|
|10000500|100005FF|256 Bytes|MIPS CNT|
|10000600|100006FF|256 Bytes|GPIO|
|10000700|100007FF|256 Bytes|SPI Slave|
|10000800|100008FF|256 Bytes|Reserved|
|10000900|100009FF|256 Bytes|I2C|
|10000A00|10000AFF|256 Bytes|I2S|
|10000B00|10000BFF|256 Bytes|SPIMaster|
|10000C00|10000CFF|256 Bytes|UARTLITE 1|
|10000D00|10000DFF|256 Bytes|UARTLITE 2|
|10000E00|10000EFF|256 Bytes|UARTLITE 3|
|10000F00|10000FFF|256 Bytes|Reserved|
|10001000|100017FF|2K Bytes|RGCTL|
|10001800|10001FFF|2K Bytes|Reserved|
|10002000|100027FF|2K Bytes|PCM (up to 16 channels)|
|10002800|10002FFF|2K Bytes|Generic DMA (up to 16 channels)|
|10003000|10003FFF|4K Bytes|Reserved|
|10004000|10004FFF|4K Bytes|AES Engine|
|10005000|10005FFF|4K bytes|PWM|
|10006000|100FFFFF|||Reserved|
|10100000|1010FFFF|64K bytes|Frame Engine|
|10110000|10117FFF|32K Bytes|Ethernet Switch|
|10118000|1011FFFF|32K Bytes|Reserved|
|10120000|10127FFF|32K Bytes|USB PHY|
|10128000|1012FFFF|32K Bytes|Reserved|
|10130000|10137FFF|32K Bytes|SDXC/eMMC|
|10138000|1013FFFF|32K Bytes|Reserved|
|10140000|1017FFFF|256K Bytes|PCI Experss|
|10180000|101BFFFF|256K Bytes|Reserved|
|101C0000|101FFFFF|256K Bytes|USB Host Controller|
|10200000|102FFFFF|1M Bytes|Reserved|
|10300000|103FFFFF|1M Bytes|WLAN MAC/BBP|
|10400000|1BFFFFFF|||Reserved|
|1C000000|1C3FFFFF|4 MBytes|SPI Flash Direct Access|
|1C400000|1FFFFFFF|||Reserved|
|20000000|2FFFFFFF|256 MBytes|PCIE Direct Access|
|30009999|3FFFFFFF|||Reserved|

## UARTLITE

### [UARTn+0004h - Divisor Latch (MS) Register](=#uart-dlr)

The table below shows the divisor needed to generate a given baud rate from CLK
inputs of 13, 26 MHz and 52MHz.

The effective clock enable generated is 16 x the required baud rate.

|BAUD|13MHz|26MHz|52MHz|
|:---|---:|---:|---:|
|110|7386|14773|29545|
|300|2708|5417|10833|
|1200|677|1354|2708|
|2400|338|677|1354|
|4800|169|339|677|
|9600|85|169|339|
|19200|42|85|169|
|38400|21|42|85|
|57600|14|28|56|
|115200|6|14|28|

Divisor needed to generate a given baud rate.

[0]: http://vocore.io/
[1]: http://www.barebox.org/
[2]: https://www.denx.de/wiki/U-Boot
[3]: http://www.barebox.org/doc/latest/user/barebox.html#starting-barebox
