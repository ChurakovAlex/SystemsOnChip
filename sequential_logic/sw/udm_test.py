# -*- coding:utf-8 -*-
from __future__ import division

import udm
from udm import *

udm = udm('COM4', 921600)
print("")

CSR_LED_ADDR    = 0x00000000
CSR_SW_ADDR     = 0x00000004
CSR_MEM   = 0x80000000


udm.wr32(CSR_LED_ADDR, 0xff00)
print("LEAD read: ", hex(udm.rd32(CSR_LED_ADDR)))


TESTMEM_ADDR_WRITE    = 0x800000ff
TESTMEM_ADDR_READ     = 0x80000f00

# test data initialization
udm.wr32(TESTMEM_ADDR_WRITE, 0x42440000)
print("")
print("x = 49:      ", hex(udm.rd32(TESTMEM_ADDR_WRITE)))
print("sqrt(x) = : ", hex(udm.rd32(TESTMEM_ADDR_READ)))

udm.wr32(TESTMEM_ADDR_WRITE, 0x4bd91af8)
print("")
print("x = 28456432:      ", hex(udm.rd32(TESTMEM_ADDR_WRITE)))
print("sqrt(x) = : ", hex(udm.rd32(TESTMEM_ADDR_READ)))

udm.wr32(TESTMEM_ADDR_WRITE, 0x4ca13e96)
print("")
print("x = 84538500:      ", hex(udm.rd32(TESTMEM_ADDR_WRITE)))
print("sqrt(x) = : ", hex(udm.rd32(TESTMEM_ADDR_READ)))
udm.memtest32(0x80000000, 512)
udm.disconnect()
