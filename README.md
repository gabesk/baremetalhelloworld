# baremetalhelloworld
Prints Hello world on bare-metal x86 PC

After realizing at work the other day that I didn't know as much as I would have liked about how virtual memory and paging work (specifically the nitty gritty details of actual mechanics of setting up paging and actually populating page table entries), I decided to make my memory day project a take on the classic bootloader minimalist example of printing something to the screen, but one that does so from a fully 32-bit enabled context with virtual memory setup.

This combined with the fact that for a long time, I've been fascinated by the content of the osdev.org website and have wanted to create my own bootloader, so that I understood the entire process of the computers I use ever day from first power on, not just some small embedded system chip (not that there's anything wrong with that; I'm fascinated with those as well).

The easiest way to get started in this direction is to download the Bochs x86 simulator. At the time of writing, searching for "bochs windows" takes you to the SourceForge page which has Windows binaries.

Then, download the NASM assembler. I'm sure any assembler will work, but most of the tutorials online reference this one, its syntax uses Intel versus GNU (which I find more intuitive), and it's simpler to get started with than ml.exe (the Microsoft assembler included with Visual Studio). There's no need to Google Windows binaries specifically; they're on the main page bundled with the rest of the downloads.

Then, follow the steps at http://wiki.osdev.org/Babystep1 to create a skeleton bootloader and verify that it works in Bochs.

The directions for using NASM on that page are straightforward, but there aren't similarly straightforward directions for Bochs.

To easy future readers, this is the easiest way I found to get started. First, just run Bochs from the Start Menu UI.

 Then, click Disk and Boot.
 

And select the floppy image. It probably doesn't matter what size your virtual floppy disk is, but 1.44 MB worked for me.

 

That's it! At that point, you can click Start, or Save to save the configuration file. Once saved, you can right click on the Bochs icon on the start menu, choose More, then Open File Location.

That will take you to the Start Menu folder, where you'll find yet another link to the actual folder of the binaries. There, you'll see bochsdbg.exe, which works just like the Bochs link from the Start Menu except that version includes a built in "kernel debugger" that you can use to break into the CPU at any point to inspect what's going on.

To use it with the config file you just saved, just call it with the -f flag pointing to the file, like so:

bochsdbg -f bochsrc.bxrc -q

(The -q flag tells Bochs not to pop up the UI.)

If all goes well, you'll see Bochs launch the virtual PC screen which will sit there at a blinking cursor, showing nothing:

If so, congrats. You've got everything setup to quickly experiment with bare bones x86 development.
