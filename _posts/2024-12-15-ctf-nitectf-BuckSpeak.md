---
title: "niteCTF 2024 - Forens/BuckSpeak"
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
# Forens/BuckSpeak
{: .text-justify}

## 00. Metainfo

|:----|:----|
|CTF:|[niteCTF 2024](https://play.nitectf2024.live/)|
|Category:|Forensics|
|CTFtime|[CTFtime](https://ctftime.org/event/2461)|


# 01. Description
**BuckBeak** From the task description: `Buckbeak is trying to say something deep but is frustrated as nobody bücking understands him. Can you help him out?` This is a fairly difficult challenge, filled with traps and endless subtasks. But let's start from the beginning. We are given a file `bucking.wav`, which plays some sound. Searching "bücking" on Google reveals a character from Harry Potter and a cipher related to musical notes, which is available on Wikipedia.
{: .text-justify}
![alt text](/assets/images/hacking/2024/04/01.png)

This makes sense since it might be some kind of cipher. I don't know much about music, but further searching led me to this [website](https://legacy.wmich.edu/mus-theo/ciphers/bucking.html), which explains the cipher in detail.
{: .text-justify}

# 02. AnthemScore
AnthemScore is a program that converts played music into sheet music. Unfortunately, the trial version only processes 30 seconds and needs to be adjusted to 3/4, but I managed to work around it.
![alt text](/assets/images/hacking/2024/04/02.png)
After manually analyzing and decoding, the sentence obtained is...
`usephrasetruefansreadthebookstohearsomethingdeep`
Is this the flag? Oh no. Is this a cipher? Also no.
{: .text-justify}

# 03. Deep Sound
When uploading the file to the Deep Sound program, it asks for a password. Is the password `usephrasetruefansreadthebookstohearsomethingdeep`? Oh no, that would be too simple.
The actual password is:
`truefansreadthebooks`
![alt text](/assets/images/hacking/2024/04/03.png)

# 03. mkvinfo & mkvextract
Okay, we have a file `screech.mkv`, and it contains a video of Buckbeak, but is this the end? Oh no, that would be too simple ;)
{: .text-justify}
![alt text](/assets/images/hacking/2024/04/04.png)

I analyzed it for several hours and found nothing. I extracted the audio, reversed it, and still nothing... However, I decided to analyze the file again.
{: .text-justify}
```bash
mkvinfo screech.mkv
# + Attachments
# | + Attached
# |  + File name: Buckbeak.otf
# |  + MIME type: application/x-truetype-font
# |  + File data: size 109032
# |  + File UID: 17636095151199042832
# | + Attached
# |  + File name: Mechanical-g5Y5.otf
# |  + MIME type: application/x-truetype-font
# |  + File data: size 112136
# |  + File UID: 4317686372283026958
```
Oh, there are fonts `Buckbeak.otf`.
I extracted them.
```bash
mkvextract attachments screech.mkv 1:Buckbeak.otf
The attachment #1, ID 17636095151199042832, MIME type application/x-truetype-font, size 109032, is written to 'Buckbeak.otf'.
```

# 04. Font Buckbeak.otf
I installed this font. For a while, I was so confused that I didn't know what to do. However, Lazarus suggested copying the text `UnderstaNDAblE Buckbēaĸ SCRéècHiɳg-ɲoǐşēЅz` using this font. Then we get the flag. I had also previously ripped the subtitles, but I'll leave that as a task for you to explore.
![alt text](/assets/images/hacking/2024/04/05.png)
{: .text-justify}

# 05. Summary
This was quite an interesting and unconventional challenge that required learning new things. It was a bit frustrating, but in the end, I was happy to discover the solution.
{: .text-justify}
