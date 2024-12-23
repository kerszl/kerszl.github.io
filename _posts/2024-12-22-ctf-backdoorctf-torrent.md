---
title: "BackdoorCTF'24 - Torrent Tempest"
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
header:
  overlay_image: /assets/images/pasek-hack.png
---
# Forens/Torrent Tempest
{: .text-justify}

## 00. Metainfo

|:----|:----|
|CTF:|[BackdoorCTF'24](https://backdoor.infoseciitr.in/)|
|Category:|Forensics|
|CTFtime|[CTFtime](https://ctftime.org/event/2540)|


# 01. Description
On **December 22-23**, the 24-hour Indian CTF competition `BackdoorCTF'24` took place, with a weight of about **50 points**. Indian CTFs are often considered easy, but this one was not. However, one advantage was that it included a **forensics** category, which is rarely featured in extremely difficult CTFs. Still, it was a very challenging competition. It featured categories like **PWN**, **reverse engineering**, **forensics**, and others. Some tasks remained unsolved, and many had only a handful of solutions.
My team, `MindCrafters`, secured **15th place** out of **477 teams**. But returning to the challenge **Torrent Tempest**—it was one of the most difficult tasks I have tackled in any CTF.
{: .text-justify}

# 02. torrent.pcap
The file `torrent.pcap` was about **192 megabytes** in size. It was a pcap file, which meant it could be analyzed using tools like **Wireshark**, **Tshark**, etc. Upon opening it in Wireshark, this is what we see:  
{: .text-justify}  
![alt text](/assets/images/hacking/2024/05/01.png)  
a plethora of packets from **BitTorrent**. BitTorrent splits the entire file into smaller pieces. As seen in the **Request** query, there is a **Piece** with an identifier, offset, and length, e.g., `(Idx:0x2, Begin:0x1fee6, Len:0xffd3)`. From my observations, these pieces range from `0x01` to `0xfa`. The packets are limited to around **64 kilobytes**, so it was likely necessary to assemble them all. However, I first attempted to inspect a single packet.
{: .text-justify}
Interestingly, I found a **PZ signature** within it, indicating a **ZIP file**. Inside, I noticed the names of two files: `key.txt` and `secret.wav`. After manual analysis and unpacking the content using **CyberChef**, I managed to view the contents of `key.txt`. It was a relatively short file. The header indicated it would occupy **120 bytes** after unpacking, so it could be extracted immediately—but more on that later. Unfortunately, `secret.wav`, according to its header, was **16 MB** in size. Therefore, the entire torrent needed to be reconstructed.
{: .text-justify}
![alt text](/assets/images/hacking/2024/05/02.png)

# 03. output.zip
After hours of attempts at searching, writing code, learning about the technical workings of BitTorrent, and discussing it with ChatGPT, I finally made progress. At some point, ChatGPT wrote a program for me, but the resulting file was much too large. As I mentioned earlier, the `wav` file was supposed to be around **16 MB**, so the output shouldn't have been much larger. 
{: .text-justify}
I told ChatGPT to ensure that it did not duplicate the same packets. The file size decreased from **90 MB** to **20 MB**, but that was still too large. After quickly reviewing the file, I realized it was filling the empty spaces with zeros. So, I asked it not to pad the file with zeros. Success! I was finally able to unpack the file.
{: .text-justify}
Below is the program:
{: .text-justify}
```python
from scapy.all import rdpcap, TCP

def parse_bittorrent_pcap(pcap_file):
    pieces = []
    seen_fragments = set()  # Zbiór do unikania duplikatów
    header_counter = 0  # Licznik nagłówków
    duplicates = []  # Lista zduplikowanych fragmentów

    # Wczytaj pakiety z pliku PCAP
    packets = rdpcap(pcap_file)

    for packet in packets:
        if packet.haslayer(TCP) and packet[TCP].payload:
            data = bytes(packet[TCP].payload)
            offset = 0

            while offset < len(data):
                if offset + 4 > len(data):
                    break

                # Długość wiadomości
                length = int.from_bytes(data[offset:offset+4], byteorder='big')
                offset += 4

                if offset + length > len(data):
                    break

                # Typ wiadomości
                message_type = data[offset]
                offset += 1

                if message_type == 0x07:  # Wiadomość 'piece'
                    piece_index = int.from_bytes(data[offset:offset+4], byteorder='big')
                    offset += 4
                    begin_offset = int.from_bytes(data[offset:offset+4], byteorder='big')
                    offset += 4
                    piece_data = data[offset:offset + length - 9]
                    offset += len(piece_data)

                    # Sprawdź, czy fragment już istnieje
                    fragment_key = (piece_index, begin_offset)
                    if fragment_key not in seen_fragments:
                        header_counter += 1
                        print(f"Nagłówek {header_counter}: Piece Index={piece_index}, Offset={begin_offset}")
                        pieces.append((piece_index, begin_offset, piece_data))
                        seen_fragments.add(fragment_key)
                    else:
                        duplicates.append(fragment_key)
                        print(f"Duplikat: Piece Index={piece_index}, Offset={begin_offset}")
                else:
                    # Jeśli to inny typ wiadomości, pomiń ją
                    offset += length - 1

    # Raportowanie duplikatów
    print(f"\nZnaleziono {len(duplicates)} zduplikowanych fragmentów.\n")

    return pieces

def assemble_file(pieces, output_file):
    # Sortuj fragmenty według indeksu i offsetu
    pieces.sort(key=lambda x: (x[0], x[1]))

    # Połącz dane bez wypełniania luk
    output = bytearray()
    for piece_index, begin_offset, piece_data in pieces:
        print(f"Łączenie: Piece Index={piece_index}, Offset={begin_offset}, Długość={len(piece_data)}")
        output.extend(piece_data)

    with open(output_file, "wb") as f:
        f.write(output)

# Plik PCAP
pcap_file = "torrent.pcap"

# Parsuj dane z PCAP
pieces = parse_bittorrent_pcap(pcap_file)

# Składaj plik bez wypełniania luk
assemble_file(pieces, "output.zip")
```
# 04. key.txt
The file `key.txt` was **120 bytes** in size. It was relatively easy to decode, with one caveat: **rot13** decoding on **dcode.fr** produced a slightly different result than on **CyberChef**. Below is the decoding process:
{: .text-justify}
```bash
NjcgNzUgNzIgNWYgNjMgNDAgNjYgNjYgNmEgMzAgNjUgNzEgNWYgNzYgNjYgNWYgMzQgNjYgNWYgNzIgNmUgNmQgNmMgNWYgNmUgNjYgNWYgNGUgNGYgNTA= -> base64
67 75 72 5f 63 40 66 66 6a 30 65 71 5f 76 66 5f 34 66 5f 72 6e 6d 6c 5f 6e 66 5f 4e 4f 50 -> ascii
gur_c@ffj0eq_vf_4f_rnml_nf_NOP -> rot13 (dcode.fr)
the_p@ssw5rd_is_9s_eazy_as_ABC (wrong)
gur_c@ffj0eq_vf_4f_rnml_nf_NOP -> rot13 (cyberchef)
the_p@ssw0rd_is_4s_eazy_as_ABC (correct)
```
# 05. secret.wav
This file was significantly larger, occupying **19,983,022 bytes**. It contained some music, but the key must have had a purpose. I checked it with **`steghide`** and **`DeepSound`**. When using `DeepSound`, it prompted me for a password. This was a good sign that the file had been encoded using this program. The second key turned out to be correct. However, it took a lot of effort to figure out the issue—it turned out something was wrong with the decoding process. Later, I reviewed the logic of the password, and everything finally made sense.
{: .text-justify}
![alt text](/assets/images/hacking/2024/05/03.png)

# 06. DeepSound
After entering the password, I was able to retrieve the flag.
{: .text-justify}
![alt text](/assets/images/hacking/2024/05/04.png)
The flag looked like this: 
{: .text-justify}
```bash
flag{t0rr3n7_tr0ub13_s0rt3d_ftw!!}
```

# 07. DeepSound

To był bardzo ciekawy CTF, jednak zadania były trochę za trudne. Za mało było łatwych zadań.


