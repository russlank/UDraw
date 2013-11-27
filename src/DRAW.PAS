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
{*  FILE: DRWA.PAS                                                         *}
{*                                                                         *}
{***************************************************************************}

{DEFINE _FINALPATH}

program Draw;

uses UWin, Graph, IntDriver, Support, Strings, Generics, WinDos, Machine, Crt{, UCrt};

{*************************************************************************}

const HEADERSIZE = 13;
      TESTCANVASLINESCOUNT = 10;
      FileHeader: string[ HEADERSIZE] = 'ULTRADRAW103';

type PDesignCanvas = ^TDesignCanvas;

     PShape = ^TShape;
     TShape = object( TGeneric)
        constructor Create;
        destructor Destroy; virtual;
        function Clone: PGeneric; virtual;
        procedure Draw( ACanvas: PDesignCanvas; ASelected: Boolean); virtual;
        procedure GetStartPoint( var AFPoint: TFPoint); virtual;
        procedure GetStopPoint( var AFPoint: TFPoint); virtual;
        function GetLength: Float; virtual;
        procedure Fit( var AFRect: TFRect); virtual;
        procedure AppendToPath( APath: PFPath); virtual;
        function GetShapeID: Integer; virtual;
        procedure Save( AStream: PStream); virtual;
        constructor Load( AStream: PStream);
        procedure Shift( ADelta: TFPoint); virtual;
        procedure MirrorX( AX: Float); virtual;
        procedure MirrorY( AY: Float); virtual;
        procedure Rotate90( ACenter: TFPoint); virtual;
        end;

{*************************************************************************}

     PLineShape = ^TLineShape;
     TLineShape = object( TShape)
        P1, P2: TFPoint;
        constructor Create( var AFPoint1, AFPoint2: TFPoint);
        destructor Destroy; virtual;
        function Clone: PGeneric; virtual;
        procedure Draw( ACanvas: PDesignCanvas; ASelected: Boolean); virtual;
        procedure GetStartPoint( var AFPoint: TFPoint); virtual;
        procedure GetStopPoint( var AFPoint: TFPoint); virtual;
        function GetLength: Float; virtual;
        procedure Fit( var AFRect: TFRect); virtual;
        procedure AppendToPath( APath: PFPath); virtual;
        function GetShapeID: Integer; virtual;
        procedure Save( AStream: PStream); virtual;
        constructor Load( AStream: PStream);
        procedure Shift( ADelta: TFPoint); virtual;
        procedure MirrorX( AX: Float); virtual;
        procedure MirrorY( AY: Float); virtual;
        procedure Rotate90( ACenter: TFPoint); virtual;
        end;

{*************************************************************************}

     PGenericShape = ^TGenericShape;
     TGenericShape = object( TShape)
        FirstPoint: PFPointList;
        LastPoint: PFPointList;
        constructor Create;
        destructor Destroy; virtual;
        procedure AppendPoint( AX, AY: Float);
        procedure ClearPoints;
        procedure AssignArcPoints( var P1, P2, P3: TFPoint; AReversed: Boolean);
        procedure AssignArcExPoints( var P1, P2, P3: TFPoint; AReversed: Boolean);
        function Clone: PGeneric; virtual;
        procedure Draw( ACanvas: PDesignCanvas; ASelected: Boolean); virtual;
        procedure GetStartPoint( var AFPoint: TFPoint); virtual;
        procedure GetStopPoint( var AFPoint: TFPoint); virtual;
        function GetLength: Float; virtual;
        procedure Fit( var AFRect: TFRect); virtual;
        procedure AppendToPath( APath: PFPath); virtual;
        function GetShapeID: Integer; virtual;
        procedure Save( AStream: PStream); virtual;
        constructor Load( AStream: PStream);
        procedure Shift( ADelta: TFPoint); virtual;
        procedure MirrorX( AX: Float); virtual;
        procedure MirrorY( AY: Float); virtual;
        procedure Rotate90( ACenter: TFPoint); virtual;
        end;


{*************************************************************************}

     PArcShape = ^TArcShape;
     TArcShape = object( TShape)
        Center, Start, Stop: TFPoint;
        ThirdPoint: TFPoint;
        Radius, StartAngle, StopAngle: Float;
        Reversed: Boolean;
        constructor Create( var P1, P2, P3: TFPoint; AReversed: Boolean);
        destructor Destroy; virtual;
        procedure Calculate;
        function Clone: PGeneric; virtual;
        procedure Draw( ACanvas: PDesignCanvas; ASelected: Boolean); virtual;
        procedure GetStartPoint( var AFPoint: TFPoint); virtual;
        procedure GetStopPoint( var AFPoint: TFPoint); virtual;
        function GetLength: Float; virtual;
        procedure Fit( var AFRect: TFRect); virtual;
        procedure AppendToPath( APath: PFPath); virtual;
        function GetShapeID: Integer; virtual;
        procedure Save( AStream: PStream); virtual;
        constructor Load( AStream: PStream);
        procedure Shift( ADelta: TFPoint); virtual;
        procedure MirrorX( AX: Float); virtual;
        procedure MirrorY( AY: Float); virtual;
        procedure Rotate90( ACenter: TFPoint); virtual;
        end;

{*************************************************************************}

     PArcExShape = ^TArcExShape;
     TArcExShape = object( TShape)
        Center, Start, Stop: TFPoint;
        StartRadius, StopRadius, StartAngle, StopAngle: Float;
        Reversed: Boolean;
        constructor Create( var P1, P2, P3: TFPoint; AReversed: Boolean);
        destructor Destroy; virtual;
        procedure Calculate;
        function Clone: PGeneric; virtual;
        procedure Draw( ACanvas: PDesignCanvas; ASelected: Boolean); virtual;
        procedure GetStartPoint( var AFPoint: TFPoint); virtual;
        procedure GetStopPoint( var AFPoint: TFPoint); virtual;
        function GetLength: Float; virtual;
        procedure Fit( var AFRect: TFRect); virtual;
        procedure AppendToPath( APath: PFPath); virtual;
        function GetShapeID: Integer; virtual;
        procedure Save( AStream: PStream); virtual;
        constructor Load( AStream: PStream);
        procedure Shift( ADelta: TFPoint); virtual;
        procedure MirrorX( AX: Float); virtual;
        procedure MirrorY( AY: Float); virtual;
        procedure Rotate90( ACenter: TFPoint); virtual;
        end;

{*************************************************************************}

     PDrawInfo = ^TDrawInfo;
     TDrawInfo = object( TGeneric)
        BasePos: TFPoint;
        LastPoint: TFPoint;
        MachineSettings: TMachineSettings;
        constructor Create;
        destructor Destroy; virtual;
        procedure Save( AStream: PStream); virtual;
        constructor Load( AStream: PStream);
        end;

{*************************************************************************}

     PTool = ^TTool;
     TTool = object( TGeneric)
        Canvas: PDesignCanvas;
        List: PTextList;
        constructor Create( ACanvas: PDesignCanvas; AList: PTextList);
        destructor Destroy; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure CanvasUpdated; virtual;
        end;

{*************************************************************************}

     PTowPointsTool = ^TTowPointsTool;
     TTowPointsTool = object( TTool)
        LastPos,
        StartPos,
        MouseDownPos,
        CurrentPos: TFPoint;
        CursorVisible: Boolean;
        FeedbackVisible: Boolean;
        constructor Create( ACanvas: PDesignCanvas; AList: PTextList);
        destructor Destroy; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure FeedBackDraw; virtual;
        procedure CursorDraw( AActivateViewPort: Boolean); virtual;
        procedure MouseDown( ABottons: Byte); virtual;
        procedure MouseUp; virtual;
        procedure CanvasUpdated; virtual;
        end;

{*************************************************************************}

     PLineTool = ^TLineTool;
     TLineTool = object( TTowPointsTool)
        constructor Create( ACanvas: PDesignCanvas; AList: PTextList);
        procedure MouseDown( ABottons: Byte); virtual;
        procedure MouseUp; virtual;
        procedure FeedBackDraw; virtual;
        end;

{*************************************************************************}

     PArcTool = ^TArcTool;
     TArcTool = object( TTowPointsTool)
        ReversedAngle: Boolean;
        constructor Create( ACanvas: PDesignCanvas; AList: PTextList);
        procedure MouseDown( ABottons: Byte); virtual;
        procedure MouseUp; virtual;
        procedure FeedBackDraw; virtual;
        end;

{*************************************************************************}

     PArcExTool = ^TArcExTool;
     TArcExTool = object( TTowPointsTool)
        ReversedAngle: Boolean;
        constructor Create( ACanvas: PDesignCanvas; AList: PTextList);
        procedure MouseDown( ABottons: Byte); virtual;
        procedure MouseUp; virtual;
        procedure FeedBackDraw; virtual;
        end;

{*************************************************************************}

     PFeedBackPanel = ^TFeedBackPanel;
     TFeedBackPanel = object( TWindow)
     private
        Pos: TFPoint;
        BasePos: TFPoint;
        Zoom: Float;
        Snap: Boolean;
        GridStyle: Byte;
        procedure DisplayPos( AActivateViewPort: Boolean);
        procedure DisplayZoom( AActivateViewPort: Boolean);
        procedure DisplaySnap( AActivateViewPort: Boolean);
        procedure DisplayGridStyle( AActivateViewPort: Boolean);
     public
        constructor Create( R: TRect);
        procedure Draw; virtual;
        procedure UpdatePos( var APos: TFPoint);
        procedure UpdateBasePos( var ABasePos: TFPoint);
        procedure UpdateZoom( var AZoom: Float);
        procedure UpdateSnap( var ASnap: Boolean);
        procedure UpdateGridStyle( var AStyle: Byte);
        end;

{*************************************************************************}

     PHeadsPanel = ^THeadsPanel;
     PRow = ^TRow;
     PHead = ^THead;
     THead = object( TGeneric)
     private
        HorizontalPos: Float;
        TuchPosX: Integer;
        Draged: Boolean;
     public
        constructor Create( AHorizontalPos: Float);
        destructor Destroy; virtual;
        procedure HandleEvent( var E: TEvent; ARow: PRow; APanel: PHeadsPanel; ASelected: Boolean); virtual;
        procedure Draw( ARow: PRow; APanel: PHeadsPanel; AInitViewPort: Boolean; ASelected: Boolean);
        procedure DrawDraged( ARow: PRow; APanel: PHeadsPanel; ASelected: Boolean);
        function GetHorizontalPos: Float;
        procedure SetHorizontalPos( APos: Float);
        procedure SaveData( AStream: PStream);
        procedure LoadData( AStream: PStream);
        procedure WritePositions( AStream: PStream);
        end;

{*************************************************************************}

     TRow = object( TGeneric)
     private
        VerticalPos: Float;
        Heads: TContainerCollection;
        TuchPosY: Integer;
        Draged: Boolean;
    public
        constructor Create( AVerticalPos: Float);
        destructor Destroy; virtual;
        procedure HandleEvent( var E: TEvent; APanel: PHeadsPanel; ASelected: Boolean); virtual;
        procedure Draw( APanel: PHeadsPanel; AInitViewPort: Boolean; ASelected: Boolean);
        procedure AppendHead( AHead: PHead);
        procedure DrawDraged( APanel: PHeadsPanel; ASelected: Boolean);
        function GetVerticalPos: Float;
        procedure SetVertialPos( APos: Float);
        procedure GetHeadsPoses( AFPath: PFPath);
        function SelectHead( AHead: PHead; APanel: PHeadsPanel): Boolean;
        function GetSelectedHead: PHead;
        procedure SaveData( AStream: PStream);
        procedure LoadData( AStream: PStream);
        procedure WritePositions( AStream: PStream);
        end;

{*************************************************************************}

     THeadsPanelInfo = record
        HeadsBaseSize: TFPoint;
        Zoom: TFPoint;
        {GridOffset: TFPoint;}
        GridSize: TFPoint;
        SnapSize: TFPoint;
        SnapOnOff: Boolean;
        end;

{*************************************************************************}

     THeadsPanel = object( TWindow)
     private
        Rows: TContainerCollection;
        Info: THeadsPanelInfo;
     public
        constructor Create( R: TRect);
        destructor Destroy; virtual;
        procedure Draw; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure ConvertToWindowX( var AFX: Float; var AX: Longint);
        procedure ConvertToWindowY( var AFY: Float; var AY: Longint);
        procedure ConvertToWindowPos( var AFPoint: TFPoint; var APoint: TPoint);
        procedure ConvertToLogicalX( var AX: Longint; var AFX: Float; ASnap: Boolean);
        procedure ConvertToLogicalY( var AY: Longint; var AFY: Float; ASnap: Boolean);
        procedure ConvertToLogicalPos( var APoint: TPoint; var AFPoint: TFPoint; ASnap: Boolean);
        procedure AppendRow( ARow: PRow);
        function GetHeadsPoses: PFPath;
        function SelectRow( ARow: PRow): Boolean;
        procedure RemoveRow;
        procedure RemoveHead;
        function GetSelectedRow: PRow;
        function GetSelectedHead: PHead;
        procedure SaveData( AStream: PStream);
        procedure LoadData( AStream: PStream);
        procedure WritePositions( AStream: PStream);
        end;

{*************************************************************************}

     PHeadCordsPanel = ^THeadCordsPanel;
     THeadCordsPanel = object( TWindow)
     private
        HeadsPanel: PHeadsPanel;
        LastPos: TFPoint;
     public
        constructor Create( var R: TRect; AHeadsPanel: PHeadsPanel);
        destructor Destroy; virtual;
        procedure Draw; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure ShowNewCords( AInitViewPort: Boolean; ASkipLastValueTest: Boolean);
        end;

{*************************************************************************}

     PRowAddDlg = ^TRowAddDlg;
     TRowAddDlg = object( TDialog)
     private
        PosEdit: PFloatEdit;
        HeadsCountEdit: PIntegerEdit;
        HeadsPanel: PHeadsPanel;
     public
        constructor Create( AHeadsPanel: PHeadsPanel);
        procedure BeforeExecuteDlg; virtual;
        procedure AfterExecuteDlg; virtual;
        function ValidateData: Boolean; virtual;
        end;

{*************************************************************************}

     PHeadsAddDlg = ^THeadsAddDlg;
     THeadsAddDlg = object( TDialog)
     private
        StartPosEdit: PFloatEdit;
        CountEdit: PIntegerEdit;
        SpacingEdit: PFloatEdit;
        HeadsPanel: PHeadsPanel;
     public
        constructor Create( AHeadsPanel: PHeadsPanel);
        procedure BeforeExecuteDlg; virtual;
        procedure AfterExecuteDlg; virtual;
        function ValidateData: Boolean; virtual;
        end;

{*************************************************************************}

     PRowHeadEditDlg = ^TRowHeadEditDlg;
     TRowHeadEditDlg = object( TDialog)
     private
        HeadPosEdit: PFloatEdit;
        RowPosEdit: PFloatEdit;
        HeadsPanel: PHeadsPanel;
        Row: PRow;
        Head: PHead;
     public
        constructor Create( AHeadsPanel: PHeadsPanel);
        procedure BeforeExecuteDlg; virtual;
        procedure AfterExecuteDlg; virtual;
        function ValidateData: Boolean; virtual;
        end;

{*************************************************************************}

     PPreviewGridEditDlg = ^TPreviewGridEditDlg;
     TPreviewGridEditDlg = object( TDialog)
     private
        {XOffsetEdit,
        YOffsetEdit,}
        GridXEdit,
        GridYEdit,
        SnapXEdit,
        SnapYEdit: PFloatEdit;
        SnapOnOffCheck: PCheckBox;
        HeadsPanel: PHeadsPanel;
    public
        constructor Create( AHeadsPanel: PHeadsPanel);
        procedure BeforeExecuteDlg; virtual;
        procedure AfterExecuteDlg; virtual;
        function ValidateData: Boolean; virtual;
        end;

{*************************************************************************}

     TDesignCanvas = object( TCanvas)
        FileDefined: Boolean;
        FileName: string;
        Shapes: TContainerCollection;
        FeedBack: PFeedBackPanel;
        Tool: PTool;
        List: PTextList;
        Info: TDrawInfo;
        SelectStart: PShape;
        SelectEnd: PShape;
        PreviewData: PMemStream;
        constructor Create( R: TRect; AList: PTextList; AFeedBack: PFeedBackPanel);
        destructor Destroy; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure Draw; virtual;
        procedure DrawShapes( AInitViewPort: Boolean);
        procedure DrawCursor;
        procedure Scroll( ADir: Integer); virtual;
        procedure SetTool( ATool: PTool);
        procedure GetDrawPoints( APath: PFPath);
        procedure GetFitRect( var FR: TFRect); virtual;
        procedure GetAvailableCommands( var ACommands: TCommandsSet); virtual;
        function WriteDataToFile( AFileNameFP: string; AFileName: string): Boolean;
        function ReadDataFromFile( AFileNameFP: string; AFileName: string): Boolean;
        procedure Update; virtual;
        procedure AppendShape( AShape: PShape);
        end;

{*************************************************************************}

     PPreviewCanvas = ^TPreviewCanvas;
     TPreviewCanvas = object( TCanvas)
        Path: PFPath;
        HeadsPoses: PFPath;
        MachineSettings: PMachineSettings;
        Repeats: Integer;
        constructor Create( R: TRect; APath: PFPath; AHeadsPoses: PFPath; AMachineSettings: PMachineSettings);
        destructor Destroy; virtual;
        procedure Draw; virtual;
        procedure GetFitRect( var FR: TFRect); virtual;
        procedure SetPath( APath: PFPath);
        procedure GetAvailableCommands( var ACommands: TCommandsSet); virtual;
        procedure SetHeadsPoses( AHeadsPoses: PFPath);
        procedure SetRepeats( ARepeats: Integer);
        end;

{*************************************************************************}

     PTestCanvas = ^TTestCanvas;
     TTestCanvas = object( TCanvas)
        ThePath: PFPath;
{$IFDEF _FINALPATH}
        FinalPath: PFPath;
{$ENDIF}
        HeadPath: Boolean;
        MachineSettings: PMachineSettings;
        Lines: array [1..TESTCANVASLINESCOUNT] of PString;
        constructor Create( R: TRect; APath: PFPath; AMachineSettings: PMachineSettings; ATextList: PTextList);
        destructor Destroy; virtual;
        procedure Draw; virtual;
        procedure GetFitRect( var FR: TFRect); virtual;
        procedure SetPath( APath: PFPath);
        procedure TugglePath;
{$IFDEF _FINALPATH}
        procedure FindFinalPath;
{$ENDIF}
        procedure GetAvailableCommands( var ACommands: TCommandsSet); virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        end;

{*************************************************************************}

     PAboutUltraSoftDlg = ^TAboutUltraSoftDlg;
     TAboutUltraSoftDlg = object( TAboutDlg)
        procedure Draw; virtual;
        end;

{*************************************************************************}

     PAboutSabbaghDlg = ^TAboutSabbaghDlg;
     TAboutSabbaghDlg = object( TAboutDlg)
        procedure Draw; virtual;
        end;

{*************************************************************************}

     PAboutMaktabiDlg = ^TAboutMaktabiDlg;
     TAboutMaktabiDlg = object( TAboutDlg)
        procedure Draw; virtual;
        end;

{*************************************************************************}

     PSettingsDlg = ^TSettingsDlg;
     TSettingsDlg = object( TDialog)
     private
        Info: PMachineSettings;
        StepLengthEdit: PFloatEdit;
        MaxXStepLengthEdit: PFloatEdit;
        MaxYStepLengthEdit: PFloatEdit;
        {SpeedAutoCheck: PCheckBox;}
        SpeedScroll: PScrollControl;
     public
        constructor Create( AInfo: PMachineSettings);
        procedure BeforeExecuteDlg; virtual;
        procedure AfterExecuteDlg; virtual;
        function ValidateData: Boolean; virtual;
        end;

{*************************************************************************}

     PFileInfo = ^TFileInfo;
     TFileInfo = record
         Index: Integer;
         Name: string[12];
         Next: PFileInfo;
         Dir: Boolean;
         end;

{*************************************************************************}

     PDesignWindow = ^TDesignWindow;
     TDesignWindow = object( TCaptionWindow)
        Canvas: PDesignCanvas;
        FeedBack: PFeedBackPanel;
        VScroolBar,
        HScroolBar: PScrollBar;
        {PreviewData: PMemStream;}
        constructor Create( AOrigin: TPoint);
        destructor Destroy; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure GetAvailableCommands( var ACommands: TCommandsSet); virtual;
        function GetCaption: string; virtual;
        end;

{*************************************************************************}

     PPreviewDlg = ^TPreviewDlg;
     TPreviewDlg = object( TDialog)
        Canvas: PPreviewCanvas;
        HeadCordsPanel: PHeadCordsPanel;
        AutoFitCheck: PCheckBox;
        VScroolBar,
        HScroolBar: PScrollBar;
        HeadsPanel: PHeadsPanel;
        RepeatEdit: PIntegerEdit;
        constructor Create( APath: PFPath; AMachineSettings: PMachineSettings);
        destructor Destroy; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure GetAvailableCommands( var ACommands: TCommandsSet); virtual;
        function DialogExitQuery( AAccept: Boolean): Boolean; virtual;
        procedure LoadData( AStream: PStream);
        procedure SaveData( AStream: PStream);
        end;

{*************************************************************************}

     PTestDlg = ^TTestDlg;
     TTestDlg = object( TDialog)
        Canvas: PTestCanvas;
        VScroolBar,
        HScroolBar: PScrollBar;
        constructor Create( APath: PFPath; AMachineSettings: PMachineSettings);
        destructor Destroy; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure GetAvailableCommands( var ACommands: TCommandsSet); virtual;
        procedure BeforeExecuteDlg; virtual;
        procedure AfterExecuteDlg; virtual;
        end;

{*************************************************************************}

     PMyDesktopClientsArea = ^TMyDesktopClientsArea;
     TMyDesktopClientsArea = object( TDesktopClientsArea)
        procedure HandleEvent( var E: TEvent); virtual;
        procedure Draw; virtual;
        end;

{*************************************************************************}

     PMyDesktop = ^TMyDesktop;
     TMyDeskTop = object( TDeskTop)
        constructor Create;
        procedure HandleEvent( var E: TEvent); virtual;
        function CreateClientsArea( var R: TRect): PDesktopClientsArea; virtual;
        procedure GetAvailableCommands( var ACommands: TCommandsSet); virtual;
        end;

{*************************************************************************}

     PDrawApplication = ^TDrawApplication;
     TDrawApplication = object( TApplication)
        constructor Create;
        destructor Destroy; virtual;
        procedure Run; virtual;
        function CreateDesktop: PDeskTop; virtual;

        end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

procedure Swap( var A, B: Float);
var Temp: Float;
begin
     Temp := A;
     A := B;
     B := Temp;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TShape.Create;
begin
     inherited Create;
end;

destructor TShape.Destroy;
begin
     inherited Destroy;
end;

function TShape.Clone: PGeneric;
begin
     Clone := nil;
end;

procedure TShape.Draw( ACanvas: PDesignCanvas; ASelected: Boolean);
begin
end;

procedure TShape.GetStartPoint( var AFPoint: TFPoint);
begin
end;

procedure TShape.GetStopPoint( var AFPoint: TFPoint);
begin
end;

function TShape.GetLength: Float;
begin
     GetLength := 0;
end;

procedure TShape.Fit( var AFRect: TFRect);
begin
end;

procedure TShape.AppendToPath( APath: PFPath);
begin
end;

function TShape.GetShapeID: Integer;
begin
     GetShapeID := 0;
end;

procedure TShape.Save( AStream: PStream);
begin
end;

constructor TShape.Load( AStream: PStream);
begin
     inherited Create;
end;

procedure TShape.Shift( ADelta: TFPoint);
begin
end;

procedure TShape.MirrorX( AX: Float);
begin
end;

procedure TShape.MirrorY( AY: Float);
begin
end;

procedure TShape.Rotate90( ACenter: TFPoint);
begin
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TLineShape.Create( var AFPoint1, AFPoint2: TFPoint);
begin
     inherited Create;
     P1 := AFPoint1;
     P2 := AFPoint2;
end;

destructor TLineShape.Destroy;
begin
     inherited Destroy;
end;

function TLineShape.Clone: PGeneric;
begin
     Clone := New( PLineShape, Create( P1, P2));
end;

procedure TLineShape.Draw( ACanvas: PDesignCanvas; ASelected: Boolean);
var VP1, VP2: TPoint;
begin
     if ( ACanvas <> nil)
     then begin
          ACanvas^.ConvertToCanvasPos( P1, VP1);
          ACanvas^.ConvertToCanvasPos( P2, VP2);
          if not ASelected
          then ACanvas^.SetPColor( clrSHAPE)
          else ACanvas^.SetPColor( clrSHAPESELECTED);
          SetLineStyle( SolidLn, 0, 3);
          ACanvas^.Line( VP1.X, VP1.Y, VP2.X, VP2.Y);
          SetLineStyle( SolidLn, 0, 0);
          end;
end;

procedure TLineShape.GetStartPoint( var AFPoint: TFPoint);
begin
     AFPoint := P1;
end;

procedure TLineShape.GetStopPoint( var AFPoint: TFPoint);
begin
     AFPoint := P2;
end;

function TLineShape.GetLength: Float;
var SqrLength: Float;
begin
     SqrLength := Sqr( P2.X - P1.X) + Sqr( P2.Y - P1.Y);
     if ( SqrLength > 0)
     then GetLength := Sqrt( SqrLength)
     else GetLength := 0;
end;

procedure TLineShape.Fit( var AFRect: TFRect);
begin
     AFRect.FitPoint( P1);
     AFRect.FitPoint( P2);
end;

procedure TLineShape.AppendToPath( APath: PFPath);
begin
     if (APath <> nil)
     then begin
          APath^.AppendPoint( P1.X, P1.Y);
          APath^.AppendPoint( P2.X, P2.Y);
          end;
end;

function TLineShape.GetShapeID: Integer;
begin
     GetShapeID := 1;
end;

procedure TLineShape.Save( AStream: PStream);
begin
     inherited Save( AStream);
     if ( AStream <> nil)
     then begin
          AStream^.Write( P1, SizeOf( P1));
          AStream^.Write( P2, SizeOf( P2));
          end;
end;

constructor TLineShape.Load( AStream: PStream);
begin
     inherited Load( AStream);
     if ( AStream <> nil)
     then begin
          AStream^.Read( P1, SizeOf( P1));
          AStream^.Read( P2, SizeOf( P2));
          end
     else begin
          P1.Assign( 0, 0);
          P2.Assign( 0, 0);
          end;
end;

procedure TLineShape.Shift( ADelta: TFPoint);
begin
     P1.X := P1.X + ADelta.X;
     P1.Y := P1.Y + ADelta.Y;
     P2.X := P2.X + ADelta.X;
     P2.Y := P2.Y + ADelta.Y;
end;

procedure TLineShape.MirrorX( AX: Float);
begin
     P1.MirrorX( AX);
     P2.MirrorX( AX);
end;

procedure TLineShape.MirrorY( AY: Float);
begin
     P1.MirrorY( AY);
     P2.MirrorY( AY);
end;

procedure TLineShape.Rotate90( ACenter: TFPoint);
begin
     P1.Rotate90( ACenter);
     P2.Rotate90( ACenter);
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TGenericShape.Create;
begin
     inherited Create;
     FirstPoint := nil;
     LastPoint := nil;
end;

destructor TGenericShape.Destroy;
begin
     ClearPoints;
     inherited Destroy;
end;

procedure TGenericShape.AppendPoint( AX, AY: Float);
var NewPoint: PFPointList;
begin
     New( NewPoint);
     NewPoint^.Next := nil;
     NewPoint^.Pos.X := AX;
     NewPoint^.Pos.Y := AY;
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

procedure TGenericShape.ClearPoints;
begin
     while ( FirstPoint <> nil)
     do begin
        LastPoint := FirstPoint;
        FirstPoint := FirstPoint^.Next;
        Dispose( LastPoint);
        end;

     LastPoint := nil;
     FirstPoint := nil;
end;

procedure TGenericShape.AssignArcPoints( var P1, P2, P3: TFPoint; AReversed: Boolean);
const Delta = 5;
var Center: TFPoint;
    Start: TFPoint;
    ThirdPoint: TFPoint;
    Reversed: Boolean;
    StartAngle: Float;
    StopAngle: Float;
    Radius: Float;
    Stop: TFPoint;

    LStartAngle, LStopAngle: Float;
    LCenterX, LCenterY: Float;
    LRadius: Float;

    X, Y: Float;
    Angle: Float;
begin
     ClearPoints;

     Center := P1;
     Start := P2;
     ThirdPoint := P3;
     Reversed := AReversed;
     StartAngle := Center.AngleDeg( Start);
     StopAngle := Center.AngleDeg( ThirdPoint);
     Radius := Center.Distance( Start);
     Stop.Assign( Center.X + Radius * Cos( StopAngle * PI / 180), Center.Y + Radius * Sin( StopAngle * PI / 180));

     LCenterX := Center.X;
     LCenterY := Center.Y;
     LRadius := Radius;

     if Reversed
     then begin
          LStartAngle := StopAngle;
          LStopAngle := StartAngle;
          end
     else begin
          LStartAngle := StartAngle;
          LStopAngle := StopAngle;
          end;

     if ( LStartAngle >= LStopAngle)
     then LStopAngle := LStopAngle + 360;

     if Reversed
     then begin
          Angle := LStopAngle;
          repeat
                X := LRadius * Cos( Angle * PI / 180) + LCenterX;
                Y := LRadius * Sin( Angle * PI / 180) + LCenterY;
                AppendPoint( X, Y);
                Angle := Angle - Delta;
          until (Angle < LStartAngle);

          if ( Angle < LStartAngle)
          then begin
               X := LRadius * Cos( LStartAngle * PI / 180) + LCenterX;
               Y := LRadius * Sin( LStartAngle * PI / 180) + LCenterY;
               AppendPoint( X, Y);
               end;
          end
     else begin
          Angle := LStartAngle;
          repeat
                X := LRadius * Cos( Angle * PI / 180) + LCenterX;
                Y := LRadius * Sin( Angle * PI / 180) + LCenterY;
                AppendPoint( X, Y);
                Angle := Angle + Delta;
          until (Angle > LStopAngle);
          if ( Angle > LStopAngle)
          then begin
               X := LRadius * Cos( LStopAngle * PI / 180) + LCenterX;
               Y := LRadius * Sin( LStopAngle * PI / 180) + LCenterY;
               AppendPoint( X, Y);
               end;
          end;
end;

procedure TGenericShape.AssignArcExPoints( var P1, P2, P3: TFPoint; AReversed: Boolean);
const Delta = 5;
var Center: TFPoint;
    Start: TFPoint;
    Stop: TFPoint;
    Reversed: Boolean;
    StartAngle: Float;
    StopAngle: Float;
    StartRadius: Float;
    StopRadius: Float;
    LStartAngle, LStopAngle: Float;
    LStartRadius, LStopRadius: Float;
    LCenterX, LCenterY: Float;
    FSteps: Float;
    Steps: Integer;
    RadiusDelta: Float;

    X, Y: Float;
    Angle: Float;
    Radius: Float;
begin
     ClearPoints;

     Center := P1;
     Start := P2;
     Stop := P3;
     Reversed := AReversed;

     StartAngle := Center.AngleDeg( Start);
     StopAngle := Center.AngleDeg( Stop);
     StartRadius := Center.Distance( Start);
     StopRadius := Center.Distance( Stop);

     LCenterX := Center.X;
     LCenterY := Center.Y;

     if Reversed
     then begin
          LStartAngle := StopAngle;
          LStopAngle := StartAngle;
          LStartRadius := StopRadius;
          LStopRadius := StartRadius;
          end
     else begin
          LStartAngle := StartAngle;
          LStopAngle := StopAngle;
          LStartRadius := StartRadius;
          LStopRadius := StopRadius;
          end;

     if ( LStartAngle >= LStopAngle)
     then LStopAngle := LStopAngle + 360;

     FSteps := (LStopAngle - LStartAngle) / Delta;
     if (Frac( FSteps) > 0)
     then Steps := Trunc( FSteps) + 1
     else Steps := Trunc( FSteps);

     RadiusDelta := (LStopRadius - LStartRadius) / Steps;

     if Reversed
     then begin
          Angle := LStopAngle;
          Radius := LStopRadius;
          repeat
                X := Radius * Cos( Angle * PI / 180) + LCenterX;
                Y := Radius * Sin( Angle * PI / 180) + LCenterY;
                AppendPoint( X, Y);
                Angle := Angle - Delta;
                Radius := Radius - RadiusDelta;
          until (Angle < LStartAngle);

          if ( Angle < LStartAngle)
          then begin
               X := LStartRadius * Cos( LStartAngle * PI / 180) + LCenterX;
               Y := LStartRadius * Sin( LStartAngle * PI / 180) + LCenterY;
               AppendPoint( X, Y);
               end;
          end
     else begin
          Angle := LStartAngle;
          Radius := LStartRadius;
          repeat
                X := Radius * Cos( Angle * PI / 180) + LCenterX;
                Y := Radius * Sin( Angle * PI / 180) + LCenterY;
                AppendPoint( X, Y);
                Angle := Angle + Delta;
                Radius := Radius + RadiusDelta;
          until (Angle > LStopAngle);

          if ( Angle > LStopAngle)
          then begin
               X := LStopRadius * Cos( LStopAngle * PI / 180) + LCenterX;
               Y := LStopRadius * Sin( LStopAngle * PI / 180) + LCenterY;
               AppendPoint( X, Y);
               end;
          end;
end;

function TGenericShape.Clone: PGeneric;
var TheClone: PGenericShape;
    ScanPoint: PFPointList;
begin
     TheClone := New( PGenericShape, Create);
     ScanPoint := FirstPoint;
     while ( ScanPoint <> nil)
     do begin
        TheClone^.AppendPoint( ScanPoint^.Pos.X, ScanPoint^.Pos.Y);
        ScanPoint := ScanPoint^.Next;
        end;
     Clone := TheClone;
end;

procedure TGenericShape.Draw( ACanvas: PDesignCanvas; ASelected: Boolean);
var VP1, VP2: TPoint;
    ScanPoint: PFPointList;
begin
     if (( ACanvas <> nil) and ( FirstPoint <> nil))
     then begin
          ScanPoint := FirstPoint^.Next;
          if ( ScanPoint <> nil)
          then begin
               if not ASelected
               then ACanvas^.SetPColor( clrSHAPE)
               else ACanvas^.SetPColor( clrSHAPESELECTED);
               SetLineStyle( SolidLn, 0, 3);
               ACanvas^.ConvertToCanvasPos( FirstPoint^.Pos, VP1);
               repeat
                     ACanvas^.ConvertToCanvasPos( ScanPoint^.Pos, VP2);
                     ACanvas^.Line( VP1.X, VP1.Y, VP2.X, VP2.Y);
                     VP1 := VP2;
                     ScanPoint := ScanPoint^.Next;
               until ( ScanPoint = nil);
               SetLineStyle( SolidLn, 0, 0);
               end;
          end;
end;

procedure TGenericShape.GetStartPoint( var AFPoint: TFPoint);
begin
     if ( FirstPoint <> nil)
     then AFPoint := FirstPoint^.Pos
     else AFPoint.Assign( 0, 0);
end;

procedure TGenericShape.GetStopPoint( var AFPoint: TFPoint);
begin
     if ( LastPoint <> nil)
     then AFPoint := LastPoint^.Pos
     else AFPoint.Assign( 0, 0);
end;

function TGenericShape.GetLength: Float;
var Length: Float;
    ScanPoint: PFPointList;
    PreScanPoint: PFPointList;
begin
     Length := 0;
     if ( FirstPoint <> nil)
     then begin
          PreScanPoint := FirstPoint;
          ScanPoint := FirstPoint^.Next;
          while ( ScanPoint <> nil)
          do begin
             Length := Length + Sqrt( Sqr( ScanPoint^.Pos.X - PreScanPoint^.Pos.X) +
                                      Sqr( ScanPoint^.Pos.Y - PreScanPoint^.Pos.Y));
             PreScanPoint := ScanPoint;
             ScanPoint := ScanPoint^.Next;
             end;
          end;
     GetLength := Length;
end;

procedure TGenericShape.Fit( var AFRect: TFRect);
var ScanPoint: PFPointList;
begin
     ScanPoint := FirstPoint;
     while ( ScanPoint <> nil)
     do begin
        AFRect.FitPoint( ScanPoint^.Pos);
        ScanPoint := ScanPoint^.Next;
        end;
end;

procedure TGenericShape.AppendToPath( APath: PFPath);
var ScanPoint: PFPointList;
begin
     if (( APath <> nil) and ( FirstPoint <> nil))
     then begin
          ScanPoint := FirstPoint;
          repeat
                APath^.AppendPoint( ScanPoint^.Pos.X, ScanPoint^.Pos.Y);
                ScanPoint := ScanPoint^.Next;
          until ( ScanPoint = nil);
          end;
end;

function TGenericShape.GetShapeID: Integer;
begin
     GetShapeID :=4;
end;

procedure TGenericShape.Save( AStream: PStream);
var PointsCount: Longint;
    ScanPoint: PFPointList;
begin
     inherited Save( AStream);

     if ( AStream <> nil)
     then begin
          PointsCount := 0;

          ScanPoint := FirstPoint;
          while ( ScanPoint <> nil)
          do begin
             PointsCount := PointsCount + 1;
             ScanPoint := ScanPoint^.Next;
             end;

          AStream^.Write( PointsCount, SizeOf( PointsCount));

          ScanPoint := FirstPoint;
          while ( ScanPoint <> nil)
          do begin
             AStream^.Write( ScanPoint^.Pos, SizeOf( ScanPoint^.Pos));
             ScanPoint := ScanPoint^.Next;
             end;
          end;
end;

constructor TGenericShape.Load( AStream: PStream);
var PointsCount: Longint;
    Pos: TFPoint;
begin
     inherited Load( AStream);

     FirstPoint := nil;
     LastPoint := nil;

     if ( AStream <> nil)
     then begin
          AStream^.Read( PointsCount, SizeOf( PointsCount));
          while ( PointsCount > 0)
          do begin
             AStream^.Read( Pos, SizeOf( Pos));
             AppendPoint( Pos.X, Pos.Y);
             PointsCount := PointsCount - 1;
             end;
          end;
end;

procedure TGenericShape.Shift( ADelta: TFPoint);
var ScanPoint: PFPointList;
begin
     ScanPoint := FirstPoint;
     while ( ScanPoint <> nil)
     do begin
        ScanPoint^.Pos.X := ScanPoint^.Pos.X + ADelta.X;
        ScanPoint^.Pos.Y := ScanPoint^.Pos.Y + ADelta.Y;
        ScanPoint := ScanPoint^.Next;
        end;
end;

procedure TGenericShape.MirrorX( AX: Float);
var ScanPoint: PFPointList;
begin
     ScanPoint := FirstPoint;
     while ( ScanPoint <> nil)
     do begin
        ScanPoint^.Pos.MirrorX( AX);
        ScanPoint := ScanPoint^.Next;
        end;
end;

procedure TGenericShape.MirrorY( AY: Float);
var ScanPoint: PFPointList;
begin
     ScanPoint := FirstPoint;
     while ( ScanPoint <> nil)
     do begin
        ScanPoint^.Pos.MirrorY( AY);
        ScanPoint := ScanPoint^.Next;
        end;
end;

procedure TGenericShape.Rotate90( ACenter: TFPoint);
var ScanPoint: PFPointList;
begin
     ScanPoint := FirstPoint;
     while ( ScanPoint <> nil)
     do begin
        ScanPoint^.Pos.Rotate90( ACenter);
        ScanPoint := ScanPoint^.Next;
        end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TArcShape.Create( var P1, P2, P3: TFPoint; AReversed: Boolean);
begin
     inherited Create;
     Center := P1;
     Start := P2;
     ThirdPoint := P3;
     Reversed := AReversed;
     Calculate;
end;

procedure TArcShape.Calculate;
begin
     StartAngle := Center.AngleDeg( Start);
     StopAngle := Center.AngleDeg( ThirdPoint);
     Radius := Center.Distance( Start);
     Stop.Assign( Center.X + Radius * Cos( StopAngle * PI / 180), Center.Y + Radius * Sin( StopAngle * PI / 180));
end;

destructor TArcShape.Destroy;
begin
     inherited Destroy;
end;

function TArcShape.Clone: PGeneric;
begin
     Clone := New( PArcShape, Create( Center, Start, ThirdPoint, Reversed));
end;

procedure TArcShape.Draw( ACanvas: PDesignCanvas; ASelected: Boolean);
var VCenter: TPoint;
    VRadius: Longint;
    Point: TPoint;
    S: string;
begin
     if ( ACanvas <> nil)
     then begin
          ACanvas^.ConvertToCanvasPos( Center, VCenter);
          ACanvas^.ConvertToCanavsLength( Radius, VRadius);
          if not ASelected
          then ACanvas^.SetPColor( clrSHAPE)
          else ACanvas^.SetPColor( clrSHAPESELECTED);
          SetLineStyle( SolidLn, 0, 3);
          if Reversed
          then ACanvas^.Arc( VCenter.X, VCenter.Y, Round( StopAngle), Round( StartAngle), VRadius)
          else ACanvas^.Arc( VCenter.X, VCenter.Y, Round( StartAngle), Round( StopAngle), VRadius);
          SetLineStyle( SolidLn, 0, 0);
          end;
end;

procedure TArcShape.GetStartPoint( var AFPoint: TFPoint);
begin
     AFPoint := Start;
end;

procedure TArcShape.GetStopPoint( var AFPoint: TFPoint);
begin
     AFPoint := Stop;
end;

function TArcShape.GetLength: Float;
begin
end;

procedure TArcShape.Fit( var AFRect: TFRect);
var P: TFPoint;
begin
     P.Assign( Center.X - Radius, Center.Y - Radius);
     AFRect.FitPoint( P);
     P.Assign( Center.X + Radius, Center.Y + Radius);
     AFRect.FitPoint( P);
end;

procedure TArcShape.AppendToPath( APath: PFPath);
const Delta = 5;
var LStartAngle, LStopAngle: Float;
    LCenterX, LCenterY: Float;
    LRadius: Float;

    X, Y: Float;
    Angle: Float;
begin
     if (APath <> nil)
     then begin
          LCenterX := Center.X;
          LCenterY := Center.Y;
          LRadius := Radius;

          if Reversed
          then begin
               LStartAngle := StopAngle;
               LStopAngle := StartAngle;
               end
          else begin
               LStartAngle := StartAngle;
               LStopAngle := StopAngle;
               end;

          if ( LStartAngle >= LStopAngle)
          then LStopAngle := LStopAngle + 360;

          if Reversed
          then begin
               Angle := LStopAngle;
               repeat
                  X := LRadius * Cos( Angle * PI / 180) + LCenterX;
                  Y := LRadius * Sin( Angle * PI / 180) + LCenterY;
                  APath^.AppendPoint( X, Y);
                  Angle := Angle - Delta;
               until (Angle < LStartAngle);
               if ( Angle < LStartAngle)
               then begin
                    X := LRadius * Cos( LStartAngle * PI / 180) + LCenterX;
                    Y := LRadius * Sin( LStartAngle * PI / 180) + LCenterY;
                    APath^.AppendPoint( X, Y);
                    end;
               end
          else begin
               Angle := LStartAngle;
               repeat
                  X := LRadius * Cos( Angle * PI / 180) + LCenterX;
                  Y := LRadius * Sin( Angle * PI / 180) + LCenterY;
                  APath^.AppendPoint( X, Y);
                  Angle := Angle + Delta;
               until (Angle > LStopAngle);
               if ( Angle > LStopAngle)
               then begin
                    X := LRadius * Cos( LStopAngle * PI / 180) + LCenterX;
                    Y := LRadius * Sin( LStopAngle * PI / 180) + LCenterY;
                    APath^.AppendPoint( X, Y);
                    end;
               end;
          end;
end;

function TArcShape.GetShapeID: Integer;
begin
     GetShapeID := 2;
end;

procedure TArcShape.Save( AStream: PStream);
begin
     inherited Save( AStream);
     if ( AStream <> nil)
     then begin
          AStream^.Write( Center, SizeOf( Center));
          AStream^.Write( Start, SizeOf( Start));
          AStream^.Write( Stop, SizeOf( Stop));
          AStream^.Write( ThirdPoint, SizeOf( ThirdPoint));
          AStream^.Write( Radius, SizeOf( Radius));
          AStream^.Write( StartAngle, SizeOf( StartAngle));
          AStream^.Write( StopAngle, SizeOf( StopAngle));
          AStream^.Write( Reversed, SizeOf( Reversed));
          end;
end;

constructor TArcShape.Load( AStream: PStream);
begin
     inherited Load( AStream);
     if ( AStream <> nil)
     then begin
          AStream^.Read( Center, SizeOf( Center));
          AStream^.Read( Start, SizeOf( Start));
          AStream^.Read( Stop, SizeOf( Stop));
          AStream^.Read( ThirdPoint, SizeOf( ThirdPoint));
          AStream^.Read( Radius, SizeOf( Radius));
          AStream^.Read( StartAngle, SizeOf( StartAngle));
          AStream^.Read( StopAngle, SizeOf( StopAngle));
          AStream^.Read( Reversed, SizeOf( Reversed));
          end
     else begin
          Center.Assign( 0, 0);
          Start.Assign( 0, 0);
          Stop.Assign( 0, 0);
          ThirdPoint.Assign( 0, 0);
          Radius := 0;
          StartAngle := 0;
          StopAngle := 0;
          Reversed := False
          end;
end;

procedure TArcShape.Shift( ADelta: TFPoint);
begin
     Center.X := Center.X + ADelta.X;
     Center.Y := Center.Y + ADelta.Y;
     Start.X := Start.X + ADelta.X;
     Start.Y := Start.Y + ADelta.Y;
     Stop.X := Stop.X + ADelta.X;
     Stop.Y := Stop.Y + ADelta.Y;
end;

procedure TArcShape.MirrorX( AX: Float);
begin
     Center.MirrorX( AX);
     Start.MirrorX( AX);
     ThirdPoint.MirrorX( AX);
     Reversed := not Reversed;
     Calculate;
end;

procedure TArcShape.MirrorY( AY: Float);
begin
     Center.MirrorY( AY);
     Start.MirrorY( AY);
     ThirdPoint.MirrorY( AY);
     Reversed := not Reversed;
     Calculate;
end;

procedure TArcShape.Rotate90( ACenter: TFPoint);
begin
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TArcExShape.Create( var P1, P2, P3: TFPoint; AReversed: Boolean);
begin
     inherited Create;

     Center := P1;
     Start := P2;
     Stop := P3;
     Reversed := AReversed;
     Calculate;
end;

procedure TArcExShape.Calculate;
begin
     StartAngle := Center.AngleDeg( Start);
     StopAngle := Center.AngleDeg( Stop);
     StartRadius := Center.Distance( Start);
     StopRadius := Center.Distance( Stop);
end;

destructor TArcExShape.Destroy;
begin
     inherited Destroy;
end;

function TArcExShape.Clone: PGeneric;
begin
     Clone := New( PArcExShape, Create( Center, Start, Stop, Reversed));
end;

procedure TArcExShape.Draw( ACanvas: PDesignCanvas; ASelected: Boolean);
var VCenter: TPoint;
    VStartRadius, VStopRadius: Longint;
    Point: TPoint;
    S: string;
begin
     if ( ACanvas <> nil)
     then begin
          ACanvas^.ConvertToCanvasPos( Center, VCenter);
          ACanvas^.ConvertToCanavsLength( StartRadius, VStartRadius);
          ACanvas^.ConvertToCanavsLength( StopRadius, VStopRadius);
          if not ASelected
          then ACanvas^.SetPColor( clrSHAPE)
          else ACanvas^.SetPColor( clrSHAPESELECTED);
          SetLineStyle( SolidLn, 0, 3);
          if Reversed
          then ACanvas^.ArcEx( VCenter.X, VCenter.Y, StopAngle, StartAngle, VStopRadius, VStartRadius)
          else ACanvas^.ArcEx( VCenter.X, VCenter.Y, StartAngle, StopAngle, VStartRadius, VStopRadius);
          SetLineStyle( SolidLn, 0, 0);
          end;
end;

procedure TArcExShape.GetStartPoint( var AFPoint: TFPoint);
begin
     AFPoint := Start;
end;

procedure TArcExShape.GetStopPoint( var AFPoint: TFPoint);
begin
     AFPoint := Stop;
end;

function TArcExShape.GetLength: Float;
begin
end;

procedure TArcExShape.Fit( var AFRect: TFRect);
var P: TFPoint;
    R: Float;
begin
     if ( StartRadius > StopRadius)
     then R := StartRadius
     else R := StopRadius;
     P.Assign( Center.X - R, Center.Y - R);
     AFRect.FitPoint( P);
     P.Assign( Center.X + R, Center.Y + R);
     AFRect.FitPoint( P);
end;

procedure TArcExShape.AppendToPath( APath: PFPath);
const Delta = 5;
var LStartAngle, LStopAngle: Float;
    LStartRadius, LStopRadius: Float;
    LCenterX, LCenterY: Float;
    FSteps: Float;
    Steps: Integer;
    RadiusDelta: Float;

    X, Y: Float;
    Angle: Float;
    Radius: Float;
begin
     if (APath <> nil)
     then begin
          LCenterX := Center.X;
          LCenterY := Center.Y;

          if Reversed
          then begin
               LStartAngle := StopAngle;
               LStopAngle := StartAngle;
               LStartRadius := StopRadius;
               LStopRadius := StartRadius;
               end
          else begin
               LStartAngle := StartAngle;
               LStopAngle := StopAngle;
               LStartRadius := StartRadius;
               LStopRadius := StopRadius;
               end;

          if ( LStartAngle >= LStopAngle)
          then LStopAngle := LStopAngle + 360;

          FSteps := (LStopAngle - LStartAngle) / Delta;
          if (Frac( FSteps) > 0)
          then Steps := Trunc( FSteps) + 1
          else Steps := Trunc( FSteps);

          RadiusDelta := (LStopRadius - LStartRadius) / Steps;

          if Reversed
          then begin
               Angle := LStopAngle;
               Radius := LStopRadius;
               repeat
                  X := Radius * Cos( Angle * PI / 180) + LCenterX;
                  Y := Radius * Sin( Angle * PI / 180) + LCenterY;
                  APath^.AppendPoint( X, Y);
                  Angle := Angle - Delta;
                  Radius := Radius - RadiusDelta;
               until (Angle < LStartAngle);


               if ( Angle < LStartAngle)
               then begin
                    X := LStartRadius * Cos( LStartAngle * PI / 180) + LCenterX;
                    Y := LStartRadius * Sin( LStartAngle * PI / 180) + LCenterY;
                    APath^.AppendPoint( X, Y);
                    end;
               end
          else begin
               Angle := LStartAngle;
               Radius := LStartRadius;
               repeat
                  X := Radius * Cos( Angle * PI / 180) + LCenterX;
                  Y := Radius * Sin( Angle * PI / 180) + LCenterY;
                  APath^.AppendPoint( X, Y);
                  Angle := Angle + Delta;
                  Radius := Radius + RadiusDelta;
               until (Angle > LStopAngle);


               if ( Angle > LStopAngle)
               then begin
                    X := LStopRadius * Cos( LStopAngle * PI / 180) + LCenterX;
                    Y := LStopRadius * Sin( LStopAngle * PI / 180) + LCenterY;
                    APath^.AppendPoint( X, Y);
                    end;
               end;
          end;
end;

function TArcExShape.GetShapeID: Integer;
begin
     GetShapeID := 3;
end;

procedure TArcExShape.Save( AStream: PStream);
begin
     inherited Save( AStream);
     if ( AStream <> nil)
     then begin
          AStream^.Write( Center, SizeOf( Center));
          AStream^.Write( Start, SizeOf( Start));
          AStream^.Write( Stop, SizeOf( Stop));
          AStream^.Write( StartRadius, SizeOf( StartRadius));
          AStream^.Write( StopRadius, SizeOf( StopRadius));
          AStream^.Write( StartAngle, SizeOf( StartAngle));
          AStream^.Write( StopAngle, SizeOf( StopAngle));
          AStream^.Write( Reversed, SizeOf( Reversed));
          end;
end;

constructor TArcExShape.Load( AStream: PStream);
begin
     inherited Load( AStream);
     if ( AStream <> nil)
     then begin
          AStream^.Read( Center, SizeOf( Center));
          AStream^.Read( Start, SizeOf( Start));
          AStream^.Read( Stop, SizeOf( Stop));
          AStream^.Read( StartRadius, SizeOf( StartRadius));
          AStream^.Read( StopRadius, SizeOf( StopRadius));
          AStream^.Read( StartAngle, SizeOf( StartAngle));
          AStream^.Read( StopAngle, SizeOf( StopAngle));
          AStream^.Read( Reversed, SizeOf( Reversed));
          end
     else begin
          Center.Assign( 0, 0);
          Start.Assign( 0, 0);
          Stop.Assign( 0, 0);
          StartRadius := 0;
          StopRadius := 0;
          StartAngle := 0;
          StopAngle := 0;
          Reversed := False;
          end;
end;

procedure TArcExShape.Shift( ADelta: TFPoint);
begin
     Center.X := Center.X + ADelta.X;
     Center.Y := Center.Y + ADelta.Y;
     Start.X := Start.X + ADelta.X;
     Start.Y := Start.Y + ADelta.Y;
     Stop.X := Stop.X + ADelta.X;
     Stop.Y := Stop.Y + ADelta.Y;
end;

procedure TArcExShape.MirrorX( AX: Float);
begin
     Center.MirrorX( AX);
     Start.MirrorX( AX);
     Stop.MirrorX( AX);
     Reversed := not Reversed;
     Calculate;
end;

procedure TArcExShape.MirrorY( AY: Float);
begin
     Center.MirrorY( AY);
     Start.MirrorY( AY);
     Stop.MirrorY( AY);
     Reversed := not Reversed;
     Calculate;
end;

procedure TArcExShape.Rotate90( ACenter: TFPoint);
begin
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TDrawInfo.Create;
begin
     inherited Create;
     LastPoint.Assign( 0, 0);
     BasePos.Assign( 0, 0);
     MachineSettings.Create;
end;

destructor TDrawInfo.Destroy;
begin
     MachineSettings.Destroy;
     inherited Destroy;
end;

procedure TDrawInfo.Save( AStream: PStream);
begin
     if ( AStream <> nil)
     then AStream^.Write( LastPoint, SizeOf( LastPoint));
     MachineSettings.Save( AStream);
end;

constructor TDrawInfo.Load( AStream: PStream);
begin
     inherited Create;
     if ( AStream <> nil)
     then AStream^.Read( LastPoint, SizeOf( LastPoint))
     else LastPoint.Assign( 0, 0);
     MachineSettings.Load( AStream);
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TTool.Create( ACanvas: PDesignCanvas; AList: PTextList);
begin
     inherited Create;
     Canvas := ACanvas;
     List := AList;
end;

destructor TTool.Destroy;
begin
     if ( Canvas <> nil)
     then Canvas^.Tool := nil;
     inherited Destroy;
end;

procedure TTool.HandleEvent( var E: TEvent);
begin
end;

procedure TTool.CanvasUpdated;
begin
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TTowPointsTool.Create( ACanvas: PDesignCanvas; AList: PTextList);
begin
     inherited Create( ACanvas, AList);
     if ( Canvas <> nil)
     then StartPos := Canvas^.Info.LastPoint
     else LastPos.Assign( 0, 0);
     CurrentPos.Assign(0, 0);
     MouseDownPos.Assign(0, 0);
     CursorVisible := False;
     FeedbackVisible := False;
end;

destructor TTowPointsTool.Destroy;
begin
     if CursorVisible
     then CursorDraw( True);
     inherited Destroy;
end;

procedure TTowPointsTool.HandleEvent( var E: TEvent);
var CurrentMousePos: TPoint;
    FP: TFPoint;
begin
     if ((E.What and evMouse) <> 0)
     then begin
          if ( Canvas <> nil)
          then with Canvas^
               do begin
                  BeginDraw;
                  CurrentMousePos := E.MouseInfo.Where;
                  MakeLocal( CurrentMousePos);
                  if (( E.What = evMouseDown) and ( not GetState( sfDrag)))
                  then begin
                       if CursorVisible
                       then CursorDraw( False);
                       ConvertToLogicalPos( CurrentMousePos, CurrentPos, CanvasInfo.Snap);
                       MouseDownPos := CurrentPos;
                       StartPos := Info.LastPoint;
                       MouseDown( E.MouseInfo.Bottons);
                       FeedBackDraw;
                       ClearEvent( E);
                       CursorDraw( False);
                       BeginDrag;
                       end
                  else if (( E.What = evMouseUp) and ( GetState( sfDrag)))
                  then begin
                       if CursorVisible
                       then CursorDraw( False);
                       if FeedbackVisible
                       then FeedBackDraw;
                       ConvertToLogicalPos( CurrentMousePos, CurrentPos, CanvasInfo.Snap);
                       MouseUp;
                       ClearEvent( E);
                       EndDrag;
                       CursorDraw( True or False);
                       end
                  else if (( E.What = evMouseDrag) and ( GetState( sfDrag)))
                  then begin
                       ConvertToLogicalPos( CurrentMousePos, FP, CanvasInfo.Snap);
                       if (( FP.X <> CurrentPos.X) or ( FP.Y <> CurrentPos.Y))
                       then begin
                            if CursorVisible
                            then CursorDraw( False);
                            if FeedbackVisible
                            then FeedBackDraw;
                            CurrentPos := FP;
                            FeedBackDraw;
                            CursorDraw( False);
                            end;
                       ClearEvent( E);
                       end
                  else begin
                       if CursorVisible
                       then CursorDraw( False);
                       ConvertToLogicalPos( CurrentMousePos, CurrentPos, CanvasInfo.Snap);
                       CursorDraw( False);
                       ClearEvent( E);
                       end;
                  EndDraw;
                  end;
          end
end;

procedure TTowPointsTool.MouseDown;
begin
end;

procedure TTowPointsTool.MouseUp;
begin
end;

procedure TTowPointsTool.FeedBackDraw;
begin
end;

procedure TTowPointsTool.CursorDraw( AActivateViewPort: Boolean);
var VCurrentPos: TPoint;
    VStartPoint: TPoint;
begin
     if ( Canvas <> nil)
     then with (Canvas^)
          do begin
             if AActivateViewPort
             then BeginDraw;
             SetWriteMode( XORPut);
             SetPColor( clrCURSOR);
             ConvertToCanvasPos( CurrentPos, VCurrentPos);
             Line( VCurrentPos.X, 0, VCurrentPos.X, Size.Y);
             Line( 0, VCurrentPos.Y, Size.X, VCurrentPos.Y);
             Rectangle( VCurrentPos.X  - 5, VCurrentPos.Y  - 5, VCurrentPos.X  + 5, VCurrentPos.Y + 5);
             ConvertToCanvasPos( Info.LastPoint, VStartPoint);
             Rectangle( VStartPoint.X  - 5, VStartPoint.Y  - 5, VStartPoint.X  + 5, VStartPoint.Y + 5);
             Line( VStartPoint.X  - 2, VStartPoint.Y, VStartPoint.X + 2, VStartPoint.Y);
             Line( VStartPoint.X, VStartPoint.Y - 2, VStartPoint.X , VStartPoint.Y + 2);
             SetWriteMode( NormalPut);
             CursorVisible := True;
             if AActivateViewPort
             then EndDraw;
             end;
end;

procedure TTowPointsTool.CanvasUpdated;
begin
     CursorVisible := False;
     FeedbackVisible := False;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TLineTool.Create( ACanvas: PDesignCanvas; AList: PTextList);
begin
     inherited Create( ACanvas, AList);
end;

procedure TLineTool.MouseDown;
begin
end;

procedure TLineTool.MouseUp;
var NewShape: PShape;
begin
     if ( Canvas <> nil)
     then with Canvas^
          do begin
             BeginDraw;
             LastPos := CurrentPos;
             NewShape := New( PLineShape, Create( StartPos, LastPos));
             AppendShape( NewShape);
             NewShape^.GetStopPoint( Info.LastPoint);
             EndDraw;
             UpdateCommands;
             if ( List <> nil)
             then List^.WriteLn('Mouse down ....');
             end;
end;

procedure TLineTool.FeedBackDraw;
var VMouseDownPos,
    VStartPos,
    VCurrentPos: TPoint;
begin
     if ( Canvas <> nil)
     then with Canvas^
          do begin
             FeedbackVisible := not FeedbackVisible;
             SetWriteMode( XORPut);
             SetPColor( clrCURSOR);
             ConvertToCanvasPos( MouseDownPos, VMouseDownPos);
             ConvertToCanvasPos( StartPos, VStartPos);
             ConvertToCanvasPos( CurrentPos, VCurrentPos);
             Line( VMouseDownPos.X, VMouseDownPos.Y, VCurrentPos.X, VCurrentPos.Y);
             Line( VStartPos.X, VStartPos.Y, VCurrentPos.X, VCurrentPos.Y);
             SetWriteMode( NormalPut);
             end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TArcTool.Create( ACanvas: PDesignCanvas; AList: PTextList);
begin
     inherited Create( ACanvas, AList);
     ReversedAngle := False;
end;

procedure TArcTool.MouseDown( ABottons: Byte);
begin
     ReversedAngle := (ABottons <> $01);
end;

procedure TArcTool.MouseUp;
var NewShape: PGenericShape;
begin
     if ( Canvas <> nil)
     then with Canvas^
          do begin
             BeginDraw;
             LastPos := CurrentPos;
             {NewShape := New( PArcShape, Create( LastPos, StartPos, MouseDownPos, ReversedAngle));}

             NewShape := New( PGenericShape, Create);
             NewShape^.AssignArcPoints( LastPos, StartPos, MouseDownPos, ReversedAngle);
             AppendShape( NewShape);
             {NewShape^.Draw( Canvas, False);}
             NewShape^.GetStopPoint( Info.LastPoint);
             EndDraw;
             UpdateCommands;
             if ( List <> nil)
             then List^.WriteLn('Mouse down ....');
             end;
end;

procedure TArcTool.FeedBackDraw;
var VMouseDownPos,
    VStartPos,
    VCurrentPos: TPoint;
    VRadius: Longint;
    StartAngle, StopAngle, Radius: Float;
begin
     if ( Canvas <> nil)
     then with Canvas^
          do begin
             FeedbackVisible := not FeedbackVisible;
             SetWriteMode( XORPut);
             SetPColor( clrCURSOR);
             ConvertToCanvasPos( MouseDownPos, VMouseDownPos);
             ConvertToCanvasPos( StartPos, VStartPos);
             ConvertToCanvasPos( CurrentPos, VCurrentPos);

             StartAngle := CurrentPos.AngleDeg( StartPos);
             StopAngle := CurrentPos.AngleDeg( MouseDownPos);
             Radius := CurrentPos.Distance( StartPos);
             ConvertToCanavsLength( Radius, VRadius);

             if ( ReversedAngle)
             then Arc( VCurrentPos.X, VCurrentPos.Y, Round( StopAngle), Round( StartAngle), VRadius)
             else Arc( VCurrentPos.X, VCurrentPos.Y, Round( StartAngle), Round( StopAngle), VRadius);
             Line( VMouseDownPos.X, VMouseDownPos.Y, VCurrentPos.X, VCurrentPos.Y);
             Line( VStartPos.X, VStartPos.Y, VCurrentPos.X, VCurrentPos.Y);

             SetWriteMode( NormalPut);
             end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TArcExTool.Create( ACanvas: PDesignCanvas; AList: PTextList);
begin
     inherited Create( ACanvas, AList);
     ReversedAngle := False;
end;

procedure TArcExTool.MouseDown( ABottons: Byte);
begin
     ReversedAngle := (ABottons <> $01);
end;

procedure TArcExTool.MouseUp;
var NewShape: PGenericShape;
begin
     if ( Canvas <> nil)
     then with Canvas^
          do begin
             BeginDraw;
             LastPos := CurrentPos;
             {NewShape := New( PArcExShape, Create( LastPos, StartPos, MouseDownPos, ReversedAngle));}
             NewShape := New( PGenericShape, Create);
             NewShape^.AssignArcExPoints( LastPos, StartPos, MouseDownPos, ReversedAngle);

             AppendShape( NewShape);
             NewShape^.GetStopPoint( Info.LastPoint);
             EndDraw;
             UpdateCommands;
             if ( List <> nil)
             then List^.WriteLn('Mouse down ....');
             end;
end;

procedure TArcExTool.FeedBackDraw;
var VMouseDownPos,
    VStartPos,
    VCurrentPos: TPoint;
    VStartRadius, VStopRadius: Longint;
    StartAngle, StopAngle, StartRadius, StopRadius: Float;
begin
     if ( Canvas <> nil)
     then with Canvas^
          do begin
             FeedbackVisible := not FeedbackVisible;
             SetWriteMode( XORPut);
             SetPColor( clrCURSOR);
             ConvertToCanvasPos( MouseDownPos, VMouseDownPos);
             ConvertToCanvasPos( StartPos, VStartPos);
             ConvertToCanvasPos( CurrentPos, VCurrentPos);

             StartAngle := CurrentPos.AngleDeg( StartPos);
             StopAngle := CurrentPos.AngleDeg( MouseDownPos);
             StartRadius := CurrentPos.Distance( StartPos);
             ConvertToCanavsLength( StartRadius, VStartRadius);
             StopRadius := CurrentPos.Distance( MouseDownPos);
             ConvertToCanavsLength( StopRadius, VStopRadius);

             if ReversedAngle
             then ArcEx( VCurrentPos.X, VCurrentPos.Y, Round( StopAngle), Round( StartAngle), VStopRadius, VStartRadius)
             else ArcEx( VCurrentPos.X, VCurrentPos.Y, Round( StartAngle), Round( StopAngle), VStartRadius, VStopRadius);
             Line( VMouseDownPos.X, VMouseDownPos.Y, VCurrentPos.X, VCurrentPos.Y);
             Line( VStartPos.X, VStartPos.Y, VCurrentPos.X, VCurrentPos.Y);

             SetWriteMode( NormalPut);
             end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TFeedBackPanel.Create( R: TRect);
begin
     inherited Create( R);
     State := sfVisible or sfEnabled;
     EventMask := $00;

     Pos.Assign( 0, 0);
     BasePos.Assign( 0, 0);
     Zoom := 1;
     GridStyle := 1;
     Snap := True;
end;

procedure TFeedBackPanel.DisplayPos( AActivateViewPort: Boolean);
var S1: string[20];
begin
     if AActivateViewPort
     then BeginDraw;
     SetPFillPattern( clr3DBACK, SolidPattern);
     Bar( 30, 2, Size.X - 3, 45);
     SetPColor( clr3DTEXT);
     Str( Pos.X:0:2, S1);
     OutTextXY( 30, 5, S1);
     Str( Pos.Y:0:2, S1);
     OutTextXY( 30, 15, S1);
     Str( (Pos.X - BasePos.X):0:2, S1);
     OutTextXY( 30, 25, S1);
     Str( (Pos.Y - BasePos.Y):0:2, S1);
     OutTextXY( 30, 35, S1);
     if AActivateViewPort
     then EndDraw;
end;

procedure TFeedBackPanel.DisplayZoom( AActivateViewPort: Boolean);
var S: string[30];
begin
     if AActivateViewPort
     then BeginDraw;
     SetPFillPattern( clr3DBACK, SolidPattern);
     Bar( 30, 46, Size.X - 3, 60);
     SetPColor( clr3DTEXT);
     Str( Zoom:0:2, S);
     S := '1:' + S;
     OutTextXY( 30, 50, S);
     if AActivateViewPort
     then EndDraw;
end;

procedure TFeedBackPanel.DisplaySnap( AActivateViewPort: Boolean);
begin
     if AActivateViewPort
     then BeginDraw;
     SetPFillPattern( clr3DBACK, SolidPattern);
     Bar( 30, 64, Size.X - 3, 75);
     SetPColor( clr3DTEXT);
     if Snap
     then OutTextXY( 30, 65, 'On')
     else OutTextXY( 30, 65, 'Off');
     if AActivateViewPort
     then EndDraw;
end;

procedure TFeedBackPanel.DisplayGridStyle( AActivateViewPort: Boolean);
begin
     if AActivateViewPort
     then BeginDraw;
     SetPFillPattern( clr3DBACK, SolidPattern);
     Bar( 30, 79, Size.X - 3, 90);
     SetPColor( clr3DTEXT);
     case GridStyle
     of 1: OutTextXY( 30, 80, 'Lines');
        2: OutTextXY( 30, 80, 'Dots');
        else
            OutTextXY( 30, 80, 'None');
        end;
     if AActivateViewPort
     then EndDraw;
end;

procedure TFeedBackPanel.Draw;
begin
     BeginDraw;

     Draw3DInFrame( 0, 0, Size.X - 1, Size.Y - 1, clr3D0, clr3D1, clr3D2, clr3D3);
     SetPFillPattern( clr3DBACK, SolidPattern);
     Bar( 2, 2, Size.X - 3, Size.Y - 3);
     OutTextXY( 5, 05, 'X :');
     OutTextXY( 5, 15, 'Y :');
     OutTextXY( 5, 25, 'RX:');
     OutTextXY( 5, 35, 'RY:');
     OutTextXY( 5, 50, '  :');
     OutTextXY( 5, 65, '  :');
     OutTextXY( 5, 80, '  :');
     Rectangle( 4, 50 - 2, 14, 58);
     Rectangle( 8, 50 + 2, 14, 58);
     Line( 9, 63, 9, 73);
     Line( 4, 68, 14, 68);
     Circle( 9, 68, 2);

     Line( 5, 78, 5, 88);
     Line( 7, 78, 7, 88);
     Line( 9, 78, 9, 88);
     Line( 11, 78, 11, 88);
     Line( 13, 78, 13, 88);
     Line( 4, 79, 14, 79);
     Line( 4, 81, 14, 81);
     Line( 4, 83, 14, 83);
     Line( 4, 85, 14, 85);
     Line( 4, 87, 14, 87);

     DisplayPos( False);
     DisplayZoom( False);
     DisplaySnap( False);
     DisplayGridStyle( False);
     EndDraw;
end;

procedure TFeedBackPanel.UpdatePos( var APos: TFPoint);
begin
     if (( APos.X <> Pos.X) or ( APos.Y <> Pos.Y))
     then begin
          Pos := APos;
          DisplayPos( True);
          end;
end;

procedure TFeedBackPanel.UpdateBasePos( var ABasePos: TFPoint);
begin
     if (( ABasePos.X <> BasePos.X) or ( ABasePos.Y <> BasePos.Y))
     then begin
          BasePos := ABasePos;
          DisplayPos( True);
          end;
end;

procedure TFeedBackPanel.UpdateZoom( var AZoom: Float);
begin
     if (Zoom <> AZoom)
     then begin
          Zoom := AZoom;
          DisplayZoom( True);
          end;
end;

procedure TFeedBackPanel.UpdateSnap( var ASnap: Boolean);
begin
     if (Snap <> ASnap)
     then begin
          Snap := ASnap;
          DisplaySnap( True);
          end;
end;

procedure TFeedBackPanel.UpdateGridStyle( var AStyle: Byte);
begin
     if (GridStyle <> AStyle)
     then begin
          GridStyle := AStyle;
          DisplayGridStyle( True);
          end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

procedure TAboutUltraSoftDlg.Draw;
var I: Integer;
begin
     inherited Draw;
     BeginDraw;
     InitClientViewPort;

     SetFillPattern( SolidPattern, 7);
     Bar( 0, 0, Size.X - 101, 100 - 1);
     SetFillPattern( SolidPattern, 13);
     Bar( 0, 100, Size.X - 101, Size.Y - 1);
     SetFillPattern( SolidPattern, 2);
     Bar( Size.X - 100, 0, Size.X - 1, Size.Y - 1);
     SetFillPattern( SolidPattern, 0);
     Bar( 0, 5, 110, 31);
     SetColor( 0);
     I := 5;
     while I <= 31
     do begin
        if Odd(I)
        then Line( 110, I, 110 + I, I)
        else Line( 110, I, 110 + I div 2, I);
        I := I + 1;
        end;
     SetTextStyle( 2{10}{2}, HorizDir, 7);
     OutFramedTextXY( 5, 5, 'ULTRASoft', 6, 5);
     SetTextStyle(DefaultFont, HorizDir, 0);
     SetColor( 8);
     OutTextXY( 10, 15 * 3,  'Software design & implementation');
     SetColor( 0);
     OutTextXY( 10, 15 * 5,  'Russlan Kafri');
     SetColor( 10);
     OutTextXY( 10, 15 * 8,  'Hama - Syria');
     OutTextXY( 10, 15 * 9,  'Tel: +46 722 77 85 08');
     OutTextXY( 10, 15 * 10, 'E-Mail: russlank@gmail.com');
     OutTextXY( 10, 15 * 11, '');
     OutTextXY( 10, 15 * 12, '');
     OutTextXY( 10, 15 * 13, '');
     EndDraw;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

procedure TAboutSabbaghDlg.Draw;
var I: Integer;
begin
     inherited Draw;
     BeginDraw;
     InitClientViewPort;
     SetFillPattern( SolidPattern, 7);
     Bar( 0, 0, Size.X - 101, 100 - 1);
     SetFillPattern( SolidPattern, 13);
     Bar( 0, 100, Size.X - 101, Size.Y - 1);
     SetFillPattern( SolidPattern, 2);
     Bar( Size.X - 100, 0, Size.X - 1, Size.Y - 1);
     SetFillPattern( SolidPattern, 0);
     Bar( 0, 5, 350, 31);
     SetColor( 0);
     I := 5;
     while I <= 31
     do begin
        if Odd(I)
        then Line( 350, I, 350 + I, I)
        else Line( 350, I, 350 + I div 2, I);
        I := I + 1;
        end;
     SetTextStyle( 2, HorizDir, 7);
     OutFramedTextXY( 5, 5, 'SABBAGH INDUSTRIAL AUTOMATION', 6, 5);
     SetTextStyle( DefaultFont, HorizDir, 0);
     SetColor( 8);
     OutTextXY( 10, 15 * 3, 'Control design & implementation');
     SetColor( 0);
     OutTextXY( 10, 15 * 4, 'Eng. Khaled Sabbagh, Eng. Jamal Sabbagh &');
     OutTextXY( 10, 15 * 5, 'Ass. Eng. Jihad Jarrah');
     SetColor( 10);
     OutTextXY( 10, 15 * 8, 'Aleppo - Syria');
     OutTextXY( 10, 15 * 9,'P.O.Box: 9934');
     OutTextXY( 10, 15 * 11, 'Tel: +963-21-2232979');
     OutTextXY( 10, 15 * 12,'     +963-21-2237832');
     EndDraw;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

procedure TAboutMaktabiDlg.Draw;
var I: Integer;
    procedure DrawSymbol( AX, AY: Integer);
    var I1: Integer;
        Width, Height: Integer;
    begin
         Width := 30;
         Height := 45;

         SetLineStyle(SolidLn, 0, 3);
         SetFillPattern(SolidPattern, 2);
         Bar(AX + 0,AY + 0,AX + 52,AY +Height);
         SetColor(3);
         for I1 := 0 to 7
         do begin
            PieSlice(AX + 23, AY + 23, (2 * I1 + 0) * 360 div 16, (2 * I1 + 1) * 360 div 16, 17);
            PieSlice(AX + 23, AY + 23, (2 * I1 + 1) * 360 div 16, (2 * I1 + 2) * 360 div 16, 14);
            end;
         SetColor( 2);
         PieSlice(AX + 23, AY + 23, 0, 360, 11);
         SetLineStyle(SolidLn, 0, 1);
         Bar(AX + 23,AY + 13,AX + 50, AY + 32);
         SetTextStyle(7, HorizDir, 3);
         OutFramedTextXY( AX + 28, AY + 7, 'M', 3, 2);
    end;
begin
     inherited Draw;
     BeginDraw;
     InitClientViewPort;
     SetFillPattern( SolidPattern, 7);
     Bar( 0, 0, Size.X - 101, 100 - 1);
     SetFillPattern( SolidPattern, 13);
     Bar( 0, 100, Size.X - 101, Size.Y - 1);
     SetFillPattern( SolidPattern, 2);
     Bar( Size.X - 100, 0, Size.X - 1, Size.Y - 1);
     SetFillPattern( SolidPattern, 0);
     Bar( 0, 5, 360, 31);
     SetColor( 0);
     I := 5;
     while I <= 31
     do begin
        if Odd(I)
        then Line( 360, I, 360 + I, I)
        else Line( 360, I, 360 + I div 2, I);
        I := I + 1;
        end;
     SetTextStyle( 2, HorizDir, 7);
     OutFramedTextXY( 5, 5, 'MAKTABI INDUSTRIAL CORPORATION', 6, 5);
     DrawSymbol( Size.X - 80, 30);
     SetTextStyle(DefaultFont, HorizDir, 0);
     SetColor( 8);
     OutTextXY( 10, 15 * 3,  'Machine design & implementation');
     SetColor( 0);
     OutTextXY( 10, 15 * 5,  'Mactabi Co. Stuff');
     SetColor( 10);
     OutTextXY( 10, 15 * 8,  'Aleppo - Syria');
     OutTextXY( 10, 15 * 9, 'Tel: +963-21-2662901');
     OutTextXY( 10, 15 * 10, '     +963-21-2663766');
     OutTextXY( 10, 15 * 11, 'E-Mail: maktabi_ind_co@net.sy');
     EndDraw;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TSettingsDlg.Create( AInfo: PMachineSettings);
var P: TPoint;
    R: TRect;
begin
     P.Assign( 500, 320);
     inherited Create( P, 'Settings');
     Info := AInfo;
     Lock;

     StepLengthEdit := New( PFloatEdit, Create( 170, 20, 0, 0.0, 10));
     MaxXStepLengthEdit := New( PFloatEdit, Create( 170, 60, 0, 1 / PULSES_PER_MM_X, 100));
     MaxYStepLengthEdit := New( PFloatEdit, Create( 170, 100, 0, 1 / PULSES_PER_MM_Y, 100));
     {SpeedAutoCheck := New( PCheckBox, Create( 170, 140));}

     R.A.X := 170;
     R.A.Y := 180;
     R.B.X := 420;
     R.B.Y := 210;
     {SpeedScroll := New( PScrollControl, Create( R, 100, 25));}
     SpeedScroll := New( PScrollControl, Create( R, 100, 25));

     InsertChild( StepLengthEdit);
     InsertChild( MaxXStepLengthEdit);
     InsertChild( MaxYStepLengthEdit);
     InsertChild( SpeedScroll);
     {InsertChild( SpeedAutoCheck);}

     InsertChild( New( PButton, Create( 265, 250, 100 + metSHADOWSIZE, 30, '&Ok', cmOk, keyO)));
     InsertChild( New( PButton, Create( 375, 250, 100 + metSHADOWSIZE, 30, '&Cancel', cmCancel, keyC)));

     AddLabel( 20, 25 + 3, 'Feed step length');
     AddLabel( 20, 65 + 3, 'Max X step length');
     AddLabel( 20, 105 + 3, 'Max Y step length');
     {AddLabel( 20, 145 + 3, 'Feed speed auto');}
     AddLabel( 20, 190 + 3, 'Feed speed');

     Unlock;
end;

procedure TSettingsDlg.BeforeExecuteDlg;
begin
     if ( Info <> nil)
     then begin
          StepLengthEdit^.SetValue( Info^.GetStepLength);
          MaxXStepLengthEdit^.SetValue( Info^.MaxXStepLength);
          MaxYStepLengthEdit^.SetValue( Info^.MaxYStepLength);
          {SpeedAutoCheck^.SetValue( Info^.SpeedAuto);}
          SpeedScroll^.SetValue( Round(( Info^.SurfaceSpeed / ANALOG_SPEED_RANGE) * 100));
          end;
end;

procedure TSettingsDlg.AfterExecuteDlg;
begin
     if ( Info <> nil)
     then begin
          Info^.StepLength := StepLengthEdit^.GetValue;
          Info^.MaxXStepLength := MaxXStepLengthEdit^.GetValue;
          Info^.MaxYStepLength := MaxYStepLengthEdit^.GetValue;
          {Info^.SpeedAuto := SpeedAutoCheck^.GetValue;}
          Info^.SurfaceSpeed := Round( SpeedScroll^.GetValue * ( ANALOG_SPEED_RANGE / 100));
          if ( Info^.SurfaceSpeed > MAXIMUM_ANALOG_SPEED_VALUE)
          then Info^.SurfaceSpeed := MAXIMUM_ANALOG_SPEED_VALUE
          else if ( Info^.SurfaceSpeed < MINIMUM_ANALOG_SPEED_VALUE)
          then Info^.SurfaceSpeed := MINIMUM_ANALOG_SPEED_VALUE;
          end;
end;

function TSettingsDlg.ValidateData: Boolean;
var Result: Boolean;
begin
     Result := False;
     if not StepLengthEdit^.ValidateString
     then StepLengthEdit^.SetFocus
     else if not MaxXStepLengthEdit^.ValidateString
     then MaxXStepLengthEdit^.SetFocus
     else if not MaxYStepLengthEdit^.ValidateString
     then MaxYStepLengthEdit^.SetFocus
     else Result := True;

     if Result
     then ValidateData := True
     else begin
          MistakeBeep;
          ValidateData := False;
          end
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor THead.Create( AHorizontalPos: Float);
begin
     inherited Create;
     Draged := False;
     HorizontalPos := AHorizontalPos;
end;

destructor THead.Destroy;
begin
     inherited Destroy;
end;

procedure THead.HandleEvent( var E: TEvent; ARow: PRow; APanel: PHeadsPanel; ASelected: Boolean);
var WindowXPos: Longint;
    WindowYPos: Longint;
    MousePos: TPoint;
    TuchPosY: Integer;
    NewPos: Float;
begin
     if (( ARow = nil) or ( APanel = nil) or (E.What = evNothing)) then Exit;

     if ( Draged)
     then begin
          if ( E.What = evMouseUp)
          then begin
               if ( Draged)
               then begin
                    DrawDraged( ARow, APanel, ASelected);
                    Draged := False;
                    APanel^.EndDrag;
                    APanel^.ClearEvent( E);
                    APanel^.Lock;
                    ARow^.SelectHead( @Self, APanel);
                    APanel^.UnLock;
                    APanel^.Update;
                    E.What := evCommand;
                    E.Command := cmUpdatePreview;
                    APanel^.PutEvent( E);
                    E.Command := cmUpdateHeadCords;
                    APanel^.PutEvent( E);
                    APanel^.ClearEvent( E);
                    end;
               end
          else if ( E.What = evMouseDrag)
          then begin
               if ( Draged)
               then begin
                    MousePos := E.MouseInfo.Where;
                    APanel^.MakeLocal( MousePos);
                    WindowXPos := TuchPosX + MousePos.X;
                    APanel^.ConvertToLogicalX( WindowXPos, NewPos, True);
                    if ( NewPos <> HorizontalPos)
                    then begin
                         DrawDraged( ARow, APanel, ASelected);
                         HorizontalPos := NewPos;
                         DrawDraged( ARow, APanel, ASelected);
                         E.What := evCommand;
                         E.Command := cmUpdatePreview;
                         APanel^.PutEvent( E);
                         E.Command := cmUpdateHeadCords;
                         APanel^.PutEvent( E);
                         end;
                    APanel^.ClearEvent( E);
                    end;
               end;
          end
     else begin
          if ( E.What = evMouseDown)
          then begin
               if ( not APanel^.GetState( sfDrag))
               then begin
                    MousePos := E.MouseInfo.Where;
                    APanel^.MakeLocal( MousePos);
                    APanel^.ConvertToWindowY( ARow^.VerticalPos, WindowYPos);
                    APanel^.ConvertToWindowX( HorizontalPos, WindowXPos);
                    TuchPosX := WindowXPos - MousePos.X;
                    TuchPosY := WindowYPos - MousePos.Y;
                    if (( Abs( TuchPosX) < 3) and (Abs( TuchPosY) < 3))
                    then begin
                         Draged := True;
                         APanel^.ClearEvent( E);
                         DrawDraged( ARow, APanel, ASelected);
                         APanel^.BeginDrag;
                         end;
                    end;
               end;
          end;

end;

procedure THead.Draw( ARow: PRow; APanel: PHeadsPanel; AInitViewPort: Boolean; ASelected: Boolean);
var Pos: TPoint;
    LPos: TFPoint;
begin
     if (( ARow = nil) or ( APanel = nil)) then Exit;
     if AInitViewPort
     then APanel^.BeginDraw;

     LPos.Assign( HorizontalPos, ARow^.VerticalPos);
     APanel^.ConvertToWindowPos( LPos, Pos);
     if ASelected
     then APanel^.SetPColor( clrGUIDELINES)
     else APanel^.SetPColor( clrGUIDELINES);
     {Rectangle( Pos.X - 10, Pos.Y - 10, Pos.X + 10, Pos.Y + 10);
     Rectangle( Pos.X - 9, Pos.Y - 9, Pos.X + 9, Pos.Y + 9);}
     Rectangle( Pos.X - 3, Pos.Y - 3, Pos.X + 3, Pos.Y + 3);
     if ASelected
     then APanel^.SetPFillPattern( clrGUIDELINES , SolidPattern)
     else APanel^.SetPFillPattern( clrGUIDELINES , LightPattern);
     {APanel^.Bar( Pos.X - 8, Pos.Y - 8, Pos.X + 8, Pos.Y + 8);}
     APanel^.Bar( Pos.X - 2, Pos.Y - 2, Pos.X + 2, Pos.Y + 2);

     if AInitViewPort
     then APanel^.EndDraw;
end;

procedure THead.DrawDraged( ARow: PRow; APanel: PHeadsPanel; ASelected: Boolean);
var Pos: TPoint;
    LPos: TFPoint;
begin
     if ((ARow = nil) or ( APanel = nil)) then Exit;
     APanel^.BeginDraw;
     LPos.Assign( HorizontalPos, ARow^.VerticalPos);
     APanel^.ConvertToWindowPos( LPos, Pos);
     APanel^.SetPColor( clrCURSOR);
     SetWriteMode( XORPut);
     {Rectangle( Pos.X - 10, Pos.Y - 10, Pos.X + 10, Pos.Y + 10);
     Rectangle( Pos.X - 9, Pos.Y - 9, Pos.X + 9, Pos.Y + 9);}
     Rectangle( Pos.X - 3, Pos.Y - 3, Pos.X + 3, Pos.Y + 3);
     SetWriteMode( NormalPut);
     APanel^.EndDraw;
end;

function THead.GetHorizontalPos: Float;
begin
     GetHorizontalPos := HorizontalPos;
end;

procedure THead.SetHorizontalPos( APos: Float);
begin
     HorizontalPos := APos;
end;

procedure THead.SaveData( AStream: PStream);
begin
     if ( AStream <> nil)
     then begin
          AStream^.Write( HorizontalPos, SizeOf( HorizontalPos));
          end;
end;

procedure THead.WritePositions( AStream: PStream);
var S: string;
begin
     if ( AStream <> nil)
     then begin
          Str( HorizontalPos:0:3, S);
          S := '   X = ' + S;
          AStream^.WriteStr( S);
          AStream^.NewLine;
          end;
end;

procedure THead.LoadData( AStream: PStream);
begin
     if ( AStream <> nil)
     then begin
          AStream^.Read( HorizontalPos, SizeOf( HorizontalPos));
          end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TRow.Create( AVerticalPos: Float);
begin
     inherited Create;
     VerticalPos := AVerticalPos;
     Heads.Create;
     Draged := False;
end;

destructor TRow.Destroy;
begin
     Heads.Destroy;
     inherited Destroy;
end;

procedure TRow.HandleEvent( var E: TEvent; APanel: PHeadsPanel; ASelected: Boolean);
var ScanHead: PHead;
    MousePos: TPoint;
    WindowYPos: Longint;
    NewVerticalPos: Float;
    TheHeadIsSelected: Boolean;
    NewPos: Float;
begin
     if (( APanel = nil) or (E.What = evNothing)) then Exit;

     if ( Draged)
     then begin
          if ( E.What = evMouseUp)
          then begin
               if ( Draged)
               then begin
                    DrawDraged( APanel, ASelected);
                    Draged := False;
                    APanel^.EndDrag;
                    APanel^.ClearEvent( E);
                    APanel^.Lock;
                    APanel^.SelectRow( @Self);
                    APanel^.Unlock;
                    APanel^.Update;
                    E.What := evCommand;
                    E.Command := cmUpdatePreview;
                    APanel^.PutEvent( E);
                    E.Command := cmUpdateHeadCords;
                    APanel^.PutEvent( E);
                    APanel^.ClearEvent( E);
                    end;
               end
          else if ( E.What = evMouseDrag)
          then begin
               if ( Draged)
               then begin
                    MousePos := E.MouseInfo.Where;
                    APanel^.MakeLocal( MousePos);
                    WindowYPos := TuchPosY + MousePos.Y;
                    APanel^.ConvertToLogicalY( WindowYPos, NewPos, True);

                    if ( NewPos <> VerticalPos)
                    then begin
                         DrawDraged( APanel, ASelected);
                         VerticalPos := NewPos;
                         DrawDraged( APanel, ASelected);
                         end;
                    APanel^.ClearEvent( E);
                    end;
               end;

          end
     else begin
          ScanHead := PHead( Heads.GetLast);
          TheHeadIsSelected := ASelected;
          while ( ScanHead <> nil)
          do begin
             ScanHead^.HandleEvent( E, @Self, APanel, TheHeadIsSelected);
             TheHeadIsSelected := False;
             if E.What = evNothing
             then break;
             ScanHead := PHead( Heads.GetPrev);
             end;

          if ( E.What = evMouseDown)
          then begin
               if ( not APanel^.GetState( sfDrag))
               then begin
                    MousePos := E.MouseInfo.Where;
                    APanel^.MakeLocal( MousePos);
                    APanel^.ConvertToWindowY( VerticalPos, WindowYPos);
                    TuchPosY := WindowYPos - MousePos.Y;
                    if ( Abs( TuchPosY) < 4)
                    then begin
                         Draged := True;
                         APanel^.ClearEvent( E);
                         DrawDraged( APanel, ASelected);
                         APanel^.BeginDrag;
                         end;
                    end;
               end;
          end;
end;

procedure TRow.Draw( APanel: PHeadsPanel; AInitViewPort: Boolean; ASelected: Boolean);
var ScanHead: PHead;
    YPos: Longint;
    SelectedHead: PHead;
begin
     if ( APanel = nil) then Exit;

     if AInitViewPort
     then APanel^.BeginDraw;

     APanel^.ConvertToWindowY( VerticalPos, YPos);

     if ASelected
     then APanel^.SetPColor( clr3D3)
     else APanel^.SetPColor( clr3D2);

     {APanel^.Line( 0, YPos - 5, APanel^.Size.X, YPos - 5);
     APanel^.Line( 0, YPos - 4, APanel^.Size.X, YPos - 4);

     APanel^.Line( 0, YPos + 4, APanel^.Size.X, YPos + 4);
     APanel^.Line( 0, YPos + 5, APanel^.Size.X, YPos + 5);}

     APanel^.Line( 0, YPos - 2, APanel^.Size.X - 20, YPos - 2);
     APanel^.Line( 0, YPos + 2, APanel^.Size.X - 20, YPos + 2);

     APanel^.Line( APanel^.Size.X - 20, YPos - 4, APanel^.Size.X, YPos - 4);
     APanel^.Line( APanel^.Size.X - 20, YPos + 4, APanel^.Size.X, YPos + 4);

     APanel^.Line( APanel^.Size.X - 20, YPos - 2, APanel^.Size.X - 20, YPos - 4);
     APanel^.Line( APanel^.Size.X - 20, YPos + 2, APanel^.Size.X - 20, YPos + 4);

     APanel^.SetPFillPattern( clr3D1 , SolidPattern);
     APanel^.Bar( 0, YPos - 1, APanel^.Size.X - 20, YPos + 1);
     APanel^.Bar( APanel^.Size.X - 19, YPos - 3, APanel^.Size.X, YPos + 3);

     SelectedHead := PHead( Heads.GetLast);
     ScanHead := PHead( Heads.GetFirst);
     while ( ScanHead <> nil)
     do begin
        ScanHead^.Draw( @Self, APanel, False, ASelected and (SelectedHead = ScanHead));
        ScanHead := PHead( Heads.GetNext);
        end;

     if AInitViewPort
     then APanel^.EndDraw;
end;

procedure TRow.AppendHead( AHead: PHead);
begin
     if ( AHead <> nil)
     then Heads.PushLast( AHead);
end;

procedure TRow.DrawDraged( APanel: PHeadsPanel; ASelected: Boolean);
var YPos: Longint;
begin
     if ( APanel = nil) then Exit;

     APanel^.BeginDraw;
     APanel^.SetPColor( clrCURSOR);
     SetWriteMode( XORPut);
     APanel^.ConvertToWindowY( VerticalPos, YPos);
     {APanel^.Line( 0, YPos - 5, APanel^.Size.X, YPos - 5);
     APanel^.Line( 0, YPos - 4, APanel^.Size.X, YPos - 4);
     APanel^.Line( 0, YPos + 4, APanel^.Size.X, YPos + 4);
     APanel^.Line( 0, YPos + 5, APanel^.Size.X, YPos + 5);}
     APanel^.Line( 0, YPos - 2, APanel^.Size.X, YPos - 2);
     APanel^.Line( 0, YPos + 2, APanel^.Size.X, YPos + 2);
     SetWriteMode( NormalPut);
     APanel^.EndDraw;
end;

function TRow.GetVerticalPos: Float;
begin
     GetVerticalPos := VerticalPos;
end;

procedure TRow.SetVertialPos( APos: Float);
begin
     VerticalPos := APos;
end;

procedure TRow.GetHeadsPoses( AFPath: PFPath);
var ScanHead: PHead;
begin
     if (AFPath <> nil)
     then begin
          ScanHead := PHead( Heads.GetFirst);
          while ( ScanHead <> nil)
          do begin
             AFPath^.AppendPoint( ScanHead^.GetHorizontalPos, VerticalPos);
             ScanHead := PHead( Heads.GetNext);
             end;
          end;
end;

function TRow.SelectHead( AHead: PHead; APanel: PHeadsPanel): Boolean;
var Selected: PHead;
    Update: Boolean;
begin
     Update := False;

     Selected := PHead( Heads.GetLast);
     if ( AHead <> Selected)
     then begin
          if ( AHead <> nil)
          then begin
               Heads.RemoveFromCollection( AHead);
               Heads.PushLast( AHead);
               Update := True;
               end;
          end;
     if ( APanel <> nil)
     then begin
          APanel^.Lock;
          if APanel^.SelectRow( @Self)
          then Update := True;
          APanel^.Unlock;
          if Update
          then APanel^.Update;
          end;

     SelectHead := Update;
end;

function TRow.GetSelectedHead: PHead;
begin
     GetSelectedHead := PHead( Heads.GetLast);
end;

procedure TRow.SaveData( AStream: PStream);
var HeadsCount: Longint;
    ScanHead: PHead;
begin
     if ( AStream <> nil)
     then begin
          HeadsCount := Heads.GetItemsCount;
          AStream^.Write( VerticalPos, SizeOf( VerticalPos));
          AStream^.Write( HeadsCount, SizeOf( HeadsCount));
          ScanHead := PHead( Heads.GetFirst);
          while ( ScanHead <> nil)
          do begin
             ScanHead^.SaveData( AStream);
             ScanHead := PHead( Heads.GetNext);
             end;
          end;
end;

procedure TRow.WritePositions( AStream: PStream);
var ScanHead: PHead;
    S: string;
begin
     if ( AStream <> nil)
     then begin
          Str( VerticalPos:0:3, S);
          S := 'Y = ' + S;
          AStream^.WriteStr( S);
          AStream^.NewLine;
          ScanHead := PHead( Heads.GetFirst);
          while ( ScanHead <> nil)
          do begin
             ScanHead^.WritePositions( AStream);
             ScanHead := PHead( Heads.GetNext);
             end;
          AStream^.NewLine;
          end;
end;


procedure TRow.LoadData( AStream: PStream);
var HeadsCount: Longint;
    NewHead: PHead;
begin
     if ( AStream <> nil)
     then begin
          Heads.Clear;
          AStream^.Read( VerticalPos, SizeOf( VerticalPos));
          AStream^.Read( HeadsCount, SizeOf( HeadsCount));
          while ( HeadsCount > 0)
          do begin
             NewHead := New( PHead, Create(0));
             NewHead^.LoadData( AStream);
             Heads.PushLast( NewHead);
             HeadsCount := HeadsCount - 1;
             end;
          end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor THeadCordsPanel.Create( var R: TRect; AHeadsPanel: PHeadsPanel);
begin
     inherited Create( R);
     State := sfVisible or sfEnabled;
     EventMask := evCommand;
     HeadsPanel := AHeadsPanel;

     LastPos.Assign( 0, 0);
end;

destructor THeadCordsPanel.Destroy;
begin
     inherited Destroy;
end;


procedure THeadCordsPanel.ShowNewCords( AInitViewPort: Boolean; ASkipLastValueTest: Boolean);
var NewPos: TFPoint;
    S1, S2: string;
    CurrentRow: PRow;
    CurrentHead: PHead;
begin
     if AInitViewPort
     then BeginDraw;

     if ( HeadsPanel <> nil)
     then begin
          CurrentRow := HeadsPanel^.GetSelectedRow;
          CurrentHead := HeadsPanel^.GetSelectedHead;
          if ( CurrentRow <> nil)
          then Str( CurrentRow^.GetVerticalPos:0:2, S2)
          else S2 := '----';
          if ( CurrentHead <> nil)
          then Str( CurrentHead^.GetHorizontalPos:0:2, S1)
          else S1 := '----';
          if (ASkipLastValueTest or (( NewPos.X <> LastPos.X) or ( NewPos.Y <> LastPos.Y)))
          then begin
               SetPFillPattern( clr3DBACK, SolidPattern);
               Bar( 2, 2, Size.X - 3, Size.Y - 3);
               S1 := 'X = ' + S1 + ', Y = ' + S2;
               SetPColor( clr3DTEXT);
               OutTextXY( (Size.X - metTEXTWIDTH * Length(S1)) div 2, ( Size.Y - metTEXTHEIGHT) div 2, S1);
               LastPos := NewPos;
               end;
          end;

     if AInitViewPort
     then EndDraw;
end;

procedure THeadCordsPanel.Draw;
begin
     BeginDraw;

     Draw3DInFrame( 0, 0, Size.X - 1, Size.Y - 1, clr3D0, clr3D1, clr3D2, clr3D3);
     ShowNewCords( False, False);
     {OutTextXY( 5, 05, 'X :');
     OutTextXY( 5, 15, 'Y :');
     OutTextXY( 5, 25, 'RX:');
     OutTextXY( 5, 35, 'RY:');
     OutTextXY( 5, 50, '  :');
     OutTextXY( 5, 65, '  :');
     OutTextXY( 5, 80, '  :');
     Rectangle( 4, 50 - 2, 14, 58);
     Rectangle( 8, 50 + 2, 14, 58);
     Line( 9, 63, 9, 73);
     Line( 4, 68, 14, 68);
     Circle( 9, 68, 2);

     Line( 5, 78, 5, 88);
     Line( 7, 78, 7, 88);
     Line( 9, 78, 9, 88);
     Line( 11, 78, 11, 88);
     Line( 13, 78, 13, 88);
     Line( 4, 79, 14, 79);
     Line( 4, 81, 14, 81);
     Line( 4, 83, 14, 83);
     Line( 4, 85, 14, 85);
     Line( 4, 87, 14, 87);

     DisplayPos( False);
     DisplayZoom( False);
     DisplaySnap( False);
     DisplayGridStyle( False);}
     EndDraw;
end;

procedure THeadCordsPanel.HandleEvent( var E: TEvent);
begin
     if E.What = evCommand
     then begin
          if ( E.Command = cmUpdateHeadCords{cmUpdateHeadPos})
          then ShowNewCords( True, True);
          end;

     if E.What <> evNothing
     then inherited HandleEvent( E);
end;


{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor THeadsPanel.Create( R: TRect);
var TempRow: PRow;
begin
     inherited Create( R);
     Options := Options or ofRedispachDragEvents;
     State := sfVisible or sfEnabled or sfFocused {or sfSelected};
     EventMask := evMouse or evKeyPress;
     Rows.Create;
     Info.HeadsBaseSize.Assign( HEADS_BASE_WIDTH, HEADS_BASE_HEIGHT);
     Info.Zoom.Assign( Info.HeadsBaseSize.X / (Size.X - 20), Info.HeadsBaseSize.Y / Size.Y);
     {Info.GridOffset.Assign( 0, 0);}
     Info.GridSize.Assign( 100, 100);
     Info.SnapSize.Assign( 1, 1);
     Info.SnapOnOff := True;
end;

destructor THeadsPanel.Destroy;
begin
     Rows.Destroy;
     inherited Destroy;
end;

procedure THeadsPanel.Draw;
var ScanRow: PRow;
    SelectedRow: PRow;

    procedure DrawBackground;
    var Visible: TFRect;
        P: TPoint;
        LP: TFPoint;
        X, Y: Longint;
        SP: TFPoint;
        Color: Byte;
    begin
         SetFillPattern( SolidPattern, 0);
         Bar( 0, 0, Size.X - 21, Size.Y - 1);
         SetPFillPattern( clrGRID1, SolidPattern);
         Bar( Size.X - 20, 0, Size.X - 1, Size.Y - 1);
         P.Assign( 0, 0);
         ConvertToLogicalPos( P, Visible.A, False);
         ConvertToLogicalPos( Size, Visible.B, False);

         SetPColor( clrGRID1);
         if (( Info.GridSize.X / Info.Zoom.X) >= 4)
         then begin
              LP.X := Int( Visible.A.X / Info.GridSize.X) * Info.GridSize.X;
              SP.X := LP.X;
              while (SP.X < Visible.B.X)
              do begin
                 ConvertToWindowX( SP.X, X);
                 Line( X, 0, X, Size.Y);
                 SP.X := SP.X + Info.GridSize.X;
                 end;
              end;

         if (( Info.GridSize.Y / Info.Zoom.Y) >= 4)
         then begin
              LP.Y := Int( Visible.A.Y / Info.GridSize.Y) * Info.GridSize.Y;
              SP.Y := LP.Y;
              while (SP.Y < Visible.B.Y)
              do begin
                 ConvertToWindowY( SP.Y, Y);
                 Line( 0, Y, Size.X - 20, Y);
                 SP.Y := SP.Y + Info.GridSize.Y;
                 end;
              end;
    end;
begin
     BeginDraw;
     DrawBackground;
     SelectedRow := PRow( Rows.GetLast);
     ScanRow := PRow( Rows.GetFirst);
     while ( ScanRow <> nil)
     do begin
        ScanRow^.Draw( @Self, False, SelectedRow = ScanRow);
        ScanRow := PRow( Rows.GetNext);
        end;
     EndDraw;
end;

procedure THeadsPanel.HandleEvent( var E: TEvent);
var ScanRow: PRow;
    ThisIsSelected: Boolean;
begin
     ScanRow := PRow( Rows.GetLast);
     ThisIsSelected := True;
     while ( ScanRow <> nil)
     do begin
        ScanRow^.HandleEvent( E, @Self, ThisIsSelected);
        ThisIsSelected := False;
        if ( E.What = evNothing)
        then Break;
        ScanRow := PRow( Rows.GetPrev);
        end;
     if E.What <> evNothing
     then inherited HandleEvent( E);
end;

procedure THeadsPanel.ConvertToWindowX( var AFX: Float; var AX: Longint);
begin
     AX := Round( AFX / Info.Zoom.X);
end;

procedure THeadsPanel.ConvertToWindowY( var AFY: Float; var AY: Longint);
begin
     AY := Round( AFY / Info.Zoom.Y);
end;

procedure THeadsPanel.ConvertToWindowPos( var AFPoint: TFPoint; var APoint: TPoint);
begin
     APoint.X := Round( AFPoint.X / Info.Zoom.X);
     APoint.Y := Round( AFPoint.Y / Info.Zoom.Y);
end;

procedure THeadsPanel.ConvertToLogicalX( var AX: Longint; var AFX: Float; ASnap: Boolean);
begin
     AFX := AX * Info.Zoom.X;

     if (ASnap)
     then AFX := (Round(AFX / Info.SnapSize.X) * Info.SnapSize.X);

     if (AFX < 0)
     then AFX := 0
     else if AFX > Info.HeadsBaseSize.X
          then AFX := Info.HeadsBaseSize.X
end;

procedure THeadsPanel.ConvertToLogicalY( var AY: Longint; var AFY: Float; ASnap: Boolean);
begin
     AFY := AY * Info.Zoom.Y;

     if (ASnap)
     then AFY := (Round(AFY / Info.SnapSize.Y) * Info.SnapSize.Y);

     if (AFY < 0)
     then AFY := 0
     else if (AFY > Info.HeadsBaseSize.Y)
          then AFY := Info.HeadsBaseSize.y
end;

procedure THeadsPanel.ConvertToLogicalPos( var APoint: TPoint; var AFPoint: TFPoint; ASnap: Boolean);
begin
     AFPoint.X := APoint.X * Info.Zoom.X;
     AFPoint.Y := APoint.Y * Info.Zoom.Y;

     if (ASnap)
     then begin
          AFPoint.X := (Round(AFPoint.X / Info.SnapSize.X) * Info.SnapSize.X);
          AFPoint.Y := (Round(AFPoint.Y / Info.SnapSize.Y) * Info.SnapSize.Y);
          end;

     if (AFPoint.X < 0)
     then AFPoint.X := 0
     else if (AFPoint.X > Info.HeadsBaseSize.X)
          then AFPoint.X := Info.HeadsBaseSize.X;

     if (AFPoint.Y < 0)
     then AFPoint.Y := 0
     else if (AFPoint.Y > Info.HeadsBaseSize.Y)
          then AFPoint.Y := Info.HeadsBaseSize.Y;
end;

procedure THeadsPanel.AppendRow( ARow: PRow);
begin
     if ( ARow <> nil)
     then begin
          Rows.PushLast( ARow);
          end;
     Update;
end;

function THeadsPanel.GetHeadsPoses: PFPath;
var ScanRow: PRow;
    HeadsPoses: PFPath;
begin
     HeadsPoses := New( PFPath, Create);
     ScanRow := PRow( Rows.GetFirst);
     while ( ScanRow <> nil)
     do begin
        ScanRow^.GetHeadsPoses( HeadsPoses);
        ScanRow := PRow( Rows.GetNext);
        end;
     GetHeadsPoses := HeadsPoses;
end;

function THeadsPanel.SelectRow( ARow: PRow): Boolean;
var Selected: PRow;
begin
     SelectRow := False;
     Selected := PRow( Rows.GetLast);
     if ( ARow <> Selected)
     then begin
          if ( ARow <> nil)
          then begin
               Rows.RemoveFromCollection( ARow);
               Rows.PushLast( ARow);
               Update;
               SelectRow := true;
               end;
          end;
end;

procedure THeadsPanel.RemoveRow;
var RemovedRow: PRow;
begin
     RemovedRow := PRow( Rows.PopLast);
     if ( RemovedRow <> nil)
     then begin
          RemovedRow^.Free;
          Update;
          end;
end;

procedure THeadsPanel.RemoveHead;
var RemovedHead: PHead;
    HeadsRow: PRow;
begin
     HeadsRow := PRow( Rows.GetLast);
     if ( HeadsRow <> nil)
     then begin
          RemovedHead := PHead( HeadsRow^.Heads.PopLast);
          if ( RemovedHead <> nil)
          then begin
               RemovedHead^.Free;
               Update;
               end;
          end;
end;

function THeadsPanel.GetSelectedRow: PRow;
begin
     GetSelectedRow := PRow( Rows.GetLast);
end;

function THeadsPanel.GetSelectedHead: PHead;
var Row: PRow;
begin
     Row := GetSelectedRow;
     if ( Row <> nil)
     then GetSelectedHead := Row^.GetSelectedHead
     else GetSelectedHead := nil;
end;

procedure THeadsPanel.SaveData( AStream: PStream);
var RowsCount: Longint;
    ScanRow: PRow;
begin
     if ( AStream <> nil)
     then begin
          AStream^.Write( Info, SizeOf( Info));
          RowsCount := Rows.GetItemsCount;
          AStream^.Write( RowsCount, SizeOf( RowsCount));
          ScanRow := PRow( Rows.GetFirst);
          while ( ScanRow <> nil)
          do begin
             ScanRow^.SaveData( AStream);
             ScanRow := PRow( Rows.GetNext);
             end;
          end;
end;

procedure THeadsPanel.WritePositions( AStream: PStream);
var ScanRow: PRow;
begin
     if ( AStream <> nil)
     then begin
          AStream^.WriteStr('Heads positions:');
          AStream^.NewLine;
          AStream^.WriteStr('----------------');
          AStream^.NewLine;
          AStream^.NewLine;
          ScanRow := PRow( Rows.GetFirst);
          while ( ScanRow <> nil)
          do begin
             ScanRow^.WritePositions( AStream);
             ScanRow := PRow( Rows.GetNext);
             end;
          end;
end;

procedure THeadsPanel.LoadData( AStream: PStream);
var RowsCount: Longint;
    NewRow: PRow;
begin
     if ( AStream <> nil)
     then begin
          Rows.Clear;
          AStream^.Read( Info, SizeOf( Info));
          AStream^.Read( RowsCount, SizeOf( RowsCount));
          while ( RowsCount > 0)
          do begin
             NewRow := New( PRow, Create(0));
             NewRow^.LoadData( AStream);
             Rows.PushLast( NewRow);
             RowsCount := RowsCount - 1;
             end;
          end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TRowAddDlg.Create( AHeadsPanel: PHeadsPanel);
var P: TPoint;
begin
     P.Assign( 300, 195);
     inherited Create( P, 'Add heads row');

     HeadsPanel := AHeadsPanel;
     Lock;
     AddLabel( 20, 20 + 10, 'Row pos');
     AddLabel( 20, 60 + 10, 'Heads count');
     PosEdit := New( PFloatEdit, Create( 120, 20, 0, 0, HEADS_BASE_HEIGHT));
     HeadsCountEdit := New( PIntegerEdit, Create( 120, 60, 0, 0, 300));
     InsertChild( PosEdit);
     InsertChild( HeadsCountEdit);

     InsertChild( New( PButton, Create( 60, 120, 100 + metSHADOWSIZE, 30, '&Add', cmOk, keyA)));
     InsertChild( New( PButton, Create( 170, 120, 100 + metSHADOWSIZE, 30, '&Cancel', cmCancel, keyC)));

     Unlock;
end;

const LastPos: Float = 0;
      LastHeadsCount: Longint = 0;

procedure TRowAddDlg.BeforeExecuteDlg;
begin
     PosEdit^.SetValue( LastPos);
     HeadsCountEdit^.SetValue( LastHeadsCount);
end;

procedure TRowAddDlg.AfterExecuteDlg;
begin
     LastPos := PosEdit^.GetValue;
     LastHeadsCount := HeadsCountEdit^.GetValue;
end;

function TRowAddDlg.ValidateData: Boolean;
var Result: Boolean;
    NewRow: PRow;
    RowPos: Float;
    HeadsCount: Longint;
    NextHeadPos: Float;
    HeadsSpacing: Float;
    I: Longint;
begin
     Result := False;
     if not PosEdit^.ValidateString
     then PosEdit^.SetFocus
     else if not HeadsCountEdit^.ValidateString
     then HeadsCountEdit^.SetFocus
     else Result := True;

     if Result
     then begin
          if ( HeadsPanel <> nil)
          then begin
               RowPos := PosEdit^.GetValue;
               HeadsCount := HeadsCountEdit^.GetValue;
               NewRow := New( PRow, Create( RowPos));
               if (HeadsCount > 1)
               then begin
                    HeadsSpacing := HEADS_BASE_WIDTH / (HeadsCount - 1);
                    NextHeadPos := 0;
                    end
               else begin
                    HeadsSpacing := 0;
                    NextHeadPos := HEADS_BASE_WIDTH / 2;
                    end;
               for I := 1 to HeadsCount
               do begin
                  NewRow^.AppendHead( New( PHead, Create( NextHeadPos)));
                  NextHeadPos := NextHeadPos + HeadsSpacing;
                  end;
               HeadsPanel^.AppendRow( NewRow);
               end;
          ValidateData := True;
          end
     else begin
          MistakeBeep;
          ValidateData := False;
          end
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor THeadsAddDlg.Create( AHeadsPanel: PHeadsPanel);
var P: TPoint;
begin
     P.Assign( 300, 235);
     inherited Create( P, 'Add heads');

     HeadsPanel := AHeadsPanel;
     Lock;
     AddLabel( 20, 20 + 10, 'Offset');
     AddLabel( 20, 60 + 10, 'Count');
     AddLabel( 20, 100 + 10, 'Spacing');

     StartPosEdit := New( PFloatEdit, Create( 120, 20, 0, 0, HEADS_BASE_WIDTH));
     CountEdit := New( PIntegerEdit, Create( 120, 60, 0, 1, 99));
     SpacingEdit := New( PFloatEdit, Create( 120, 100, 0, 0, HEADS_BASE_WIDTH));

     InsertChild( StartPosEdit);
     InsertChild( CountEdit);
     InsertChild( SpacingEdit);

     InsertChild( New( PButton, Create( 60, 160, 100 + metSHADOWSIZE, 30, '&Add', cmOk, keyA)));
     InsertChild( New( PButton, Create( 170, 160, 100 + metSHADOWSIZE, 30, '&Cancel', cmCancel, keyC)));

     Unlock;
end;

const LastStartPos: Float = 0;
      LastCount: Longint = 1;
      LastSpacing: Float = 10;

procedure THeadsAddDlg.BeforeExecuteDlg;
begin
     StartPosEdit^.SetValue( LastStartPos);
     CountEdit^.SetValue( LastCount);
     SpacingEdit^.SetValue( LastSpacing);
end;

procedure THeadsAddDlg.AfterExecuteDlg;
begin
     LastStartPos := StartPosEdit^.GetValue;
     LastCount := CountEdit^.GetValue;
     LastSpacing := SpacingEdit^.GetValue;

     LastStartPos := LastStartPos + ( LastCount * LastSpacing);
     if ( LastStartPos > HEADS_BASE_WIDTH)
     then LastStartPos := 0;
end;

function THeadsAddDlg.ValidateData: Boolean;
var Result: Boolean;
    StartPos: Float;
    Count: Longint;
    Spacing: Float;


    TheRow: PRow;
    NextHeadPos: Float;
    I: Longint;
begin
     Result := False;
     if not StartPosEdit^.ValidateString
     then StartPosEdit^.SetFocus
     else if not CountEdit^.ValidateString
     then CountEdit^.SetFocus
     else if not SpacingEdit^.ValidateString
     then SpacingEdit^.SetFocus
     else Result := True;

     if Result
     then begin
          if ( HeadsPanel <> nil)
          then begin
               StartPos := StartPosEdit^.GetValue;
               Count := CountEdit^.GetValue;
               Spacing := SpacingEdit^.GetValue;

               TheRow := HeadsPanel^.GetSelectedRow;
               if ( TheRow <> nil)
               then begin
                    NextHeadPos := StartPos;
                    for I := 1 to Count
                    do begin
                       if ( NextHeadPos <= HEADS_BASE_WIDTH)
                       then begin
                            TheRow^.AppendHead( New( PHead, Create( NextHeadPos)));
                            NextHeadPos := NextHeadPos + Spacing;
                            end
                       else Break;
                       end;
                    end;
               end;
          ValidateData := True;
          end
     else begin
          MistakeBeep;
          ValidateData := False;
          end
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TRowHeadEditDlg.Create( AHeadsPanel: PHeadsPanel);
var P: TPoint;
begin
     P.Assign( 300, 205);
     inherited Create( P, 'Add heads row');

     HeadsPanel := AHeadsPanel;
     if ( HeadsPanel <> nil)
     then begin
          Row := HeadsPanel^.GetSelectedRow;
          Head := HeadsPanel^.GetSelectedHead;
          end;
     Lock;
     AddLabel( 20, 20 + 10, 'Heat pos');
     AddLabel( 20, 20 + 50, 'Row pos');
     HeadPosEdit := New( PFloatEdit, Create( 120, 20, 0, 0, HEADS_BASE_WIDTH));
     RowPosEdit := New( PFloatEdit, Create( 120, 60, 0, 0, HEADS_BASE_HEIGHT));
     InsertChild( HeadPosEdit);
     InsertChild( RowPosEdit);
     InsertChild( New( PButton, Create( 60, 120, 100 + metSHADOWSIZE, 30, '&Ok', cmOk, keyO)));
     InsertChild( New( PButton, Create( 170, 120, 100 + metSHADOWSIZE, 30, '&Cancel', cmCancel, keyC)));
     Unlock;
end;

procedure TRowHeadEditDlg.BeforeExecuteDlg;
begin
     if ( Head <> nil)
     then HeadPosEdit^.SetValue( Head^.GetHorizontalPos)
     else HeadPosEdit^.SetValue( 0);

     if ( Row <> nil)
     then RowPosEdit^.SetValue( Row^.GetVerticalPos)
     else RowPosEdit^.SetValue( 0);
end;

procedure TRowHeadEditDlg.AfterExecuteDlg;
begin
end;

function TRowHeadEditDlg.ValidateData: Boolean;
var Result: Boolean;
begin
     Result := False;
     if not HeadPosEdit^.ValidateString
     then HeadPosEdit^.SetFocus;
     if not RowPosEdit^.ValidateString
     then RowPosEdit^.SetFocus
     else Result := True;

     if Result
     then begin
          if ( Head <> nil)
          then Head^.SetHorizontalPos( HeadPosEdit^.GetValue);

          if ( Row <> nil)
          then Row^.SetVertialPos( RowPosEdit^.GetValue);

          ValidateData := True;
          end
     else begin
          MistakeBeep;
          ValidateData := False;
          end
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TPreviewGridEditDlg.Create( AHeadsPanel: PHeadsPanel);
var P: TPoint;
begin
     P.Assign( 400, 220);
     inherited Create( P, 'Head grid settings');

     HeadsPanel := AHeadsPanel;

     Lock;

     {AddLabel( 20, 20 + 10, 'Grid offset');}
     AddLabel( 20, 20 + 10, 'Grid size');
     AddLabel( 20, 20 + 50, 'Snap size');
     AddLabel( 20, 20 + 90, 'Snap active');

     {XOffsetEdit := New( PFloatEdit, Create( 120, 20, 120, 0, HEADS_BASE_WIDTH));
     YOffsetEdit := New( PFloatEdit, Create( 250, 20, 120, 0, HEADS_BASE_HEIGHT));}
     GridXEdit := New( PFloatEdit, Create( 120, 20, 120, 0.1, 100));
     GridYEdit := New( PFloatEdit, Create( 250, 20, 120, 0.1, 100));;
     SnapXEdit := New( PFloatEdit, Create( 120, 60, 120, 0.1, 100));
     SnapYEdit := New( PFloatEdit, Create( 250, 60, 120, 0.1, 100));;
     SnapOnOffCheck := New( PCheckBox, Create( 120, 100));

     {InsertChild( XOffsetEdit);
     InsertChild( YOffsetEdit);}
     InsertChild( GridXEdit);
     InsertChild( GridYEdit);
     InsertChild( SnapXEdit);
     InsertChild( SnapYEdit);
     InsertChild( SnapOnOffCheck);

     InsertChild( New( PButton, Create( 160, 140, 100 + metSHADOWSIZE, 30, '&Ok', cmOk, keyO)));
     InsertChild( New( PButton, Create( 270, 140, 100 + metSHADOWSIZE, 30, '&Cancel', cmCancel, keyC)));

     Unlock;
end;

procedure TPreviewGridEditDlg.BeforeExecuteDlg;
begin
     if ( HeadsPanel <> nil)
     then begin
          {XOffsetEdit^.SetValue( HeadsPanel^.Info.GridOffset.X);
          YOffsetEdit^.SetValue( HeadsPanel^.Info.GridOffset.Y);}
          GridXEdit^.SetValue( HeadsPanel^.Info.GridSize.X);
          GridYEdit^.SetValue( HeadsPanel^.Info.GridSize.Y);
          SnapXEdit^.SetValue( HeadsPanel^.Info.SnapSize.X);
          SnapYEdit^.SetValue( HeadsPanel^.Info.SnapSize.Y);
          SnapOnOffCheck^.SetValue( HeadsPanel^.Info.SnapOnOff);
          end
     else begin
          {XOffsetEdit^.SetValue( 0);
          YOffsetEdit^.SetValue( 0);}
          GridXEdit^.SetValue( 10);
          GridYEdit^.SetValue( 10);
          SnapXEdit^.SetValue( 1);
          SnapYEdit^.SetValue( 1);
          end;
end;

procedure TPreviewGridEditDlg.AfterExecuteDlg;
begin
end;

function TPreviewGridEditDlg.ValidateData: Boolean;
var Result: Boolean;
begin
     Result := False;
     {if not XOffsetEdit^.ValidateString
     then XOffsetEdit^.SetFocus
     else if not YOffsetEdit^.ValidateString
     then YOffsetEdit^.SetFocus
     else }
     if not GridXEdit^.ValidateString
     then GridXEdit^.SetFocus
     else if not GridYEdit^.ValidateString
     then GridYEdit^.SetFocus
     else if not SnapXEdit^.ValidateString
     then SnapXEdit^.SetFocus
     else if not SnapYEdit^.ValidateString
     then SnapYEdit^.SetFocus
     else Result := True;

     if Result
     then begin
          if ( HeadsPanel <> nil)
          then begin
               {HeadsPanel^.Info.GridOffset.X := XOffsetEdit^.GetValue;
               HeadsPanel^.Info.GridOffset.Y := YOffsetEdit^.GetValue;}
               HeadsPanel^.Info.GridSize.X := GridXEdit^.GetValue;
               HeadsPanel^.Info.GridSize.Y := GridYEdit^.GetValue;
               HeadsPanel^.Info.SnapSize.X := SnapXEdit^.GetValue;
               HeadsPanel^.Info.SnapSize.Y := SnapYEdit^.GetValue;
               HeadsPanel^.Info.SnapOnOff := SnapOnOffCheck^.GetValue;
               end;
          ValidateData := True;
          end
     else begin
          MistakeBeep;
          ValidateData := False;
          end
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

var ShapesClipboard: TContainerCollection;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}


constructor TDesignCanvas.Create( R: TRect; AList: PTextList; AFeedBack: PFeedBackPanel);
begin
     inherited Create( R);
     State := sfVisible or sfEnabled or sfFocused or sfSelected;
     EventMask := evMouse;
     List := AList;
     FeedBack := AFeedBack;
     PreviewData := nil;
     Info.Create;
     Tool := nil;
     Shapes.Create;
     Info.Create;
     FileName := DefFileName;
     SelectStart := nil;
     SelectEnd := nil;
     FileDefined := False;
end;

destructor TDesignCanvas.Destroy;
begin
     if ( PreviewData <> nil)
     then PreviewData^.Free;
     if ( Tool <> nil)
     then Tool^.Free;
     Shapes.Destroy;
     Info.Destroy;
     inherited Destroy;
end;

procedure TDesignCanvas.Draw;
var VP1, VP2: TPoint;
    LP1: TFPoint;
    LimitsOfset: Float;
    Limit1, Limit2: Float;
begin
     inherited Draw;

     BeginDraw;
     LP1.Assign( 0, 0);
     SetPColor( clrGUIDELINES);
     ConvertToCanvasPos( LP1, VP1);
     if (VP1.Y < Size.Y)
     then begin
          Line( VP1.X - 50, VP1.Y, VP1.X + 50, VP1.Y);
          if VP1.Y < Size.Y - 4
          then Line( VP1.X, VP1.Y, VP1.X, Size.Y - 4);
          Line( VP1.X - 4, Size.Y - 4, VP1.X, Size.Y);
          Line( VP1.X + 4, Size.Y - 4, VP1.X, Size.Y);
          Line( VP1.X - 4, Size.Y - 4, VP1.X + 4, Size.Y - 4);
          end
     else begin
          Line( VP1.X - 4, Size.Y - 4, VP1.X, Size.Y);
          Line( VP1.X + 4, Size.Y - 4, VP1.X, Size.Y);
          Line( VP1.X - 4, Size.Y - 4, VP1.X + 4, Size.Y - 4);
          end;

     Limit1 := TheMachine.GetSizeXMM / 2;
     if (CanvasInfo.LimitsOffset > Limit1)
     then Limit1 := TheMachine.GetSizeXMM
     else if (CanvasInfo.LimitsOffset < - Limit1)
     then Limit1 := 0
     else Limit1 := Limit1 + CanvasInfo.LimitsOffset;
     Limit2 := Limit1 - TheMachine.GetSizeXMM;

     LP1.Assign( Limit1, 0);
     ConvertToCanvasPos( LP1, VP1);

     if ( VP1.X < Size.X)
     then begin
          if ( VP1.X > 0)
          then begin
               Line( VP1.X, 0, VP1.X, Size.Y);
               SetLineStyle( DottedLn, 0, 1);
               Line( VP1.X + 2, 0, VP1.X + 2, Size.Y);
               SetLineStyle( SolidLn, 0, 1);
               end
          else begin
               VP2.Assign( 10, Size.Y div 2);
               Line( 10, VP2.Y, Size.X, VP2.Y);
               Line( 10, VP2.Y, 20, VP2.Y - 10);
               Line( 10, VP2.Y, 20, VP2.Y + 10);
               Line( 9, VP2.Y, 19, VP2.Y - 10);
               Line( 9, VP2.Y, 19, VP2.Y + 10);
               end;
          end;


     LP1.Assign( Limit2, 0);
     ConvertToCanvasPos( LP1, VP1);

     if ( VP1.X > 0)
     then begin

          if ( VP1.X < Size.X)
          then begin
               Line( VP1.X, 0, VP1.X, Size.Y);
               SetLineStyle( DottedLn, 0, 1);
               Line( VP1.X - 2, 0, VP1.X - 2, Size.Y);
               SetLineStyle( SolidLn, 0, 1);
               end
          else begin
               VP2.Assign( Size.X - 10, Size.Y div 2);
               Line( 0, VP2.Y, Size.X - 10, VP2.Y);
               Line( Size.X - 20, VP2.Y - 10, Size.X - 10, VP2.Y);
               Line( Size.X - 20, VP2.Y + 10, Size.X - 10, VP2.Y);
               Line( Size.X - 19, VP2.Y - 10, Size.X - 9, VP2.Y);
               Line( Size.X - 19, VP2.Y + 10, Size.X - 9, VP2.Y);
               end;
          end;

     ConvertToCanvasPos( Info.BasePos, VP1);
     Line( VP1.X - 10, VP1.Y, VP1.X + 10, VP1.Y);
     Line( VP1.X, VP1.Y - 10, VP1.X, VP1.Y + 10);
     Rectangle( VP1.X - 10, VP1.Y - 10, VP1.X + 10, VP1.Y + 10);

     DrawShapes( False);

     if ( Tool <> nil)
     then Tool^.CanvasUpdated;

     EndDraw;
end;

procedure TDesignCanvas.DrawShapes( AInitViewPort: Boolean);
var ScanShape: PShape;
    Selected: Boolean;
begin
     if AInitViewPort
     then BeginDraw;
     ScanShape := PShape( Shapes.GetFirst);
     Selected := False;
     while ( ScanShape <> nil)
     do begin
        if ( ScanShape = SelectStart)
        then Selected := True;
        ScanShape^.Draw( @Self, Selected);
        if ( ScanShape = SelectEnd)
        then Selected := False;
        ScanShape := PShape( Shapes.GetNext);
        end;
     if AInitViewPort
     then EndDraw;
end;

procedure TDesignCanvas.DrawCursor;
begin
end;

procedure TDesignCanvas.Scroll( ADir: Integer);
begin
     inherited Scroll( ADir);

     case ADir
     of 0: begin
           FeedBack^.UpdateZoom( CanvasInfo.Zoom);
           end;
        9: begin
           FeedBack^.UpdateZoom( CanvasInfo.Zoom);
           end;
        end;
end;

procedure TDesignCanvas.HandleEvent( var E: TEvent);
var Pos: TPoint;
    TempShape: PShape;
    NewTool: PTool;
    FPos: TFPoint;
    SettingsDlg: PSettingsDlg;
    FileDlg: PFileDlg;
    R: TRect;

    TempPath: PFPath;
    P1, P2: TPoint;
    ScanPoint: TFPoint;

    PreviewDlg: PPreviewDlg;
    TestDlg: PTestDlg;
    RunDlg: PRunDlg;
    Menu: PMenu;
    MenuItems: PMenuItem;
    Window: PWindow;

    LastSelectStart,
    LastSelectEnd: PShape;

    NewShapes: TCollection;
    NewShape: PShape;

    CenterPos: TFPoint;
    ShiftDelta: TFPoint;
    NewEnd: TFPoint;
    OldEnd: TFPoint;

    function TestSelectRange: Boolean;
    begin
         TestSelectRange := False;
         if (( SelectStart <> nil) and ( SelectEnd <> nil))
         then if (Shapes.IsMember( SelectStart) and Shapes.IsMember( SelectEnd))
              then TestSelectRange := True;
    end;

    function RemoveSelected: Boolean;
    var ShiftDelta: TFPoint;
        FPos: TFPoint;
        ScanShape: PShape;
    begin
         RemoveSelected := False;
         if TestSelectRange
         then begin
              SelectStart^.GetStartPoint( FPos);
              SelectEnd^.GetStopPoint( ShiftDelta);
              ShiftDelta.X := FPos.X - ShiftDelta.X;
              ShiftDelta.Y := FPos.Y - ShiftDelta.Y;
              LastSelectStart := PShape( Shapes.GetBefore( SelectStart));
              LastSelectEnd := PShape( Shapes.GetAfter( SelectEnd));
              repeat
                    ScanShape := SelectStart;
                    SelectStart := PShape( Shapes.GetAfter( ScanShape));
                    Shapes.RemoveFromCollection( ScanShape);
                    RemoveSelected := True;
                    ScanShape^.Free;
              until ( SelectStart = LastSelectEnd);
              ScanShape := LastSelectEnd;
              while ( ScanShape <> nil)
              do begin
                 ScanShape^.Shift( ShiftDelta);
                 ScanShape := PShape( Shapes.GetAfter( ScanShape));
                 end;
              SelectStart :=  nil;
              SelectEnd := nil;
              ScanShape := PShape( Shapes.GetLast);
              if ( ScanShape <> nil)
              then ScanShape^.GetStopPoint( Info.LastPoint)
              else Info.LastPoint.Assign( 0, 0);
              end;
    end;

    function KeepSelectedInClipboard: Boolean;
    var ShiftDelta: TFPoint;
        FPos: TFPoint;
        ScanShape: PShape;
        NewShape: PShape;
    begin
         KeepSelectedInClipboard := False;
         if TestSelectRange
         then begin
              ShapesClipboard.Clear;
              if TestSelectRange
              then begin
                   ShapesClipboard.Clear;
                   SelectStart^.GetStartPoint( FPos);
                   ShiftDelta.X := - FPos.X;
                   ShiftDelta.Y := - FPos.Y;
                   ScanShape := SelectStart;
                   while ( ScanShape <> nil)
                   do begin
                      NewShape := PShape( ScanShape^.Clone);
                      if ( NewShape <> nil)
                      then begin
                           NewShape^.Shift( ShiftDelta);
                           ShapesClipboard.PushLast( NewShape);
                           KeepSelectedInClipboard := True;
                           end;
                      if ( ScanShape <> SelectEnd)
                      then ScanShape := PShape( Shapes.GetAfter( ScanShape))
                      else Break;
                      end;
                   end;
              end;
    end;

    function PasteClipboard: Boolean;
    var FPos: TFPoint;
        ShiftDelta: TFPoint;
        ScanShape: PShape;
        NewShape: PShape;
    begin
         PasteClipboard := False;
         if ( ShapesClipboard.GetItemsCount > 0)
         then begin
              if TestSelectRange
              then begin
                   SelectStart^.GetStartPoint( ShiftDelta);
                   ScanShape := PShape( ShapesClipboard.GetFirst);
                   while ( ScanShape <> nil)
                   do begin
                      NewShape := PShape( ScanShape^.Clone);
                      if ( NewShape <> nil)
                      then begin
                           NewShape^.Shift( ShiftDelta);
                           Shapes.InsertBefore( SelectStart, NewShape);
                           PasteClipboard := True;
                           end;
                      ScanShape := PShape( ShapesClipboard.GetNext);
                      end;
                   if ( NewShape <> nil)
                   then begin
                        NewShape^.GetStopPoint( ShiftDelta);
                        SelectStart^.GetStartPoint( FPos);
                        ShiftDelta.X := ShiftDelta.X - FPos.X;
                        ShiftDelta.Y := ShiftDelta.Y - FPos.Y;
                        ScanShape := SelectStart;
                        while ( ScanShape <> nil)
                        do begin
                           ScanShape^.Shift( ShiftDelta);
                           ScanShape := PShape( Shapes.GetAfter( ScanShape));
                           end;
                        end;
                   ScanShape := PShape( Shapes.GetLast);
                   if ( ScanShape <> nil)
                   then ScanShape^.GetStopPoint( Info.LastPoint)
                   else Info.LastPoint.Assign( 0, 0);
                   end
              else begin
                   ScanShape := PShape( ShapesClipboard.GetFirst);
                   while ( ScanShape <> nil)
                   do begin
                      NewShape := PShape( ScanShape^.Clone);
                      if ( NewShape <> nil)
                      then begin
                           NewShape^.Shift( Info.LastPoint);
                           Shapes.PushLast( NewShape);
                           PasteClipboard := True;
                           end;
                      ScanShape := PShape( ShapesClipboard.GetNext);
                      end;
                   ScanShape := PShape( Shapes.GetLast);
                   if ( ScanShape <> nil)
                   then ScanShape^.GetStopPoint( Info.LastPoint)
                   else Info.LastPoint.Assign( 0, 0);
                   end;
              end;
    end;

begin
     if (( E.What and evMouse) <> $00)
     then begin
          Pos := E.MouseInfo.Where;
          MakeLocal( Pos);
          ConvertToLogicalPos( Pos, FPos, CanvasInfo.Snap);

          if ( E.What = evMouseDown)
          then begin
               if ((E.MouseInfo.ShiftStatus and shkShiftDown) <> 0)
               then begin
                    Info.BasePos := FPos;
                    FeedBack^.UpdateBasePos( Info.BasePos);
                    ClearEvent( E);
                    Update;
                    end;
               end;
          FeedBack^.UpdatePos( FPos);
          end
     else if ( E.What = evCommand)
     then begin
          case E.Command
          of cmDeleteLastShape:
                begin
                TempShape := PShape( Shapes.PopLast);
                if ( TempShape <> nil)
                then begin
                     TempShape^.GetStartPoint( Info.LastPoint);
                     TempShape^.Free;
                     end;
                SelectStart := nil;
                SelectEnd := nil;
                Update;
                UpdateCommands;
                ClearEvent( E);
                end;
             cmDeleteSelected: begin
                               if RemoveSelected
                               then begin
                                    Update;
                                    UpdateCommands;
                                    end;
                               ClearEvent( E);
                               end;
             cmCopySelected: begin
                             if KeepSelectedInClipboard
                             then UpdateCommands;
                             ClearEvent( E);
                             end;
             cmCutSelected: begin
                            if KeepSelectedInClipboard
                            then if RemoveSelected
                                 then begin
                                      Update;
                                      UpdateCommands;
                                      end;
                            ClearEvent( E);
                            end;
             cmPasteSelected: begin
                              if PasteClipboard
                              then begin
                                   Update;
                                   UpdateCommands;
                                   end;
                              ClearEvent( E);
                              end;
             cmMirrorX: begin
                        if TestSelectRange
                        then begin
                             SelectStart^.GetStartPoint( CenterPos);
                             TempShape := SelectStart;
                             while (TempShape <> nil)
                             do begin
                                TempShape^.MirrorX( CenterPos.X);
                                if ( TempShape = SelectEnd)
                                then begin
                                     TempShape^.GetStopPoint( NewEnd);
                                     TempShape := PShape( Shapes.GetAfter( TempShape));
                                     Break;
                                     end;
                                TempShape := PShape( Shapes.GetAfter( TempShape));
                                end;

                             if ( TempShape <> nil)
                             then begin
                                  TempShape^.GetStartPoint( OldEnd);
                                  ShiftDelta.X := NewEnd.X - OldEnd.X;
                                  ShiftDelta.Y := NewEnd.Y - OldEnd.Y;
                                  repeat
                                        TempShape^.Shift( ShiftDelta);
                                        TempShape := PShape( Shapes.GetAfter( TempShape));
                                  until ( TempShape = nil);
                                  end;
                             TempShape := PShape( Shapes.GetLast);
                             if ( TempShape <> nil)
                             then TempShape^.GetStopPoint( Info.LastPoint)
                             else Info.LastPoint.Assign( 0, 0);
                             Update;
                             end;
                        ClearEvent( E);
                        end;
             cmMirrorY: begin
                        if TestSelectRange
                        then begin
                             SelectStart^.GetStartPoint( CenterPos);
                             TempShape := SelectStart;
                             while (TempShape <> nil)
                             do begin
                                TempShape^.MirrorY( CenterPos.Y);
                                if ( TempShape = SelectEnd)
                                then begin
                                     TempShape^.GetStopPoint( NewEnd);
                                     TempShape := PShape( Shapes.GetAfter( TempShape));
                                     Break;
                                     end;
                                TempShape := PShape( Shapes.GetAfter( TempShape));
                                end;

                             if ( TempShape <> nil)
                             then begin
                                  TempShape^.GetStartPoint( OldEnd);
                                  ShiftDelta.X := NewEnd.X - OldEnd.X;
                                  ShiftDelta.Y := NewEnd.Y - OldEnd.Y;
                                  repeat
                                        TempShape^.Shift( ShiftDelta);
                                        TempShape := PShape( Shapes.GetAfter( TempShape));
                                  until ( TempShape = nil);
                                  end;
                             TempShape := PShape( Shapes.GetLast);
                             if ( TempShape <> nil)
                             then TempShape^.GetStopPoint( Info.LastPoint)
                             else Info.LastPoint.Assign( 0, 0);
                             Update;
                             end;
                        ClearEvent( E);
                        end;
             cmRotate90: begin
                         ClearEvent( E);
                         end;
             cmToolLine: begin
                         SetTool( New( PLineTool, Create( @Self, List)));
                         if ( List <> nil)
                         then List^.WriteLn('LINE tool selected.');
                         ClearEvent( E);
                         end;
             cmToolArc: begin
                        SetTool( New( PArcTool, Create( @Self, List)));
                        if ( List <> nil)
                        then List^.WriteLn('ARC tool selected.');
                        ClearEvent( E);
                        end;
             cmToolArcEx: begin
                          SetTool( New( PArcExTool, Create( @Self, List)));
                          if ( List <> nil)
                          then List^.WriteLn('ARC EX tool selected.');
                          ClearEvent( E);
                          end;
             cmNoTool: begin
                       SetTool( nil);
                       ClearEvent( E);
                       end;
             cmZoomIn,
             cmZoomOut,
             cmZoom11,
             cmZoomFit: begin
                        inherited HandleEvent( E);
                        FeedBack^.UpdateZoom( CanvasInfo.Zoom);
                        end;
             cmEditSettings: begin
                             ClearEvent( E);
                             SettingsDlg := New( PSettingsDlg, Create( @Info.MachineSettings));
                             SettingsDlg^.ExecuteDlg( @Self);
                             SettingsDlg^.Free;
                             Update;
                             end;
             cmPreview: begin
                        ClearEvent( E);
                        TempPath := New( PFPath, Create);
                        GetDrawPoints( TempPath);
                        PreviewDlg := New( PPreviewDlg, Create( TempPath, PMachineSettings(Info.MachineSettings.Clone)));
                        if ( PreviewData <> nil)
                        then begin
                             if ( PreviewData^.GetSize > 0)
                             then begin
                                  PreviewData^.SetPos(0);
                                  PreviewDlg^.LoadData( PreviewData);
                                  end;
                             end;
                        PreviewDlg^.ExecuteDlg( @Self);
                        if MessageYN( @Self,'Preview', 'Do you want to keep the preview settings?')
                        then begin
                             if ( PreviewData <> nil)
                             then PreviewData^.Free;
                             PreviewData := New( PMemStream, Create);
                             PreviewDlg^.SaveData( PreviewData);
                             end;
                        PreviewDlg^.Free;
                        end;
             cmAnalize: begin
                        ClearEvent( E);
                        TempPath := New( PFPath, Create);
                        GetDrawPoints( TempPath);
                        TestDlg := New( PTestDlg, Create( TempPath, PMachineSettings(Info.MachineSettings.Clone)));
                        TestDlg^.ExecuteDlg( @Self);
                        TestDlg^.Free;
                        end;
             cmRun: begin
                    ClearEvent( E);
                    TempPath := New( PFPath, Create);
                    GetDrawPoints( TempPath);
                    if TempPath^.ProduceHeadPath( Info.MachineSettings.GetStepLength,
                                                  Info.MachineSettings.MaxXStepLength,
                                                  Info.MachineSettings.MaxYStepLength, True)
                    then begin
                         RunDlg := New( PRunDlg, Create( TempPath, PMachineSettings(Info.MachineSettings.Clone)));
                         RunDlg^.ExecuteDlg( @Self);
                         RunDlg^.Free;
                         end
                    else begin
                         TempPath^.Free;
                         Message( @Self, 'ERROR', 'This drawn could not be implemented.');
                         end;
                    end;
             cmSnapOnOff: begin
                          CanvasInfo.Snap := not CanvasInfo.Snap;
                          FeedBack^.UpdateSnap( CanvasInfo.Snap);
                          ClearEvent( E);
                          end;
             cmGridStyle: begin
                          inherited HandleEvent( E);
                          FeedBack^.UpdateGridStyle( CanvasInfo.GridStyle);
                          end;
             cmEditGrid: begin
                         inherited HandleEvent( E);
                         end;
             cmSave: begin
                     if (not FileDefined)
                     then begin
                          E.What := evCommand;
                          E.Command := cmSaveAs;
                          PutEvent( E);
                          ClearEvent( E);
                          end
                     else WriteDataToFile( FileName, '');
                     end;
             cmLoadFile: begin
                         ClearEvent( E);
                         FileDlg := New( PFileDlg, Create( '', True, 'UDW'));
                         FileDlg^.ExecuteDlg( @Self);
                         if ( FileDlg^.IsFileSelected)
                         then begin
                              FileName := FileDlg^.GetFileNameFP;
                              FileDefined := ReadDataFromFile( FileName, FileDlg^.GetFileName);
                              E.What := evCommand;
                              E.Command := cmUpdateCaption;
                              E.Info := @Self;
                              PutEvent( E);
                              ClearEvent( E);
                              end;
                         FileDlg^.Free;
                         UpdateCommands;
                         end;
             cmSaveAs: begin
                       ClearEvent( E);
                       FileDlg := New( PFileDlg, Create( FileName, False, 'UDW'));
                       FileDlg^.ExecuteDlg( @Self);
                       if ( FileDlg^.IsFileSelected)
                       then begin
                            FileName := FileDlg^.GetFileNameFP;
                            WriteDataToFile( FileName, FileDlg^.GetFileName);
                            E.What := evCommand;
                            E.Command := cmUpdateCaption;
                            E.Info := @Self;
                            PutEvent( E);
                            ClearEvent( E);
                            end;
                       FileDlg^.Free;
                       end;
             end;
          end
     else if ( E.What = evKeyPress)
     then begin
          case E.KeyInfo.ScanCode
          of keyBACKSPACE: begin
                           E.What := evCommand;
                           E.Command := cmDeleteLastShape;
                           PutEvent( E);
                           ClearEvent( E);
                           end;
             {keyF2: begin
                    E.What := evCommand;
                    E.Command := cmSave;
                    PutEvent( E);
                    ClearEvent( E);
                    end;}
             keyDEL: begin
                     E.What := evCommand;
                     E.Command := cmDeleteSelected;
                     PutEvent( E);
                     ClearEvent( E);
                     end;
             keyPAGEUP: begin
                        LastSelectStart := SelectStart;
                        LastSelectEnd := SelectEnd;
                        if (( E.KeyInfo.ShiftStatus and shkShiftDown) <> $0000)
                        then begin
                             if (( SelectEnd <> nil) and ( SelectEnd <> SelectStart))
                             then begin
                                  TempShape := PShape( Shapes.GetBefore( SelectEnd));
                                  if ( TempShape <> nil)
                                  then SelectEnd := TempShape;
                                  end
                             else SelectEnd := SelectStart;
                             end
                        else begin
                             if ( SelectStart <> nil)
                             then begin
                                  TempShape := PShape( Shapes.GetBefore( SelectStart));
                                  if ( TempShape <> nil)
                                  then SelectStart := TempShape;
                                  end
                             else begin
                                  SelectStart := PShape( Shapes.GetLast);
                                  SelectEnd := SelectStart;
                                  end;
                             end;
                        ClearEvent( E);
                        if ((LastSelectStart <> SelectStart) or (LastSelectEnd <> SelectEnd))
                        then begin
                             DrawShapes( True);
                             UpdateCommands;
                             end;
                        end;
             keyPAGEDOWN: begin
                          LastSelectStart := SelectStart;
                          LastSelectEnd := SelectEnd;

                          if (( E.KeyInfo.ShiftStatus and shkShiftDown) <> $0000)
                          then begin
                               if ( SelectEnd <> nil)
                               then SelectEnd := PShape( Shapes.GetAfter( SelectEnd))
                               else SelectEnd := SelectStart;
                               end
                          else begin
                               if ( SelectStart <> nil)
                               then begin
                                    TempShape := PShape( Shapes.GetAfter( SelectStart));
                                    if SelectEnd = SelectStart
                                    then SelectEnd := TempShape;
                                    SelectStart := TempShape;
                                    end;
                               end;
                          ClearEvent( E);
                          if ((LastSelectStart <> SelectStart) or (LastSelectEnd <> SelectEnd))
                          then begin
                               DrawShapes( True);
                               UpdateCommands;
                               end;
                          end;
              end;
          end;

     if (( Tool <> nil) and (E.What <> evNoThing))
     then Tool^.HandleEvent( E);

     if (E.What <> evNoThing)
     then inherited Handleevent( E);
end;

procedure TDesignCanvas.SetTool( ATool: PTool);
begin
     if ( Tool <> nil)
     then Tool^.Free;
     Tool := ATool;
end;

procedure TDesignCanvas.GetDrawPoints( APath: PFPath);
var ScanShape: PShape;
begin
     if (APath <> nil)
     then begin
          APath^.Clear;
          ScanShape := PShape( Shapes.GetFirst);
          while ( ScanShape <> nil)
          do begin
             ScanShape^.AppendToPath( APath);
             ScanShape := PShape( Shapes.GetNext);
             end;
          end;
end;

procedure TDesignCanvas.GetFitRect( var FR: TFRect);
var ScanShape: PShape;
begin
     inherited GetFitRect( FR);

     ScanShape := PShape( Shapes.GetFirst);
     while ( ScanShape <> nil)
     do begin
        ScanShape^.Fit( FR);
        ScanShape := PShape( Shapes.GetNext);
        end;
end;

procedure TDesignCanvas.GetAvailableCommands( var ACommands: TCommandsSet);
begin
     ACommands := ACommands + [ cmNoTool,
                                cmToolLine,
                                cmUserCommand,
                                cmToolArc,
                                cmToolArcEx,
                                cmEditSettings,
                                cmPreview,
                                cmAnalize,
                                cmRun,
                                cmSave,
                                cmLoadFile,
                                cmSaveAs,
                                cmMirrorX,
                                cmMirrorY,
                                cmRotate90,
                                cmSnapOnOff
                                ];
     if ( Shapes.GetItemsCount > 0)
     then ACommands := ACommands + [ cmDeleteLastShape];
     if (SelectStart <> nil)
     then ACommands := ACommands + [ cmDeleteSelected,
                                     cmCutSelected,
                                     cmCopySelected ];
     if ( ShapesClipboard.GetItemsCount > 0)
     then ACommands := ACommands + [ cmPasteSelected];
     inherited GetAvailableCommands( ACommands);
end;

function TDesignCanvas.WriteDataToFile( AFileNameFP: string; AFileName: string): Boolean;
var Stream: PFileStream;
    ScanShape: PShape;
    ShapesCount: Longint;
    ShapeID: Integer;
    PreviewDataSize: Longint;
begin
     Stream := New( PFileStream, Create( AFileNameFP, fstCreate));
     Stream^.Write( FileHeader, HEADERSIZE);
     Stream^.Write( CanvasInfo, SizeOf( CanvasInfo));
     Info.Save( Stream);
     ShapesCount := Shapes.GetItemsCount;
     Stream^.Write( ShapesCount, SizeOf( ScanShape));
     if ( ShapesCount > 0)
     then begin
          ScanShape := PShape( Shapes.GetFirst);
          while ( ScanShape <> nil)
          do begin
             ShapeID := ScanShape^.GetShapeID;
             Stream^.Write( ShapeID, SizeOf( ShapeID));
             ScanShape^.Save( Stream);
             ScanShape := PShape( Shapes.GetNext);
             end;
          end;
     if ( PreviewData <> nil)
     then PreviewData^.SaveData( Stream)
     else begin
          PreviewData := New( PMemStream, Create);
          PreviewData^.SaveData( Stream);
          PreviewData^.Free;
          PreviewData := nil;
          end;
     Stream^.Free;
     WriteDataToFile := True;
end;

function TDesignCanvas.ReadDataFromFile( AFileNameFP: string; AFileName: string): Boolean;
var Stream: PFileStream;
    ShapesCount: Longint;
    ShapeID: Integer;
    Shape: PShape;
    TheHeader: string[HEADERSIZE];

begin
     ReadDataFromFile := False;
     Stream := New( PFileStream, Create( AFileNameFP, fstOpenRead));
     Stream^.Read( TheHeader, HEADERSIZE);
     if ( TheHeader = FileHeader)
     then begin
          Stream^.Read( CanvasInfo, SizeOf( CanvasInfo));
          Info.Destroy;
          Info.Load( Stream);
          Shapes.Clear;
          Stream^.Read( ShapesCount, SizeOf( ShapesCount));
          while ( ShapesCount > 0)
          do begin
             Stream^.Read( ShapeID, SizeOf( ShapeID));
             case ShapeID
             of 1: Shape := New( PLineShape, Load( Stream));
                2: Shape := New( PArcShape, Load( Stream));
                3: Shape := New( PArcExShape, Load( Stream));
                4: Shape := New( PGenericShape, Load( Stream));
                else
                    Shape := nil;
                end;
             if ( Shape <> nil)
             then Shapes.PushLast( Shape);
             ShapesCount := ShapesCount - 1;
             end;
          if ( PreviewData <> nil)
          then PreviewData^.Free;
          PreviewData := New( PMemStream, Create);
          PreviewData^.LoadData( Stream);
          if ( PreviewData^.GetSize <= 0)
          then begin
               PreviewData^.Free;
               PreviewData := nil;
               end;
          Update;
          ReadDataFromFile := True;
          end
     else Message( @Self, 'ERROR', 'Bad file format, unable to load ~' + AFileName + '~ file.');
     Stream^.Free;
end;

procedure TDesignCanvas.Update;
var Pos: TFPoint;
begin
     inherited Update;
     if ( FeedBack <> nil)
     then begin
          Pos.Assign( 0, 0);
          FeedBack^.UpdatePos( Pos);
          FeedBack^.UpdateZoom( CanvasInfo.Zoom);
          end;
end;

procedure TDesignCanvas.AppendShape( AShape: PShape);
begin
     if ( AShape <> nil)
     then begin
          Shapes.PushLast( AShape);
          AShape^.Draw( @Self, False);
          DrawShapes( True);
          UpdateCommands;
          end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TPreviewCanvas.Create( R: TRect; APath: PFPath; AHeadsPoses: PFPath; AMachineSettings: PMachineSettings);
begin
     inherited Create( R);
     SetOption( ofSelectable, True);
     Path := nil;
     HeadsPoses := AHeadsPoses;
     MachineSettings := AMachineSettings;
     Repeats := 1;
     SetPath( APath);
end;

destructor TPreviewCanvas.Destroy;
begin
     if ( Path <> nil)
     then Path^.Free;

     if ( MachineSettings <> nil)
     then MachineSettings^.Free;

     if ( HeadsPoses <> nil)
     then HeadsPoses^.Free;

     inherited Destroy;
end;

procedure TPreviewCanvas.Draw;
var P1, P2: TPoint;
    I,J: Integer;
    VP1, VP2: TPoint;
    LP1: TFPoint;
    Offset: TFPoint;

    procedure DrawPath;
    var FP: TFPoint;
        VP1, VP2: TPoint;
        Counter: Integer;
    begin
         Counter := Repeats;
         repeat
            if ( Path^.GetFirstPoint( FP))
            then begin
                 FP.X := FP.X + Offset.X;
                 FP.Y := FP.Y + Offset.Y;
                 ConvertToCanvasPos( FP, P1);
                 while Path^.GetNextPoint( FP)
                 do begin
                    FP.X := FP.X + Offset.X;
                    FP.Y := FP.Y + Offset.Y;
                    ConvertToCanvasPos( FP, P2);
                    Line( P1.X, P1.Y, P2.X, P2.Y);
                    P1 := P2;
                    end;
                 end;
            Offset.X := FP.X;
            Offset.Y := FP.Y;
            Counter := Counter - 1;
         until (Counter <= 0);
    end;
begin
     inherited Draw;

     BeginDraw;

     LP1.Assign(0 ,0);
     SetPColor( clrGUIDELINES);
     ConvertToCanvasPos( LP1, VP1);
     if (VP1.Y < Size.Y)
     then begin
          Line( VP1.X - 50, VP1.Y, VP1.X + 50, VP1.Y);
          if VP1.Y < Size.Y - 4
          then Line( VP1.X, VP1.Y, VP1.X, Size.Y - 4);
          Line( VP1.X - 4, Size.Y - 4, VP1.X, Size.Y);
          Line( VP1.X + 4, Size.Y - 4, VP1.X, Size.Y);
          Line( VP1.X - 4, Size.Y - 4, VP1.X + 4, Size.Y - 4);
          end
     else begin
          Line( VP1.X - 4, Size.Y - 4, VP1.X, Size.Y);
          Line( VP1.X + 4, Size.Y - 4, VP1.X, Size.Y);
          Line( VP1.X - 4, Size.Y - 4, VP1.X + 4, Size.Y - 4);
          end;

     if ( Path <> nil)
     then begin
          SetColor(15);
          if ( HeadsPoses <> nil)
          then begin
               if HeadsPoses^.GetFirstPoint( Offset)
               then begin
                    repeat
                          DrawPath;
                    until not HeadsPoses^.GetNextPoint( Offset);
                    end
               else begin
                    Offset.Assign( 0, 0);
                    DrawPath;
                    end;
               end
          else begin
               Offset.Assign( 0, 0);
               DrawPath;
               end;
          end;
     EndDraw;
end;

procedure TPreviewCanvas.GetFitRect( var FR: TFRect);
var HFR: TFRect;
    FP1: TFPoint;
    FP2: TFPoint;
begin
     inherited GetFitRect( FR);
     if (( Path <> nil) and ( MachineSettings <> nil))
     then begin
          Path^.GetFitRect( FR, True);
          if (Repeats > 1)
          then if Path^.GetFirstPoint( FP1)
               then if Path^.GetLastPoint( FP2)
                    then begin
                         FR.B.X := FR.B.X + ( FP2.X - FP1.X) * (Repeats - 1);
                         FR.B.Y := FR.B.Y + ( FP2.Y - FP1.Y) * (Repeats - 1);
                         end;
          if ( HeadsPoses <> nil)
          then begin
               HeadsPoses^.GetFitRect( HFR, True);
               FR.A.X := FR.A.X + HFR.A.X;
               FR.A.Y := FR.A.Y + HFR.A.Y;
               FR.B.X := FR.B.X + HFR.B.X;
               FR.B.Y := FR.B.Y + HFR.B.Y;
               end;
          end
end;

procedure TPreviewCanvas.SetPath( APath: PFPath);
begin
     if ( Path <> nil)
     then Path^.Free;

     Path := APath;
     Scroll( 9);
end;

procedure TPreviewCanvas.GetAvailableCommands( var ACommands: TCommandsSet);
begin
     inherited GetAvailableCommands( ACommands);
end;

procedure TPreviewCanvas.SetHeadsPoses( AHeadsPoses: PFPath);
begin
     if ( HeadsPoses <> nil)
     then HeadsPoses^.Free;
     HeadsPoses := AHeadsPoses;
     Update;
end;

procedure TPreviewCanvas.SetRepeats( ARepeats: Integer);
begin
     if (ARepeats > 1)
     then Repeats := ARepeats
     else Repeats := 1;
     Update;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TTestCanvas.Create( R: TRect; APath: PFPath; AMachineSettings: PMachineSettings; ATextList: PTextList);
var I: Integer;
begin
     inherited Create( R);
     ThePath := nil;
{$IFDEF _FINALPATH}
     FinalPath := nil;
{$ENDIF}
     for I := 1 to TESTCANVASLINESCOUNT
     do Lines[ I] := nil;
     MachineSettings := AMachineSettings;
     HeadPath := True;
     SetPath( APath);
end;

destructor TTestCanvas.Destroy;
var I: Integer;
begin
     if ( ThePath <> nil)
     then ThePath^.Free;

{$IFDEF _FINALPATH}
     if ( FinalPath <> nil)
     then FinalPath^.Free;
{$ENDIF}

     for I := 1 to TESTCANVASLINESCOUNT
     do if ( Lines[ I] <> nil)
        then FreeString( Lines[I]);

     if ( MachineSettings <> nil)
     then MachineSettings^.Free;

     inherited Destroy;
end;

procedure TTestCanvas.Draw;
var P1, P2: TPoint;
    FP1, FP2: TFPoint;
    LP1: TFPoint;
    VP1: TPoint;
    BasePoint1, BasePoint2: TFPoint;
    DrawPoint1, DrawPoint2: TFPoint;
    I: Integer;
    S: String;

begin
     inherited Draw;

     BeginDraw;

     LP1.Assign(0 ,0);
     SetPColor( clrGUIDELINES);
     ConvertToCanvasPos( LP1, VP1);
     if (VP1.Y < Size.Y)
     then begin
          Line( VP1.X - 50, VP1.Y, VP1.X + 50, VP1.Y);
          if VP1.Y < Size.Y - 4
          then Line( VP1.X, VP1.Y, VP1.X, Size.Y - 4);
          Line( VP1.X - 4, Size.Y - 4, VP1.X, Size.Y);
          Line( VP1.X + 4, Size.Y - 4, VP1.X, Size.Y);
          Line( VP1.X - 4, Size.Y - 4, VP1.X + 4, Size.Y - 4);
          end
     else begin
          Line( VP1.X - 4, Size.Y - 4, VP1.X, Size.Y);
          Line( VP1.X + 4, Size.Y - 4, VP1.X, Size.Y);
          Line( VP1.X - 4, Size.Y - 4, VP1.X + 4, Size.Y - 4);
          end;


     if ( MachineSettings <> nil)
     then begin
          if ( ThePath <> nil)
          then begin
               if (ThePath^.GetFirstPoint( FP1))
               then begin
                    ConvertToCanvasPos( FP1, P1);
                    SetPColor( clrCURSOR);
                    Line( P1.X - 10, P1.Y, P1.X + 10, P1.Y);
                    Line( P1.X, P1.Y - 10, P1.X, P1.Y + 10);
                    while ( ThePath^.GetNextPoint( FP2))
                    do begin
                       ConvertToCanvasPos( FP2, P2);
                       SetColor(14);
                       Line( P1.X, P1.Y, P2.X, P2.Y);
                       PutPixel( P1.X, P1.Y, 12);
                       FP1 := FP2;
                       P1 := P2;
                       end;
                    SetColor(13);
                    PutPixel( P1.X, P1.Y, 13);
                    SetPColor( clrCURSOR);
                    Line( P1.X - 10, P1.Y, P1.X + 10, P1.Y);
                    Line( P1.X, P1.Y - 10, P1.X, P1.Y + 10);
                    end;
               end;

{$IFDEF _FINALPATH}
          if ( FinalPath <> nil)
          then begin
               if ( FinalPath^.GetFirstPoint( FP1))
               then begin
                    ConvertToCanvasPos( FP1, P1);
                    SetPColor( clrCURSOR);
                    Circle( P1.X, P1.Y, 5);
                    SetColor( 8);
                    while ( FinalPath^.GetNextPoint( FP2))
                    do begin
                       ConvertToCanvasPos( FP2, P2);
                       Line( P1.X, P1.Y, P2.X, P2.Y);
                       PutPixel( P1.X, P1.Y, 7);
                       FP1 := FP2;
                       P1 := P2;
                       end;
                    SetPColor( clrCURSOR);
                    PutPixel( P1.X, P1.Y, 7);
                    Circle( P1.X, P1.Y, 5);
                    end;
               end;
          SetColor( 13);
{$ENDIF}

          for I := 1 to TESTCANVASLINESCOUNT
          do if ( Lines[ I] <> nil)
             then OutTextXY( 10, 10 + (I - 1) * (metTEXTHEIGHT + 5), Lines[I]^);
          end;
     EndDraw;
end;

procedure TTestCanvas.GetFitRect( var FR: TFRect);
begin
     inherited GetFitRect( FR);
     if ( ThePath <> nil)
     then ThePath^.GetFitRect( FR, True);
{$IFDEF _FINALPATH}
     if ( FinalPath <> nil)
     then FinalPath^.GetFitRect( FR, False);
{$ENDIF}
end;

procedure TTestCanvas.SetPath( APath: PFPath);
var LastPoint: TFPoint;
    FN, HN, BN: Longint;
    S1, S2: string;
    FValue: Float;
    IValue: Longint;
    FRect: TFRect;
    I: Integer;
begin
     if ( ThePath <> nil)
     then ThePath^.Free;

{$IFDEF _FINALPATH}
     if ( FinalPath <> nil)
     then begin
          FinalPath^.Free;
          FinalPath := nil;
          end;
{$ENDIF}

     for I := 1 to TESTCANVASLINESCOUNT
     do if ( Lines[ I] <> nil)
        then begin
             FreeString( Lines[I]);
             Lines[I] := nil;
             end;

     ThePath := APath;
     HeadPath := True;
     if (( ThePath <> nil) and ( MachineSettings <> nil))
     then begin
          if ThePath^.ProduceHeadPath( MachineSettings^.GetStepLength,
                                       MachineSettings^.MaxXStepLength,
                                       MachineSettings^.MaxYStepLength, False)
          then begin
{$IFDEF _FINALPATH}
               FindFinalPath;
{$ENDIF}
               FValue := ThePath^.GetMaxXStep;
               Str( FValue:0:3, S1);
               Lines[1] := AllocateString( 'MAX STEP ON X     : ' + S1 + ' mm.');
               FValue := ThePath^.GetMaxYStep;
               Str( FValue:0:3, S1);
               Lines[2] := AllocateString( 'MAX STEP ON Y     : ' + S1 + ' mm.');
               IValue := ThePath^.GetStepsCount;
               Str( IValue, S1);
               Lines[3] := AllocateString( 'STEPS COUNT       : ' + S1);

               ThePath^.GetFitRect( FRect, True);
               Str( (FRect.B.X - FRect.A.X):0:1, S1);
               Lines[4] := AllocateString( 'RANGE WIDTH       : ' + S1 + ' mm.');
               Str( (FRect.B.Y - FRect.A.Y):0:1, S1);
               Lines[5] := AllocateString( 'RANGE HEIGHT      : ' + S1 + ' mm.');
               Str( MachineSettings^.GetStepLength:0:3, S1);
               Lines[6] := AllocateString( 'FEED STEP LENGTH  : ' + S1 + ' mm.');
               Str( MachineSettings^.GetStepPulsesCount, S1);
               Lines[7] := AllocateString( 'STEP PULSES COUNT : ' + S1);

               end
          else Lines[1] := AllocateString( 'ERROR: UNABLE TO PRODUCE HEAD PATH');
          end
     else Lines[1] := AllocateString( 'WARNING: NO PATH TO DISPLAY');
     Scroll( 9);
end;

procedure TTestCanvas.TugglePath;
begin
     if (( ThePath <> nil) and ( MachineSettings <> nil))
     then begin
          if HeadPath
          then begin
               ThePath^.SubtractSteps( - MachineSettings^.GetStepLength);
               HeadPath := False;
               end
          else begin
               ThePath^.SubtractSteps( + MachineSettings^.GetStepLength);
               HeadPath := True;
               end;
          Scroll( 9);
          end;
end;

{$IFDEF _FINALPATH}

procedure TTestCanvas.FindFinalPath;
var DeltasPath: PRPath;
    Delta: PDeltaList;
    FirstDelta: PDeltaList;
    LastPos: TFPoint;
    NewPos: TFPoint;
    YStep: Float;
    S: string;
    StepsCount: Longint;
begin
     if (( ThePath = nil) or ( MachineSettings = nil))
     then Exit;

     if ( FinalPath <> nil)
     then begin
          FinalPath^.Free;
          FinalPath := nil;
          end;

     DeltasPath := ThePath^.ProduceDeltaPath( PULSES_PER_MM_X, PULSES_PER_MM_Y);
     if ( DeltasPath <> nil)
     then begin
          FinalPath := New( PFPath, Create);
          FirstDelta := DeltasPath^.GetFirstDeltaEx;
          if ( FirstDelta <> nil)
          then begin
               Delta := FirstDelta;
               StepsCount := 0;
               LastPos.Assign( 0, 0);
               FinalPath^.AppendPoint( 0, 0);
               YStep := MachineSettings^.GetStepLength;
               repeat
                     StepsCount := StepsCount + 1;
                     NewPos.X := LastPos.X + Delta^.Delta.X / PULSES_PER_MM_X;
                     NewPos.Y := LastPos.Y + Delta^.Delta.Y / PULSES_PER_MM_Y + YStep;
                     FinalPath^.AppendPoint( NewPos.X, NewPos.Y);
                     LastPos := NewPos;
                     Delta := Delta^.Next;
               until ( Delta = FirstDelta);
               Str( StepsCount, S);
               Lines[10] := AllocateString( 'FINAL STEPS COUNT : ' + S);
               end;
          DeltasPath^.Free;
          end;
end;

{$ENDIF}

procedure TTestCanvas.GetAvailableCommands( var ACommands: TCommandsSet);
begin
     inherited GetAvailableCommands( ACommands);
end;

procedure TTestCanvas.HandleEvent( var E: TEvent);
begin
     if E.What = evCommand
     then begin
          case E.Command
          of cmTuggle: begin
                       TugglePath;
                       ClearEvent( E);
                       end;
             end;
          end;
     inherited HandleEvent( E);
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TDesignWindow.Create( AOrigin: TPoint);
var R: TRect;
    Panel: PJustFrame;
begin
     R.A := AOrigin;
     {R.B.Assign( 630, 440);}
     R.B.Assign( 640, 455);
     inherited Create( 'Design', R.A, R.B);
     Style := cwsCOLSEABLE;

     Lock;
     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 5;
     R.B.Y := R.B.Y - R.A.Y - 5 {- 53};
     R.A.X := R.B.X - 205 + 100;
     R.A.Y := R.B.Y - 130{100};
     FeedBack := New( PFeedBackPanel, Create( R));
     InsertChild( FeedBack);

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 5 - 110 - 22;
     R.B.Y := R.B.Y - R.A.Y - 5 {- 53} - 22;
     R.A.X := 5;
     R.A.Y := 5;
     Panel := New( PJustFrame, Create( R));
     InsertChild( Panel);
     Panel^.GetClientRect( R);
     R.A.X := 0;
     R.A.Y := 0;
     R.B.X := R.B.X - R.A.X - 1;
     R.B.Y := R.B.Y - R.A.Y - 1;
     Canvas := New( PDesignCanvas, Create( R, nil{List}, FeedBack));
     Panel^.InsertChild( Canvas);

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 5 - 110;
     R.B.Y := R.B.Y - R.A.Y - 5 {- 53} - 22;
     R.A.X := R.B.X - 21;
     R.A.Y := 5;
     VScroolBar := New( PScrollBar, Create( R, Canvas, True, 10, 100, 0));
     InsertChild( VScroolBar);

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 5 - 110 - 22;
     R.B.Y := R.B.Y - R.A.Y - 5 {- 53};
     R.A.X := 5;
     R.A.Y := R.B.Y - 21;
     HScroolBar := New( PScrollBar, Create( R, Canvas, False, 10, 100, 0));
     InsertChild( HScroolBar);


     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 5;
     R.B.Y := R.B.Y - R.A.Y - 5 - 135{205}{175};
     R.A.X := R.B.X - 205 + 100;
     R.A.Y := 5;

     InsertChild(new(PMenuList,Create( R, 'Menu title',
        NewMenuItem('&Zoom ...', keyZ,1,
           NewMenuItem('Zoom &In', keyI, cmZoomIn,nil,
           NewMenuItem('Zoom &Out', keyO, cmZoomOut,nil,
           NewMenuItem('Zoom &1:1', key1, cmZoom11,nil,
           NewMenuItem('Zoom &Fit', keyF, cmZoomFit, nil,
           NewMenuItem('To (&0,0)', key0, cmScrollToCenter, nil,
           NewMenuItem('..', keyNONE, cmMenuBack, nil,nil)))))),

        NewMenuItem('&Tools ...', keyT,0,
           NewMenuItem('&None', keyN,cmNoTool,nil,
           NewMenuItem('&Line', keyL,cmToolLine,nil,
           NewMenuItem('&Arc', keyA,cmToolArc,nil,
           NewMenuItem('Arc &ex.', keyE,cmToolArcEx,nil,
           NewMenuItem('..', keyNONE, cmMenuBack, nil,nil))))),
        NewMenuItem('&Edit ...', keyE,0,
           NewMenuItem('&Copy', keyC, cmCopySelected,nil,
           NewMenuItem('Cu&t', keyT, cmCutSelected,nil,
           NewMenuItem('&Paste', keyP, cmPasteSelected,nil,
           NewMenuItem('..', keyNONE, cmMenuBack, nil, nil)))),
        NewMenuItem('E&ffects ...', keyF,0,
           NewMenuItem('Mirror &X', keyX,cmMirrorX,nil,
           NewMenuItem('Mirror &Y', keyY,cmMirrorY,nil,
           NewMenuItem('Ro&tate', keyT,cmRotate90,nil,
           NewMenuItem('..', keyNONE, cmMenuBack, nil, nil)))),
        NewMenuItem('&Delete last shape', keyD,cmDeleteLastShape,nil,
        NewMenuItem('Delete &Selected', keyS,cmDeleteSelected,nil,
        NewMenuItem('S&nap on/off', keyN,cmSnapOnOff,nil,
        NewMenuItem('&Grid style', keyG,cmGridStyle,nil,
        NewMenuItem('G&rid size', keyR,cmEditGrid, nil,
        NewMenuItem('&Actions ...', keyA,0,
           NewMenuItem('A&nalize', keyA,cmAnalize,nil,
           NewMenuItem('&Preview', keyP,cmPreview,nil,
           NewMenuItem('&Run', keyR,cmRun,nil,
           NewMenuItem('..', keyNONE, cmMenuBack, nil, nil)))),nil
        {NewMenuItem('Test &1', key1,cmTest1,nil,
        NewMenuItem('Test &2', key2,cmTest2,nil,nil}
        )))))))))))));

     Unselect;
     UnLock;
end;

destructor TDesignWindow.Destroy;
begin
     inherited Destroy;
end;

procedure TDesignWindow.HandleEvent( var E: TEvent);
begin
     if E.What = evCommand
     then begin
          case E.Command
          of cmUpdateCaption: begin
                              if ((E.Info = Canvas) and GetState( sfFocused))
                              then DrawFrame( True);
                              ClearEvent( E);
                              end;
             end;
          end;
     inherited HandleEvent( E);
end;

procedure TDesignWindow.GetAvailableCommands( var ACommands: TCommandsSet);
begin
     ACommands := ACommands + [{cmClose}];
     inherited GetAvailableCommands( ACommands);
end;

function TDesignWindow.GetCaption: string;
var TheCaption: string;
begin
     TheCaption := inherited GetCaption;
     if ( Canvas <> nil)
     then TheCaption := TheCaption + ' [' + Canvas^.FileName + ']';
     GetCaption := TheCaption;
end;


{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TPreviewDlg.Create( APath: PFPath; AMachineSettings: PMachineSettings);
var R: TRect;
    Panel: PJustFrame;
begin
     Canvas := nil; { For reducing the possible problem of ~GetCaption~ function }
     R.A.Assign( 615, 465);
     inherited Create( R.A, 'Preview');
     Lock;

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 22 - 5 - 120;
     R.B.Y := R.B.Y - R.A.Y - 22 - 5 - 130;
     R.A.X := 5;
     R.A.Y := 5;
     Panel := New( PJustFrame, Create( R));
     InsertChild( Panel);
     Panel^.GetClientRect( R);
     R.A.X := 0;
     R.A.Y := 0;
     R.B.X := R.B.X - R.A.X - 1;
     R.B.Y := R.B.Y - R.A.Y - 1;
     Canvas := New( PPreviewCanvas, Create( R, APath, nil, AMachineSettings));
     Panel^.InsertChild( Canvas);
     Panel^.SetOption( ofSelectable, True);
     {Canvas^.SetFocus;}

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 5 - 120;
     R.B.Y := R.B.Y - R.A.Y - 5 - 22 - 130;
     R.A.X := R.B.X - 21;
     R.A.Y := 5;
     VScroolBar := New( PScrollBar, Create( R, Canvas, True, 10, 100, 0));
     InsertChild( VScroolBar);

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 22 - 5 - 120;
     R.B.Y := R.B.Y - R.A.Y - 5 - 130;
     R.A.X := 5;
     R.A.Y := R.B.Y - 21;
     HScroolBar := New( PScrollBar, Create( R, Canvas, False, 10, 100, 0));
     InsertChild( HScroolBar);

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 5;
     R.B.Y := R.B.Y - R.A.Y - 5;
     R.A.X := 5;
     R.A.Y := R.B.Y - 95;
     Panel := New( PJustFrame, Create( R));
     InsertChild( Panel);
     Panel^.GetClientRect( R);
     R.A.X := 0;
     R.A.Y := 0;
     R.B.X := R.B.X - R.A.X - 1;
     R.B.Y := R.B.Y - R.A.Y - 1;
     HeadsPanel := New( PHeadsPanel, Create( R));
     Panel^.InsertChild( HeadsPanel);

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 5 - 120;
     R.B.Y := R.B.Y - R.A.Y - 105;
     R.A.X := 205;
     R.A.Y := R.B.Y - 25;
     HeadCordsPanel := New( PHeadCordsPanel, Create( R, HeadsPanel));
     InsertChild( HeadCordsPanel);

     R.A.X := 150;
     AutoFitCheck := New( PCheckBox, Create( R.A.X, R.A.Y));
     AutoFitCheck^.SetValue( True);
     InsertChild( AutoFitCheck);
     AddLabel( 10, R.A.Y + 10, 'Auto fit preview');

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X;
     R.B.Y := R.B.Y - R.A.Y;
     R.A.X := 0;
     R.A.Y := 0;

     RepeatEdit := New( PIntegerEdit, Create( R.B.X - 110, 25, 100, 1, 20));
     RepeatEdit^.SetValue(1);
     InsertChild( RepeatEdit);

     AddLabel( R.B.X - 115, 10, 'Repeats:');

     InsertChild( New( PButton, Create( R.B.X - 110, R.B.Y - 100 - 261 - 10, 100 + metSHADOWSIZE, 30,
                  '&Grid', cmEditPreviewGrid, keyG)));
     InsertChild( New( PButton, Create( R.B.X - 110, R.B.Y - 100 - 228 - 10, 100 + metSHADOWSIZE, 30,
                  '&Positions', cmPositions, keyP)));
     InsertChild( New( PButton, Create( R.B.X - 110, R.B.Y - 100 - 195 - 10, 100 + metSHADOWSIZE, 30,
                  '&Add Row', cmAddRow, keyA)));
     InsertChild( New( PButton, Create( R.B.X - 110, R.B.Y - 100 - 162 - 10, 100 + metSHADOWSIZE, 30,
                  'Add &Heads', cmAddHeads, keyH)));
     InsertChild( New( PButton, Create( R.B.X - 110, R.B.Y - 100 - 129 - 10, 100 + metSHADOWSIZE, 30,
                  'Remove Ro&w', cmRemoveRow, keyW)));
     InsertChild( New( PButton, Create( R.B.X - 110, R.B.Y - 100 - 96 - 10, 100 + metSHADOWSIZE, 30,
                  '&Remove Head', cmRemoveHead, keyR)));
     InsertChild( New( PButton, Create( R.B.X - 110, R.B.Y - 100 - 63 - 10, 100 + metSHADOWSIZE, 30,
                  '&Edit', cmEditPos, keyE)));
     InsertChild( New( PButton, Create( R.B.X - 110, R.B.Y - 100 - 30 - 10, 100 + metSHADOWSIZE, 30,
                  '&Close', cmCancel, keyC)));

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 5;
     R.B.Y := R.B.Y - R.A.Y - 5 - 145;
     R.A.X := R.B.X - 205 + 100;
     R.A.Y := 70;

     Unselect;
     UnLock;
end;

destructor TPreviewDlg.Destroy;
begin
     inherited Destroy;
end;

procedure TPreviewDlg.HandleEvent( var E: TEvent);
var Repeats: Longint;
    RowAddDlg: PRowAddDlg;
    HeadsAddDlg: PHeadsAddDlg;
    RowHeadEditDlg: PRowHeadEditDlg;
    PreviewGridEditDlg: PPreviewGridEditDlg;
    FileDlg: PFileDlg;
    FileName: string;
    Stream: PFileStream;
begin
     if ( E.What = evCommand)
     then begin
          case E.Command
          of cmUpdatePreview: begin
                              Lock;
                              Canvas^.SetHeadsPoses( HeadsPanel^.GetHeadsPoses);
                              if not RepeatEdit^.ValidateString
                              then RepeatEdit^.SetValue( 1);
                              Repeats := RepeatEdit^.GetValue;
                              Canvas^.SetRepeats( Repeats);
                              Unlock;
                              if AutoFitCheck^.GetValue
                              then begin
                                   E.What := evCommand;
                                   E.Command := cmZoomFit;
                                   Canvas^.HandleEvent( E);
                                   end
                              else Canvas^.Update;
                              ClearEvent( E);
                              end;
             cmAddRow: begin
                       RowAddDlg := New( PRowAddDlg, Create( HeadsPanel));
                       RowAddDlg^.ExecuteDlg( @Self);
                       RowAddDlg^.Free;
                       HeadsPanel^.Update;
                       E.What := evCommand;
                       E.Command := cmUpdatePreview;
                       PutEvent( E);
                       ClearEvent( E);
                       end;
             cmRemoveRow: begin
                          HeadsPanel^.RemoveRow;
                          E.What := evCommand;
                          E.Command := cmUpdatePreview;
                          PutEvent( E);
                          ClearEvent( E);
                          end;
             cmRemoveHead: begin
                           HeadsPanel^.RemoveHead;
                           E.What := evCommand;
                           E.Command := cmUpdatePreview;
                           PutEvent( E);
                           ClearEvent( E);
                           end;
             cmEditPos: begin
                        if ( HeadsPanel^.GetSelectedHead <> nil)
                        then begin
                             RowHeadEditDlg := New( PRowHeadEditDlg, Create( HeadsPanel));
                             RowHeadEditDlg^.ExecuteDlg( @Self);
                             RowHeadEditDlg^.Free;
                             HeadsPanel^.Update;
                             end
                        else MistakeBeep;
                        E.What := evCommand;
                        E.Command := cmUpdatePreview;
                        PutEvent( E);
                        ClearEvent( E);
                        end;
             cmEditPreviewGrid: begin
                                PreviewGridEditDlg := New( PPreviewGridEditDlg, Create( HeadsPanel));
                                PreviewGridEditDlg^.ExecuteDlg( @Self);
                                PreviewGridEditDlg^.Free;
                                HeadsPanel^.Update;
                                E.What := evCommand;
                                E.Command := cmUpdatePreview;
                                PutEvent( E);
                                ClearEvent( E);
                                end;
             cmAddHeads: begin
                         HeadsAddDlg := New( PHeadsAddDlg, Create( HeadsPanel));
                         HeadsAddDlg^.ExecuteDlg( @Self);
                         HeadsAddDlg^.Free;
                         HeadsPanel^.Update;
                         E.What := evCommand;
                         E.Command := cmUpdatePreview;
                         PutEvent( E);
                         ClearEvent( E);
                         end;
             cmPositions: begin
                          FileDlg := New( PFileDlg, Create( '', False, 'TXT'));
                          FileDlg^.ExecuteDlg( @Self);
                          if ( FileDlg^.IsFileSelected)
                          then begin
                               FileName := FileDlg^.GetFileNameFP;
                               Stream := New( PFileStream, Create( FileName, fstCreate));
                               HeadsPanel^.WritePositions( Stream);
                               Stream^.Free;
                               {WriteDataToFile( FileName, FileDlg^.GetFileName);}
                               end;
                          FileDlg^.Free;
                          end;
             end;
          end;

     if E.What <> evNoThing
     then inherited HandleEvent( E);
end;

procedure TPreviewDlg.GetAvailableCommands( var ACommands: TCommandsSet);
begin
     ACommands := ACommands + [cmPositions, cmAddRow, cmRemoveRow, cmEditPos, cmEditPreviewGrid, cmCancel, cmUpdatePreview];
     inherited GetAvailableCommands( ACommands);
end;

function TPreviewDlg.DialogExitQuery( AAccept: Boolean): Boolean;
var E: TEvent;
begin
     if AAccept
     then begin
          E.What := evCommand;
          E.Command := cmUpdatePreview;
          PutEvent( E);
          DialogExitQuery := False;
          end;
end;

procedure TPreviewDlg.SaveData( AStream: PStream);
begin
     if ( AStream <> nil)
     then HeadsPanel^.SaveData( AStream);
end;

procedure TPreviewDlg.LoadData( AStream: PStream);
begin
     if ( AStream <> nil)
     then HeadsPanel^.LoadData( AStream);
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TTestDlg.Create( APath: PFPath; AMachineSettings: PMachineSettings);
var R: TRect;
    Panel: PJustFrame;
begin
     R.A.Assign( 620, 460);
     inherited Create( R.A, 'Test');
     Lock;

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 17 - 5;
     R.B.Y := R.B.Y - R.A.Y - 5 - 17 - 60;
     R.A.X := 5;
     R.A.Y := 5;
     Panel := New( PJustFrame, Create( R));
     InsertChild( Panel);
     Panel^.GetClientRect( R);
     R.A.X := 0;
     R.A.Y := 0;
     R.B.X := R.B.X - R.A.X - 1;
     R.B.Y := R.B.Y - R.A.Y - 1;
     Canvas := New( PTestCanvas, Create( R, APath, AMachineSettings, nil));
     Panel^.InsertChild( Canvas);

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 5;
     R.B.Y := R.B.Y - R.A.Y - 5 - 17 - 60;
     R.A.X := R.B.X - 15;
     R.A.Y := 5;
     VScroolBar := New( PScrollBar, Create( R, Canvas, True, 10, 100, 0));
     InsertChild( VScroolBar);

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 17 - 5;
     R.B.Y := R.B.Y - R.A.Y - 5 - 60;
     R.A.X := 5;
     R.A.Y := R.B.Y - 15;
     HScroolBar := New( PScrollBar, Create( R, Canvas, False, 10, 100, 0));
     InsertChild( HScroolBar);

     {InsertChild( New( PButton, Create( 500, 320, 100 + metSHADOWSIZE, 30, '&Run', cmRunSimulation, keyR)));}
     GetClientRect( R);
     {InsertChild( New( PButton, Create( R.B.X - 340 - metSHADOWSIZE - 20,
                  R.B.Y - R.A.Y - 30 - metSHADOWSIZE - 15, 100 + metSHADOWSIZE, 30 + metSHADOWSIZE,
                  '&Next Step', cmTest1, keyN)));}
     {InsertChild( New( PButton, Create( R.B.X - 340 - metSHADOWSIZE - 20,
                  R.B.Y - R.A.Y - 30 - metSHADOWSIZE - 15, 100 + metSHADOWSIZE, 30 + metSHADOWSIZE,
                  '&Real Path', cmRealPath, keyT)));}
     InsertChild( New( PButton, Create( R.B.X - 220 - metSHADOWSIZE - 20,
                  R.B.Y - R.A.Y - 30 - metSHADOWSIZE - 15, 100 + metSHADOWSIZE, 30 + metSHADOWSIZE,
                  '&Tuggle', cmTuggle, keyT)));
     InsertChild( New( PButton, Create( R.B.X - 100 - metSHADOWSIZE - 20,
                  R.B.Y - R.A.Y - 30 - metSHADOWSIZE - 15, 100 + metSHADOWSIZE, 30 + metSHADOWSIZE,
                  '&Ok', cmOk, keyO)));

     Unselect;
     UnLock;
end;

destructor TTestDlg.Destroy;
begin
     inherited Destroy;
end;

procedure TTestDlg.HandleEvent( var E: TEvent);
begin
     if E.What <> evNoThing
     then inherited HandleEvent( E);
end;

procedure TTestDlg.GetAvailableCommands( var ACommands: TCommandsSet);
begin
     ACommands := ACommands + [];
     inherited GetAvailableCommands( ACommands);
end;

procedure TTestDlg.BeforeExecuteDlg;
begin
end;

procedure TTestDlg.AfterExecuteDlg;
begin
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

procedure TMyDesktopClientsArea.HandleEvent( var E: TEvent);
begin
     if (E.What = evKeyPress)
     then begin
          case E.KeyInfo.ScanCode
          of keyF6: begin
                    if (First <> nil)
                    then SelectNext( First);
                    ClearEvent( E);
                    end;
             keySHIFTF6: begin
                         if (First <> nil)
                         then SelectPrev( First);
                         ClearEvent( E);
                         end;
               end;
          end;

     if ( E.What <> evNothing)
     then inherited HandleEvent( E);
end;

procedure TMyDesktopClientsArea.Draw;
begin
     inherited Draw;
     BeginDraw;
     SetFillPattern( SolidPattern, 9);
     Bar( Size.X - 85, Size.Y - 14, Size.X - 2, Size.Y - 2);
     SetColor( 10);
     Rectangle( Size.X - 86, Size.Y - 14, Size.X - 1, Size.Y - 1);
     DrawTradeMark( Size.X - 80, Size.Y - 11);
     EndDraw;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TMyDesktop.Create;
var Pos, _Size: TPoint;
begin
     inherited Create(''{'ULTRA DRAW'},
        NewMenuItem('&File', keyF, cmNone,
           NewMenuItem('&New design', keyN, cmNew, nil,
           {NewMenuItem('Preview',Ord('p'), cmPreview, nil,}
           NewMenuItem('&Open', keyO, cmOpen, nil,
           NewMenuItem('&Save', keyS, cmSave, nil,
           NewMenuItem('Save &as', keyA, cmSaveAs, nil,
           NewMenuItem('A&nalize', keyA, cmAnalize, nil,
           NewMenuItem('&Preview', keyP,cmPreview,nil,
           NewMenuItem('&Run', keyR, cmRun, nil,
           {NewMenuItem('Save all',Ord('l'), cmSaveAll, nil,}
           {NewMenuItem('Close',Ord('c'), cmClose, nil,}
           NewMenuItem('E&xit', keyX, cmExitApplication, nil, nil)))))))),
        NewMenuItem('&Edit', keyE,0,
           NewMenuItem('&Copy', keyC, cmCopySelected,nil,
           NewMenuItem('Cu&t', keyT, cmCutSelected,nil,
           NewMenuItem('&Paste', keyP, cmPasteSelected,nil, nil))),
        NewMenuItem('&Zoom', keyZ,cmNone,
           NewMenuItem('Zoom &In', keyI,cmZoomIn,nil,
           NewMenuItem('Zoom &Out', keyO,cmZoomOut,nil,
           NewMenuItem('Zoom &1:1', key1,cmZoom11,nil,
           NewMenuItem('Zoom &Fit', keyF,cmZoomFit, nil,
           NewMenuItem('To (&0,0)', key0,cmScrollToCenter, nil,nil))))),
        NewMenuItem('&Settings', keyS, cmNone,
           NewMenuItem('Grid s&tyle', keyT,cmGridStyle,nil,
           NewMenuItem('&Grid size', keyG,cmEditGrid, nil,
           NewMenuItem('&Settings', keyS,cmEditSettings,nil,
           NewMenuItem('Machine &configuration', keyC,cmConfig,nil,nil)))),
        NewMenuItem('&About', keyA,cmNone,
           NewMenuItem('The &Producer', keyP,cmAboutMaktabi,nil,
           NewMenuItem('The &Control', keyC,cmAboutSabbagh,nil,
           NewMenuItem('The &Software', keyS,cmAboutUltraSoft,nil,nil))),
         nil))))));
     UpdateCommands;
end;

procedure TMyDesktop.HandleEvent( var E: TEvent);
var Pos: TPoint;
    NewWindow: PDesignWindow;
    Dlg: PDialog;
    ConfigurationDlg: PConfigurationDlg;
begin
     if ( E.What = evCommand)
     then begin
          case E.Command
          of cmNew: begin
                    Pos.Assign( 0, 0);
                    NewWindow := New( PDesignWindow, Create( Pos));
                    InsertTopWindow( NewWindow);
                    ClearEvent( E);
                    end;
             cmOpen: begin
                     Pos.Assign( 0, 0);
                     NewWindow := New( PDesignWindow, Create( Pos));
                     InsertTopWindow( NewWindow);
                     E.What := evCommand;
                     E.Command := cmLoadFile;
                     PutEvent( E);
                     ClearEvent( E);
                     end;
             cmAboutUltraSoft: begin
                               Dlg := New( PAboutUltraSoftDlg, Create( 'About The Software'));
                               Dlg^.ExecuteDlg( @Self);
                               Dlg^.Free;
                               ClearEvent( E);
                               end;
             cmAboutSabbagh: begin
                             Dlg := New( PAboutSabbaghDlg, Create( 'About The Control'));
                             Dlg^.ExecuteDlg( @Self);
                             Dlg^.Free;
                             ClearEvent( E);
                             end;
             cmAboutMaktabi: begin
                             Dlg := New( PAboutMaktabiDlg, Create( 'About The Producer'));
                             Dlg^.ExecuteDlg( @Self);
                             Dlg^.Free;
                             ClearEvent( E);
                             end;
             cmConfig: begin
                       ConfigurationDlg := New( PConfigurationDlg, Create);
                       ConfigurationDlg^.ExecuteDlg( @Self);
                       ConfigurationDlg^.Free;
                       end;
             end;
          end
     else begin
          if (E.What = evKeyPress)
          then begin
               case E.KeyInfo.ScanCode
               of {4400: begin
                         E.What := evCommand;
                         E.Command := cmExitApplication;
                         PutEvent( E);
                         ClearEvent( E);
                         end;}
                  keyF2: begin
                         E.What := evCommand;
                         E.Command := cmNewDesign;
                         PutEvent( E);
                         ClearEvent( E);
                         end;
                  end;
               end;
          end;


     if ( E.What <> evNothing)
     then inherited HandleEvent( E);
end;

function TMyDesktop.CreateClientsArea( var R: TRect): PDesktopClientsArea;
begin
     CreateClientsArea := New( PMyDesktopClientsArea, Create( R));
end;

procedure TMyDesktop.GetAvailableCommands( var ACommands: TCommandsSet);
begin
     ACommands := ACommands + [cmNew, cmOpen, cmAboutUltraSoft, cmAboutSabbagh, cmAboutMaktabi, cmConfig];
     inherited GetAvailableCommands( ACommands);
end;
{
function TMyDesktop.CommandAvailable( ACommand: Word): Boolean;
begin
     case ACommand
     of cmNew: begin
               CommandAvailable := True;
               end;
     else
         CommandAvailable := inherited CommandAvailable( ACommand);
     end;
end;
}


{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TDrawApplication.Create;
begin
     TheScreen.Create;
     SetBkColor( 0);
     TheMachine.Create;
     ShapesClipboard.Create;
     inherited Create;
     TheScreen.ShowMouseCursor;
end;

procedure TDrawApplication.Run;
begin
     {TheMachine.AppendAction( New( PAlarmAction, Create( 20, 200)));
     TheMachine.AppendAction( New( PDelayAction, Create( 45)));
     TheMachine.AppendAction( New( PGotoFromZeroAction, Create( TheMachine.GetSizeX div 2,
                                                                TheMachine.GetSizeY div 2)));
     TheMachine.AppendAction( New( PAlarmAction, Create( 5, 200)));
     TheMachine.RunActions;}
     inherited Run;
end;

destructor TDrawApplication.Destroy;
begin
     inherited Destroy;
     ShapesClipboard.Destroy;
     GenericsDone;
     TheMachine.Destroy;
     TheScreen.Destroy;
end;


function TDrawApplication.CreateDesktop: PDeskTop;
begin
     CreateDesktop := New( PMyDeskTop, Create);
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

var App: TDrawApplication;
    MemBefore: Longint;
    MemAfter: Longint;
begin
     MemBefore := MemAvail;
     App.Create;
     App.Run;
     App.Destroy;
     MemAfter := MemAvail;
     WriteLn( 'Memory before  :', MemBefore);
     WriteLn( 'Memory after   :', MemAfter);
     WriteLn( 'Defference     :', MemBefore - MemAfter);
end.