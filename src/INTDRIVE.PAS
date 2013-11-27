{***************************************************************************}
{*  UltraDraw  -- An application to prepare graphical drawings, generate   *}
{*                and optimize the control, and drive an on-texture        *}
{*                drawing robot machine.                                   *}
{*                                                                         *}
{*  Copyright (C) 2000-2001 Russlan Kafri. <russlank@gmail.com>            *}
{*                                                                         *}
{*  This program is free software; you can redistribute it and/or modify   *}
{*  it under the terms of the GNU General Public License version 2         *}
{*  as published by the Free Software Foundation.                          *}
{*                                                                         *}
{*  This program is distributed in the hope that it will be useful,        *}
{*  but WITHOUT ANY WARRANTY; without even the implied warranty of         *}
{*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *}
{*  GNU General Public License for more details.                           *}
{*                                                                         *}
{*  You should have received a copy of the GNU General Public License      *}
{*  along with this program (see the file COPYING included with this       *}
{*  distribution); if not, write to the Free Software Foundation, Inc.,    *}
{*  59 Temple Place, Suite 330, Boston, MA  02111-1307  USA                *}
{*                                                                         *}
{*                                                                         *}
{*  FILE: INITDRIVE.PAS                                                    *}
{*                                                                         *}
{***************************************************************************}

{$F+}
unit IntDriver;

interface

uses Dos, Graph, Crt, {UCrt,} Generics;

{DEFINE SVGA256COLORS}

{************************************************}
{*                                              *}
{*                                              *}
{************************************************}

const MAXNICEVALUE = MaxLongInt;
      MINNICEVALUE = 0;
      TIMERNICEVALUE = 20;
      MOUSENICEVALUE = 500;
      KEBOARDNICEVALUE = 1000;
      NORMALNICEVALUE = 5000;
      TIMERUNIT = ( 2 / 18.2); { = (1 / 9.1) Sec.}
      MOUSEREPEATDELAY = 2;
      MOUSEFIRSTREPEATDELAY = 9;
      MOUSECURSORSIZEX = 16;
      MOUSECURSORSIZEY = 24;
{$IFDEF SVGA256COLORS}
      COLORSCOUNT      = 256;
{$ELSE}
      COLORSCOUNT      = 16;
{$ENDIF}


const evNoThing     = $00;
      evMouseMove   = $01;
      evMouseDown   = $02;
      evMouseUp     = $04;
      evMouseDrag   = $08;
      evMouseRepeat = $10;
      evMouse       = (evMouseMove or evMouseDown or evMouseUp or evMouseDrag or evMouseRepeat);
      evKeyPress    = $20;
      evTimer       = $40;
      evCommand     = $80;

      shkInsertOn               = $0080;
      shkCapsLockOn             = $0040;
      shkNumLockOn              = $0020;
      shkScrollLockOn           = $0010;
      shkAltDown                = $0008;
      shkControlDown            = $0004;
      shkLeftShiftDown          = $0002;
      shkRightShiftDown         = $0001;
      shkShiftDown              = shkLeftShiftDown or shkRightShiftDown;
      shkSysReqDown             = $8000;
      shkCapsLockDown           = $4000;
      shkNumLockDown            = $2000;
      shkScrollLockDown         = $1000;
      shkRightAltDown           = $0800;
      shkRightControlDown       = $0400;
      shkLeftAltDown            = $0200;
      shkLeftControlDown        = $0100;

      keyNONE         = 0;

      keyF1           = $3B;
      keyF2           = $3C;
      keyF3           = $3D;
      keyF4           = $3E;
      keyF5           = $3F;
      keyF6           = $40;
      keyF7           = $41;
      keyF8           = $42;
      keyF9           = $43;
      keyF10          = $44;

      keySHIFTF1      = $54;
      keySHIFTF2      = $55;
      keySHIFTF3      = $56;
      keySHIFTF4      = $57;
      keySHIFTF5      = $58;
      keySHIFTF6      = $59;
      keySHIFTF7      = $5A;
      keySHIFTF8      = $5B;
      keySHIFTF9      = $5C;
      keySHIFTF10     = $5D;

      keyCTRLF1       = $5E;
      keyCTRLF2       = $5F;
      keyCTRLF3       = $60;
      keyCTRLF4       = $61;
      keyCTRLF5       = $62;
      keyCTRLF6       = $63;
      keyCTRLF7       = $64;
      keyCTRLF8       = $65;
      keyCTRLF9       = $66;
      keyCTRLF10      = $67;

      keyALTF1        = $68;
      keyALTF2        = $69;
      keyALTF3        = $6A;
      keyALTF4        = $6B;
      keyALTF5        = $6C;
      keyALTF6        = $6D;
      keyALTF7        = $6E;
      keyALTF8        = $6F;
      keyALTF9        = $70;
      keyALTF10       = $71;

      keyESC          = 1;
      keyENTER        = 28;
      keyBACKSPACE    = 14;
      keyUP           = 72;
      keyDOWN         = 80;
      keyLEFT         = 75;
      keyRIGHT        = 77;
      keyINSERT       = 82;
      keyDEL          = 83;
      keyHOME         = 71;
      keyEND          = 79;
      keyPAGEUP       = 73;
      keyPAGEDOWN     = 81;
      keyTAB          = 15;
      keySPACE        = $39;

      keyA            = $1E;
      keyB            = $30;
      keyC            = $2E;
      keyD            = $20;
      keyE            = $12;
      keyF            = $21;
      keyG            = $22;
      keyH            = $23;
      keyI            = $17;
      keyJ            = $24;
      keyK            = $25;
      keyL            = $26;
      keyM            = $32;
      keyN            = $31;
      keyO            = $18;
      keyP            = $19;
      keyQ            = $10;
      keyR            = $13;
      keyS            = $1F;
      keyT            = $14;
      keyU            = $16;
      keyV            = $2F;
      keyW            = $11;
      keyX            = $2D;
      keyY            = $15;
      keyZ            = $2C;
      key0            = $0B;
      key1            = $02;
      key2            = $03;
      key3            = $04;
      key4            = $05;
      key5            = $06;
      key6            = $07;
      key7            = $08;
      key8            = $09;
      key9            = $0A;

      {
                 . . .

      key?        = ?  + ? * 256;
      }

{************************************************}
{*                                              *}
{*                                              *}
{************************************************}

type Float = Double;

     TCommand = Word;

     TCommandsSet = set of Byte;

     PPoint = ^TPoint;
     TPoint = object
       X, Y: Longint;
       procedure Assign( AX, AY: Longint);
       end;

     TRect = object
        A, B: TPoint;
        procedure Assign( X1, Y1, X2, Y2: Integer);
        procedure Assign_( AA, AB: TPoint);
        function PointIn( AP: TPoint): Boolean;
        function IsCruss( AR: TRect): Boolean;
        procedure GetSize( var AP: TPoint);
        procedure FitPoint( var APoint: TPoint);
        end;

      PGraphImageRec = ^TGraphImageRec;
      TGraphImageRec = record
         SizeX: Word;
         SizeY: Word;
         Data: array[0..0] of Byte;
         end;

     PColorRec = ^TColorRec;
     TColorRec = record
                 Red,Green,Blue:Byte;
                 end;

     TPalette = array[ 0..COLORSCOUNT - 1] Of TColorRec;
     PPalette = ^TPalette;

     TKeyInfo = record
        ScanCode: Byte;
        CharCode: Char;
        ShiftStatus: Word;
        end;

     TMouseInfo = record
        Where: TPoint;
        Bottons: Byte;
        ShiftStatus: Word;
        end;

     TTimeInfo = record
        TimerId: Integer;
        end;

     TEvent = record
         What: Byte;
         case Byte
         of 0: ( MouseInfo: TMouseInfo );
            1: ( KeyInfo: TKeyInfo);
            3: ( Command: TCommand;
                 SubCommand: Longint;
                 Info: Pointer);
            4: ( TimeInfo: TTimeInfo);
            end;

      TFillPattern = FillPatternType;
      TColor = Word;
      TLineStyle = Word;
      TLinePattern = Word;
      TLineThikness = Word;
      TTextFont = Word;
      TTextDirection = Word;
      TTextCharSize = Word;

      TFillInfo = record
         FillPattern: TFillPattern;
         FillColor: TColor;
         end;

      TLineInfo = record
         LinePattern: TLinePattern;
         LineStyle: TLineStyle;
         LineThikness: TLineThikness;
         end;

      TTextInfo = record
         TextFont: TTextFont;
         TextDirection: TTextDirection;
         TextCharSize: TTextCharSize;
         end;

      PVewPortInfo = ^TVewPortInfo;
      TVewPortInfo = record
         Color: TColor;
         BackColor: TColor;
         PortRange: TRect;
         DrawOffset: TPoint;
         FillInfo: TFillInfo;
         LineInfo: TLineInfo;
         TextInfo: TTextInfo;
         ViewEnabled: Boolean;
         end;

      PViewPortInfoList = ^TViewPortInfoList;
      TViewPortInfoList = record
         VewPortInfo: TVewPortInfo;
         Next: PViewPortInfoList;
         end;

{*************************************************************************}

     PImageItem = ^TImageItem;
     TImageItem = record
        Offset: Integer;
        ImageSize: Word;
        Image: Pointer;
        Next: PImageItem;
        end;

{*************************************************************************}

     PScreenImage = ^TScreenImage;
     TScreenImage = object(TGeneric)
        ImageParts: PImageItem;
        X,Y: Integer;
        constructor Create;
        destructor Destroy; virtual;
        procedure Clear;
        procedure Get(AX1, AY1, AX2, AY2: Integer);
        procedure Put(AX, AY: Integer);
        procedure Restore;
        end;

{*************************************************************************}

      PScreen = ^TScreen;
      TScreen = object( TGeneric)
      private
         ViewPortInfoList: PViewPortInfoList;
         ViewPortInfo: TVewPortInfo;
         MaxX: Word;
         MaxY: Word;
         MouseShowCounter: Integer;
{$IFDEF SVGA256COLORS}
         MouseCursorPos: TPoint;
         MouseBackImage: PGraphImageRec;
         MouseOrShape: PGraphImageRec;
         MouseAndShape: PGraphImageRec;
         TempMouseImage: PGraphImageRec;
         MouseBackImagePresents: Boolean;
         MouseBackImageSize: Word;
         ShapeCreated: Boolean;
{$ENDIF}
         OriginalPalette: TPalette;
         procedure ActivateViewPort;
         procedure InitDefaultViewPort;
{$IFDEF SVGA256COLORS}
         procedure DrawMouseCursor;
{$ENDIF}
      public
         constructor Create;
         destructor Destroy; virtual;
         function StartGraphMode: Boolean;
         function FinishGraphMode: Boolean;

         procedure SetViewPortRange( var APortRange: TRect; var ADrawOffset: TPoint);
         procedure SetGlobalScreenViewPort;
         procedure SetColor( AColor: TColor);
         procedure SetBackColor( AColor: TColor);
         procedure SetFillPattern( var AFillPattern: TFillPattern; AColor: TColor);
         procedure SetLineStyle( ALineStyle: TLineStyle; ALinePattern: TLinePattern; ALineThikness: TLineThikness);
         procedure SetTextStyle( ATextFont: TTextFont; ATextDirection: TTextDirection; ATextCharSize: TTextCharSize);
         procedure SetVewPortInfo( var AVewPortInfo: TVewPortInfo);
         procedure GetVewPortInfo( var AVewPortInfo: TVewPortInfo);
         procedure PushViewPortInfo;
         function PopViewPortInfo: Boolean;
         procedure ClearViewPortInfoStack;
         function TextWidth( AStr: string): Word;
         function TextWidthEx( AStr: string): Word;
         procedure OutTextXY( AX, AY: Integer; AStr: string);
         procedure OutTextXYEx( AX, AY: Integer; AStr: string);
         procedure OutFramedTextXY( AX, AY: Integer; AStr: string; ATextColor, AFrameColor: Integer);
         procedure MoveTo( AX, AY: Integer);
         procedure OutText( AStr: string);
         procedure Pixel( X1, Y1: Integer; AColor: Integer);
         procedure Line( X1, Y1, X2, Y2: Integer);
         procedure Arc( AX, AY, AStartAngle, AStopAngle, ARadius: Integer);
         procedure ArcEx( AX, AY: Integer; AStartAngle, AStopAngle, AStartRadius, AStopRadius: Float);
         procedure Circle( X1, Y1, R: Integer);
         procedure Rectangle( X1, Y1, X2, Y2: Integer);
         procedure Bar( X1, Y1, X2, Y2: Integer);
         procedure PutPixel( X, Y: Integer; Color: Word);
         procedure ScroolUp( APixels: Integer);
         procedure ScroolDown( APixels: Integer);
         procedure ScroolLeft( APixels: Integer);
         procedure ScroolRight( APixels: Integer);
         procedure ClearViewPort;
         procedure ShowMouseCursor;
         procedure HideMouseCursor;
{$IFDEF SVGA256COLORS}
         procedure UpdateMouseCursorPos( var ANewPos: TPoint);
         procedure SaveMouseBackImage;
         procedure RestoreMouseBackImage;
         procedure CreateMouseShape;
{$ENDIF}
        procedure SetColorPalette( AColor, ARed, AGreen, ABlue: Byte);
        procedure GetColorPalette( AColor: Byte; var ARed: Byte; var AGreen: Byte; var ABlue: Byte);
        procedure SetPalette( Table: PPalette);
        procedure GetPalette( Table: PPalette);
        procedure SaveColorsPalette;
        procedure RestoreColorsPalette;
        procedure SetActiveColorsPalette;
        end;

      TProcess = procedure;

{************************************************}
{*                                              *}
{*                                              *}
{************************************************}

const TimeTicker: Boolean = False;
      LastTimeTickerValue: Boolean = False;
      MouseRepeatTimer: Integer = 0;

procedure GetMouseEvent( var E: TEvent);
procedure GetKbEvent( var E: TEvent);
procedure WaitEvent(var E:TEvent);
procedure MistakeBeep;
procedure InstallProcess( AProcess: TProcess; ANice: Longint);
procedure UninstallProcess( AProcess: TProcess);
function PopEvent( var E: TEvent): Boolean;
function PushEvent( var E: TEvent): Boolean;
procedure KeyboardEventGenerator; far;
procedure MouseEventGenerator; far;
procedure Timer; far;
procedure InstallInterrupts;
procedure UnInstallInterrupts;
procedure RunTimer( ATime: Longint);
function GetTimerValue: Longint;
function IsTimerOn: Boolean;
function ResetTime: Longint;
function GetTime: Longint;

const TimerCounter: Longint = 0;
      TimeCounter: Longint = 0;

const LightPattern : TFillPattern = ( 85, 170, 85, 170, 85, 170, 85, 170);
      VeryLightPattern : TFillPattern = ( 68, 17, 68, 17, 68, 17, 68, 17);
      UltraLightPattern : TFillPattern = ( 68, 0, 17, 0, 68, 0, 17, 0);
      SolidPattern : TFillPattern = ( 255, 255, 255, 255, 255, 255, 255, 255);
      LinesPattern : TFillPattern = ( 17, 34, 68, 136, 17, 34, 68, 136);
      Squares : TFillPattern = ( $F0, $F0, $F0, $F0, $0F, $0F, $0F, $0F);

var TheScreen: TScreen;
const TheScreenIsInitialized: Boolean = False;


Implementation

{************************************************}
{*                                              *}
{*                                              *}
{************************************************}

const CursorBitmap: array[0..MOUSECURSORSIZEY * MOUSECURSORSIZEX - 1] of Byte = (
   $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $00, $0D, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $00, $0D, $0D, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $00, $06, $0D, $0D, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $00, $06, $0D, $0D, $0D, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $00, $06, $06, $0D, $0D, $0D, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $00, $06, $06, $0D, $0D, $0D, $0D, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $00, $06, $06, $06, $0D, $0D, $0D, $0D, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $00, $06, $06, $06, $0D, $0D, $0D, $0D, $0D, $00, $FF, $FF, $FF, $FF, $FF, $FF,
   $00, $06, $06, $06, $06, $0D, $0D, $0D, $0D, $0D, $00, $FF, $FF, $FF, $FF, $FF,
   $00, $06, $06, $0D, $06, $0D, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF,
   $00, $06, $0D, $00, $06, $06, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $00, $0D, $00, $FF, $00, $06, $0D, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $00, $00, $FF, $FF, $00, $06, $06, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $00, $FF, $FF, $FF, $FF, $00, $06, $0D, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
   );


{************************************************}
{*                                              *}
{*                                              *}
{************************************************}

type PProcessList = ^TProcessList;
     TProcessList = record
         Process: TProcess;
         Nice: Longint;
         NiceCounter: Longint;
         Next: PProcessList;
         end;

const IdleProcesses: PProcessList = nil;

{
procedure InitIdleProcesses;
begin
     IdleProcesses := nil;
end;
}

procedure CallIdleProcesses;
var ScanProcess: PProcessList;
begin
     ScanProcess := IdleProcesses;
     while ( ScanProcess <> nil)
     do begin
        if ( @ScanProcess^.Process <> nil)
        then begin
             if ( ScanProcess^.NiceCounter > 0)
             then ScanProcess^.NiceCounter := ScanProcess^.NiceCounter - 1
             else begin
                  ScanProcess^.Process;
                  ScanProcess^.NiceCounter := ScanProcess^.Nice;
                  end;
             end;
        ScanProcess := ScanProcess^.Next;
        end;
end;

procedure InstallProcess( AProcess: TProcess; ANice: Longint);
var ScanProcess: PProcessList;
    Found: Boolean;
    NewIdle: PProcessList;
begin
     if ( @AProcess <> nil)
     then begin
          Found := False;
          ScanProcess := IdleProcesses;
          while ( ScanProcess <> nil)
          do begin
             if ( @ScanProcess^.Process <> @AProcess)
             then ScanProcess := ScanProcess^.Next
             else begin
                  ScanProcess^.Nice := ANice;
                  ScanProcess^.NiceCounter := ANice;
                  ScanProcess := nil;
                  Found := True
                  end;
             end;
          if not Found
          then begin
               New( NewIdle);
               NewIdle^.Process := AProcess;
               NewIdle^.Nice := ANice;
               NewIdle^.NiceCounter := ANice;
               NewIdle^.Next := IdleProcesses;
               IdleProcesses := NewIdle;
               end;
          end;
end;

procedure UninstallProcess( AProcess: TProcess);
var PreScanProcess, ScanProcess: PProcessList;
    RemovedProcess: PProcessList;
begin
     PreScanProcess := nil;
     ScanProcess := IdleProcesses;
     while ( ScanProcess <> nil)
     do begin
        if ( @ScanProcess^.Process = @AProcess)
        then begin
             RemovedProcess := ScanProcess;
             ScanProcess := ScanProcess^.Next;
             Dispose( RemovedProcess);
             if ( PreScanProcess <> nil)
             then PreScanProcess^.Next := ScanProcess
             else IdleProcesses := ScanProcess;
             end
        else begin
             PreScanProcess := ScanProcess;
             ScanProcess := ScanProcess^.Next;
             end;
        end;
end;

{************************************************}
{*                                              *}
{*                                              *}
{************************************************}

const LastMousePosition: TPoint = (X:0;Y:0);
      LastMouseBottons: Byte = (0);
      NextEvent: TEvent = ( What: evNothing);
      EVENTQUEUESIZE = 256;

{************************************************}
{*                                              *}
{*                                              *}
{************************************************}

type TEventQueue = record
         Head, Tail: Integer;
         Events: array[ 0..EVENTQUEUESIZE] of TEvent;
         end;

const EventQueue: TEventQueue = ( Head: 0; Tail: 0);

{
procedure InitEventQueue;
begin
     EventQueue.Head := 0;
     EventQueue.Tail := 0;
end;
}

function PushEvent( var E: TEvent): Boolean;
var NewTail: Integer;
begin
     if ( E.What <> evNothing)
     then begin
          if ( EventQueue.Tail < EVENTQUEUESIZE)
          then NewTail := EventQueue.Tail + 1
          else NewTail := 0;
          if ( NewTail <> EventQueue.Head)
          then begin
               EventQueue.Events[ NewTail] := E;
               EventQueue.Tail := NewTail;
               PushEvent := True;
               end
          else PushEvent := False;
          end
     else PushEvent := False;
end;

function PopEvent( var E: TEvent): Boolean;
begin
     if ( EventQueue.Head <> EventQueue.Tail)
     then begin
          if ( EventQueue.Head < EVENTQUEUESIZE)
          then EventQueue.Head := EventQueue.Head + 1
          else EventQueue.Head := 0;
          E := EventQueue.Events[ EventQueue.Head];
          PopEvent := True;
          end
     else PopEvent := False;
end;

function IsEventQueueEmpty: Boolean;
begin
     IsEventQueueEmpty := ( EventQueue.Head = EventQueue.Tail);
end;

{************************************************}
{*                                              *}
{*                                              *}
{************************************************}

procedure TPoint.Assign( AX, AY:Longint);
begin
     X := AX;
     Y := AY;
end;

{************************************************}
{*                                              *}
{*                                              *}
{************************************************}

procedure TRect.Assign( X1, Y1, X2, Y2: Integer);
begin
     A.Assign( X1, Y1);
     B.Assign( X2, Y2);
end;

procedure TRect.Assign_( AA, AB: TPoint);
begin
     A := AA;
     B := AB;
end;

function TRect.PointIn( AP: TPoint): Boolean;
begin
     PointIn := (( AP.X >= A.X) and ( AP.Y >= A.Y) and ( AP.X < B.X) and ( AP.Y < B.Y));
end;

function TRect.IsCruss( AR: TRect): Boolean;
begin
     IsCruss := Self.PointIn( AR.A) or Self.PointIn( AR.B)
                        or AR.PointIn( A) or AR.PointIn( B);
end;

procedure TRect.GetSize( var AP: TPoint);
begin
     AP.Assign( B.X - A.X,B.Y - A.Y);
end;

procedure TRect.FitPoint( var APoint: TPoint);
begin
     if APoint.X < A.X
     then A.X := APoint.X
     else if APoint.X > B.X
          then B.X := APoint.X;

     if APoint.Y < A.Y
     then A.Y := APoint.Y
     else if APoint.Y > B.Y
          then B.Y := APoint.Y;
end;


{************************************************}
{*                                              *}
{*                                              *}
{************************************************}

{procedure SetGraphMode;
var gm,gd:Integer;
    Palette: PaletteType;
    R: Registers;
begin
     gd := detect;
     InitGraph(gd,gm,'');
     GetPalette(Palette);
     Palette.Size := 16;
     Palette.Colors[5] := 85;
     Palette.Colors[9] := 81;
     Palette.Colors[14] := 38;
     Palette.Colors[1] := 8;
     Palette.Colors[3] := 28;
     Palette.Colors[6] := 14;
     Palette.Colors[2] := 1;
     Palette.Colors[4] := 36;
     Palette.Colors[5] := 40;
     Palette.Colors[13] := 55;
     Palette.Colors[11] := 43;
     Palette.Colors[10] := 12;
     Palette.Colors[8] := 24;
     SetAllPalette(Palette);

     R.AX := $08;
     R.CX := 0;
     R.DX := GetMaxY;
     Intr( $33, R);

     R.AX := $07;
     R.CX := 0;
     R.DX := GetMaxX;
     Intr( $33, R);

end;}

{procedure CloseGraphMode;
begin
     CloseGraph;
end;}

{procedure ShowMouseCursor;
Var R:Registers;
Begin
     MouseShowCounter := MouseShowCounter - 1;
     If MouseShowCounter = 0
     Then Begin
          R.AX:=$01;
          R.BX:=$00;
          Intr($33,R);
          End;
End;}

{procedure HideMouseCursor;
var R:Registers;
begin
     MouseShowCounter:= MouseShowCounter + 1;
     if MouseShowCounter = 1
     then begin
          R.AX:=$02;
          R.BX:=$00;
          Intr($33,R);
          end;
end;}

procedure GetMouseEvent( var E:TEvent);
var R: Registers;
begin
          R.AX := $03;
          R.BX := $00;
          Intr( $33, R);

          E.MouseInfo.Where.X := R.CX;
          E.MouseInfo.Where.Y := R.DX;
{$IFDEF SVGA256COLORS}
          {E.MouseInfo.Where.Y := E.MouseInfo.Where.Y * 479 div 199;}
          if TheScreenIsInitialized
          then TheScreen.UpdateMouseCursorPos( E.MouseInfo.Where);
{$ENDIF}
          E.MouseInfo.Bottons := R.BL;
          if (( E.MouseInfo.Where.X = LastMousePosition.X) and ( E.MouseInfo.Where.Y = LastMousePosition.Y))
          then begin
               if ( E.MouseInfo.Bottons = LastMouseBottons)
               then begin
                    if (( MouseRepeatTimer <> 0) or (LastMouseBottons = 0))
                    then E.What := evNothing
                    else begin
                         MouseRepeatTimer := MOUSEREPEATDELAY;
                         E.What := evMouseRepeat;
                         end;
                    end
               else if ( E.MouseInfo.Bottons < LastMouseBottons)
               then begin
                    MouseRepeatTimer := MOUSEFIRSTREPEATDELAY;
                    E.What := evMouseUp;
                    LastMouseBottons := E.MouseInfo.Bottons;
                    end
               else begin
                    MouseRepeatTimer := MOUSEFIRSTREPEATDELAY;
                    E.What := evMouseDown;
                    LastMouseBottons := E.MouseInfo.Bottons;
                    end;
               end
          else begin
               LastMousePosition := E.MouseInfo.Where;
               if ( E.MouseInfo.Bottons = LastMouseBottons)
               then begin
                    if ( LastMouseBottons <> 0)
                    then E.What := evMouseDrag
                    else E.What := evMouseMove;
                    end
               else if ( E.MouseInfo.Bottons < LastMouseBottons)
               then begin
                    E.What := evMouseUp;
                    LastMouseBottons := E.MouseInfo.Bottons;
                    end
               else begin
                    E.What := evMouseDown;
                    LastMouseBottons := E.MouseInfo.Bottons;
                    end;
               end;

          if ( E.What <> evNoThing)
          then begin
               R.AH := $12;
               Intr( $16, R);
               E.MouseInfo.ShiftStatus := ( WORD( R.AL) or ( WORD( R.AH) shr 8));
               end;
          {end
     else E.What := evNothing;}
end;

procedure GetKbEvent( var E: TEvent);
var R: Registers;
begin
     R.AH := $11;
     Intr( $16, R);
     if (( R.Flags and $40) = $00)
     then begin
          E.What := evKeyPress;
          R.AH := $10;
          Intr( $16, R);
          E.KeyInfo.CharCode := Char(R.AL);
          E.KeyInfo.ScanCode := R.AH;
          R.AH := $12;
          Intr( $16, R);
          E.KeyInfo.ShiftStatus := ( WORD( R.AL) or ( WORD( R.AH) shr 8));
          end;
end;

procedure KeyboardEventGenerator;
var E: TEvent;
begin
     E.What := evNothing;
     GetKbEvent( E);
     if E.What <> evNothing
     then PushEvent( E);
end;

procedure MouseEventGenerator;
var E: TEvent;
begin
     E.What := evNothing;
     GetMouseEvent( E);
     if ( E.What <> evNothing)
     then PushEvent( E);
end;

{
procedure WaitEvent( var E:TEvent);
var R:Registers;
begin
     repeat
           if IsEventQueueEmpty
           then begin
                E.What := evNothing;
                while True
                do begin
                   if ( NextEvent.What <> evNothing)
                   then begin
                        E := NextEvent;
                        NextEvent.What := evNothing;
                        Exit;
                        end;
                   GetKbEvent(E);
                   if ( E.What <> evNothing)
                   then Exit;
                   GetMouseEvent(E);
                   if ( E.What <> evNothing)
                   then Exit;
                   CallIdleProcesses;
                   end;
                end
           else PopEvent( E);
     until ( E.What <> evNothing);
end;
}

procedure WaitEvent( var E:TEvent);
var R:Registers;
begin
     while IsEventQueueEmpty
     do CallIdleProcesses;
     PopEvent( E);
end;

procedure MistakeBeep;
begin
     Sound(1000);
     Delay( 100);
     NoSound;
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

const OldClockVec: Pointer = nil;

procedure Timer;
var E: TEvent;
begin
     if ( TimeTicker and ( not LastTimeTickerValue))
     then begin
          if ( TimerCounter > 0)
          then TimerCounter := TimerCounter - 1;
          if ( MouseRepeatTimer > 0)
          then MouseRepeatTimer := MouseRepeatTimer - 1;
          TimeCounter := TimeCounter + 1;
          end;
     LastTimeTickerValue := TimeTicker;
end;

function GetTimerCounter: Longint;
begin
     GetTimerCounter := TimerCounter;
end;

procedure RunTimer( ATime: Longint);
begin
     TimerCounter := ATime;
end;

function GetTimerValue: Longint;
begin
     GetTimerValue := TimerCounter;
end;

function IsTimerOn: Boolean;
begin
     IsTimerOn := ( TimerCounter > 0);
end;

function ResetTime: Longint;
begin
     ResetTime := TimeCounter;
     TimeCounter := 0;
end;

function GetTime: Longint;
begin
     GetTime := TimeCounter;
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

{
      TFillInfo = record
         FillPattern: TFillPattern;
         FillColor: TColor;
         end;

      TLineInfo = record
         LinePattern: TLinePattern;
         LineStyle: TLineStyle;
         LineThikness: TLineThikness;
         end;

      TTextInfo = record
         TextFont: TTextFont;
         TextDirection: TTextDirection;
         TextCharSize: TTextCharSize;
         end;

      PVewPortInfo = ^TVewPortInfo;
      TVewPortInfo = record
         Color: TColor;
         BackColor: TColor;
         PortRange: TRect;
         FillInfo: TFillInfo;
         LineInfo: TLineInfo;
         TextInfo: TTextInfo;
         end;

      PViewPortInfoList = ^TViewPortInfoList;
      TViewPortInfoList = record
         VewPortInfo: TVewPortInfo;
         Next: PViewPortInfoList;
         end;
}

constructor TScreenImage.Create;
begin
     inherited Create;
     ImageParts := nil;
end;

destructor TScreenImage.Destroy;
begin
     Clear;
     inherited Destroy;
end;

procedure TScreenImage.Clear;
var Temp: PImageItem;
begin
     while (ImageParts <> nil)
     do begin
        Temp := ImageParts;
        ImageParts := ImageParts^.Next;
        FreeMem(Temp^.Image, Temp^.ImageSize);
        Dispose(Temp);
        end;
     X := 0;
     Y := 0;
end;

procedure TScreenImage.Get(AX1, AY1, AX2, AY2: Integer);
var RemainHeight: Integer;
    PartialHeight: Integer;
    X1,Y1,X2,Y2: Integer;
    Temp: Integer;
    MaxX,MaxY: Integer;
    CurrentY: Integer;
    Size: Word;
    NewPart: PImageItem;
begin
     Clear;
     if AX1 > AX2
     then begin
          X1 := AX2;
          X2 := AX1;
          end
     else begin
          X1 := AX1;
          X2 := AX2;
          end;

     if AY1 > AY2
     then begin
          Y1 := AY2;
          Y2 := AY1;
          end
     else begin
          Y1 := AY1;
          Y2 := AY2;
          end;

     MaxX := GetMaxX;
     MaxY := GetMaxY;

     if X1 < 0
     then begin
          X1 := 0;
          if X2 < 0
          then Exit
          else if X2 > MaxX
          then  X2 := MaxX;
          end
     else if X1 > MaxX
     then Exit
     else if X2 > MaxX
     then  X2 := MaxX;

     if Y1 < 0
     then begin
          Y1 := 0;
          if Y2 < 0
          then Exit
          else if Y2 > MaxY
          then  Y2 := MaxY;
          end
     else if Y1 > MaxY
     then Exit
     else if Y2 > MaxY
     then  Y2 := MaxY;

     RemainHeight := Y2 - Y1 + 1;
     PartialHeight := 50000 div (X2 - X1 + 1);
     CurrentY := Y1;

     repeat
           if RemainHeight > PartialHeight
           then RemainHeight := RemainHeight - PartialHeight
           else begin
                PartialHeight := RemainHeight;
                RemainHeight := 0;
                end;
           Size := ImageSize(X1, CurrentY, X2, CurrentY + PartialHeight - 1);
           New(NewPart);
           NewPart^.Next := ImageParts;
           ImageParts := NewPart;
           NewPart^.ImageSize := Size;
           NewPart^.Offset := CurrentY - Y1;
           GetMem(NewPart^.Image, Size);
           GetImage(X1, CurrentY, X2, CurrentY + PartialHeight - 1, NewPart^.Image^);
           CurrentY := CurrentY + PartialHeight;
     until (RemainHeight <= 0);
     X := X1;
     Y := Y1;
end;

procedure TScreenImage.Put(AX, AY: Integer);
var ScanPart: PImageItem;
begin
     ScanPart := ImageParts;
     while (ScanPart <> nil)
     do begin
        PutImage(AX, AY + ScanPart^.Offset, ScanPart^.Image^, NormalPut);
        ScanPart := ScanPart^.Next;
        end;
end;

procedure TScreenImage.Restore;
begin
     Put(X,Y);
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

{$IFDEF SVGA256COLORS}

function DetectVGA256 : integer;
{ Detects VGA or MCGA video cards }
var
  DetectedDriver : integer;
  SuggestedMode  : integer;
begin
  DetectGraph(DetectedDriver, SuggestedMode);
  if (DetectedDriver = VGA) or (DetectedDriver = MCGA) then
  begin
    {Writeln('Which video mode would you like to use?');
    Writeln('  0) 320x200x256');
    Writeln('  1) 640x400x256');
    Writeln('  2) 640x480x256');
    Writeln('  3) 800x600x256');
    Writeln('  4) 1024x768x256');
    Writeln('  5) 640x350x256');
    Writeln('  6) 1280x1024x256');
    Write('> ');}
    SuggestedMode := 2;
    DetectVGA256 := SuggestedMode;
  end
  else
    DetectVGA256 := grError; { Couldn't detect hardware }
end; { DetectVGA256 }

procedure SetGraphMode;
var AutoDetectPointer : pointer;
    GraphDriver : integer;  { The Graphics device driver }
    GraphMode   : integer;  { The Graphics mode value }
    ErrorCode   : integer;  { Reports any graphics errors }
    InGraphicsMode : boolean; { Flags initialization of graphics mode }
    UseWhichDriver : integer;
    R: Registers;
begin
  { when using Crt and graphics, turn off Crt's memory-mapped writes }
  DirectVideo := False;

  AutoDetectPointer := @DetectVGA256;   { Point to detection routine }
  GraphDriver := InstallUserDriver('SVGA256', AutoDetectPointer);
  GraphDriver := Detect;
  InitGraph(GraphDriver, GraphMode, '');

  ErrorCode := GraphResult;             { preserve error return }
  if ErrorCode AND $80 = $80 then
     ErrorCode := ErrorCode OR $ff00;
  if ErrorCode <> grOK then             { error? }
  begin
    Writeln('Graphics error: ', GraphErrorMsg(ErrorCode));
    if ErrorCode = grFileNotFound then  { Can't find driver file }
    begin
      Writeln('ERROR: Unable to find display driver ...');
    end
    else
      Halt(1);                          { Some other error: terminate }
  end;
end;

{$ENDIF}


{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}



constructor TScreen.Create;
begin
     inherited Create;
     ViewPortInfoList := nil;
     StartGraphMode;
     InitDefaultViewPort;
     MouseShowCounter := 1;
{$IFDEF SVGA256COLORS}
     MouseCursorPos.Assign( 0, 0);
     MouseBackImageSize := ImageSize( 0, 0, MOUSECURSORSIZEX, MOUSECURSORSIZEY);
     GetMem( MouseBackImage, MouseBackImageSize);
     GetMem( TempMouseImage, MouseBackImageSize);
     GetMem( MouseOrShape, MouseBackImageSize);
     GetMem( MouseAndShape, MouseBackImageSize);
     ShapeCreated := False;
     MouseBackImagePresents := False;
{$ENDIF}
     TheScreenIsInitialized := True;
end;

destructor TScreen.Destroy;
begin
     TheScreenIsInitialized := False;
{$IFDEF SVGA256COLORS}
     FreeMem( MouseBackImage, MouseBackImageSize);
     FreeMem( TempMouseImage, MouseBackImageSize);
     FreeMem( MouseOrShape, MouseBackImageSize);
     FreeMem( MouseAndShape, MouseBackImageSize);
{$ENDIF}
     ClearViewPortInfoStack;
     FinishGraphMode;
     inherited Destroy;
end;

procedure TScreen.InitDefaultViewPort;
begin
     ViewPortInfo.ViewEnabled := True;
     ViewPortInfo.Color := 7;
     ViewPortInfo.BackColor := 0;
     ViewPortInfo.PortRange.Assign( 0, 0, MaxX, MaxY);
     ViewPortInfo.DrawOffset.Assign( 0, 0);
     ViewPortInfo.FillInfo.FillPattern := SolidPattern;
     ViewPortInfo.FillInfo.FillColor := 7;
     ViewPortInfo.LineInfo.LineStyle := SolidLn;
     ViewPortInfo.LineInfo.LinePattern := $FF;
     ViewPortInfo.LineInfo.LineThikness := 1;
     ViewPortInfo.TextInfo.TextFont := 0;
     ViewPortInfo.TextInfo.TextDirection := HorizDir;
     ViewPortInfo.TextInfo.TextCharSize := 0;
     ActivateViewPort;
end;

procedure TScreen.ActivateViewPort;
begin
     if (( ViewPortInfo.PortRange.A.X < ViewPortInfo.PortRange.B.X)
        and ( ViewPortInfo.PortRange.A.Y < ViewPortInfo.PortRange.B.Y))
     then begin
          Graph.SetViewPort( ViewPortInfo.PortRange.A.X,
                             ViewPortInfo.PortRange.A.Y,
                             ViewPortInfo.PortRange.B.X,
                             ViewPortInfo.PortRange.B.Y, True);
          end;

     Graph.SetColor( ViewPortInfo.Color);
     Graph.SetBkColor( ViewPortInfo.BackColor);
     Graph.SetFillPattern( ViewPortInfo.FillInfo.FillPattern,
                           ViewPortInfo.FillInfo.FillColor);
     Graph.SetLineStyle( ViewPortInfo.LineInfo.LineStyle,
                         ViewPortInfo.LineInfo.LinePattern,
                         ViewPortInfo.LineInfo.LineThikness);
     Graph.SetTextStyle( ViewPortInfo.TextInfo.TextFont,
                         ViewPortInfo.TextInfo.TextDirection,
                         ViewPortInfo.TextInfo.TextCharSize);
end;

function TScreen.StartGraphMode: Boolean;
{$IFDEF SVGA256COLORS}
var R: Registers;
begin
     SetGraphMode;

     SaveColorsPalette;
     SetActiveColorsPalette;

     MaxX := GetMaxX;
     MaxY := GetMaxY;

     R.AX := $00; { Reset mouse driver }
     Intr( $33, R);

     R.AX := $08; { Set mouse Y range }
     R.CX := 0;
     R.DX := MaxY;
     Intr( $33, R);

     R.AX := $07; { Set mouse X range }
     R.CX := 0;
     R.DX := GetMaxX;
     Intr( $33, R);

     StartGraphMode := True;
end;

{$ELSE}

var gm,gd:Integer;
    R: Registers;
    ErrorCode   : integer;  { Reports any graphics errors }
begin
     gd := detect;
     InitGraph(gd,gm,'');

     ErrorCode := GraphResult;             { preserve error return }
     if (( ErrorCode and $80) = $80)
     then ErrorCode := ErrorCode or $ff00;

     if ( ErrorCode <> grOK)
     then begin
          StartGraphMode := False;
          Writeln('Graphics error: ', GraphErrorMsg(ErrorCode));
          if ErrorCode = grFileNotFound
          then begin { Can't find driver file }
               Writeln('ERROR: Unable to find display driver ...');
               end
          else begin
               { Some other error}
               end;
          MaxX := 0;
          MaxY := 0;

          StartGraphMode := False;
          end
     else begin
          SaveColorsPalette;
          SetActiveColorsPalette;

          MaxX := GetMaxX;
          MaxY := GetMaxY;

          R.AX := $00; { Reset mouse driver }
          Intr( $33, R);

          R.AX := $08; { Set mouse Y range }
          R.CX := 0;
          R.DX := GetMaxY;
          Intr( $33, R);

          R.AX := $07; { Set mouse X range }
          R.CX := 0;
          R.DX := GetMaxX;
          Intr( $33, R);

          StartGraphMode := True;
          end;
end;
{$ENDIF}

function TScreen.FinishGraphMode: Boolean;
begin
     RestoreColorsPalette;

     CloseGraph;

     FinishGraphMode := True;
end;

procedure TScreen.SetViewPortRange( var APortRange: TRect; var ADrawOffset: TPoint);
begin
     ViewPortInfo.PortRange := APortRange;
     if (( ViewPortInfo.PortRange.A.X < ViewPortInfo.PortRange.B.X)
        and ( ViewPortInfo.PortRange.A.Y < ViewPortInfo.PortRange.B.Y))
     then begin
          if ViewPortInfo.PortRange.A.X < 0
          then ViewPortInfo.PortRange.A.X := 0;
          if ViewPortInfo.PortRange.A.Y < 0
          then ViewPortInfo.PortRange.A.Y := 0;
          if ViewPortInfo.PortRange.B.X > MaxX
          then ViewPortInfo.PortRange.B.X := MaxX;
          if ViewPortInfo.PortRange.B.Y > MaxY
          then ViewPortInfo.PortRange.B.Y := MaxY;
          ViewPortInfo.DrawOffset.X := ADrawOffset.X - ViewPortInfo.PortRange.A.X;
          ViewPortInfo.DrawOffset.Y := ADrawOffset.Y - ViewPortInfo.PortRange.A.Y;
          Graph.SetViewPort( ViewPortInfo.PortRange.A.X,
                             ViewPortInfo.PortRange.A.Y,
                             ViewPortInfo.PortRange.B.X,
                             ViewPortInfo.PortRange.B.Y, True);
          ViewPortInfo.ViewEnabled := True;
          end
     else ViewPortInfo.ViewEnabled := False;
end;

procedure TScreen.SetGlobalScreenViewPort;
begin
     ViewPortInfo.PortRange.Assign( 0, 0, MaxX, MaxY);
     ViewPortInfo.DrawOffset.Assign( 0, 0);
     Graph.SetViewPort( ViewPortInfo.PortRange.A.X,
                        ViewPortInfo.PortRange.A.Y,
                        ViewPortInfo.PortRange.B.X,
                        ViewPortInfo.PortRange.B.Y, True);
     ViewPortInfo.ViewEnabled := True;
end;

procedure TScreen.SetColor( AColor: TColor);
begin
     ViewPortInfo.Color := AColor;
     Graph.SetColor( ViewPortInfo.Color);
end;

procedure TScreen.SetBackColor( AColor: TColor);
begin
     ViewPortInfo.BackColor := AColor;
     Graph.SetBkColor( ViewPortInfo.BackColor);
end;

procedure TScreen.SetFillPattern( var AFillPattern: TFillPattern; AColor: TColor);
begin
     ViewPortInfo.FillInfo.FillPattern := AFillPattern;
     ViewPortInfo.FillInfo.FillColor := AColor;
     Graph.SetFillPattern( ViewPortInfo.FillInfo.FillPattern,
                           ViewPortInfo.FillInfo.FillColor);
end;

procedure TScreen.SetLineStyle( ALineStyle: TLineStyle; ALinePattern: TLinePattern; ALineThikness: TLineThikness);
begin
     ViewPortInfo.LineInfo.LineStyle := ALineStyle;
     ViewPortInfo.LineInfo.LinePattern := ALinePattern;
     ViewPortInfo.LineInfo.LineThikness := ALineThikness;
     Graph.SetLineStyle( ViewPortInfo.LineInfo.LineStyle,
                         ViewPortInfo.LineInfo.LinePattern,
                         ViewPortInfo.LineInfo.LineThikness);
end;

procedure TScreen.SetTextStyle( ATextFont: TTextFont; ATextDirection: TTextDirection; ATextCharSize: TTextCharSize);
begin
     ViewPortInfo.TextInfo.TextFont := ATextFont;
     ViewPortInfo.TextInfo.TextDirection := ATextDirection;
     ViewPortInfo.TextInfo.TextCharSize := ATextCharSize;
     Graph.SetTextStyle( ViewPortInfo.TextInfo.TextFont,
                         ViewPortInfo.TextInfo.TextDirection,
                         ViewPortInfo.TextInfo.TextCharSize);
end;

procedure TScreen.SetVewPortInfo( var AVewPortInfo: TVewPortInfo);
begin
     ViewPortInfo := AVewPortInfo;
     ActivateViewPort;
end;

procedure TScreen.GetVewPortInfo( var AVewPortInfo: TVewPortInfo);
begin
     AVewPortInfo := ViewPortInfo;
end;

procedure TScreen.PushViewPortInfo;
var NewInfo: PViewPortInfoList;
begin
     New( NewInfo);
     NewInfo^.VewPortInfo := ViewPortInfo;
     NewInfo^.Next := ViewPortInfoList;
     ViewPortInfoList := NewInfo;

     InitDefaultViewPort;
end;

function TScreen.PopViewPortInfo: Boolean;
var TempInfo: PViewPortInfoList;
begin
     if ( ViewPortInfoList <> nil)
     then begin
          TempInfo := ViewPortInfoList;
          ViewPortInfoList := ViewPortInfoList^.Next;
          ViewPortInfo := TempInfo^.VewPortInfo;
          Dispose( TempInfo);
          ActivateViewPort;
          PopViewPortInfo := True;
          end
     else begin
          InitDefaultViewPort;
          PopViewPortInfo := False;
          end;
end;

procedure TScreen.ClearViewPortInfoStack;
var ScanViewPortInfo: PViewPortInfoList;
begin
     while ( ViewPortInfoList <> nil)
     do begin
        ScanViewPortInfo := ViewPortInfoList;
        ViewPortInfoList := ViewPortInfoList^.Next;
        Dispose( ScanViewPortInfo);
        end;
end;

function TScreen.TextWidth( AStr: string): Word;
begin
     TextWidth := Graph.TextWidth( AStr);
end;

function TScreen.TextWidthEx( AStr: string): Word;
var UPos: Integer;
begin
     UPos := Pos( '&', AStr);
     if ( UPos > 0)
     then TextWidthEx := Graph.TextWidth( AStr) - Graph.TextWidth( '&')
     else TextWidthEx := Graph.TextWidth( AStr);
end;

procedure TScreen.OutTextXY( AX, AY: Integer; AStr: string);
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     Graph.OutTextXY( AX + ViewPortInfo.DrawOffset.X, AY + ViewPortInfo.DrawOffset.Y, AStr);
end;

procedure TScreen.OutTextXYEx( AX, AY: Integer; AStr: string);
var S: string;
    UPos: Integer;
    Len: Integer;
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     UPos := Pos('&', AStr);
     if (UPos > 0)
     then begin
          Delete( AStr, UPos, 1);
          Graph.OutTextXY( AX + ViewPortInfo.DrawOffset.X, AY + ViewPortInfo.DrawOffset.Y, AStr);
          Len := Length( AStr);
          FillChar( S[1], Len, ' ');
          S[0] := Char(Len);
          S[UPos] := '_';
          Graph.OutTextXY( AX + ViewPortInfo.DrawOffset.X, AY + ViewPortInfo.DrawOffset.Y + 1, S);
          end
     else Graph.OutTextXY( AX + ViewPortInfo.DrawOffset.X, AY + ViewPortInfo.DrawOffset.Y, AStr);
end;

procedure TScreen.OutFramedTextXY( AX, AY: Integer; AStr: string; ATextColor, AFrameColor: Integer);
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     SetColor( AFrameColor);
     Graph.OutTextXY( AX + ViewPortInfo.DrawOffset.X + 0, AY + ViewPortInfo.DrawOffset.Y + 0, AStr);
     Graph.OutTextXY( AX + ViewPortInfo.DrawOffset.X + 1, AY + ViewPortInfo.DrawOffset.Y + 0, AStr);
     Graph.OutTextXY( AX + ViewPortInfo.DrawOffset.X + 2, AY + ViewPortInfo.DrawOffset.Y + 0, AStr);
     Graph.OutTextXY( AX + ViewPortInfo.DrawOffset.X + 2, AY + ViewPortInfo.DrawOffset.Y + 1, AStr);
     Graph.OutTextXY( AX + ViewPortInfo.DrawOffset.X + 2, AY + ViewPortInfo.DrawOffset.Y + 2, AStr);
     Graph.OutTextXY( AX + ViewPortInfo.DrawOffset.X + 1, AY + ViewPortInfo.DrawOffset.Y + 2, AStr);
     Graph.OutTextXY( AX + ViewPortInfo.DrawOffset.X + 0, AY + ViewPortInfo.DrawOffset.Y + 2, AStr);
     Graph.OutTextXY( AX + ViewPortInfo.DrawOffset.X + 0, AY + ViewPortInfo.DrawOffset.Y + 1, AStr);
     SetColor( ATextColor);
     Graph.OutTextXY( AX + ViewPortInfo.DrawOffset.X + 1, AY + ViewPortInfo.DrawOffset.Y + 1, AStr);
     Graph.SetColor( ViewPortInfo.Color);
end;

procedure TScreen.MoveTo( AX, AY: Integer);
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     Graph.MoveTo( AX + ViewPortInfo.DrawOffset.X, AY + ViewPortInfo.DrawOffset.Y);
end;

procedure TScreen.OutText( AStr: string);
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     Graph.OutText( AStr);
end;

procedure TScreen.Pixel( X1, Y1: Integer; AColor: Integer);
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     Graph.PutPixel( X1 + ViewPortInfo.DrawOffset.X,Y1 + ViewPortInfo.DrawOffset.Y, AColor);
end;

procedure TScreen.Line( X1, Y1, X2, Y2: Integer);
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     Graph.Line( X1 + ViewPortInfo.DrawOffset.X,
                 Y1 + ViewPortInfo.DrawOffset.Y,
                 X2 + ViewPortInfo.DrawOffset.X,
                 Y2 + ViewPortInfo.DrawOffset.Y);
end;

procedure TScreen.Arc( AX, AY, AStartAngle, AStopAngle, ARadius: Integer);
const Delta = 5;
var Angle, TempAngle: Integer;
    X, Y, LX, LY: Integer;
    CX, CY: Integer;
begin
     if not ViewPortInfo.ViewEnabled then Exit;

     if ( AStartAngle >= AStopAngle)
     then AStopAngle := AStopAngle + 360;

     CX := AX + ViewPortInfo.DrawOffset.X;
     CY := AY + ViewPortInfo.DrawOffset.Y;
     LX := Round( ARadius * Cos( AStartAngle * PI / 180)) + CX;
     LY := Round( ARadius * Sin( AStartAngle * PI / 180)) + CY;
     Angle := AStartAngle + Delta;
     while ( AStopAngle >= Angle)
     do begin
        X := Round( ARadius * Cos( Angle * PI / 180)) + CX;
        Y := Round( ARadius * Sin( Angle * PI / 180)) + CY;
        Graph.Line( LX, LY, X, Y);
        Angle := Angle + Delta;
        LX := X;
        LY := Y;
        end;
     if ( Angle > AStopAngle)
     then begin
          X := Round( ARadius * Cos( AStopAngle * PI / 180)) + CX;
          Y := Round( ARadius * Sin( AStopAngle * PI / 180)) + CY;
          Graph.Line( LX, LY, X, Y);
          end;
end;

procedure TScreen.ArcEx( AX, AY: Integer; AStartAngle, AStopAngle, AStartRadius, AStopRadius: Float);
const Delta = 5;
var Angle, TempAngle: Float;
    X, Y, LX, LY: Integer;
    CX, CY: Integer;
    Radius: Float;
    RadiusDelta: Float;
    Steps: Integer;
    FSteps: Float;
begin
     if not ViewPortInfo.ViewEnabled then Exit;

     if ( AStartAngle >= AStopAngle)
     then AStopAngle := AStopAngle + 360;

     FSteps := (AStopAngle - AStartAngle) / Delta;

     if (Frac( FSteps) > 0)
     then Steps := Trunc( FSteps) + 1
     else Steps := Trunc( FSteps);

     RadiusDelta := (AStopRadius - AStartRadius) / Steps;

     CX := AX + ViewPortInfo.DrawOffset.X;
     CY := AY + ViewPortInfo.DrawOffset.Y;
     LX := Round( AStartRadius * Cos( AStartAngle * PI / 180)) + CX;
     LY := Round( AStartRadius * Sin( AStartAngle * PI / 180)) + CY;
     Angle := AStartAngle + Delta;
     Radius := AStartRadius + RadiusDelta;

     {Circle( LX, LY, 3);}
     while ( AStopAngle >= Angle)
     do begin
        X := Round( Radius * Cos( Angle * PI / 180)) + CX;
        Y := Round( Radius * Sin( Angle * PI / 180)) + CY;
        Graph.Line( LX, LY, X, Y);
        Angle := Angle + Delta;
        Radius := Radius + RadiusDelta;
        LX := X;
        LY := Y;
        end;

     if ( Angle > AStopAngle)
     then begin
          X := Round( AStopRadius * Cos( AStopAngle * PI / 180)) + CX;
          Y := Round( AStopRadius * Sin( AStopAngle * PI / 180)) + CY;
          Graph.Line( LX, LY, X, Y);
          end;
end;

procedure TScreen.Circle( X1, Y1, R: Integer);
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     Graph.Circle( X1 + ViewPortInfo.DrawOffset.X, Y1 + ViewPortInfo.DrawOffset.Y, R);
end;

procedure TScreen.Rectangle( X1, Y1, X2, Y2: Integer);
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     Graph.Rectangle( X1 + ViewPortInfo.DrawOffset.X,
                      Y1 + ViewPortInfo.DrawOffset.Y,
                      X2 + ViewPortInfo.DrawOffset.X,
                      Y2 + ViewPortInfo.DrawOffset.Y);
end;

procedure TScreen.Bar( X1, Y1, X2, Y2: Integer);
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     Graph.Bar( X1 + ViewPortInfo.DrawOffset.X,
                Y1 + ViewPortInfo.DrawOffset.Y,
                X2 + ViewPortInfo.DrawOffset.X,
                Y2 + ViewPortInfo.DrawOffset.Y);
end;

procedure TScreen.PutPixel( X, Y: Integer; Color: Word);
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     Graph.PutPixel( X + ViewPortInfo.DrawOffset.X, Y + ViewPortInfo.DrawOffset.Y , Color);
end;

procedure TScreen.ScroolUp( APixels: Integer);
var Image: TScreenImage;
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     Image.Create;
     HideMouseCursor;
     Image.Get( 0, APixels, ViewPortInfo.PortRange.B.X - ViewPortInfo.PortRange.A.X,
                            ViewPortInfo.PortRange.B.Y - ViewPortInfo.PortRange.A.Y);
     Image.Put( 0, 0);
     ShowMouseCursor;
     Image.Destroy;

     {SetFillPattern( Solid, BackColor);
     Bar( 0, GetHeight - APixels, GetWidth, GetHeight);}
end;

procedure TScreen.ScroolDown( APixels: Integer);
var Image: TScreenImage;
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     Image.Create;
     HideMouseCursor;
     Image.Get( 0, 0 , ViewPortInfo.PortRange.B.X - ViewPortInfo.PortRange.A.X,
                       ViewPortInfo.PortRange.B.Y - ViewPortInfo.PortRange.A.Y - APixels);
     Image.Put( 0, APixels);
     ShowMouseCursor;
     Image.Destroy;

     {SetFillPattern( Solid, BackColor);
     Bar( 0, GetHeight - APixels, GetWidth, GetHeight);}
end;

procedure TScreen.ScroolLeft( APixels: Integer);
var Image: TScreenImage;
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     Image.Create;
     HideMouseCursor;
     Image.Get( APixels, 0 , ViewPortInfo.PortRange.B.X - ViewPortInfo.PortRange.A.X,
                             ViewPortInfo.PortRange.B.Y - ViewPortInfo.PortRange.A.Y);
     Image.Put( 0, 0);
     ShowMouseCursor;
     Image.Destroy;

     {SetFillPattern( Solid, BackColor);
     Bar( 0, GetHeight - APixels, GetWidth, GetHeight);}
end;

procedure TScreen.ScroolRight( APixels: Integer);
var Image: TScreenImage;
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     Image.Create;
     HideMouseCursor;
     Image.Get( 0, 0, ViewPortInfo.PortRange.B.X - ViewPortInfo.PortRange.A.X - APixels,
                      ViewPortInfo.PortRange.B.Y - ViewPortInfo.PortRange.A.Y);
     Image.Put( APixels, 0);
     ShowMouseCursor;
     Image.Destroy;

     {SetFillPattern( Solid, BackColor);
     Bar( 0, GetHeight - APixels, GetWidth, GetHeight);}
end;

procedure TScreen.ClearViewPort;
begin
     if not ViewPortInfo.ViewEnabled then Exit;
     Graph.ClearViewPort;
end;

{$IFDEF SVGA256COLORS}

procedure TScreen.CreateMouseShape;
begin
     SetFillPattern( SolidPattern, 15);
     SetColor( 0);
     GetImage( 0, 0, MOUSECURSORSIZEX - 1, MOUSECURSORSIZEY - 1, TempMouseImage^);
     Bar( 0, 0, MOUSECURSORSIZEX - 1, MOUSECURSORSIZEY - 1);
     MoveTo( 0, 0);
     LineTo( 20, 10);
     LineTo( 10, 10);
     LineTo( 10, 20);
     LineTo( 0, 0);
     GetImage( 0, 0, MOUSECURSORSIZEX - 1, MOUSECURSORSIZEY - 1, MouseAndShape^);
     SetFillPattern( SolidPattern, 0);
     SetColor( 15);
     Bar( 0, 0, MOUSECURSORSIZEX - 1, MOUSECURSORSIZEY - 1);
     MoveTo( 2, 2);
     LineTo( 16, 9);
     LineTo( 9, 9);
     LineTo( 9, 16);
     LineTo( 2, 2);
     MoveTo( 4, 4);
     LineTo( 12, 8);
     LineTo( 8, 8);
     LineTo( 8, 12);
     LineTo( 4, 4);
     MoveTo( 6, 6);
     LineTo( 8, 7);
     LineTo( 7, 7);
     LineTo( 7, 8);
     LineTo( 6, 6);
     GetImage( 0, 0, MOUSECURSORSIZEX - 1, MOUSECURSORSIZEY - 1, MouseOrShape^);
     PutImage( 0, 0, TempMouseImage^, NormalPut);
     ShapeCreated := True;
end;

{$ENDIF}

{$IFDEF SVGA256COLORS}
{procedure TScreen.DrawMouseCursor;
var X, Y: Word;
    Offset: Word;
begin
     if MouseBackImagePresents
     then begin
          System.Move( MouseBackImage^, TempMouseImage^, MouseBackImageSize);
          for Offset := 0 to MouseBackImageSize - 7
          do TempMouseImage^.Data[ Offset] := ((TempMouseImage^.Data[ Offset]
                                              or MouseOrShape^.Data[ Offset])
                                              and MouseAndShape^.Data[ Offset]);
          PutImage( MouseCursorPos.X, MouseCursorPos.Y, TempMouseImage^, NormalPut);
          end;
end;}

procedure TScreen.DrawMouseCursor;
var X, Y: Word;
    BOffset: Word;
    BRange: Word;
    IOffset: Word;
    B: Byte;
    Data: Byte;

begin
     if MouseBackImagePresents
     then begin
          System.Move( MouseBackImage^, TempMouseImage^, MouseBackImageSize);

          BOffset := 0;
          IOffset := 0;
          BRange := 0;
          for Y := 0 to TempMouseImage^.SizeY
          do begin
             BOffset := BRange;
             for X := 0 to TempMouseImage^.SizeX
             do begin
                if ( CursorBitmap[ BOffset] < 255)
                then TempMouseImage^.Data[ IOffset] := CursorBitmap[BOffset];
                IOffset := IOffset + 1;
                BOffset := BOffset + 1;
                end;
             BRange := BRange + MOUSECURSORSIZEX;
             end;

          {for Offset := 0 to MouseBackImageSize - 7
          do begin
             Data := TempMouseImage^.Data[ Offset];
             Data := ;
             TempMouseImage^.Data[ Offset] := Data;
             B := (B + 1) mod 4;
             end;}
          PutImage( MouseCursorPos.X, MouseCursorPos.Y, TempMouseImage^, NormalPut);
          end;
end;
{$ENDIF}

procedure TScreen.ShowMouseCursor;
{$IFDEF SVGA256COLORS}
begin
     MouseShowCounter := MouseShowCounter - 1;

     if not ShapeCreated
     then CreateMouseShape;
     If MouseShowCounter = 0
     Then Begin
          PushViewPortInfo;
          SetGlobalScreenViewPort;
          SaveMouseBackImage;
          DrawMouseCursor;
          PopViewPortInfo;
          End;
end;
{$ELSE}
var R: Registers;
begin
     MouseShowCounter := MouseShowCounter - 1;

     If MouseShowCounter = 0
     Then Begin
          R.AX:=$01;
          R.BX:=$00;
          Intr($33,R);
          End;
end;
{$ENDIF}

procedure TScreen.HideMouseCursor;
{$IFDEF SVGA256COLORS}
begin
     MouseShowCounter:= MouseShowCounter + 1;
     if MouseShowCounter = 1
     then begin
          PushViewPortInfo;
          SetGlobalScreenViewPort;
          RestoreMouseBackImage;
          PopViewPortInfo;
          end;
end;
{$ELSE}
var R: Registers;
begin
     MouseShowCounter:= MouseShowCounter + 1;
     if MouseShowCounter = 1
     then begin
          R.AX:=$02;
          R.BX:=$00;
          Intr($33,R);
          end;
end;
{$ENDIF}

{$IFDEF SVGA256COLORS}

procedure TScreen.UpdateMouseCursorPos( var ANewPos: TPoint);
begin
     if ((ANewPos.X <> MouseCursorPos.X) or (ANewPos.Y <> MouseCursorPos.Y))
     then begin
          if ( MouseShowCounter <= 0)
          then begin
               PushViewPortInfo;
               SetGlobalScreenViewPort;
               RestoreMouseBackImage;
               MouseCursorPos := ANewPos;
               SaveMouseBackImage;
               DrawMouseCursor;
               PopViewPortInfo;
               end
          else MouseCursorPos := ANewPos;
          end;
end;

procedure TScreen.SaveMouseBackImage;
var CursorRange: TPoint;
begin
     if (( MouseCursorPos.X <= MaxX) and ( MouseCursorPos.Y <= MaxY))
     then begin
          CursorRange.Assign( MouseCursorPos.X + MOUSECURSORSIZEX - 1, MouseCursorPos.Y + MOUSECURSORSIZEY - 1);
          if CursorRange.X > MaxX
          then CursorRange.X := MaxX;
          if CursorRange.Y > MaxY
          then CursorRange.Y := MaxY;
          GetImage( MouseCursorPos.X, MouseCursorPos.Y,
                    CursorRange.X, CursorRange.Y,
                    MouseBackImage^);
          MouseBackImagePresents := True;
          end
     else MouseBackImagePresents := False;
end;

procedure TScreen.RestoreMouseBackImage;
begin
     if (( MouseCursorPos.X <= MaxX) and ( MouseCursorPos.Y <= MaxY))
     then begin
          PutImage( MouseCursorPos.X, MouseCursorPos.Y,
                    MouseBackImage^, NormalPut);
          end;
end;

{$ENDIF}

procedure TScreen.SetColorPalette( AColor, ARed, AGreen, ABlue: Byte);
begin
     asm
        MOV AL,$10
        MOV AH,$10
        XOR BH,BH
        MOV BL,AColor
        MOV CH, AGreen
        MOV CL, ABlue
        MOV DH, ARed
        INT $10
     end;
end;

procedure TScreen.GetColorPalette( AColor: Byte; var ARed: Byte; var AGreen: Byte; var ABlue: Byte);
var Green, Blue, Red: Byte;
begin
     asm
        MOV AL, $15
        MOV AH, $10
        XOR BH, BH
        MOV BL, AColor
        INT $10
        MOV Green, CH
        MOV Blue, CL
        MOV Red, DH
     end;
     AGreen := Green;
     ABlue := Blue;
     ARed := Red;
end;

procedure TScreen.SetPalette( Table: PPalette);
begin
     asm
        MOV AL,$12
        MOV AH,$10
        MOV BX,$0000
        MOV CX,COLORSCOUNT
        LES DX,Table
        INT $10
     end;
end;

procedure TScreen.GetPalette( Table: PPalette);
begin
     asm
        MOV AL,$17
        MOV AH,$10
        MOV BX,$0000
        MOV CX,COLORSCOUNT
        LES DX,Table
        INT $10
     end;
end;

procedure TScreen.SetActiveColorsPalette;
var NewPalette: TPalette;
    I: Integer;
begin
     for I := 0 to COLORSCOUNT - 1
     do Graph.SetPalette(I, I);
     SetColorPalette( 0, 0, 0, 0);
     {SetColorPalette( 1, 5, 5, 15);
     SetColorPalette( 2, 15, 15, 30);
     SetColorPalette( 3, 30, 30, 50);
     SetColorPalette( 4, 50, 50, 63);}
     SetColorPalette( 1, 10, 10, 15);
     SetColorPalette( 2, 20, 20, 30);
     SetColorPalette( 3, 40, 40, 50);
     SetColorPalette( 4, 50, 50, 63);
     SetColorPalette( 5, 40, 5, 5);
     SetColorPalette( 6, 63, 10, 10);
     SetColorPalette( 7, 53, 40, 8);
     SetColorPalette( 8, 59, 52, 36);
     SetColorPalette( 9, 0, 21, 42);
     SetColorPalette( 10, 15, 39, 63);
     SetColorPalette( 11, 10, 47, 14);
     SetColorPalette( 12, 31, 57, 34);
     SetColorPalette( 13, 0, 0, 32);
     SetColorPalette( 14, 0, 32, 32);
     {SetColorPalette( 15, 63, 63, 63);}
     SetColorPalette( 15, 63, 63, 63);
end;

procedure TScreen.SaveColorsPalette;
begin
     GetPalette( @OriginalPalette);
end;

procedure TScreen.RestoreColorsPalette;
begin
     SetPalette( @OriginalPalette);
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}


procedure STI;
begin
     inline ($FB);
end;

procedure CLI;
begin
     inline ($FA);
end;

procedure CallOldInt( Ptr: Pointer);
begin
     inline ($9C/$FF/$5E/$06);
end;

procedure ClockInterrupt( Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word); interrupt;
begin
     if ( OldClockVec <> nil)
     then CallOldInt( OldClockVec);
     TimeTicker := not TimeTicker;
     STI;
end;

procedure InstallInterrupts;
begin
     CLI;
     GetIntVec($08, OldClockVec);
     SetIntVec($08, @ClockInterrupt);
     STI;
end;

procedure UnInstallInterrupts;
begin
     SetIntVec($08, OldClockVec);
end;

end.