program crt_test;

uses crt;

{program to test new crt unit}

var i : byte;
var c : char;
var s : string;
var m : word;

Procedure Notes;
begin
     ClrScr;
     Writeln('This Test Program is provided to check a Borland CRT replacement');
     Writeln;
     Writeln('Although some parts of the CRT unit are implicitly tested within');
     Writeln('this program, all functions and procedures are exercised as much');
     Writeln('is possible. All bug reports plus any suggestions should be sent');
     Writeln('via email to crt@pedt.demon.co.uk');
     Writeln;
     Writeln('This replacement is currently in beta. This Replacement is dated');
     Writeln('1999-05-29 and supercedes any replacement CRT unit that has been');
     Writeln('previously made available by Pedt Scragg.');
     Writeln;
     Writeln('Please press a key to continue with the test');
     While not KeyPressed do ;
     While KeyPressed do c := readkey;
end;

Procedure Test_ClrScr;
begin
     Writeln;
     Writeln;
     TextColor(yellow);
     Writeln('Test of ClrScr');
     Writeln('Please Press any Key to Clear Screen');
     TextColor(LightGray);
     While not KeyPressed do ;
     While KeyPressed do c := readkey;
     ClrScr;
     Writeln('Test of ClrScr completed');
     Writeln('Press any key to continue');
     While not KeyPressed do ;
     While KeyPressed do c := readkey;
end;

Procedure Test_TextColor;
begin
     ClrScr;
     Writeln('Test of TextColor');
     Writeln('Please Press any Key at end');
     for i := 0 to 15 do
     begin
          TextColor(i);
          writeln('testing colours');
          Delay(500);
     end;
     TextColor(LightGray);
     GotoXY(1,20);
     Write('Done');
     While not KeyPressed do ;
     While KeyPressed do c := readkey;
end;

Procedure Test_TextBackground;
begin
     ClrScr;
     Writeln('Test of TextBackground');
     Writeln('Please Press any Key at end');
     TextColor(red);
     for i := 0 to 7 do
     begin
          TextBackground(i);
          Writeln('Testing TextBackground');
          Delay(500);
     end;
     TextColor(lightblue);
     for i := 0 to 7 do
     begin
          TextBackground(i);
          Writeln('Testing TextBackground');
          Delay(500);
     end;
     TextBackground(black);
     TextColor(LightGray);
     GotoXY(1,20);
     Write('Done');
     While not KeyPressed do ;
     While KeyPressed do c := readkey;
end;

Procedure Test_ClrEol;
begin
     ClrScr;
     Writeln('Test of ClrEol');
     Writeln('Please Press any Key at end');
     Writeln('Rows 5 to 16 will be filled with # characters then each row from');
     Writeln('X*2 position will be cleared. Delay used to show clearing of #''s');

     FillChar(s[1],50,'#');
     s[0] := chr(50);
     for i := 5 to 16 do
     begin
          GotoXY(1,i);
          Write(s);
     end;

     Delay(2000);

     For i := 5 to 16 do
     begin
          GotoXY(i*2,i);
          Delay(400);
          ClrEol;
     end;
     GotoXY(1,20);
     Write('Done');
     While not KeyPressed do ;
     While KeyPressed do c := readkey;
end;

Procedure Test_InsLine;
begin
     ClrScr;
     Writeln('Test of InsLine');
     Writeln('Please Press any Key at end');
     Writeln('Rows 5 to 10 will be filled with # characters then four rows from');
     Writeln('row 8 will have blank rows inserted. Delay used to show Inserts.');

     FillChar(s[1],50,'#');
     s[0] := chr(50);
     for i := 5 to 10 do
     begin
          GotoXY(1,i);
          Write(s);
     end;

     Delay(2000);

     GotoXY(1,8);

     For I := 1 to 4 do
     begin
          InsLine;
          Delay(1000);
     end;
     GotoXY(1,20);
     Write('Done');
     While not KeyPressed do ;
     While KeyPressed do c := readkey;
end;

Procedure Test_DelLine;
begin
     ClrScr;
     Writeln('Test of DelLine');
     Writeln('Please Press any Key at end');
     Writeln('Rows 5 to 16 will be filled with # characters then nine rows from');
     Writeln('row 6 will have the rows removed. Delay used to show the Deletes');

     FillChar(s[1],50,'#');
     s[0] := chr(50);
     for i := 5 to 16 do
     begin
          GotoXY(1,i);
          Write(s);
     end;

     Delay(2000);

     GotoXY(1,6);

     For I := 1 to 9 do
     begin
          DelLine;
          Delay(1000);
     end;
     GotoXY(1,20);
     Write('Done');
     While not KeyPressed do ;
     While KeyPressed do c := readkey;
end;

Procedure Test_Sound;
begin
     ClrScr;
     Writeln('Test of Sound');
     Writeln('Please Press any Key at end');

     for i := 1 to 20 do
     begin
          Sound(i*200);
          delay(100);
     end;
     NoSound;

     GotoXY(1,20);
     Write('Done');
     While not KeyPressed do ;
     While KeyPressed do c := readkey;
end;

Procedure Test_High_Norm_LowVideo;
begin
     ClrScr;
     Writeln('Test of High/Norm/Video');
     Writeln('Please Press any Key at end');

     FillChar(s[1],50,'#');
     s[0] := chr(50);

     TextColor(RED);

     For i := 3 to 12 do
     begin
          Case i mod 2 of
          0 : LowVideo;
          1 : HighVideo;
          end;

          Delay(400);
          Writeln(s);
     end;

     NormVideo;

     GotoXY(1,20);
     Write('Done');
     While not KeyPressed do ;
     While KeyPressed do c := readkey;
end;

Procedure Test_Where;
begin
     ClrScr;
     Writeln('Test of WhereX and WhereY');
     Writeln('Please Press any Key at end');

     For i := 4 to 12 do
     begin
         GotoXY(i*3,i);
         Writeln('X=',WhereX,'  Y=',WhereY);
         Delay(500);
     end;

     GotoXY(1,20);
     Write('Done');
     While not KeyPressed do ;
     While KeyPressed do c := readkey;
end;

Procedure Test_TextMode;
var Hold : Word;
begin
     ClrScr;
     Writeln('Test of TextMode');
     Writeln('Please Press any Key at end');

     If m = 7 then
          Writeln('Mono Adaptor - cannot test modes')
     else
     begin
          Hold := LastMode;
          Delay(2000);
          TextMode(BW40);
          Writeln('BW40 Mode');
          Delay(4000);
          TextMode(CO40);
          TextColor(yellow);
          TextBackground(blue);
          Writeln('CO40 Mode');
          Delay(4000);
          TextMode(BW80);
          Writeln('BW80 Mode');
          Delay(4000);
          TextMode(CO80);
          TextColor(yellow);
          TextBackground(blue);
          Writeln('CO80 Mode');
          Delay(4000);
          TextMode(BW80+Font8x8);
          Writeln('BW80+Font8x8 Mode');
          Delay(4000);
          TextMode(CO80+Font8x8);
          TextColor(yellow);
          TextBackground(blue);
          Writeln('CO80+Font8x8 Mode');
          Delay(4000);
          TextMode(Hold);
          ClrScr;
     end;
     GotoXY(1,20);
     Write('Done');
     While not KeyPressed do ;
     While KeyPressed do c := readkey;
end;

Procedure Test_Readkey;
begin
     ClrScr;
     Writeln('Test of Readkey');
     Writeln('Keystrokes will be written to screen in numeric format');
     Writeln('Press the ESC key to exit from this procedure');
     repeat
           c := Readkey;
           if c = #0 then
           begin
                write(ord(c):4);
                c := readkey;
                Writeln(ord(c):4);
           end
           else
           Writeln(ord(c):4);
     until c = #27;
end;

Procedure Test_Window;
begin
     ClrScr;
     Writeln('Test of Window');
     Writeln('Previous Set of Procedures to be tested in a Window');
     Writeln('Please press a key to start - procedures should be offset');

     While not KeyPressed do ;
     While KeyPressed do c := readkey;
     TextColor(yellow);
     TextBackground(blue);
     ClrScr;
     Window(5,5,79,24);
     TextColor(LightGray);
     TextBackground(black);
     ClrScr;
     WriteLn('Window is ',succ(lo(windmin)),',',succ(hi(windmin)),
     ',',Succ(Lo(windmax)),',',Succ(Hi(windmax)));

     Write('Press a key to begin');
     While not KeyPressed do ;
     While KeyPressed do c := readkey;

     Test_ClrScr;
     Test_TextColor;
     Test_TextBackGround;
     Test_ClrEol;
     Test_InsLine;
     Test_DelLine;
     Test_High_Norm_LowVideo;
     Test_Where;


     Window(1,1,80,25);
     Write('Press any Key to return to full screen and end program.');
     While not KeyPressed do ;
     While KeyPressed do c := readkey;
     ClrScr;
end;

begin
     Notes;
     Test_ClrScr;
     Test_TextColor;
     Test_TextBackGround;
     Test_ClrEol;
     Test_InsLine;
     Test_DelLine;
     Test_High_Norm_LowVideo;
     Test_Where;
     Test_ReadKey;
     Test_TextMode;
     Test_Sound;
     Test_Window;
end.
