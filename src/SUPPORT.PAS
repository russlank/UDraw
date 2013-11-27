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
{*  FILE: SUPPORT.PAS                                                      *}
{*                                                                         *}
{***************************************************************************}

unit Support;

interface

{DEFINE _DEBUG}

uses Generics, UWin, IntDriver, Graph, Crt{, UCrt};

{*************************************************************************}

const cmDeleteLastShape = cmUserCommand + 1;
      cmDeleteSelected  = cmUserCommand + 2;
      cmCopySelected    = cmUserCommand + 3;
      cmCutSelected     = cmUserCommand + 4;
      cmPasteSelected   = cmUserCommand + 5;
      cmNoTool          = cmUserCommand + 6;
      cmToolLine        = cmUserCommand + 7;
      cmToolArc         = cmUserCommand + 8;
      cmToolArcEx       = cmUserCommand + 9;
      cmGridStyle       = cmUserCommand + 10;
      cmZoomIn          = cmUserCommand + 11;
      cmZoomOut         = cmUserCommand + 12;
      cmZoom11          = cmUserCommand + 13;
      cmNewDesign       = cmUserCommand + 14;
      cmScrollToCenter  = cmUserCommand + 15;
      cmZoomFit         = cmUserCommand + 16;
      cmEditSettings    = cmUserCommand + 17;
      cmPreview         = cmUserCommand + 18;
      cmAnalize         = cmUserCommand + 19;
      cmRun             = cmUserCommand + 20;
      cmSnapOnOff       = cmUserCommand + 21;
      cmUpdatePreview   = cmUserCommand + 22;
      cmAddRow          = cmUserCommand + 23;
      cmRemoveRow       = cmUserCommand + 24;
      cmRemoveHead      = cmUserCommand + 25;
      cmEditPos         = cmUserCommand + 26;
      cmPositions       = cmUserCommand + 27;
      cmAddHeads        = cmUserCommand + 28;
      cmEditPreviewGrid = cmUserCommand + 29;
      {cmRunSimulation   = cmUserCommand + 27;}
      cmGo              = cmUserCommand + 30;
      cmManUp           = cmUserCommand + 31;
      cmManUpL          = cmUserCommand + 32;
      cmManUpR          = cmUserCommand + 33;
      cmManDown         = cmUserCommand + 34;
      cmManDownL        = cmUserCommand + 35;
      cmManDownR        = cmUserCommand + 36;
      cmManLeft         = cmUserCommand + 37;
      cmManRight        = cmUserCommand + 38;
      cmResetPos        = cmUserCommand + 39;
      cmGoCount         = cmUserCommand + 40;
      cmEditGrid        = cmUserCommand + 41;
      cmMirrorX         = cmUserCommand + 42;
      cmMirrorY         = cmUserCommand + 43;
      cmRotate90        = cmUserCommand + 44;
      cmConfig          = cmUserCommand + 45;
      cmSaveSettings    = cmUserCommand + 46;
      cmRestoreLastMeasurments = cmUserCommand + 47;
      cmRunMeasurments  = cmUserCommand + 48;
      cmLockSpeed       = cmUserCommand + 49;
      cmUnlockSpeed     = cmUserCommand + 50;
      cmUpdateCaption   = cmUserCommand + 51;
      cmUpdateHeadPos   = cmUserCommand + 52;
      cmUpdateHeadCords = cmUserCommand + 53;


      cmNew             = cmUserCommand + 60;
      cmOpen            = cmUserCommand + 61;
      cmSave            = cmUserCommand + 62;
      cmSaveAs          = cmUserCommand + 63;
      cmAboutUltraSoft  = cmUserCommand + 64;
      cmAboutSabbagh    = cmUserCommand + 65;
      cmAboutMaktabi    = cmUserCommand + 66;
      cmLoadFile        = cmUserCommand + 67;
      cmTuggle          = cmUserCommand + 68;
      cmStopMachine     = cmUserCommand + 69;
      cmLastLapRequest  = cmUserCommand + 70;
      {cmRealPath        = cmUserCommand + 69;}

      cmMachineError    = cmUserCommand + 81;
      cmUpdateMachineStateView = cmUserCommand + 82;

      cmTest1           = cmUserCommand + 100;
      cmTest2           = cmUserCommand + 101;
      cmTest3           = cmUserCommand + 102;
      cmTest4           = cmUserCommand + 103;

{*************************************************************************}

      DefFileName : string = 'NONAME.UDW';

{*************************************************************************}

type PFPoint = ^TFPoint;
     TFPoint = object
        X, Y: Float;
        procedure Assign( AX, AY: Float);
        function Distance( var FPoint: TFPoint): Float;
        function AngleRad( var FPoint: TFPoint): Float;
        function AngleDeg( var FPoint: TFPoint): Float;
        procedure MirrorX( AX: Float);
        procedure MirrorY( AY: Float);
        procedure Rotate90( var ACenter: TFPoint);
        end;

{*************************************************************************}

     PFRect = ^TFRect;
     TFRect = object
        A: TFPoint;
        B: TFPoint;
        procedure Assign( AX, AY, BX, BY: Float);
        procedure FitPoint( var AFPoint: TFPoint);
        end;

{*************************************************************************}

     TDelta = record
         X: Integer;
         Y: Integer;
         end;

{*************************************************************************}

     PDeltaList = ^TDeltaList;
     TDeltaList = record

        Delta: TDelta;
        Next: PDeltaList;
        Prev: PDeltaList;
        {YDistanceFromNextLocalEnd: Integer;}
        {NextLocalEnd: PDeltaList;}
{$IFDEF DEBUG}
        No: Longint;
{$ENDIF}
        end;

     PRPath = ^TRPath;
     TRPath = object( TGeneric)
        FirstDelta: PDeltaList;
        Cursor: PDeltaList;
        Count: Longint;
        constructor Create;
        destructor Destroy; virtual;
        procedure Clear;
        procedure AppendDelta( ADelta: TDelta; AReduceZeroDelta: Boolean);
        function GetFirstDelta( var ADelta: TDelta): Boolean;
        function GetFirstDeltaEx: PDeltaList;
        function GetNextDelta( var ADelta: TDelta): Boolean;
        function GetNextDeltaEx: PDeltaList;
        function GetCurrentDelta( var ADelta: TDelta): Boolean;
        function GetCurrentDeltaEx: PDeltaList;
        function IsCurrentFirst: Boolean;
        function GetCount: Longint;
        function GetLength: Longint;
        procedure GetFitRect( var ARect: TRect; AInitRect: Boolean);
        {procedure FindLocalEnds;}
{$IFDEF DEBUG}
        procedure WriteElementsToFile( AFileName: string);
{$ENDIF}
        end;

{*************************************************************************}

     PFPointList = ^TFPointList;
     TFPointList = record
        Pos: TFPoint;
        Next: PFPointList;
        end;

     PFPath = ^TFPath;
     TFPath = object( TGeneric)
        FirstPoint: PFPointList;
        LastPoint: PFPointList;
        Cursor: PFPointList;
        constructor Create;
        destructor Destroy; virtual;
        procedure Clear;
        procedure AppendPoint( AX, AY: Float);
        function GetFirstPoint( var APoint: TFPoint): Boolean;
        function GetLastPoint( var APoint: TFPoint): Boolean;
        function GetNextPoint( var APoint: TFPoint): Boolean;
        procedure DragPoints( var APoint: TFPoint);
        procedure AppendToPath( APath: PFPath);
        procedure AppendToRPath( APath: PRPath; AReduceZeroDelta: Boolean);
        function GetPathLength: Float;
        procedure GetFitRect( var AFRect: TFRect; AInitRect: Boolean);
        procedure Expand( AXRate, AYRate: Float);
        procedure HashPath( AHashLength: Float);
        procedure SnapPath( AXSnap, AYSnap: Float; ARemovePointsRepitition: Boolean);
        procedure SnapPathY( AYSnap: Float);
        procedure SnapPathX( AXSnap: Float);
        procedure HashByYLevels( AYStep: Float; ASnap: Boolean);
        procedure SnapVerticalMoves( AYStep: Float);
        procedure SubtractSteps( AYStep: Float);
        procedure RemoveLastPointXOffset;
        procedure RemoveLastPointYOffset;
        function HashRectangularly( AMaxXStepLength,
                                    AMaxYStepLength,
                                    AFeedStepLength: Float;
                                    AMaxSteps: Longint;
                                    var AStepsCountOverflow: Boolean): Boolean;
        function HashByLevels( AFeedStepLength: Float; var AMaxXStepLength: Float): Boolean;
        function GetStepsCount: Longint;
        function FindStepsCount( AMaxXStepLength,
                                 AMaxYStepLength,
                                 AFeedStepLength: Float;
                                 AMaxSteps: Longint;
                                 var AStepsCountOverflow: Boolean): Longint;
        function FindStepsCount_( AMaxXStepLength,
                                 AMaxYStepLength,
                                 AFeedStepLength: Float;
                                 AMaxSteps: Longint;
                                 var AStepsCountOverflow: Boolean): Longint;

        function GetMutionLength: Float;
        function GetMutionLengthOnX: Float;
        function GetMutionLengthOnY: Float;
        function GetMaxXStep: Float;
        function GetMaxYStep: Float;
        function ProduceHeadPath( AFeedStepLength, AMaxXStepLength, AMaxYStepLength: Float; ATestMaxSteps: Boolean): Boolean;
        function ProduceDeltaPath( StepsPerXUnit, StepsPerYUnit: Longint): PRPath;
        end;

{*************************************************************************}

     TCanvasInfo = record
        Zoom: Float;
        Offset: TFPoint;
        GridSize: TFPoint;
        SnapGridSize: TFPoint;
        Snap: Boolean;
        GridStyle: Byte;
        LimitsOffset: Float;
        end;

{*************************************************************************}

     PJustFrame = ^TJustFrame;
     TJustFrame = object( TGroupWindow)
        constructor Create( R: TRect);
        procedure Draw; virtual;
        procedure GetClientRect( var R: TRect); virtual;
        end;

{*************************************************************************}

     PCanvas = ^TCanvas;
     TCanvas = object( TWindow)
        CanvasInfo: TCanvasInfo;
        constructor Create( R: TRect);
        destructor Destroy; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure DrawGrid; virtual;
        procedure Draw; virtual;
        procedure Scroll( ADir: Integer); virtual;
        procedure GetFitRect( var FR: TFRect); virtual;
        procedure ConvertToLogicalX( var AX: Longint; var AFX: Float; ASnap: Boolean);
        procedure ConvertToLogicalY( var AY: Longint; var AFY: Float; ASnap: Boolean);
        procedure ConvertToCanvasX( var AFX: Float; var AX: Longint);
        procedure ConvertToCanvasY( var AFY: Float; var AY: Longint);
        procedure ConvertToLogicalPos( var APoint: TPoint; var AFPoint: TFPoint; ASnap: Boolean);
        procedure ConvertToCanvasPos( var AFPoint: TFPoint; var APoint: TPoint);
        procedure ConvertToCanvasPosEx( var AIPoint: TPoint; var APoint: TPoint);
        procedure ConvertToCanavsLength( AFLength: Float; var ALength: Longint);
        procedure ConvertToLogicalLength( ALength: Longint; var AFLength: Float);
        procedure ConvertToLogicalSize( var APoint: TPoint; var AFPoint: TFPoint);
        procedure ConvertToCanavsSize( var AFPoint: TFPoint; var APoint: TPoint);
        procedure GetAvailableCommands( var ACommands: TCommandsSet); virtual;
        end;

{*************************************************************************}

     PGridEditDlg = ^TGridEditDlg;
     TGridEditDlg = object( TDialog)
        Canvas: PCanvas;
        GridXEdit,
        GridYEdit,
        SnapXEdit,
        SnapYEdit,
        LimitsOffsetEdit: PFloatEdit;
        constructor Create( ACanvas: PCanvas);
        procedure BeforeExecuteDlg; virtual;
        procedure AfterExecuteDlg; virtual;
        function ValidateData: Boolean; virtual;
        end;


implementation

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

procedure TFPoint.Assign( AX, AY: Float);
begin
     X := AX;
     Y := AY;
end;

function TFPoint.Distance( var FPoint: TFPoint): Float;
begin
     Distance := Sqrt( Sqr( FPoint.X - X) + Sqr( FPoint.Y - Y));
end;

function TFPoint.AngleRad( var FPoint: TFPoint): Float;
var DeltaX, DeltaY: Float;
begin
     DeltaX := FPoint.X - X;
     DeltaY := FPoint.Y - Y;
     if ( DeltaX <> 0)
     then begin
          if (DeltaX > 0)
          then AngleRad := ArcTan( DeltaY / DeltaX)
          else AngleRad := ArcTan( DeltaY / DeltaX) + PI;
          end
     else if DeltaY > 0
          then AngleRad := PI / 2
          else AngleRad := 3 * PI / 2;
end;

function TFPoint.AngleDeg( var FPoint: TFPoint): Float;
begin
     AngleDeg := AngleRad( FPoint) * 180 / PI;
end;

procedure TFPoint.MirrorX( AX: Float);
begin
     X := 2 * AX - X;
end;

procedure TFPoint.MirrorY( AY: Float);
begin
     Y := 2 * AY - Y;
end;

procedure TFPoint.Rotate90( var ACenter: TFPoint);
var TempX, TempY: Float;
begin
     TempX := X;
     TempY := Y;
     X := + (TempY - ACenter.Y) + ACenter.X;
     Y := - (TempX - ACenter.X) + ACenter.Y;
end;


{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

procedure TFRect.Assign( AX, AY, BX, BY: Float);
begin
     A.Assign( AX, AY);
     B.Assign( BX, BY);
end;

procedure TFRect.FitPoint( var AFPoint: TFPoint);
begin
     if AFPoint.X < A.X
     then A.X := AFPoint.X
     else if AFPoint.X > B.X
          then B.X := AFPoint.X;

     if AFPoint.Y < A.Y
     then A.Y := AFPoint.Y
     else if AFPoint.Y > B.Y
          then B.Y := AFPoint.Y;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TRPath.Create;
begin
     inherited Create;
     FirstDelta := nil;
     Cursor := nil;
     Count := 0;
end;

destructor TRPath.Destroy;
begin
     Clear;
     inherited Destroy;
end;

procedure TRPath.Clear;
var ScanDelta: PDeltaList;
begin
     if ( FirstDelta <> nil)
     then begin
          ScanDelta := FirstDelta;
          if (ScanDelta^.Prev <> nil)
          then begin
               ScanDelta^.Prev^.Next := nil;
               while ( ScanDelta <> nil)
               do begin
                  FirstDelta := ScanDelta^.Next;
                  Dispose( ScanDelta);
                  ScanDelta := FirstDelta;
                  end;
               end;
          end;
     FirstDelta := nil;
     Cursor := nil;
end;

procedure TRPath.AppendDelta( ADelta: TDelta; AReduceZeroDelta: Boolean);
var NewDelta: PDeltaList;
begin
     if (AReduceZeroDelta and ( ADelta.X = 0) and ( ADelta.Y = 0))
     then Exit;

     Count := Count + 1;
     NewDelta := New( PDeltaList);
     NewDelta^.Delta := ADelta;

{$IFDEF DEBUG}
     NewDelta^.No := Count;
{$ENDIF}

     if ( FirstDelta <> nil)
     then begin
          NewDelta^.Next := FirstDelta;
          NewDelta^.Prev := FirstDelta^.Prev;
          FirstDelta^.Prev^.Next := NewDelta;
          FirstDelta^.Prev := NewDelta;
          end
     else begin
          NewDelta^.Next := NewDelta;
          NewDelta^.Prev := NewDelta;
          FirstDelta := NewDelta;
          end;

     Cursor := NewDelta;
end;

function TRPath.GetCount: Longint;
begin
     GetCount := Count;
end;

function TRPath.GetFirstDelta( var ADelta: TDelta): Boolean;
begin
     if ( FirstDelta <> nil)
     then begin
          Cursor := FirstDelta;
          ADelta := Cursor^.Delta;
          GetFirstDelta := True;
          end
     else begin
          ADelta.X := 0;
          ADelta.Y := 0;
          GetFirstDelta := False;
          Cursor := nil;
          end;
end;

function TRPath.GetFirstDeltaEx: PDeltaList;
begin
     Cursor := FirstDelta;
     GetFirstDeltaEx := FirstDelta;
end;

function TRPath.GetNextDelta( var ADelta: TDelta): Boolean;
begin
     if ( Cursor <> nil)
     then Cursor := Cursor^.Next;

     if ( Cursor <> nil)
     then begin
          ADelta := Cursor^.Delta;
          GetNextDelta := True;
          end
     else begin
          ADelta.X := 0;
          ADelta.Y := 0;
          GetNextDelta := False;
          end;
end;

function TRPath.GetNextDeltaEx: PDeltaList;
begin
     if ( Cursor <> nil)
     then Cursor := Cursor^.Next;
     GetNextDeltaEx := Cursor;
end;

function TRPath.GetCurrentDelta( var ADelta: TDelta): Boolean;
begin
     if ( Cursor <> nil)
     then begin
          ADelta := Cursor^.Delta;
          GetCurrentDelta := True;
          end
     else begin
          ADelta.X := 0;
          ADelta.Y := 0;
          GetCurrentDelta := False;
          end;
end;

function TRPath.GetCurrentDeltaEx: PDeltaList;
begin
     GetCurrentDeltaEx := Cursor;
end;

function TRPath.IsCurrentFirst: Boolean;
begin
     IsCurrentFirst := ( Cursor = FirstDelta);
end;

function TRPath.GetLength: Longint;
var Length: Longint;
    ScanDelta: PDeltaList;
    AbsDelta: TDelta;
begin
     Length := 0;
     if ( FirstDelta <> nil)
     then begin
          ScanDelta := FirstDelta;
          repeat
                AbsDelta.X := Abs( ScanDelta^.Delta.X);
                AbsDelta.Y := Abs( ScanDelta^.Delta.Y);
                if ( AbsDelta.X >= AbsDelta.Y)
                then Length := Length + AbsDelta.X
                else Length := Length + AbsDelta.Y;
                ScanDelta := ScanDelta^.Next;
          until (ScanDelta = FirstDelta);
          end;
     GetLength := Length;
end;

procedure TRPath.GetFitRect( var ARect: TRect; AInitRect: Boolean);
var ScanDelta: PDeltaList;
    Pos: TPoint;
begin
     if AInitRect
     then begin
          ARect.A.Assign( 0, 0);
          ARect.B.Assign( 0, 0);
          end
     else begin
          if ( 0 > ARect.B.X)
          then ARect.B.X := 0
          else if ( 0 < ARect.A.X)
          then ARect.A.X := 0;

          if ( 0 > ARect.B.Y)
          then ARect.B.Y := 0
          else if ( 0 < ARect.A.Y)
          then ARect.A.Y := 0;
          end;

     Pos.Assign( 0, 0);
     if ( FirstDelta <> nil)
     then begin
          ScanDelta := FirstDelta;
          repeat
                Pos.X := Pos.X + ScanDelta^.Delta.X;
                Pos.Y := Pos.Y + ScanDelta^.Delta.Y;
                if ( Pos.X > ARect.B.X)
                then ARect.B.X := Pos.X
                else if ( Pos.X < ARect.A.X)
                then ARect.A.X := Pos.X;

                if ( Pos.Y > ARect.B.Y)
                then ARect.B.Y := Pos.Y
                else if ( Pos.Y < ARect.A.Y)
                then ARect.A.Y := Pos.Y;

                ScanDelta := ScanDelta^.Next;
          until (ScanDelta = FirstDelta);
          end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TFPath.Create;
begin
     inherited Create;
     FirstPoint := nil;
     LastPoint := nil;
     Cursor := nil;
end;

procedure TFPath.Clear;
var ScanPoint: PFPointList;
begin
     while ( FirstPoint <> nil)
     do begin
        ScanPoint := FirstPoint;
        FirstPoint := FirstPoint^.Next;
        Dispose( ScanPoint);
        end;
     FirstPoint := nil;
     LastPoint := nil;
     Cursor := nil;
end;

destructor TFPath.Destroy;
begin
     Clear;
     inherited Destroy;
end;

procedure TFPath.AppendPoint( AX, AY: Float);
var NewPoint: PFPointList;
begin
     if ( LastPoint <> nil)
     then if ((LastPoint^.Pos.X = AX) and (LastPoint^.Pos.Y = AY))
          then Exit;
     New( NewPoint);
     NewPoint^.Pos.Assign( AX, AY);
     NewPoint^.Next := nil;
     Cursor := NewPoint;
     if ( FirstPoint <> nil)
     then begin
          LastPoint^.Next := NewPoint;
          LastPoint := NewPoint;
          end
     else begin
          FirstPoint := NewPoint;
          LastPoint := NewPoint;
          end;
end;

function TFPath.GetFirstPoint( var APoint: TFPoint): Boolean;
begin
     Cursor := FirstPoint;
     if ( Cursor <> nil)
     then begin
          APoint := Cursor^.Pos;
          GetFirstPoint := True;
          end
     else GetFirstPoint := False;
end;

function TFPath.GetLastPoint( var APoint: TFPoint): Boolean;
begin
     Cursor := LastPoint;
     if ( Cursor <> nil)
     then begin
          APoint := Cursor^.Pos;
          GetLastPoint := True;
          end
     else GetLastPoint := False;
end;

function TFPath.GetNextPoint( var APoint: TFPoint): Boolean;
begin
     if ( Cursor <> nil)
     then begin
          Cursor := Cursor^.Next;
          if ( Cursor <> nil)
          then begin
               APoint := Cursor^.Pos;
               GetNextPoint := True;
               Exit;
               end
          end;
     GetNextPoint := False;
end;

procedure TFPath.AppendToPath( APath: PFPath);
var ScanPoint: PFPointList;
begin
     if ( APath <> nil)
     then begin
          ScanPoint := FirstPoint;
          while ( ScanPoint <> nil)
          do begin
             APath^.AppendPoint( ScanPoint^.Pos.X, ScanPoint^.Pos.Y);
             ScanPoint := ScanPoint^.Next;
             end;
          end;
end;

procedure TFPath.AppendToRPath( APath: PRPath; AReduceZeroDelta: Boolean);
var CurrentPos: TPoint;
    ScanPoint: PFPointList;
    Delta: TDelta;
begin
     if (APath = nil)
     then Exit;
     CurrentPos.Assign( 0, 0);
     ScanPoint := FirstPoint;
     if ( ScanPoint <> nil)
     then begin
          if (( ScanPoint^.Pos.X = 0) and ( ScanPoint^.Pos.Y = 0))
          then ScanPoint := ScanPoint^.Next;
          while ( ScanPoint <> nil)
          do begin
             Delta.X := Round( ScanPoint^.Pos.X - CurrentPos.X);
             Delta.Y := Round( ScanPoint^.Pos.Y - CurrentPos.Y);
             CurrentPos.X := CurrentPos.X + Delta.X;
             CurrentPos.Y := CurrentPos.Y + Delta.Y;
             APath^.AppendDelta( Delta, AReduceZeroDelta);
             ScanPoint := ScanPoint^.Next;
             end;
          end;
end;

procedure TFPath.DragPoints( var APoint: TFPoint);
var ScanPoint: PFPointList;
begin
     ScanPoint := FirstPoint;
     while ( ScanPoint <> nil)
     do begin
        ScanPoint^.Pos.X := ScanPoint^.Pos.X + APoint.X;
        ScanPoint^.Pos.Y := ScanPoint^.Pos.Y + APoint.Y;
        ScanPoint := ScanPoint^.Next;
        end;
end;

function TFPath.GetPathLength: Float;
var ScanPoint: PFPointList;
    PrevScanPoint: PFPointList;
    Length: Float;
begin
     Length := 0;
     if (FirstPoint <> nil)
     then begin
          PrevScanPoint := FirstPoint;
          ScanPoint := FirstPoint^.Next;
          while ( ScanPoint <> nil)
          do begin
             Length := Length + ScanPoint^.Pos.Distance( PrevScanPoint^.Pos);
             PrevScanPoint := ScanPoint;
             ScanPoint := PrevScanPoint^.Next;
             end;
          end;
end;

procedure TFPath.GetFitRect( var AFRect: TFRect; AInitRect: Boolean);
var ScanPoint: PFPointList;
begin
     if ( FirstPoint <> nil)
     then begin
          if AInitRect
          then AFRect.Assign( FirstPoint^.Pos.X, FirstPoint^.Pos.Y, FirstPoint^.Pos.X, FirstPoint^.Pos.Y)
          else AFRect.FitPoint( FirstPoint^.Pos);
          ScanPoint := FirstPoint^.Next;
          while ( ScanPoint <> nil)
          do begin
             AFRect.FitPoint( ScanPoint^.Pos);
             ScanPoint := ScanPoint^.Next;
             end;
          end
     else if AInitRect
          then AFRect.Assign( 0, 0, 0, 0);
end;

procedure TFPath.Expand( AXRate, AYRate: Float);
var ScanPoint: PFPointList;
begin
     ScanPoint := FirstPoint;
     while ( ScanPoint <> nil)
     do begin
        ScanPoint^.Pos.X := ScanPoint^.Pos.X * AXRate;
        ScanPoint^.Pos.Y := ScanPoint^.Pos.Y * AYRate;
        ScanPoint := ScanPoint^.Next;
        end;
end;

procedure TFPath.HashPath( AHashLength: Float);
var OldFirstPoint: PFPointList;
    ScanPoint, PrevScanPoint: PFPointList;
    CurrentLength: Float;

    DeltaX, DeltaY: Float;
    M: Float;
    CurrentX, CurrentY: Float;
    FPointsCount: Float;
    PointsCount: Longint;
begin
     OldFirstPoint := FirstPoint;

     FirstPoint := nil;
     LastPoint := nil;
     Cursor := nil;

     if ( OldFirstPoint <> nil)
     then begin
          PrevScanPoint := OldFirstPoint;
          ScanPoint := OldFirstPoint^.Next;

          AppendPoint( PrevScanPoint^.Pos.X, PrevScanPoint^.Pos.Y);
          while ( ScanPoint <> nil)
          do begin
             CurrentLength := ScanPoint^.Pos.Distance( PrevScanPoint^.Pos);
             if (CurrentLength > 0)
             then begin
                  FPointsCount := CurrentLength / AHashLength;
                  PointsCount := Trunc( FPointsCount) + 1;
                  DeltaX := ( ScanPoint^.Pos.X - PrevScanPoint^.Pos.X) / PointsCount;
                  DeltaY := ( ScanPoint^.Pos.Y - PrevScanPoint^.Pos.Y) / PointsCount;
                  CurrentX := PrevScanPoint^.Pos.X;
                  CurrentY := PrevScanPoint^.Pos.Y;
                  while ( PointsCount > 1)
                  do begin
                     CurrentX := CurrentX + DeltaX;
                     CurrentY := CurrentY + DeltaY;
                     AppendPoint( CurrentX, CurrentY);
                     PointsCount := PointsCount - 1;
                     end;
                  AppendPoint( ScanPoint^.Pos.X, ScanPoint^.Pos.Y);
                  end;
             PrevScanPoint := ScanPoint;
             ScanPoint := ScanPoint^.Next;
             end;
          end;

     while ( OldFirstPoint <> nil)
     do begin
        ScanPoint := OldFirstPoint;
        OldFirstPoint := OldFirstPoint^.Next;
        Dispose( ScanPoint);
        end;
end;

procedure TFPath.SnapPath( AXSnap, AYSnap: Float; ARemovePointsRepitition: Boolean);
var ScanPoint, PrevScanPoint: PFPointList;
    RemovedPoint: PFPointList;
begin
     if (FirstPoint <> nil)
     then begin
          PrevScanPoint := FirstPoint;
          PrevScanPoint^.Pos.X := Int( PrevScanPoint^.Pos.X / AXSnap) * AXSnap;
          PrevScanPoint^.Pos.Y := Int( PrevScanPoint^.Pos.Y / AYSnap) * AYSnap;
          ScanPoint := PrevScanPoint^.Next;
          while ( ScanPoint <> nil)
          do begin
             ScanPoint^.Pos.X := Int( ScanPoint^.Pos.X / AXSnap) * AXSnap;
             ScanPoint^.Pos.Y := Int( ScanPoint^.Pos.Y / AYSnap) * AYSnap;
             if ( ARemovePointsRepitition
                  and (ScanPoint^.Pos.X = PrevScanPoint^.Pos.X)
                  and (ScanPoint^.Pos.Y = PrevScanPoint^.Pos.Y))
             then begin
                  RemovedPoint := ScanPoint;
                  PrevScanPoint^.Next := ScanPoint^.Next;
                  ScanPoint := ScanPoint^.Next;
                  if ( LastPoint = RemovedPoint)
                  then LastPoint := PrevScanPoint;
                  Dispose( RemovedPoint);
                  end
             else begin
                  PrevScanPoint := ScanPoint;
                  ScanPoint := ScanPoint^.Next;
                  end;
             end;
          end;
end;

procedure TFPath.SnapPathY( AYSnap: Float);
var ScanPoint, PrevScanPoint: PFPointList;
    RemovedPoint: PFPointList;
begin
     if (FirstPoint <> nil)
     then begin
          PrevScanPoint := FirstPoint;
          PrevScanPoint^.Pos.Y := Int( PrevScanPoint^.Pos.Y / AYSnap) * AYSnap;
          ScanPoint := PrevScanPoint^.Next;
          while ( ScanPoint <> nil)
          do begin
             ScanPoint^.Pos.Y := Int( ScanPoint^.Pos.Y / AYSnap) * AYSnap;
             if ((ScanPoint^.Pos.X = PrevScanPoint^.Pos.X) and (ScanPoint^.Pos.Y = PrevScanPoint^.Pos.Y))
             then begin
                  RemovedPoint := ScanPoint;
                  PrevScanPoint^.Next := ScanPoint^.Next;
                  ScanPoint := ScanPoint^.Next;
                  if ( LastPoint = RemovedPoint)
                  then LastPoint := PrevScanPoint;
                  Dispose( RemovedPoint);
                  end
             else begin
                  PrevScanPoint := ScanPoint;
                  ScanPoint := ScanPoint^.Next;
                  end;
             end;
          end;
end;

procedure TFPath.SnapPathX( AXSnap: Float);
var ScanPoint, PrevScanPoint: PFPointList;
    RemovedPoint: PFPointList;
begin
     if (FirstPoint <> nil)
     then begin
          PrevScanPoint := FirstPoint;
          PrevScanPoint^.Pos.X := Int( PrevScanPoint^.Pos.X / AXSnap) * AXSnap;
          ScanPoint := PrevScanPoint^.Next;
          while ( ScanPoint <> nil)
          do begin
             ScanPoint^.Pos.X := Int( ScanPoint^.Pos.X / AXSnap) * AXSnap;
             if ((ScanPoint^.Pos.X = PrevScanPoint^.Pos.X) and (ScanPoint^.Pos.Y = PrevScanPoint^.Pos.Y))
             then begin
                  RemovedPoint := ScanPoint;
                  PrevScanPoint^.Next := ScanPoint^.Next;
                  ScanPoint := ScanPoint^.Next;
                  if ( LastPoint = RemovedPoint)
                  then LastPoint := PrevScanPoint;
                  Dispose( RemovedPoint);
                  end
             else begin
                  PrevScanPoint := ScanPoint;
                  ScanPoint := ScanPoint^.Next;
                  end;
             end;
          end;
end;


procedure TFPath.HashByYLevels( AYStep: Float; ASnap: Boolean);
var CurrentY: Float;
    NothingHashed: Boolean;
    ScanPoint, PrevScanPoint: PFPointList;
    NewPoint: PFPointList;
begin
     if ( FirstPoint <> nil)
     then begin
          if ASnap
          then begin
               ScanPoint := FirstPoint;
               while ( ScanPoint <> nil)
               do begin
                  ScanPoint^.Pos.Y := Round( ScanPoint^.Pos.Y / AYStep);
                  ScanPoint := ScanPoint^.Next;
                  end;
               end
          else begin
               ScanPoint := FirstPoint;
               while ( ScanPoint <> nil)
               do begin
                  ScanPoint^.Pos.Y := ScanPoint^.Pos.Y / AYStep;
                  ScanPoint := ScanPoint^.Next;
                  end;
               end;

          CurrentY := 0;
          repeat
                NothingHashed := True;
                PrevScanPoint := FirstPoint;
                ScanPoint := PrevScanPoint^.Next;
                while ( ScanPoint <> nil)
                do begin
                   if ((( PrevScanPoint^.Pos.Y < CurrentY) and ( ScanPoint^.Pos.Y > CurrentY))
                      or (( PrevScanPoint^.Pos.Y > CurrentY) and ( ScanPoint^.Pos.Y < CurrentY)))
                   then begin
                        New( NewPoint);
                        NewPoint^.Pos.Y := CurrentY;
                        NewPoint^.Pos.X := ( CurrentY - ScanPoint^.Pos.Y) * ( ScanPoint^.Pos.X - PrevScanPoint^.Pos.X) /
                                           ( ScanPoint^.Pos.Y - PrevScanPoint^.Pos.Y) + ScanPoint^.Pos.X;
                        NewPoint^.Next := ScanPoint;
                        PrevScanPoint^.Next := NewPoint;
                        NothingHashed := False;
                        end
                   else if (( PrevScanPoint^.Pos.Y = CurrentY) or (ScanPoint^.Pos.Y = CurrentY))
                   then NothingHashed := False;
                   PrevScanPoint := ScanPoint;
                   ScanPoint := ScanPoint^.Next;
                   end;
                CurrentY := CurrentY + 1;
          until NothingHashed;

          CurrentY := 0;
          repeat
                CurrentY := CurrentY - 1;
                NothingHashed := True;
                PrevScanPoint := FirstPoint;
                ScanPoint := PrevScanPoint^.Next;
                while ( ScanPoint <> nil)
                do begin
                   if ((( PrevScanPoint^.Pos.Y < CurrentY) and ( ScanPoint^.Pos.Y > CurrentY))
                      or (( PrevScanPoint^.Pos.Y > CurrentY) and ( ScanPoint^.Pos.Y < CurrentY)))
                   then begin
                        New( NewPoint);
                        NewPoint^.Pos.Y := CurrentY;
                        NewPoint^.Pos.X := ( CurrentY - ScanPoint^.Pos.Y) * ( ScanPoint^.Pos.X - PrevScanPoint^.Pos.X) /
                                           ( ScanPoint^.Pos.Y - PrevScanPoint^.Pos.Y) + ScanPoint^.Pos.X;
                        NewPoint^.Next := ScanPoint;
                        PrevScanPoint^.Next := NewPoint;
                        NothingHashed := False;
                        end
                   else if (( PrevScanPoint^.Pos.Y = CurrentY) or (ScanPoint^.Pos.Y = CurrentY))
                   then NothingHashed := False;
                   PrevScanPoint := ScanPoint;
                   ScanPoint := ScanPoint^.Next;
                   end;
          until NothingHashed;

          PrevScanPoint := FirstPoint;
          ScanPoint := PrevScanPoint^.Next;
          while ( ScanPoint <> nil)
          do begin
             if (( ScanPoint^.Pos.Y <> Int(ScanPoint^.Pos.Y))
                or (( PrevScanPoint^.Pos.X = ScanPoint^.Pos.X) and ( PrevScanPoint^.Pos.Y = ScanPoint^.Pos.Y)))
             then begin
                  ScanPoint := ScanPoint^.Next;
                  if ( ScanPoint = nil)
                  then LastPoint := PrevScanPoint;
                  Dispose( PrevScanPoint^.Next);
                  PrevScanPoint^.Next := ScanPoint;
                  end
             else begin
                  PrevScanPoint := ScanPoint;
                  ScanPoint := ScanPoint^.Next;
                  end;
             end;

          ScanPoint := FirstPoint;
          while ( ScanPoint <> nil)
          do begin
             ScanPoint^.Pos.Y := ScanPoint^.Pos.Y * AYStep;
             ScanPoint := ScanPoint^.Next;
             end;
          end;
end;

procedure TFPath.SnapVerticalMoves( AYStep: Float);
var ScanPoint, PrevScanPoint: PFPointList;
    PrevY: Float;
begin
     if ( FirstPoint <> nil)
     then begin
          ScanPoint := FirstPoint;
          while ( ScanPoint <> nil)
          do begin
             ScanPoint^.Pos.Y := ScanPoint^.Pos.Y / AYStep;
             ScanPoint := ScanPoint^.Next;
             end;

          PrevScanPoint := FirstPoint;
          ScanPoint := PrevScanPoint^.Next;
          PrevY := PrevScanPoint^.Pos.Y;
          while ( ScanPoint <> nil)
          do begin
             if ( ScanPoint^.Pos.Y = PrevY)
             then begin
                  if ( Int( ScanPoint^.Pos.Y) <> ScanPoint^.Pos.Y)
                  then begin
                       PrevScanPoint^.Pos.Y := Round( PrevScanPoint^.Pos.Y);
                       ScanPoint^.Pos.Y := PrevScanPoint^.Pos.Y;
                       end
                  else PrevY := ScanPoint^.Pos.Y;
                  end
             else PrevY := ScanPoint^.Pos.Y;
             PrevScanPoint := ScanPoint;
             ScanPoint := ScanPoint^.Next;
             end;

          ScanPoint := FirstPoint;
          while ( ScanPoint <> nil)
          do begin
             ScanPoint^.Pos.Y := ScanPoint^.Pos.Y * AYStep;
             ScanPoint := ScanPoint^.Next;
             end;
          end;
end;

procedure TFPath.SubtractSteps( AYStep: Float);
var ScanPoint: PFPointList;
    YOffset: Float;
    OriginalY: Float;
begin
     if ( FirstPoint <> nil)
     then begin
          ScanPoint := FirstPoint^.Next;
          YOffset := AYStep;
          while ( ScanPoint <> nil)
          do begin
             ScanPoint^.Pos.Y := ScanPoint^.Pos.Y - YOffset;
             YOffset := YOffset + AYStep;
             ScanPoint := ScanPoint^.Next;
             end;
          end;
end;

procedure TFPath.RemoveLastPointXOffset;
var PointsCount: Longint;
    ScanPoint: PFPointList;
    XError: Float;
    XOffset: Float;
begin
     if ( FirstPoint <> nil)
     then begin
          PointsCount := 0;
          ScanPoint := FirstPoint;
          while ( ScanPoint <> nil)
          do begin
             PointsCount := PointsCount + 1;
             ScanPoint := ScanPoint^.Next;
             end;
          if (PointsCount > 1)
          then begin
               if ( LastPoint <> nil)
               then begin
                    XError := LastPoint^.Pos.X / (PointsCount - 1);
                    ScanPoint := FirstPoint^.Next;
                    XOffset := XError;
                    while ( ScanPoint <> nil)
                    do begin
                       ScanPoint^.Pos.X := ScanPoint^.Pos.X - XOffset;
                       XOffset := XOffset + XError;
                       ScanPoint := ScanPoint^.Next;
                       end;
                    LastPoint^.Pos.X := 0;
                    end;
               end;
          end;
end;

procedure TFPath.RemoveLastPointYOffset;
var PointsCount: Longint;
    ScanPoint: PFPointList;
    YError: Float;
    YOffset: Float;
begin
     if ( FirstPoint <> nil)
     then begin
          PointsCount := 0;
          ScanPoint := FirstPoint;
          while ( ScanPoint <> nil)
          do begin
             PointsCount := PointsCount + 1;
             ScanPoint := ScanPoint^.Next;
             end;
          if (PointsCount > 1)
          then begin
               if ( LastPoint <> nil)
               then begin
                    YError := LastPoint^.Pos.Y / (PointsCount - 1);
                    ScanPoint := FirstPoint^.Next;
                    YOffset := YError;
                    while ( ScanPoint <> nil)
                    do begin
                       ScanPoint^.Pos.Y := ScanPoint^.Pos.Y - YOffset;
                       YOffset := YOffset + YError;
                       ScanPoint := ScanPoint^.Next;
                       end;
                    LastPoint^.Pos.Y := 0;
                    end;
               end;
          end;
end;

(*
function TFPath.HashRectangularly( AMaxXStepLength, AMaxYStepLength, AFeedStepLength: Float): Boolean;
var MutionPoint: PFPointList;
    NextStart, NextEnd: PFPointList;
    TempPoint: PFPointList;
    Center: TFPoint;
    NewPos: TFPoint;
    NewPosFound: Boolean;
label SkipFindingNewPoint;
begin
     if (FirstPoint <> nil)
     then begin
          HashRectangularly := True;

          MutionPoint := FirstPoint;
          NextEnd := MutionPoint^.Next;
          Center.X := MutionPoint^.Pos.X;
          Center.Y := MutionPoint^.Pos.Y + AFeedStepLength;

          while ( NextEnd <> nil)
          do begin
             NextStart := MutionPoint;

             { Repeat while ~NextEnd~ point is in the rectangle of mution range }
             while (not (( NextEnd^.Pos.X >= Center.X + AMaxXStepLength) or ( NextEnd^.Pos.X <= Center.X - AMaxXStepLength)
                   or ( NextEnd^.Pos.Y >= Center.Y + AMaxYStepLength) or ( NextEnd^.Pos.Y <= Center.Y - AMaxYStepLength)))
             do begin
                NextStart := NextEnd;
                NextEnd := NextEnd^.Next;
                if NextEnd = nil
                then begin
                     { Remove points between last created point and last point in the drawn }
                     TempPoint := MutionPoint^.Next;
                     while ( TempPoint <> NextStart)
                     do begin
                        MutionPoint^.Next := TempPoint^.Next;
                        Dispose( TempPoint);
                        TempPoint := MutionPoint^.Next;
                        end;
                     goto SkipFindingNewPoint;
                     end;
                end;

             { Here we must Calculate NEW POINT CORDINATES}

             if ( NextEnd^.Pos.X >= Center.X + AMaxXStepLength)
             then begin
                  NewPos.X := Center.X + AMaxXStepLength;
                  NewPosFound := True;
                  end
             else if ( NextEnd^.Pos.X <= Center.X - AMaxXStepLength)
             then begin
                  NewPos.X := Center.X - AMaxXStepLength;
                  NewPosFound := True;
                  end
             else NewPosFound := False;

             NewPos.Y := ( NewPos.X - NextStart^.Pos.X) * ( NextEnd^.Pos.Y - NextStart^.Pos.Y)
                         / ( NextEnd^.Pos.X - NextStart^.Pos.X) + NextStart^.Pos.Y;

             if (( NewPos.Y > Center.Y + AMaxYStepLength) or ( NewPos.Y < Center.Y - AMaxYStepLength))
             then NewPosFound := False;

             if not NewPosFound
             then begin
                  if ( NextEnd^.Pos.Y >= Center.Y + AMaxYStepLength)
                  then begin
                       NewPos.Y := Center.Y + AMaxYStepLength;
                       NewPosFound := True;
                       end
                  else if ( NextEnd^.Pos.Y <= Center.Y - AMaxYStepLength)
                  then begin
                       NewPos.Y := Center.Y - AMaxYStepLength;
                       NewPosFound := True;
                       end
                  else NewPosFound := False;

                  if NewPosFound
                  then begin
                       NewPos.X := ( NewPos.Y - NextStart^.Pos.Y) * ( NextEnd^.Pos.X - NextStart^.Pos.X)
                                   / ( NextEnd^.Pos.Y - NextStart^.Pos.Y) + NextStart^.Pos.X;
                       if (( NewPos.X > Center.X + AMaxXStepLength) or ( NewPos.X < Center.X - AMaxXStepLength))
                       then NewPosFound := False;
                       end;
                  end;

             if NewPosFound
             then begin
                  New( TempPoint);
                  TempPoint^.Pos := NewPos;
                  TempPoint^.Next := NextEnd;
                  NextStart^.Next := TempPoint;

                  { Here we must remove all points between ~MutionPoint~ and ~TempPoint~}
                  NextStart := MutionPoint^.Next;
                  while ( NextStart <> TempPoint)
                  do begin
                     MutionPoint^.Next := NextStart^.Next;
                     Dispose( NextStart);
                     NextStart := MutionPoint^.Next;
                     end;

                  MutionPoint := TempPoint;
                  Center.X := MutionPoint^.Pos.X;
                  Center.Y := MutionPoint^.Pos.Y + AFeedStepLength;
                  { NOTE: ~NextEnd~ point is the same as it is }
                  end
             else begin
                  NextEnd := nil;
                  HashRectangularly := False;
                  end;
SkipFindingNewPoint:
             end;
          end
     else HashRectangularly := False;
end;
*)

function TFPath.HashRectangularly( AMaxXStepLength,
                                   AMaxYStepLength,
                                   AFeedStepLength: Float;
                                   AMaxSteps: Longint;
                                   var AStepsCountOverflow: Boolean): Boolean;
var MutionPoint: PFPointList;
    NextStart, NextEnd: PFPointList;
    TempPoint: PFPointList;
    Center: TFPoint;
    NewPos: TFPoint;
    NewPosFound: Boolean;
    Count: Longint;
label SkipFindingNewPoint1, SkipFindingNewPoint2;
begin
{$IFDEF _DEBUG}
     WriteLn( DebugFile, 'CALL: HashRectangularly(', AMaxXStepLength:0:10,',',
                                                     AMaxYStepLength:0:10,',',
                                                     AFeedStepLength:0:10,',',
                                                     AMaxSteps,')');
     Flush( DebugFile);
{$ENDIF}


     AStepsCountOverflow := False;
     if (FirstPoint <> nil)
     then begin
          Count := 0;
          if ( AFeedStepLength < AMaxYStepLength)
          then begin
               HashRectangularly := True;

               MutionPoint := FirstPoint;
               NextEnd := MutionPoint^.Next;
               Center.X := MutionPoint^.Pos.X;
               Center.Y := MutionPoint^.Pos.Y + AFeedStepLength;

               while ( NextEnd <> nil)
               do begin
                  NextStart := MutionPoint;

                  { Repeat while ~NextEnd~ point is in the rectangle of mution range }
                  while (not (( NextEnd^.Pos.X >= Center.X + AMaxXStepLength)
                        or ( NextEnd^.Pos.X <= Center.X - AMaxXStepLength)
                        or ( NextEnd^.Pos.Y >= Center.Y + AMaxYStepLength)
                        or ( NextEnd^.Pos.Y <= Center.Y - AMaxYStepLength)))
                  do begin
                     NextStart := NextEnd;
                     NextEnd := NextEnd^.Next;
                     if NextEnd = nil
                     then begin
                          { Remove points between last created point and last point in the drawn }
                          TempPoint := MutionPoint^.Next;
                          while ( TempPoint <> NextStart)
                          do begin
                             MutionPoint^.Next := TempPoint^.Next;
                             Dispose( TempPoint);
                             TempPoint := MutionPoint^.Next;
                             end;
                          goto SkipFindingNewPoint1;
                          end;
                     end;

                  { Here we must Calculate NEW POINT CORDINATES}

                  if ( NextEnd^.Pos.X >= Center.X + AMaxXStepLength)
                  then begin
                       NewPos.X := Center.X + AMaxXStepLength;
                       NewPosFound := True;
                       end
                  else if ( NextEnd^.Pos.X <= Center.X - AMaxXStepLength)
                  then begin
                       NewPos.X := Center.X - AMaxXStepLength;
                       NewPosFound := True;
                       end
                  else NewPosFound := False;

                  if NewPosFound
                  then begin
                       NewPos.Y := ( NewPos.X - NextStart^.Pos.X) * ( NextEnd^.Pos.Y - NextStart^.Pos.Y)
                                   / ( NextEnd^.Pos.X - NextStart^.Pos.X) + NextStart^.Pos.Y;

                       if (( NewPos.Y > Center.Y + AMaxYStepLength) or ( NewPos.Y < Center.Y - AMaxYStepLength))
                       then NewPosFound := False;
                       end;

                  if not NewPosFound
                  then begin
                       if ( NextEnd^.Pos.Y >= Center.Y + AMaxYStepLength)
                       then begin
                            NewPos.Y := Center.Y + AMaxYStepLength;
                            NewPosFound := True;
                            end
                       else if ( NextEnd^.Pos.Y <= Center.Y - AMaxYStepLength)
                       then begin
                            NewPos.Y := Center.Y - AMaxYStepLength;
                            NewPosFound := True;
                            end
                       else NewPosFound := False;

                       if NewPosFound
                       then begin
                            NewPos.X := ( NewPos.Y - NextStart^.Pos.Y) * ( NextEnd^.Pos.X - NextStart^.Pos.X)
                                        / ( NextEnd^.Pos.Y - NextStart^.Pos.Y) + NextStart^.Pos.X;

                            if (( NewPos.X > Center.X + AMaxXStepLength) or ( NewPos.X < Center.X - AMaxXStepLength))
                            then NewPosFound := False;
                            end;
                       end;

                  if NewPosFound
                  then begin
                       Count := Count + 1;

                       New( TempPoint);
                       TempPoint^.Pos := NewPos;
                       TempPoint^.Next := NextEnd;
                       NextStart^.Next := TempPoint;

                       { Here we must remove all points between ~MutionPoint~ and ~TempPoint~}
                       NextStart := MutionPoint^.Next;
                       while ( NextStart <> TempPoint)
                       do begin
                          MutionPoint^.Next := NextStart^.Next;
                          Dispose( NextStart);
                          NextStart := MutionPoint^.Next;
                          end;

                       MutionPoint := TempPoint;
                       Center.X := MutionPoint^.Pos.X;
                       Center.Y := MutionPoint^.Pos.Y + AFeedStepLength;

                       if ( Count > AMaxSteps)
                       then begin
                            AStepsCountOverflow := True;
                            HashRectangularly := False;
                            NextEnd := nil;
                            end
                       { NOTE: ~NextEnd~ point is the same as it is }
                       end
                  else begin
                       NextEnd := nil;
                       HashRectangularly := False;
                       end;
                  SkipFindingNewPoint1:
                  end;
               end
          else begin
               HashRectangularly := True;

               MutionPoint := FirstPoint;
               NextEnd := MutionPoint^.Next;
               Center.X := MutionPoint^.Pos.X;
               Center.Y := MutionPoint^.Pos.Y + AFeedStepLength;

               while ( NextEnd <> nil)
               do begin
                  NextStart := MutionPoint;
                  (*
                  while ( NextEnd^.Pos.Y < Center.Y - AMaxYStepLength)
                  do begin
                     NextStart := NextEnd;
                     NextEnd := NextEnd^.Next;
                     if NextEnd = nil
                     then begin
                          { Remove points between last created point and last point in the drawn }
                          TempPoint := MutionPoint^.Next;
                          while ( TempPoint <> NextStart)
                          do begin
                             MutionPoint^.Next := TempPoint^.Next;
                             Dispose( TempPoint);
                             TempPoint := MutionPoint^.Next;
                             end;
                          goto SkipFindingNewPoint2;
                          end;
                     end;

                  if ( NextEnd^.Pos.Y >= Center.Y + AMaxYStepLength)
                  then NewPos.Y := Center.Y + AMaxYStepLength
                  else NewPos.Y := Center.Y - AMaxYStepLength;

                  NewPos.X := ( NewPos.Y - NextStart^.Pos.Y) * ( NextEnd^.Pos.X - NextStart^.Pos.X)
                              / ( NextEnd^.Pos.Y - NextStart^.Pos.Y) + NextStart^.Pos.X;

                  if (( NewPos.X > Center.X + AMaxXStepLength) or ( NewPos.X < Center.X - AMaxXStepLength))
                  then begin
                       NewPos.Y := Center.Y - AMaxYStepLength;
                       NewPos.X := ( NewPos.Y - NextStart^.Pos.Y) * ( NextEnd^.Pos.X - NextStart^.Pos.X)
                                   / ( NextEnd^.Pos.Y - NextStart^.Pos.Y) + NextStart^.Pos.X;
                       if (( NewPos.X <= Center.X + AMaxXStepLength) and ( NewPos.X >= Center.X - AMaxXStepLength))
                       then NewPosFound := True
                       else NewPosFound := False;
                       end
                  else NewPosFound := True;
                  *)

                  while ( NextEnd^.Pos.Y < Center.Y)
                  do begin
                     NextStart := NextEnd;
                     NextEnd := NextEnd^.Next;
                     if NextEnd = nil
                     then begin
                          { Remove points between last created point and last point in the drawn }
                          TempPoint := MutionPoint^.Next;
                          while ( TempPoint <> NextStart)
                          do begin
                             MutionPoint^.Next := TempPoint^.Next;
                             Dispose( TempPoint);
                             TempPoint := MutionPoint^.Next;
                             end;
                          goto SkipFindingNewPoint2;
                          end;
                     end;

                  NewPos.Y := Center.Y;

                  NewPos.X := ( NewPos.Y - NextStart^.Pos.Y) * ( NextEnd^.Pos.X - NextStart^.Pos.X)
                              / ( NextEnd^.Pos.Y - NextStart^.Pos.Y) + NextStart^.Pos.X;

                  NewPosFound := (( NewPos.X <= Center.X + AMaxXStepLength) and ( NewPos.X >= Center.X - AMaxXStepLength));

                  if NewPosFound
                  then begin
                       Count := Count + 1;

                       New( TempPoint);
                       TempPoint^.Pos := NewPos;
                       TempPoint^.Next := NextEnd;
                       NextStart^.Next := TempPoint;

                       { Here we must remove all points between ~MutionPoint~ and ~TempPoint~}
                       NextStart := MutionPoint^.Next;
                       while ( NextStart <> TempPoint)
                       do begin
                          MutionPoint^.Next := NextStart^.Next;
                          Dispose( NextStart);
                          NextStart := MutionPoint^.Next;
                          end;

                       MutionPoint := TempPoint;
                       Center.X := MutionPoint^.Pos.X;
                       Center.Y := MutionPoint^.Pos.Y + AFeedStepLength;

                       if ( Count > AMaxSteps)
                       then begin
                            AStepsCountOverflow := True;
                            HashRectangularly := False;
                            NextEnd := nil;
                            end
                       { NOTE: ~NextEnd~ point is the same as it is }
                       end
                  else begin
                       NextEnd := nil;
                       HashRectangularly := False;
                       end;
                  SkipFindingNewPoint2:
                  end;
               end;
          end
     else HashRectangularly := False;
{$IFDEF _DEBUG}
     WriteLn( DebugFile, 'EXIT: HashRectangularly');
     Flush( DebugFile);
{$ENDIF}

end;


function TFPath.HashByLevels( AFeedStepLength: Float; var AMaxXStepLength: Float): Boolean;
var MutionPoint: PFPointList;
    NextStart, NextEnd: PFPointList;
    TempPoint: PFPointList;
    Center: TFPoint;
    NewPos: TFPoint;
    XStepLength: Float;
label SkipFindingNewPoint;
begin
{$IFDEF _DEBUG}
     WriteLn( DebugFile, 'CALL: HashByLevels(', AFeedStepLength:0:10,',AMaxXStepLength)');
     Flush( DebugFile);
{$ENDIF}
     AMaxXStepLength := 0;
     if (FirstPoint <> nil)
     then begin
          HashByLevels := True;

          MutionPoint := FirstPoint;
          NextEnd := MutionPoint^.Next;
          Center.X := MutionPoint^.Pos.X;
          Center.Y := MutionPoint^.Pos.Y + AFeedStepLength;

          while ( NextEnd <> nil)
          do begin
             NextStart := MutionPoint;
             (*
             while ( NextEnd^.Pos.Y < Center.Y - AMaxYStepLength)
             do begin
                NextStart := NextEnd;
                NextEnd := NextEnd^.Next;
                if NextEnd = nil
                then begin
                     { Remove points between last created point and last point in the drawn }
                     TempPoint := MutionPoint^.Next;
                     while ( TempPoint <> NextStart)
                     do begin
                        MutionPoint^.Next := TempPoint^.Next;
                        Dispose( TempPoint);
                        TempPoint := MutionPoint^.Next;
                        end;
                     goto SkipFindingNewPoint2;
                     end;
                end;

             if ( NextEnd^.Pos.Y >= Center.Y + AMaxYStepLength)
             then NewPos.Y := Center.Y + AMaxYStepLength
             else NewPos.Y := Center.Y - AMaxYStepLength;

             NewPos.X := ( NewPos.Y - NextStart^.Pos.Y) * ( NextEnd^.Pos.X - NextStart^.Pos.X)
                         / ( NextEnd^.Pos.Y - NextStart^.Pos.Y) + NextStart^.Pos.X;

             if (( NewPos.X > Center.X + AMaxXStepLength) or ( NewPos.X < Center.X - AMaxXStepLength))
             then begin
                  NewPos.Y := Center.Y - AMaxYStepLength;
                  NewPos.X := ( NewPos.Y - NextStart^.Pos.Y) * ( NextEnd^.Pos.X - NextStart^.Pos.X)
                              / ( NextEnd^.Pos.Y - NextStart^.Pos.Y) + NextStart^.Pos.X;
                  if (( NewPos.X <= Center.X + AMaxXStepLength) and ( NewPos.X >= Center.X - AMaxXStepLength))
                  then NewPosFound := True
                  else NewPosFound := False;
                  end
             else NewPosFound := True;
             *)

             while ( NextEnd^.Pos.Y < Center.Y)
             do begin
                NextStart := NextEnd;
                NextEnd := NextEnd^.Next;
                if NextEnd = nil
                then begin
                     { Remove points between last created point and last point in the drawn }
                     TempPoint := MutionPoint^.Next;
                     while ( TempPoint <> NextStart)
                     do begin
                        MutionPoint^.Next := TempPoint^.Next;
                        Dispose( TempPoint);
                        TempPoint := MutionPoint^.Next;
                        end;
                     goto SkipFindingNewPoint;
                     end;
                end;

             NewPos.Y := Center.Y;

             NewPos.X := ( NewPos.Y - NextStart^.Pos.Y) * ( NextEnd^.Pos.X - NextStart^.Pos.X)
                         / ( NextEnd^.Pos.Y - NextStart^.Pos.Y) + NextStart^.Pos.X;

             XStepLength := Abs( NewPos.X - Center.X);

             if ( XStepLength > AMaxXStepLength)
             then AMaxXStepLength := XStepLength;

             New( TempPoint);
             TempPoint^.Pos := NewPos;
             TempPoint^.Next := NextEnd;
             NextStart^.Next := TempPoint;

             { Here we must remove all points between ~MutionPoint~ and ~TempPoint~}
             NextStart := MutionPoint^.Next;
             while ( NextStart <> TempPoint)
             do begin
                MutionPoint^.Next := NextStart^.Next;
                Dispose( NextStart);
                NextStart := MutionPoint^.Next;
                end;

             MutionPoint := TempPoint;
             Center.X := MutionPoint^.Pos.X;
             Center.Y := MutionPoint^.Pos.Y + AFeedStepLength;

             { NOTE: ~NextEnd~ point is the same as it is }
             SkipFindingNewPoint:
             end;
          end
     else HashByLevels := False;
{$IFDEF _DEBUG}
     WriteLn( DebugFile, 'EXIT: HashByLevels');
     Flush( DebugFile);
{$ENDIF}

end;

(*
function TFPath.FindStepsCount( AMaxXStepLength, AMaxYStepLength, AFeedStepLength: Float): Longint;
var NextStartPos: TFPoint;
    NextEnd: PFPointList;
    Center: TFPoint;
    NewPos: TFPoint;
    NewPosFound: Boolean;
    Count: Longint;
label SkipFindingNewPoint;
begin
     Count := 0;
     if (FirstPoint <> nil)
     then begin
          NextEnd := FirstPoint^.Next;
          NextStartPos := FirstPoint^.Pos;
          Center.X := NextStartPos.X;
          Center.Y := NextStartPos.Y + AFeedStepLength;

          while ( NextEnd <> nil)
          do begin
             { Repeat while ~NextEnd~ point is in the rectangle of mution range }
             while (not (( NextEnd^.Pos.X >= Center.X + AMaxXStepLength) or ( NextEnd^.Pos.X <= Center.X - AMaxXStepLength)
                   or ( NextEnd^.Pos.Y >= Center.Y + AMaxYStepLength) or ( NextEnd^.Pos.Y <= Center.Y - AMaxYStepLength)))
             do begin
                NextStartPos := NextEnd^.Pos;
                NextEnd := NextEnd^.Next;
                if NextEnd = nil
                then begin
                     { Remove points between last created point and last point in the drawn }
                     Count := Count + 1;
                     goto SkipFindingNewPoint;
                     end;
                end;

             { Here we must Calculate NEW POINT CORDINATES}

             if ( NextEnd^.Pos.Y >= Center.Y + AMaxYStepLength)
             then begin
                  NewPos.Y := Center.Y + AMaxYStepLength;
                  NewPosFound := True;
                  end
             else if ( NextEnd^.Pos.Y <= Center.Y - AMaxYStepLength)
             then begin
                  NewPos.Y := Center.Y - AMaxYStepLength;
                  NewPosFound := True;
                  end
             else NewPosFound := False;

             if NewPosFound
             then begin
                  NewPos.X := ( NewPos.Y - NextStartPos.Y) * ( NextEnd^.Pos.X - NextStartPos.X)
                              / ( NextEnd^.Pos.Y - NextStartPos.Y) + NextStartPos.X;
                  if (( NewPos.X > Center.X + AMaxXStepLength) or ( NewPos.X < Center.X - AMaxXStepLength))
                  then NewPosFound := False;
                  end;

             if not NewPosFound
             then begin
                  if ( NextEnd^.Pos.X >= Center.X + AMaxXStepLength)
                  then begin
                       NewPos.X := Center.X + AMaxXStepLength;
                       NewPosFound := True;
                       end
                  else if ( NextEnd^.Pos.X <= Center.X - AMaxXStepLength)
                  then begin
                       NewPos.X := Center.X - AMaxXStepLength;
                       NewPosFound := True;
                       end
                  else NewPosFound := False;

                  NewPos.Y := ( NewPos.X - NextStartPos.X) * ( NextEnd^.Pos.Y - NextStartPos.Y)
                              / ( NextEnd^.Pos.X - NextStartPos.X) + NextStartPos.Y;
                  end;

             Center.X := NewPos.X;
             Center.Y := NewPos.Y + AFeedStepLength;
             NextStartPos := NewPos;
             Count := Count + 1;
             { NOTE: ~NextEnd~ point is the same as it is }

SkipFindingNewPoint:
             end;
          end;
     FindStepsCount := Count;
end;
*)

(*
function TFPath.FindStepsCount( AMaxXStepLength, AMaxYStepLength, AFeedStepLength: Float): Longint;
var NextStartPos: TFPoint;
    NextEnd: PFPointList;
    Center: TFPoint;
    NewPos: TFPoint;
    NewPosFound: Boolean;
    Count: Longint;
label SkipFindingNewPoint;
begin
     Count := 0;
     if (FirstPoint <> nil)
     then begin
          NextEnd := FirstPoint^.Next;
          NextStartPos := FirstPoint^.Pos;
          Center.X := NextStartPos.X;
          Center.Y := NextStartPos.Y + AFeedStepLength;

          while ( NextEnd <> nil)
          do begin
             { Repeat while ~NextEnd~ point is in the rectangle of mution range }
             while (not (( NextEnd^.Pos.X >= Center.X + AMaxXStepLength) or ( NextEnd^.Pos.X <= Center.X - AMaxXStepLength)
                   or ( NextEnd^.Pos.Y >= Center.Y + AMaxYStepLength) or ( NextEnd^.Pos.Y <= Center.Y - AMaxYStepLength)))
             do begin
                NextStartPos := NextEnd^.Pos;
                NextEnd := NextEnd^.Next;
                if NextEnd = nil
                then begin
                     { Remove points between last created point and last point in the drawn }
                     Count := Count + 1;
                     goto SkipFindingNewPoint;
                     end;
                end;

             { Here we must Calculate NEW POINT CORDINATES}

             if ( NextEnd^.Pos.Y >= Center.Y + AMaxYStepLength)
             then begin
                  NewPos.Y := Center.Y + AMaxYStepLength;
                  NewPosFound := True;
                  end
             else if ( NextEnd^.Pos.Y <= Center.Y - AMaxYStepLength)
             then begin
                  NewPos.Y := Center.Y - AMaxYStepLength;
                  NewPosFound := True;
                  end
             else NewPosFound := False;

             if NewPosFound
             then begin
                  NewPos.X := ( NewPos.Y - NextStartPos.Y) * ( NextEnd^.Pos.X - NextStartPos.X)
                              / ( NextEnd^.Pos.Y - NextStartPos.Y) + NextStartPos.X;
                  if (( NewPos.X > Center.X + AMaxXStepLength) or ( NewPos.X < Center.X - AMaxXStepLength))
                  then NewPosFound := False;
                  end;

             if not NewPosFound
             then begin
                  if ( NextEnd^.Pos.X >= Center.X + AMaxXStepLength)
                  then begin
                       NewPos.X := Center.X + AMaxXStepLength;
                       NewPosFound := True;
                       end
                  else if ( NextEnd^.Pos.X <= Center.X - AMaxXStepLength)
                  then begin
                       NewPos.X := Center.X - AMaxXStepLength;
                       NewPosFound := True;
                       end
                  else NewPosFound := False;

                  NewPos.Y := ( NewPos.X - NextStartPos.X) * ( NextEnd^.Pos.Y - NextStartPos.Y)
                              / ( NextEnd^.Pos.X - NextStartPos.X) + NextStartPos.Y;
                  end;

             Center.X := NewPos.X;
             Center.Y := NewPos.Y + AFeedStepLength;
             NextStartPos := NewPos;
             Count := Count + 1;
             { NOTE: ~NextEnd~ point is the same as it is }

SkipFindingNewPoint:
             end;
          end;
     FindStepsCount := Count;
end;
*)

function TFPath.GetStepsCount: Longint;
var ScanPoint: PFPointList;
    Count: Longint;
begin
     Count := 0;
     ScanPoint := FirstPoint;
     while ( ScanPoint <> nil)
     do begin
        Count := Count + 1;
        ScanPoint := ScanPoint^.Next;
        end;
     if Count > 0
     then GetStepsCount := Count - 1
     else GetStepsCount := 0
end;

function TFPath.FindStepsCount_( AMaxXStepLength,
                                AMaxYStepLength,
                                AFeedStepLength: Float;
                                AMaxSteps: Longint;
                                var AStepsCountOverflow: Boolean): Longint;

var TempPath: PFPath;
    Count: Longint;
begin
     TempPath := New( PFPath, Create);
     AppendToPath( TempPath);
     TempPath^.HashRectangularly( AMaxXStepLength,
                                  AMaxYStepLength,
                                  AFeedStepLength,
                                  AMaxSteps,
                                  AStepsCountOverflow);
     if AStepsCountOverflow
     then Count := AMaxSteps + 1
     else Count := TempPath^.GetStepsCount;
     TempPath^.Free;
     FindStepsCount_ := Count;
end;

function TFPath.FindStepsCount( AMaxXStepLength,
                                AMaxYStepLength,
                                AFeedStepLength: Float;
                                AMaxSteps: Longint;
                                var AStepsCountOverflow: Boolean): Longint;
var NextStartPos: TFPoint;
    NextEnd: PFPointList;
    Center: TFPoint;
    NewPos: TFPoint;
    NewPosFound: Boolean;
    Count: Longint;
label SkipFindingNewPoint1, SkipFindingNewPoint2;
begin
     AStepsCountOverflow := False;
     Count := 0;
     if (FirstPoint <> nil)
     then begin
          Count := 0;
          if ( AFeedStepLength < AMaxYStepLength)
          then begin

               NextStartPos := FirstPoint^.Pos;
               NextEnd := FirstPoint^.Next;
               Center.X := NextStartPos.X;
               Center.Y := NextStartPos.Y + AFeedStepLength;

               while ( NextEnd <> nil)
               do begin

                  { Repeat while ~NextEnd~ point is in the rectangle of mution range }
                  while (not (( NextEnd^.Pos.X >= Center.X + AMaxXStepLength)
                        or ( NextEnd^.Pos.X <= Center.X - AMaxXStepLength)
                        or ( NextEnd^.Pos.Y >= Center.Y + AMaxYStepLength)
                        or ( NextEnd^.Pos.Y <= Center.Y - AMaxYStepLength)))
                  do begin
                     NextStartPos := NextEnd^.Pos;
                     NextEnd := NextEnd^.Next;
                     if NextEnd = nil
                     then begin
                          { Remove points between last created point and last point in the drawn }
                          Count := Count + 1;
                          goto SkipFindingNewPoint1;
                          end;
                     end;

                  { Here we must Calculate NEW POINT CORDINATES}

                  if ( NextEnd^.Pos.X >= Center.X + AMaxXStepLength)
                  then begin
                       NewPos.X := Center.X + AMaxXStepLength;
                       NewPosFound := True;
                       end
                  else if ( NextEnd^.Pos.X <= Center.X - AMaxXStepLength)
                  then begin
                       NewPos.X := Center.X - AMaxXStepLength;
                       NewPosFound := True;
                       end
                  else NewPosFound := False;

                  if NewPosFound
                  then begin
                       NewPos.Y := ( NewPos.X - NextStartPos.X) * ( NextEnd^.Pos.Y - NextStartPos.Y)
                                   / ( NextEnd^.Pos.X - NextStartPos.X) + NextStartPos.Y;

                       if (( NewPos.Y > Center.Y + AMaxYStepLength) or ( NewPos.Y < Center.Y - AMaxYStepLength))
                       then NewPosFound := False;
                       end;

                  if not NewPosFound
                  then begin
                       if ( NextEnd^.Pos.Y >= Center.Y + AMaxYStepLength)
                       then begin
                            NewPos.Y := Center.Y + AMaxYStepLength;
                            NewPosFound := True;
                            end
                       else if ( NextEnd^.Pos.Y <= Center.Y - AMaxYStepLength)
                       then begin
                            NewPos.Y := Center.Y - AMaxYStepLength;
                            NewPosFound := True;
                            end
                       else NewPosFound := False;

                       if NewPosFound
                       then begin
                            NewPos.X := ( NewPos.Y - NextStartPos.Y) * ( NextEnd^.Pos.X - NextStartPos.X)
                                             / ( NextEnd^.Pos.Y - NextStartPos.Y) + NextStartPos.X;

                            if (( NewPos.X > Center.X + AMaxXStepLength) or ( NewPos.X < Center.X - AMaxXStepLength))
                            then NewPosFound := False;
                            end;
                       end;

                  if NewPosFound
                  then begin
                       Count := Count + 1;

                       { Here we must remove all points between ~MutionPoint~ and ~TempPoint~}
                       NextStartPos := NewPos;

                       Center.X := NextStartPos.X;
                       Center.Y := NextStartPos.Y + AFeedStepLength;

                       if ( Count > AMaxSteps)
                       then begin
                            AStepsCountOverflow := True;
                            NextEnd := nil;
                            end
                       { NOTE: ~NextEnd~ point is the same as it is }
                       end
                  else NextEnd := nil;
                  SkipFindingNewPoint1:
                  end;
               end
          else begin

               NextStartPos := FirstPoint^.Pos;
               NextEnd := FirstPoint^.Next;
               Center.X := NextStartPos.X;
               Center.Y := NextStartPos.Y + AFeedStepLength;

               while ( NextEnd <> nil)
               do begin
                  (*
                  while ( NextEnd^.Pos.Y < Center.Y - AMaxYStepLength)
                  do begin
                     NextStartPos := NextEnd^.Pos;
                     NextEnd := NextEnd^.Next;
                     if NextEnd = nil
                     then begin
                          { Remove points between last created point and last point in the drawn }
                          Count := Count + 1;
                          goto SkipFindingNewPoint2;
                          end;
                     end;

                  if ( NextEnd^.Pos.Y >= Center.Y + AMaxYStepLength)
                  then NewPos.Y := Center.Y + AMaxYStepLength
                  else NewPos.Y := Center.Y - AMaxYStepLength;

                  NewPos.X := ( NewPos.Y - NextStartPos.Y) * ( NextEnd^.Pos.X - NextStartPos.X)
                              / ( NextEnd^.Pos.Y - NextStartPos.Y) + NextStartPos.X;

                  if (( NewPos.X > Center.X + AMaxXStepLength) or ( NewPos.X < Center.X - AMaxXStepLength))
                  then begin
                       NewPos.Y := Center.Y - AMaxYStepLength;
                       NewPos.X := ( NewPos.Y - NextStartPos.Y) * ( NextEnd^.Pos.X - NextStartPos.X)
                                   / ( NextEnd^.Pos.Y - NextStartPos.Y) + NextStartPos.X;
                       if (( NewPos.X <= Center.X + AMaxXStepLength) and ( NewPos.X >= Center.X - AMaxXStepLength))
                       then NewPosFound := True
                       else NewPosFound := False;
                       end
                  else NewPosFound := True;
                  *)

                  while ( NextEnd^.Pos.Y < Center.Y)
                  do begin
                     NextStartPos := NextEnd^.Pos;
                     NextEnd := NextEnd^.Next;
                     if NextEnd = nil
                     then begin
                          { Remove points between last created point and last point in the drawn }
                          Count := Count + 1;
                          goto SkipFindingNewPoint2;
                          end;
                     end;

                  NewPos.Y := Center.Y;

                  NewPos.X := ( NewPos.Y - NextStartPos.Y) * ( NextEnd^.Pos.X - NextStartPos.X)
                              / ( NextEnd^.Pos.Y - NextStartPos.Y) + NextStartPos.X;

                  NewPosFound := (( NewPos.X <= Center.X + AMaxXStepLength) and ( NewPos.X >= Center.X - AMaxXStepLength));

                  if NewPosFound
                  then begin
                       Count := Count + 1;

                       NextStartPos := NewPos;

                       Center.X := NextStartPos.X;
                       Center.Y := NextStartPos.Y + AFeedStepLength;

                       if ( Count > AMaxSteps)
                       then begin
                            AStepsCountOverflow := True;
                            NextEnd := nil;
                            end
                       { NOTE: ~NextEnd~ point is the same as it is }
                       end
                  else begin
                       NextEnd := nil;
                       end;
                  SkipFindingNewPoint2:
                  end;
               end;
          end;
     FindStepsCount := Count;
end;


function TFPath.GetMutionLength: Float;
var Length: Float;
    ScanPoint, PrevScanPoint: PFPointList;
    XLength, YLength: Float;
begin
     if ( FirstPoint <> nil)
     then begin
          Length := 0;
          PrevScanPoint := FirstPoint;
          ScanPoint := PrevScanPoint^.Next;
          while ( ScanPoint <> nil)
          do begin
             XLength := Abs( ScanPoint^.Pos.X - PrevScanPoint^.Pos.X);
             YLength := Abs( ScanPoint^.Pos.Y - PrevScanPoint^.Pos.Y);
             if ( XLength >= YLength)
             then Length := Length + XLength
             else Length := Length + YLength;
             PrevScanPoint := ScanPoint;
             ScanPoint := ScanPoint^.Next;
             end;
          GetMutionLength := Length;
          end
     else GetMutionLength := 0;
end;

function TFPath.GetMutionLengthOnX: Float;
var Length: Float;
    ScanPoint, PrevScanPoint: PFPointList;
begin
     if ( FirstPoint <> nil)
     then begin
          Length := 0;
          PrevScanPoint := FirstPoint;
          ScanPoint := PrevScanPoint^.Next;
          while ( ScanPoint <> nil)
          do begin
             Length := Length + Abs( ScanPoint^.Pos.X - PrevScanPoint^.Pos.X);
             PrevScanPoint := ScanPoint;
             ScanPoint := ScanPoint^.Next;
             end;
          GetMutionLengthOnX := Length;
          end
     else GetMutionLengthOnX := 0;
end;

function TFPath.GetMutionLengthOnY: Float;
var Length: Float;
    ScanPoint, PrevScanPoint: PFPointList;
begin
     if ( FirstPoint <> nil)
     then begin
          Length := 0;
          PrevScanPoint := FirstPoint;
          ScanPoint := PrevScanPoint^.Next;
          while ( ScanPoint <> nil)
          do begin
             Length := Length + Abs( ScanPoint^.Pos.Y - PrevScanPoint^.Pos.Y);
             PrevScanPoint := ScanPoint;
             ScanPoint := ScanPoint^.Next;
             end;
          GetMutionLengthOnY := Length;
          end
     else GetMutionLengthOnY := 0;
end;

function TFPath.GetMaxXStep: Float;
var MaxXStep, XStep: Float;
    ScanPoint, PrevScanPoint: PFPointList;
begin
     if ( FirstPoint <> nil)
     then begin
          MaxXStep := 0;
          PrevScanPoint := FirstPoint;
          ScanPoint := PrevScanPoint^.Next;
          while ( ScanPoint <> nil)
          do begin
             XStep := Abs( ScanPoint^.Pos.X - PrevScanPoint^.Pos.X);
             if XStep > MaxXStep
             then MaxXStep := XStep;
             PrevScanPoint := ScanPoint;
             ScanPoint := ScanPoint^.Next;
             end;
          GetMaxXStep := MaxXStep;
          end
     else GetMaxXStep := 0;
end;

function TFPath.GetMaxYStep: Float;
var MaxYStep, YStep: Float;
    ScanPoint, PrevScanPoint: PFPointList;
begin
     if ( FirstPoint <> nil)
     then begin
          MaxYStep := 0;
          PrevScanPoint := FirstPoint;
          ScanPoint := PrevScanPoint^.Next;
          while ( ScanPoint <> nil)
          do begin
             YStep := Abs( ScanPoint^.Pos.Y - PrevScanPoint^.Pos.Y);
             if YStep > MaxYStep
             then MaxYStep := YStep;
             PrevScanPoint := ScanPoint;
             ScanPoint := ScanPoint^.Next;
             end;
          GetMaxYStep := MaxYStep;
          end
     else GetMaxYStep := 0;
end;

const MAXTRYS = 1000;

function TFPath.ProduceHeadPath( AFeedStepLength, AMaxXStepLength, AMaxYStepLength: Float; ATestMaxSteps: Boolean): Boolean;
var ProbeHeadStep: Float;
    RequiredStepsCount: Longint;
    FRequiredStepsCount: Float;
    MinimumYStepLength, MaximumYStepLength: Float;
    SearchXStepLength, SearchYStepLength: Float;
    XToYRate: Float;
    Count: Longint;
    StopSearch: Boolean;
    Trys: Integer;
    OverFlow: Boolean;
    PathHashSucceed: Boolean;
    MaxXStepLength: Float;
begin
     ProduceHeadPath := False;
     if ( LastPoint <> nil)
     then begin
          RemoveLastPointXOffset;
          if (( LastPoint^.Pos.Y > 0) and (LastPoint^.Pos.X = 0))
          then begin
               FRequiredStepsCount := Abs( LastPoint^.Pos.Y / AFeedStepLength);
               RequiredStepsCount := Trunc( FRequiredStepsCount);
               if ( FRequiredStepsCount > RequiredStepsCount)
               then RequiredStepsCount := RequiredStepsCount + 1;
               MaximumYStepLength := 10 * GetMutionLength / RequiredStepsCount;
               MinimumYStepLength := AFeedStepLength;
               if ( MaximumYStepLength > MinimumYStepLength)
               then begin
                    XToYRate := AMaxXStepLength / AMaxYStepLength;
                    StopSearch := False;
                    Trys := 1;
                    repeat
{$IFDEF _DEBUG}
                          WriteLn( DebugFile, 'TRY NO = ', Trys);
                          Flush( DebugFile);
{$ENDIF}
                          SearchYStepLength := ( MinimumYStepLength + MaximumYStepLength) / 2;
                          SearchXStepLength := SearchYStepLength * XToYRate;
                          if ( Abs(SearchYStepLength - AFeedStepLength) > 1.0E-10)
                          then begin
                               Count := FindStepsCount( SearchXStepLength,
                                                        SearchYStepLength,
                                                        AFeedStepLength,
                                                        RequiredStepsCount + 1,
                                                        OverFlow);

                               if ( Count > ( RequiredStepsCount + 0))
                               then MinimumYStepLength := SearchYStepLength
                               else if ( Count < ( RequiredStepsCount - 0))
                               then MaximumYStepLength := SearchYStepLength
                               else StopSearch := True;
                               if Trys <= MAXTRYS
                               then Trys := Trys + 1
                               else StopSearch := True;
                               end
                          else begin
                               Trys := MAXTRYS + 1;
                               StopSearch := True;
                               end;
                    until StopSearch;

                    if ( Trys <= MAXTRYS)
                    then begin
                         PathHashSucceed := HashRectangularly( SearchXStepLength,
                                                               SearchYStepLength,
                                                               AFeedStepLength,
                                                               RequiredStepsCount + 1,
                                                               OverFlow);
                         end
                    else begin
                         PathHashSucceed := HashByLevels( AFeedStepLength, MaxXStepLength);
                         SearchXStepLength := MaxXStepLength;
                         SearchYStepLength := 0;
                         end;

                    if PathHashSucceed
                    then begin
                         SubtractSteps( AFeedStepLength);
                         LastPoint^.Pos.X := 0;
                         LastPoint^.Pos.Y := 0;
                         if ATestMaxSteps
                         then begin
                              if (( AMaxXStepLength > SearchXStepLength)
                                 and ( AMaxYStepLength > SearchYStepLength))
                              then ProduceHeadPath := True;
                              end
                         else ProduceHeadPath := True;
                         end
                    else ProduceHeadPath := False;
                    end
               end;
          end;
end;

function TFPath.ProduceDeltaPath( StepsPerXUnit, StepsPerYUnit: Longint): PRPath;
var TempPath: PFPath;
    DeltasPath: PRPath;
begin
     TempPath := New( PFPath, Create);
     AppendToPath( TempPath);
     TempPath^.Expand( StepsPerXUnit, StepsPerYUnit);
     TempPath^.SnapPath( 1, 1, False);
     DeltasPath := New( PRPath, Create);
     TempPath^.AppendToRPath( DeltasPath, False);
     TempPath^.Free;
     ProduceDeltaPath := DeltasPath;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TJustFrame.Create( R: TRect);
begin
     inherited Create( R);
     State := sfVisible or sfEnabled;
     Options := ofFramed {or ofSelectable}{or ofFirstClick};
     EventMask := $FF;
end;

procedure TJustFrame.Draw;
begin
     BeginDraw;
     Rectangle( 0, 0, Size.X - 1, Size.Y - 1);
     Draw3DInFrame( 0, 0, Size.X - 1, Size.Y - 1, clr3D0, clr3D1, clr3D2, clr3D3);
     EndDraw;
end;

procedure TJustFrame.GetClientRect( var R: TRect);
begin
     R.A.Assign( 2, 2);
     R.B.Assign( Size.X - 2, Size.Y - 2);
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TCanvas.Create( R: TRect);
begin
     inherited Create( R);
     State := sfVisible or sfEnabled or sfFocused or sfSelected;
     EventMask := evMouse;

     CanvasInfo.Snap := True;
     CanvasInfo.Zoom := 0.5;
     CanvasInfo.Offset.Assign(0, 0);
     CanvasInfo.GridSize.Assign( 10, 10);
     CanvasInfo.SnapGridSize.Assign( 2.5, 2.5);
     CanvasInfo.GridStyle := 1;
     CanvasInfo.LimitsOffset := 0;
end;

destructor TCanvas.Destroy;
begin
     inherited Destroy;
end;

procedure TCanvas.HandleEvent( var E: TEvent);
var GridEditDlg: PGridEditDlg;
begin
     if ( E.What = evCommand)
     then begin
          {if ( Parent <> nil)
          then if Parent^.GetState( sfFocused)
               then begin}
                    case E.Command
                    of cmZoomIn: begin
                                 if (CanvasInfo.Zoom > 0.01)
                                 then begin
                                      CanvasInfo.Zoom := CanvasInfo.Zoom / 2;
                                      Draw;
                                      end;
                                 ClearEvent( E);
                                 end;
                       cmZoomOut: begin
                                  if (CanvasInfo.Zoom < 20)
                                  then begin
                                       CanvasInfo.Zoom := CanvasInfo.Zoom * 2;
                                       Draw;
                                       end;
                                  ClearEvent( E);
                                  end;
                       cmZoom11: begin
                                 CanvasInfo.Zoom := 1;
                                 Draw;
                                 ClearEvent( E);
                                 end;
                       cmZoomFit: begin
                                  Scroll( 9);
                                  ClearEvent( E);
                                  end;
                       cmScrollToCenter: begin
                                         Scroll( 0);
                                         {Delay(100);}
                                         ClearEvent( E);
                                         end;
                       cmScrollUp: begin
                                   Scroll( 4);
                                   {Delay(100);}
                                   ClearEvent( E);
                                   end;
                       cmScrollDown: begin
                                     Scroll( 2);
                                     {Delay(100);}
                                     ClearEvent( E);
                                     end;
                       cmScrollLeft: begin
                                     Scroll( 3);
                                     {Delay(100);}
                                     ClearEvent( E);
                                     end;
                       cmScrollRight: begin
                                      Scroll( 1);
                                      {Delay(100);}
                                      ClearEvent( E);
                                      end;
                       cmGridStyle: begin
                                     CanvasInfo.GridStyle := ( CanvasInfo.GridStyle + 1) mod 3;
                                     ClearEvent( E);
                                     Update;
                                     end;
                       cmEditGrid: begin
                                   GridEditDlg := New( PGridEditDlg, Create( @Self));
                                   GridEditDlg^.ExecuteDlg( @Self);
                                   Update;
                                   GridEditDlg^.Free;
                                   ClearEvent( E);
                                   end;
                       {end;}
             end;
          end
     else if ( E.What = evKeyPress)
     then begin
          case E.KeyInfo.ScanCode
          of keyUP: begin
                    {Arrow Up}
                    E.What := evCommand;
                    E.Command := cmScrollUp;
                    PutEvent( E);
                    ClearEvent( E);
                    end;
             keyDOWN: begin
                      {Arrow Down}
                      E.What := evCommand;
                      E.Command := cmScrollDown;
                      PutEvent( E);
                      ClearEvent( E);
                      end;
             keyLEFT: begin
                      {Arrow Left}
                      E.What := evCommand;
                      E.Command := cmScrollLeft;
                      PutEvent( E);
                      ClearEvent( E);
                      end;
             keyRIGHT: begin
                       {Arrow Right}
                       E.What := evCommand;
                       E.Command := cmScrollRight;
                       PutEvent( E);
                       ClearEvent( E);
                       end;
             keyHOME: begin
                      {Home}
                      E.What := evCommand;
                      E.Command := cmScrollToCenter;
                      PutEvent( E);
                      ClearEvent( E);
                      end;
             keyEND: begin
                     {End}
                     E.What := evCommand;
                     E.Command := cmZoomFit;
                     PutEvent( E);
                     ClearEvent( E);
                     end;
             {keyPAGEUP: begin
                        end;
             keyPAGEDOWN: begin
                          end;
             keyDEL: begin
                     end;
             keyINSERT: begin
                        end;
             keyBACKSPACE: begin
                           E.What := evCommand;
                           E.Command := cmDeleteLastShape;
                           PutEvent( E);
                           ClearEvent( E);
                           end;}
             else
                 case E.KeyInfo.CharCode
                 of '+': begin
                         E.What := evCommand;
                         E.Command := cmZoomIn;
                         PutEvent( E);
                         ClearEvent( E);
                         end;
                     '-': begin
                          E.What := evCommand;
                          E.Command := cmZoomOut;
                          PutEvent( E);
                          ClearEvent( E);
                          end;
                     end;
             end;
          end;
end;

procedure TCanvas.DrawGrid;
var Visible: TFRect;
    P: TPoint;
    LP: TFPoint;
    X, Y: Longint;
    SP: TFPoint;
    Color: Byte;
begin
     P.Assign( 0, 0);
     ConvertToLogicalPos( P, Visible.A, False);
     ConvertToLogicalPos( Size, Visible.B, False);

     case CanvasInfo.GridStyle
     of 1: begin
           SetPColor( clrGRID1);
           if (( CanvasInfo.GridSize.X / CanvasInfo.Zoom) >= 4)
           then begin
                LP.X := Int( Visible.A.X / CanvasInfo.GridSize.X) * CanvasInfo.GridSize.X;
                SP.X := LP.X;
                while (SP.X < Visible.B.X)
                do begin
                   ConvertToCanvasX( SP.X, X);
                   Line( X, 0, X, Size.Y);
                   SP.X := SP.X + CanvasInfo.GridSize.X;
                   end;
                end;

           if (( CanvasInfo.GridSize.Y / CanvasInfo.Zoom) >= 4)
           then begin
                LP.Y := Int( Visible.A.Y / CanvasInfo.GridSize.Y) * CanvasInfo.GridSize.Y;
                SP.Y := LP.Y;
                while (SP.Y < Visible.B.Y)
                do begin
                   ConvertToCanvasY( SP.Y, Y);
                   Line( 0, Y, Size.X, Y);
                   SP.Y := SP.Y + CanvasInfo.GridSize.Y;
                   end;
                end;
           end;
        2: begin
           if ((( CanvasInfo.GridSize.X / CanvasInfo.Zoom) >= 4) and (( CanvasInfo.GridSize.Y / CanvasInfo.Zoom) >= 4))
           then begin
                Color := GetPColor( clrGRID2);
                LP.X := Int( Visible.A.X / CanvasInfo.GridSize.X) * CanvasInfo.GridSize.X;
                SP.X := LP.X;
                while (SP.X < Visible.B.X)
                do begin
                   ConvertToCanvasX( SP.X, X);
                   LP.Y := Int( Visible.A.Y / CanvasInfo.GridSize.Y) * CanvasInfo.GridSize.Y;
                   SP.Y := LP.Y;
                   while (SP.Y < Visible.B.Y)
                   do begin
                      ConvertToCanvasY( SP.Y, Y);
                      PutPixel( X, Y, Color);
                      SP.Y := SP.Y + CanvasInfo.GridSize.Y;
                      end;
                   SP.X := SP.X + CanvasInfo.GridSize.X;
                   end;
                end;
           end;
        end;
end;


procedure TCanvas.Draw;
begin
     BeginDraw;
     SetFillPattern( SolidPattern, 0);
     Bar( 0, 0, Size.X - 1, Size.Y - 1);
     DrawGrid;
     EndDraw;
end;

procedure TCanvas.GetFitRect( var FR: TFRect);
begin
     FR.A.Assign( -1, -1);
     FR.B.Assign( +1, +1);
end;

procedure TCanvas.Scroll( ADir: Integer);
var LSize: TFPoint;
    LRect: TFRect;
    F1, F2: Float;
begin
     ConvertToLogicalSize( Size, LSize);
     case ADir
     of 0: begin
           CanvasInfo.Offset.X := 0;
           CanvasInfo.Offset.Y := 0;
           CanvasInfo.Zoom := 1;
           end;
        1: begin
           CanvasInfo.Offset.X := CanvasInfo.Offset.X + LSize.X / 10;
           end;
        2: begin
           CanvasInfo.Offset.Y := CanvasInfo.Offset.Y + LSize.Y / 10;
           end;
        3: begin
           CanvasInfo.Offset.X := CanvasInfo.Offset.X - LSize.X / 10;
           end;
        4: begin
           CanvasInfo.Offset.Y := CanvasInfo.Offset.Y - LSize.Y / 10;
           end;
        5: begin
           CanvasInfo.Offset.X := CanvasInfo.Offset.X + LSize.X * 0.9;
           end;
        6: begin
           CanvasInfo.Offset.Y := CanvasInfo.Offset.Y + LSize.Y * 0.9;
           end;
        7: begin
           CanvasInfo.Offset.X := CanvasInfo.Offset.X - LSize.X * 0.9;
           end;
        8: begin
           CanvasInfo.Offset.Y := CanvasInfo.Offset.Y - LSize.Y * 0.9;
           end;
        9: begin
           GetFitRect( LRect);
           CanvasInfo.Offset.X := ( LRect.A.X + LRect.B.X) / 2;
           CanvasInfo.Offset.Y := ( LRect.A.Y + LRect.B.Y) / 2;
           ConvertToLogicalSize( Size, LSize);
           F1 := ( LRect.B.X - LRect.A.X) / Size.X;
           F2 := ( LRect.B.Y - LRect.A.Y) / Size.Y;
           if F1 > F2
           then CanvasInfo.Zoom := F1 * 1.1
           else CanvasInfo.Zoom := F2 * 1.1;
           if ( CanvasInfo.Zoom < 0.05)
           then CanvasInfo.Zoom := 0.05;
           end;
        end;
     Update;
end;

procedure TCanvas.ConvertToLogicalX( var AX: Longint; var AFX: Float; ASnap: Boolean);
begin
     AFX := ((AX - Size.X div 2) * CanvasInfo.Zoom) + CanvasInfo.Offset.X;
     if ASnap
     then AFX := Round(AFX / CanvasInfo.SnapGridSize.X) * CanvasInfo.SnapGridSize.X;
end;

procedure TCanvas.ConvertToLogicalY( var AY: Longint; var AFY: Float; ASnap: Boolean);
begin
     AFY := ((AY - Size.Y div 2) * CanvasInfo.Zoom) + CanvasInfo.Offset.Y;
     if ASnap
     then AFY := Round(AFY / CanvasInfo.SnapGridSize.Y) * CanvasInfo.SnapGridSize.Y;
end;

procedure TCanvas.ConvertToCanvasX( var AFX: Float; var AX: Longint);
begin
     AX := Round(( AFX - CanvasInfo.Offset.X) / CanvasInfo.Zoom) + Size.X div 2;
end;

procedure TCanvas.ConvertToCanvasY( var AFY: Float; var AY: Longint);
begin
     AY := Round(( AFY - CanvasInfo.Offset.Y) / CanvasInfo.Zoom) + Size.Y div 2;
end;

procedure TCanvas.ConvertToLogicalPos( var APoint: TPoint; var AFPoint: TFPoint; ASnap: Boolean);
begin
     AFPoint.X := ((APoint.X - Size.X div 2) * CanvasInfo.Zoom) + CanvasInfo.Offset.X;
     AFPoint.Y := ((APoint.Y - Size.Y div 2) * CanvasInfo.Zoom) + CanvasInfo.Offset.Y;
     if ASnap
     then begin
          AFPoint.X := Round(AFPoint.X / CanvasInfo.SnapGridSize.X) * CanvasInfo.SnapGridSize.X;
          AFPoint.Y := Round(AFPoint.Y / CanvasInfo.SnapGridSize.Y) * CanvasInfo.SnapGridSize.Y;
          end;
end;

procedure TCanvas.ConvertToLogicalLength( ALength: Longint; var AFLength: Float);
begin
     AFLength := ALength * CanvasInfo.Zoom;
end;

procedure TCanvas.ConvertToLogicalSize( var APoint: TPoint; var AFPoint: TFPoint);
begin
     AFPoint.X := APoint.X * CanvasInfo.Zoom;
     AFPoint.Y := APoint.Y * CanvasInfo.Zoom;
end;

procedure TCanvas.ConvertToCanvasPos( var AFPoint: TFPoint; var APoint: TPoint);
begin
     APoint.X := Round(( AFPoint.X - CanvasInfo.Offset.X) / CanvasInfo.Zoom) + Size.X div 2;
     APoint.Y := Round(( AFPoint.Y - CanvasInfo.Offset.Y) / CanvasInfo.Zoom) + Size.Y div 2;
end;

procedure TCanvas.ConvertToCanvasPosEx( var AIPoint: TPoint; var APoint: TPoint);
var FPoint: TFPoint;
begin
     FPoint.Assign( AIPoint.X, AIPoint.Y);
     ConvertToCanvasPos( FPoint, APoint);
end;

procedure TCanvas.ConvertToCanavsLength( AFLength: Float; var ALength: Longint);
begin
     ALength := Round(AFLength / CanvasInfo.Zoom);
end;

procedure TCanvas.ConvertToCanavsSize( var AFPoint: TFPoint; var APoint: TPoint);
begin
     APoint.X := Round( AFPoint.X / CanvasInfo.Zoom);
     APoint.Y := Round( AFPoint.Y / CanvasInfo.Zoom);
end;

procedure TCanvas.GetAvailableCommands( var ACommands: TCommandsSet);
begin
     ACommands := ACommands + [cmZoomIn, cmZoomOut, cmZoom11, cmZoomFit, cmScrollToCenter, cmGridStyle, cmEditGrid];
     inherited GetAvailableCommands( ACommands);
end;

(*
function TCanvas.CommandAvailable( ACommand: Word): Boolean;
var Enabled: Boolean;
begin
     {
     Enabled := False;
     if ( Parent <> nil)
     then if Parent^.GetState( sfFocused)
          then begin
               case ACommand
               of cmZoomIn,
                  cmZoomOut,
                  cmZoom11,
                  cmZoomFit,
                  cmScrollToCenter: Enabled := True;
                  end;
               end;
     if not Enabled
     then CommandAvailable := inherited CommandAvailable( ACommand)
     else CommandAvailable := True;
     }
     Enabled := False;
     case ACommand
     of cmZoomIn,
        cmZoomOut,
        cmZoom11,
        cmZoomFit,
        cmScrollToCenter: Enabled := True;
        end;
     if not Enabled
     then CommandAvailable := inherited CommandAvailable( ACommand)
     else CommandAvailable := True;
end;
*)

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TGridEditDlg.Create( ACanvas: PCanvas);
var P: TPoint;
begin
     P.Assign( 400, 240);
     inherited Create( P, 'Grid edit');

     Canvas := ACanvas;

     Lock;

     AddLabel( 20, 20 + 10, 'Grid size');
     AddLabel( 20, 20 + 50, 'Snap size');
     AddLabel( 20, 20 + 90, 'Start offset');

     GridXEdit := New( PFloatEdit, Create( 120, 20, 120, 0.1, 100));
     GridYEdit := New( PFloatEdit, Create( 250, 20, 120, 0.1, 100));
     SnapXEdit := New( PFloatEdit, Create( 120, 60, 120, 0.1, 100));
     SnapYEdit := New( PFloatEdit, Create( 250, 60, 120, 0.1, 100));
     LimitsOffsetEdit := New( PFloatEdit, Create( 120, 100, 120, -1000, +1000));

     InsertChild( GridXEdit);
     InsertChild( GridYEdit);
     InsertChild( SnapXEdit);
     InsertChild( SnapYEdit);
     InsertChild( LimitsOffsetEdit);

     InsertChild( New( PButton, Create( 160, 160, 100 + metSHADOWSIZE, 30, '&Ok', cmOk, keyO)));
     InsertChild( New( PButton, Create( 270, 160, 100 + metSHADOWSIZE, 30, '&Cancel', cmCancel, keyC)));
     Unlock;
end;

procedure TGridEditDlg.BeforeExecuteDlg;
begin
     if ( Canvas <> nil)
     then begin
          GridXEdit^.SetValue( Canvas^.CanvasInfo.GridSize.X);
          GridYEdit^.SetValue( Canvas^.CanvasInfo.GridSize.Y);
          SnapXEdit^.SetValue( Canvas^.CanvasInfo.SnapGridSize.X);
          SnapYEdit^.SetValue( Canvas^.CanvasInfo.SnapGridSize.Y);
          LimitsOffsetEdit^.SetValue( Canvas^.CanvasInfo.LimitsOffset);
          end
     else begin
          GridXEdit^.SetValue( 10);
          GridYEdit^.SetValue( 10);
          SnapXEdit^.SetValue( 1);
          SnapYEdit^.SetValue( 1);
          LimitsOffsetEdit^.SetValue( 0);
          end;
end;

procedure TGridEditDlg.AfterExecuteDlg;
begin
end;

function TGridEditDlg.ValidateData: Boolean;
var Result: Boolean;
begin
     Result := False;
     if not GridXEdit^.ValidateString
     then GridXEdit^.SetFocus
     else if not GridYEdit^.ValidateString
     then GridYEdit^.SetFocus
     else if not SnapXEdit^.ValidateString
     then SnapXEdit^.SetFocus
     else if not SnapYEdit^.ValidateString
     then SnapYEdit^.SetFocus
     else if not LimitsOffsetEdit^.ValidateString
     then LimitsOffsetEdit^.SetFocus
     else Result := True;

     if Result
     then begin
          if ( Canvas <> nil)
          then begin
               Canvas^.CanvasInfo.GridSize.X := GridXEdit^.GetValue;
               Canvas^.CanvasInfo.GridSize.Y := GridYEdit^.GetValue;
               Canvas^.CanvasInfo.SnapGridSize.X := SnapXEdit^.GetValue;
               Canvas^.CanvasInfo.SnapGridSize.Y := SnapYEdit^.GetValue;
               Canvas^.CanvasInfo.LimitsOffset := LimitsOffsetEdit^.GetValue;
               end;
          ValidateData := True;
          end
     else begin
          MistakeBeep;
          ValidateData := False;
          end
end;


end.
