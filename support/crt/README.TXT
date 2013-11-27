CRT Replacement Units for Turbo/Borland pascal Compilers
========================================================


1. Preamble
-----------

Crt unit as supplied by Borland has a few defects. No smart linking is 
possible with the unit and the T/BP7 version fails with RTE200 on fast 
computers whilst the TP6 version has inconsistent delay problems when 
used on a fast computer.

These CRT units have been written as a direct replacement to the Borland 
supplied CRT unit to both remove the RTE200 problem in T/BP7 and also to 
shrink the required code to a minimum if all procedures and functions are 
not used. 


2. Reasoning
------------

There seemed a need to address these problems in view of the many 
questions asked in newsgroups about the RTE bug in T/BP7 and a number of 
questions about the TP6 Delay. A rewritten CRT unit that could be used 
as a drop in replacement to the Borland supplied unit whilst offering a 
number of enhancements that did not break older programs and precompiled 
units started to seem a needed resource to Turbo Pascal programmers.


3. Testing
----------

Testing was carried out by myself, using nested precompiled units, 
to check if dropping a replacement CRT unit into the turbo.tpl or 
tpp.tpl library would break a precompiled unit that used the original 
CRT. This has proved not to be the case. Feedback from some regulars of 
comp.lang.pascal.borland helped significantly in the testing.

Following testing, it seems that the interface part of CRT has not 
changed since V5.00 of Turbo Pascal. I was able to drop in the new 
unit directly into turbo.tpl and the V7 tpp.tpl for all versions 
from V5.00 upwards so have made these units additionally available


4. Distributed Files
--------------------

This distribution contains the following files:

CRT50.TPU - CRT for V5.00
CRT55.TPU - CRT for V5.50
CRT60.TPU - CRT for V6.00
CRT70.TPU - CRT for V7.0x Real Mode
CRT70.TPP - CRT for V7.0x Protected Mode
CRT80.TPU - CRT for Delphi V1 if created Real Mode Units[1]
CRT80.TPP - CRT for Delphi V1 if created Protected Mode units[1]
TEST.PAS  - A Test program that exercises most of the CRT unit
README.TXT- This File

[1] Note that it is possible to create a DOS .EXE using the command
line compiler of Delphi V1 - DCC.EXE - if you have the RTL source.
There is information on how to do this at my web site at
http://www.pedt.demon.co.uk/usenet/


5. Replacing CRT.TPU into TURBO.TPL or CRT.TPP into TPP.TPL
-----------------------------------------------------------

First BACK UP YOUR ORIGINAL LIBRARY! 

Extract the relevant files from CRT.TPU and rename the files with 
the correct CRT<version>.TPU/P to CRT.TPU/P as required.

For example, for V6 of Turbo pascal rename CRT60.TPU to CRT.TPU

Use TPUMOVER.EXE supplied with your distribution of the compiler.

Follow the instructions of TPUMOVER to delete the current CRT unit from 
the TURBO.TPL or TPP.TPL as required. Now add the new CRT.TPU/P unit to
the *.TPL file.

You may wish to check that previously compiled programs using CRT and
external programs will still compile and run properly. It is STRONGLY 
suggested that this is done by copying the source to a new directory and 
compiling from there rather than over-writing your *.TPU files even 
though a back up of *.TPL files will mean you can restore the original.


6. Changes
----------

a) Split into separate sections (16 *.OBJ files) to maximise the amount 
of smart linking that can be done. This means that programs will be 
smaller if not using all the procedures and functions in CRT.

b) Supports F11,F12 etc. if extended keyboard available. Uses Int$16 
$00/$01 otherwise as per the original CRT unit. Already written code 
should be perfectly OK with the extension to ReadKey to read extended 
codes as they should come up as unrecognised in older code. Gray cursor 
keys and KeyPad give the KeyPad codes on extended keyboards. If you need 
to distinguish between the cursor keys and the keypad keys you should 
already have your own unit to do this.

c) CheckSnow is set false on EGA, VGA or better grahpics by default on 
both initialisation and TextMode changes. CheckSnow still sets true on 
CGA cards. The assembly code used is as fast as the need to explicitly 
set CheckSnow to false on EGA/VGA cards after using TextMode.

d) Writing via DirectVideo or BIOS writes: checking conditions changed so 
that non-CGA Text Ouput works a little faster on most machines. As most 
computers now in use have EGA, VGA or SVGA graphics, the coding is set to 
maximise the speed of writing to these cards at the expense of making CGA 
writes slightly slower.

e) Modes above $7 checked and, if Text Mode rather than Graphics Mode, no 
force into 80x25 Text Mode on program startup. The original CRT unit set 
80x25 colour text mode (Mode 3) if the video mode was above Mode 3 and 
not Monochrome Adaptor. If you use 132x25 text mode then this will stay 
when running programs compiled with the new CRT unit. If you explicitly 
need 80x25 then use TextMode to change the mode at program startup whilst 
using the LastMode variable to store the original screen mode to restore 
this on program termination.

f) Delay fixed to longint/dword status to prevent RTE200. This occurred 
on computers above 200MHz using T/PP7.0x and has been the subject of many 
questions in comp.lang.pascal.borland and borland.public.turbopascal. The 
version of CRT for TP6.00 resolves the incorrect delay of the original 
CRT unit for fast computers.

g) Instructions, as far as possible, allow pipelining on P5+ and any 
compatible CPU to maximise the speed of the unit.


7. Not changed
--------------

1. In BW40/80 modes, colour EGA/VGA cards will allow changing the colour 
of Text or Background to non-BW colours. 

2. Interface part of the unit - to remain compatible.


8. Thanks
---------

My thanks to all who tested the unit and provided helpful suggestions in 
comp.lang.pascal.borland newsgroup. Particular thanks to Osmo Ronkanen, 
Dr. John Stockton, Mike Copeland, Franz Glaser, Bill Boulton, and Robert 
Prins in particular for their comments in comp.lang.pascal.borland and 
also thanks to those who provided feedback for the test unit.

I am indebted to Osmo Ronkanen who provided, via comp.lang.pascal.borland, 
the following code which was translated to assembler to ensure a quick 
response speed from the coding. His posts are quoted below: 

a) far quicker check for an extended keyboard than I was using:

---Quote

If you do so then make sure you handle the 224 codes properly. That is
if the scan code is zero, or more like under 70 then 224 in place of the
ASCII code is just that, character number 224. Otherwise, it should be
converted into zero as it just signals the difference between grey and
numeric bad cursor keys.

Well here is my version:

const scancode:char=#0;
var extended_kbd:boolean;  

function readkey:char; assembler;
         asm
         mov al,scancode
         or al,al
         jz @new
         mov scancode,0
         ret

@new:    mov ah,extended_kbd
         mov cl,4
         shl ah,cl
         int 16h
         cmp al,0E0h
         jne @x
         cmp al,70
         jbe @x
         xor al,al

@x:      or al,al
         jnz @out
         mov scancode,ah
@out:    end;


function status:word;
         inline(
         $B8/$00/$12/      {MOV AX,1200h}
         $CD/$16           {INT 16h }
         );

{$ifdef msdos}
const seg0040=$40;
{$endif}

begin
  tmp:=mem[Seg0040:$17];
  extended_kbd:=false;
  if lo(status)=tmp then begin
     mem[Seg0040:$17]:=tmp xor 7;
     tmp2:=status;
     extended_kbd:=(tmp2<>$1200) and (lo(tmp2)=tmp xor 7);
     mem[Seg0040:$17]:=tmp;
  End;
end.

---end

b) routine to determine if extended text modes (such as 132x25) was 
present and currently in use to obviate forcing to 80x25. 

---quote

>Anyone any thoughts on how I might be able to check if these higher mode
>numbers are text or graphics ?

How about something like:

Function Txtmode:boolean;
var b:byte;
    rg:registers;
    x,y:word;
begin
  x:=wherex;
  y:=wherey;
  gotoxy(1,1);
  txtmode:=false;
  b:=mem[$b800:0];
  rg.ah:=8;
  rg.bh:=0;
  intr($10,rg);
  if rg.al<>b then exit;

  mem[$b800:0]:=b xor 255;
  rg.ah:=8;
  rg.bh:=0;
  intr($10,rg);
  Txtmode:=rg.al=b xor 255;
  mem[$b800:0]:=b;
  gotoxy(x,y);
End;

---end


8. Bug Reports
--------------

I've set up a separate email address crt@pedt.demon.co.uk for comment, 
criticism and bug reports for these units.


9. Disclaimer
-------------

Units are supplied as is and whilst testing seems to indicate that they 
operate as a drop in replacement without any problems, programmers should 
make their own tests to ensure that their program works as expected.


Pedt Scragg, August 1999
email: crt@pedt.demon.co.uk
