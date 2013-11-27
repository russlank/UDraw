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
{*  FILE: MACHINE.PAS                                                      *}
{*                                                                         *}
{***************************************************************************}

unit Machine;

interface

{DEFINE _USEPORTS}
{DEFINE _DEBUG}
{$DEFINE _POSPANEL}
{$DEFINE _OFFSETERROR}

uses Generics, Graph, UWin, IntDriver, Crt, {UCrt,} Support, Dos;

const PULSES_PER_MM_X           = 10{10};  { n per mm. }{?}
      PULSES_PER_MM_Y           = 50{50};  { n per mm. }{?}
      DEF_MACHINE_WINDOW_WIDTH  = 8 * 10 * PULSES_PER_MM_X; { pulses }
      DEF_MACHINE_WINDOW_HEIGHT = 15 * 10 * PULSES_PER_MM_Y; { pulses }
      HEAD_X_TO_Y_SPEED_RATE    = ( PULSES_PER_MM_Y / PULSES_PER_MM_X);
      SAFTEY_LIMIT_X            = PULSES_PER_MM_X * 5; { 1/PULSES_PER_MM_X mm.}
      SAFTEY_LIMIT_Y            = PULSES_PER_MM_Y * 5; { 1/PULSES_PER_MM_Y mm.}

      OFFSET_TOLERANCE_X        = PULSES_PER_MM_X div 2;
      OFFSET_TOLERANCE_Y        = PULSES_PER_MM_Y div 2;
      SEARCH_STEP_X             = 2{PULSES_PER_MM_X};{Must be more than 1}
      SEARCH_STEP_Y             = 2{PULSES_PER_MM_Y};{Must be more than 1}

      STEPPERFREQUENCY          = $0034;

      MAX_FEEDCOUNTER_VALUE     = 5;

      MAXFEEDWAIT               = 500;
      {MAXCURRECTWAIT            = 100000;}

      HEADS_BASE_WIDTH          = 3000; {mm.}
      HEADS_BASE_HEIGHT         = 200;  {mm.}

      MINIMUM_STEP_PULSES_COUNT         = 2;
      MINIMUM_ANALOG_SPEED_VALUE        = 10;
      MAXIMUM_ANALOG_SPEED_VALUE        = 2048;
      ANALOG_SPEED_RANGE                = 2048;
      CYLINDER_RADIUS                   = 48; {mm.}{?}
      CYLINDER_CIRCUMFERENCE            = 2 * PI * CYLINDER_RADIUS; {mm.}
      COMPLETE_ROTATION_PULSES          = 15000;{?}
      PULSE_LINEAR_LENGTH               = CYLINDER_CIRCUMFERENCE / COMPLETE_ROTATION_PULSES; {mm.}

      {TIMED_STEP_TIME                   = 91 * 2;}{182 = 20 Sec.}{91 = 10 Sec. exacttly}

      DEF_SURFACESPEED          = 1024;
      DEF_STEPLENGTH            = 0.1; {mm.}
      DEF_MAXYSTEPLENGTH        = 10; {mm.}
      DEF_MAXXSTEPLENGTH        = DEF_MAXYSTEPLENGTH * HEAD_X_TO_Y_SPEED_RATE; {mm.}

      DataCTC1_1                = $31C; { To move on X }
      DataCTC1_2                = $31D; { To move on Y }
      DataCTC1_3                = $31E; { To Steppers frequency }
      ControlCTC1               = $31F;

      DataCTC2_1                = $30C; { Movement feedback counter }
{      DataCTC2_2                = $30D;}
{      DataCTC2_3                = $30E;}
      ControlCTC2               = $30F;

      DataPPI1A                 = $318;  { Sensors }
      DataPPI1B                 = $319;  { Emergency Input }
      DataPPI1C                 = $31A;  { X & Y Dirs. + Motor On/Off}
      ControlPPI1               = $31B;

{      DataPPI2A                 = $304;}
      DataPPI2B                 = $305;  { Encoder feed back }
      DataPPI2C                 = $306;
      ControlPPI2               = $307;

      DataPPI3A                 = $308;  { Motor speed (LOW 8 Bits}
{      DataPPI3B                 = $309;}
      DataPPI3C                 = $30A;  { Motor speed (HIGH 4 Bits}
      ControlPPI3               = $30B;

{      DataPPI4A                 = $328;}
      DataPPI4B                 = $329;
      DataPPI4C                 = $32A;
      ControlPPI4               = $32B;

      mstFEEDMOTORON            = $00000001;
      mstHEADMOVING             = $00000002{( mstHEADXMOVING or mstHEADYMOVING)};
      mstSHIFTREQUESTON         = $00000004;
      mstSTOPREQUEST            = $00000008;
      mstXDIR                   = $00000010;
      mstYDIR                   = $00000020;
      mstENABLEY1               = $00000040;
      mstENABLEY2               = $00000080;
      mstXHILIMIT               = $00000100;
      mstXLOLIMIT               = $00000200;
      mstXHILIMITSENSOR         = $00000400;
      mstXLOLIMITSENSOR         = $00000800;
      mstY1HILIMIT              = $00001000;
      mstY1LOLIMIT              = $00002000;
      mstY1HILIMITSENSOR        = $00004000;
      mstY1LOLIMITSENSOR        = $00008000;
      mstY2LOLIMITSENSOR        = $00010000;
      mstYHILIMIT               = ( mstY1HILIMIT or mstY1HILIMITSENSOR);
      mstYLOLIMIT               = ( mstY1LOLIMIT or mstY1LOLIMITSENSOR or mstY2LOLIMITSENSOR);
      mstLIMIT                  = ( mstXHILIMIT
                                    or mstXLOLIMIT
                                    or mstXHILIMITSENSOR
                                    or mstXLOLIMITSENSOR
                                    or mstY1HILIMIT
                                    or mstY1LOLIMIT
                                    or mstY1HILIMITSENSOR
                                    or mstY1LOLIMITSENSOR
                                    or mstY2LOLIMITSENSOR);
      mstXCENTER                = $00020000;
      mstYCENTER                = $00040000;
      mstXOFFSETERROR           = $00080000;
      mstYOFFSETERROR           = $00100000;
      mstERROR                  = $00200000;
      mstLASTLAPREQUEST         = $00400000;
      mstEMERGENCY              = $00800000;
      mstANYERROR               = ( mstERROR or mstSTOPREQUEST or mstEMERGENCY);
      mstOVERSPEED              = $01000000;
      mstRUNNING                = $02000000;
      mstSPEEDAUTO              = $04000000;
      mstWAITINGFEED            = $08000000;
      {mstSPEEDUP                = $00100000;
      mstSPEEDDOWN              = $00200000;}

type TMotorsSel = ( motBoth, motY2, motY1);

     PMachineSettings = ^TMachineSettings;
     TMachineSettings = object( TGeneric)
        SurfaceSpeed: Word;
        StepLength: Float;
        MaxYStepLength: Float;
        MaxXStepLength: Float;
        SpeedAuto: Boolean;
        constructor Create;
        destructor Destroy; virtual;
        function Clone: PGeneric; virtual;
        procedure Save( AStream: PStream); virtual;
        constructor Load( AStream: PStream);
        function GetStepPulsesCount: Word;
        function GetStepLength: Float;
        function GetFeedSpeed: Word;
        function GetSpeedAuto: Boolean;
        end;

     TMachineMeasurments = record
         SizeX: Longint;
         SizeY: Longint;
         HeadXCenterStart: Longint;
         HeadXCenterEnd: Longint;
         HeadYCenterStart: Longint;
         HeadYCenterEnd: Longint;
         {HeadXSpeed: Float;
         HeadYSpeed: Float;
         SpeedTimeFactor: Float;}
         end;

     PAction = ^TAction;

     PMachine = ^TMachine;
     TMachine = object( TGeneric)
     private
         PPI1A,
         PPI1B,
         PPI1C,
         PPI2A,
         PPI2B,
         PPI2C,
         PPI3A,
         PPI3B,
         PPI3C,
         PPI4A,
         PPI4B,
         PPI4C: Byte;

         HeadYPos: Longint;
         HeadXPos: Longint;

         HeadXError: Longint;
         HeadYError: Longint;

         Engaged: Boolean;

         State: Longint;
         FeedSpeed: Word;
         OldFeedSpeed: Word;

         XAcc: Longint;
         YAcc: Longint;

         {LastSentToX: TWord;
         LastSentToY: TWord;}

         FeedCounter: Longint;
         FeedWaitCounter: Longint;
         {CurrectWaitCounter: Longint;}

         Moves: PRPath;
         NextStep: TDelta;
         DrawnRepeats: Longint;

         MeasurementsChanged: Boolean;
         Measurements: TMachineMeasurments;
         TempMeasurements: TMachineMeasurments;
         CurrentActionStep: Integer;
         GotoFromZeroPosX: Longint;
         GotoFromZeroPosY: Longint;
         DelayTime: Longint;

         Actions: TContainerCollection;
         BusyDoingActions: Boolean;

{$IFDEF _DEBUG}
         F: Text;
{$ENDIF}
         function Syncronize: Boolean;
     public
         constructor Create;
         destructor Destroy; virtual;
         function GetSizeX: Longint;
         function GetSizeY: Longint;
         function GetSizeXMM: Longint;
         function GetSizeYMM: Longint;
         function LoadMeasurements: Boolean;
         function SaveMeasurements: Boolean;
         function AreChangedMeasurements: Boolean;
         procedure SetMoves( AMoves: PRPath);
         procedure OpenInterface;
         procedure CloseInterface;
         function Engage: Boolean;
         function IsEngaged: Boolean;
         procedure Release;
         function ResetErrors: Boolean;
         function MoveToStartPos( var ADrawnRect: TRect): Boolean;
         function MoveHead( AX, AY: Integer; AYMotors: TMotorsSel): Boolean;
         function ForceMoveHead( AX, AY: Integer; AYMotors: TMotorsSel; ASkipLimitsCheck: Boolean): Boolean;
         {procedure ChangeSpeedUp;
         procedure ChangeSpeedDown;
         procedure StopChangeSpeed;}
         function SwitchFeedOn: Boolean;
         function SwitchFeedOff: Boolean;
         function GetFeedState( var AState: Boolean): Boolean;
         function PickCountersValues( var AXCounter: TWord; var AYCounter: TWord): Boolean;
         function GetRealPos( var AX: Longint; var AY: Longint): Boolean;
         function GetHeadXPos: Longint;
         function GetHeadYPos: Longint;
         function SetFeedSpeed( ASpeed: Word): Boolean;
         function SetFeedBackCounter( ACount: Word): Boolean;
         function MachineOn: Boolean;
         function MachineOff: Boolean;
         function IsMachineOn: Boolean;
         function GetState: Word;
         function DoNextGotoFromZeroStep: Boolean;
         function RunGotoFromZero( AX, AY: Longint): Boolean;
         function DoNextPathStep: Boolean;
         function DoNextMeasurementStep: Boolean;
         function RunMeasurements: Boolean;
         {function DoNextSetFeedSpeedStep: Boolean;}
         {function RunSetFeedSpeed: Boolean;}
         function DoNextDelayStep: Boolean;
         function RunDelay( ATime: Longint): Boolean;
         function RunAlarm( ATime: Longint; AFrequency: Integer): Boolean;
         function DoNextAlarmStep: Boolean;
         function RunPath( AMoves: PRPath; ACount: Longint; AMachineSettings: PMachineSettings): Boolean;
         function StopRequest: Boolean;
         function LastLapRequest: Boolean;
         procedure UpdateStateView;
         procedure DoNextIdleCycle;
         procedure UninstallAllRelatedProcesses;
         function AppendAction( AAction: PAction): Boolean;
         function ClearActions: Boolean;
         function DoNextAction: Boolean;
         function RunActions: Boolean;
         function IsBusy: Boolean;
         function SetSpeedAuto( AAuto: Boolean): Boolean;
         function IsSpeedAuto: Boolean;
         end;

{*************************************************************************}

     TAction = object( TGeneric)
     public
         constructor Create;
         function RunAction( AMachine: PMachine): Boolean; virtual;
         end;

{*************************************************************************}

     PGotoFromZeroAction = ^TGotoFromZeroAction;
     TGotoFromZeroAction = object( TAction)
     private
         GotoPosX: Longint;
         GotoPosY: Longint;
     public
         constructor Create( AX, AY: Longint);
         function RunAction( AMachine: PMachine): Boolean; virtual;
         end;

{*************************************************************************}

     PRunPathAction = ^TRunPathAction;
     TRunPathAction = object( TAction)
     private
         Moves: PRPath;
         Count: Longint;
         MachineSettings: PMachineSettings;
     public
         constructor Create( AMoves: PRPath; ACount: Longint; AMachineSettings: PMachineSettings);
         destructor Destroy; virtual;
         function RunAction( AMachine: PMachine): Boolean; virtual;
         end;

{*************************************************************************}

     PDoMeasurmentAction = ^TDoMeasurmentAction;
     TDoMeasurmentAction = object( TAction)
     public
         function RunAction( AMachine: PMachine): Boolean; virtual;
         end;

{*************************************************************************}

     {PSetFeedSpeedAction = ^TSetFeedSpeedAction;
     TSetFeedSpeedAction = object( TAction)
     public
         function RunAction( AMachine: PMachine): Boolean; virtual;
         end;}

{*************************************************************************}

     PDelayAction = ^TDelayAction;
     TDelayAction = object( TAction)
     private
         DelayTime: Longint;
     public
         constructor Create( ATime: Longint);
         function RunAction( AMachine: PMachine): Boolean; virtual;
         end;

{*************************************************************************}

     PAlarmAction = ^TAlarmAction;
     TAlarmAction = object( TAction)
     private
         DelayTime: Longint;
         Frequency: Integer;
     public
         constructor Create( ATime: Longint; AFrequency: Integer);
         function RunAction( AMachine: PMachine): Boolean; virtual;
         end;

{*************************************************************************}

{$IFDEF _POSPANEL}
     PPosPanel = ^TPosPanel;
     TPosPanel = object( TWindow)
     private
        LastPos: TPoint;
     public
        constructor Create( R: TRect);
        procedure Draw; virtual;
        procedure UpdatePos;
        end;
{$ENDIF}

{*************************************************************************}

     PMachineStatePanel = ^TMachineStatePanel;
     TMachineStatePanel = object( TWindow)
     private
        LastState: Longint;
        LastFeedSpeed: Word;
        LastValue: Longint;
     public
        constructor Create( AOrigin: TPoint);
        procedure Draw; virtual;
        procedure UpdateStateView( ACheckLast: Boolean);
        procedure HandleEvent( var E: TEvent); virtual;
        end;

{*************************************************************************}

     PRunDlg = ^TRunDlg;
     TRunDlg = object( TDialog)
        List: PTextList;
        Path: PFPath;
        MachineSettings: PMachineSettings;
{$IFDEF _POSPANEL}
        PosPanel: PPosPanel;
{$ENDIF}
        StatePanel: PMachineStatePanel;
        SpeedScroll: PScrollControl;
        CountEdit: PIntegerEdit;
        constructor Create( APath: PFPath; AMachineSettings: PMachineSettings);
        destructor Destroy; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure GetAvailableCommands( var ACommands: TCommandsSet); virtual;
        procedure Go( ACount: Longint);
        procedure SetPath( APath: PFPath);
        function ManUp( AYMotors: TMotorsSel; ASkipLimits: Boolean): Boolean;
        function ManDown( AYMotors: TMotorsSel; ASkipLimits: Boolean): Boolean;
        function ManLeft( ASkipLimits: Boolean): Boolean;
        function ManRight( ASkipLimits: Boolean): Boolean;
        function ResetPos: Boolean;
        function DialogExitQuery( AAccept: Boolean): Boolean; virtual;
        procedure ChildNotify( AChild: PWindow); virtual;
        {procedure DisplayPos;}
        end;

{*************************************************************************}

     PConfigurationDlg = ^TConfigurationDlg;
     TConfigurationDlg = object( TDialog)
        List: PTextList;
        StatePanel: PMachineStatePanel;
        LastTask: Integer;
        constructor Create;
        destructor Destroy; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure GetAvailableCommands( var ACommands: TCommandsSet); virtual;
        function ManUp( AYMotors: TMotorsSel; ASkipLimits: Boolean): Boolean;
        function ManDown( AYMotors: TMotorsSel; ASkipLimits: Boolean): Boolean;
        function ManLeft( ASkipLimits: Boolean): Boolean;
        function ManRight( ASkipLimits: Boolean): Boolean;
        function DialogExitQuery( AAccept: Boolean): Boolean; virtual;
        procedure DisplayMeasurments( var MachineMeasurments: TMachineMeasurments);
        function ResetPos: Boolean;
        function RunMeasurements: Boolean;
        end;

{*************************************************************************}
{
procedure DoNextAction_; far;
procedure DoNextMachineIdleCycle_; far;
procedure DoNextPathStep_; far;
procedure DoNextGotoFromZeroStep_; far;
procedure DoNextMeasurementStep_; far;
procedure DoNextSetFeedSpeedStep_; far;
procedure DoNextDelayStep_; far;
procedure DoNextAlarmStep_; far;
}
{*************************************************************************}

var TheMachine: TMachine;

implementation

{$IFNDEF _USEPORTS}
const MotionXCounter: Longint = 0;
      MotionYCounter: Longint = 0;
{$ENDIF}

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TMachineSettings.Create;
begin
     inherited Create;
     SurfaceSpeed := DEF_SURFACESPEED; { mm. / sec}
     StepLength := DEF_STEPLENGTH; { mm. }
     MaxYStepLength := DEF_MAXYSTEPLENGTH; {mm.}
     MaxXStepLength := DEF_MAXXSTEPLENGTH; {mm.}
     SpeedAuto := True;
end;

destructor TMachineSettings.Destroy;
begin
     inherited Destroy;
end;

function TMachineSettings.Clone: PGeneric;
var NewClone: PMachineSettings;
begin
     NewClone := New( PMachineSettings, Create);
     NewClone^.SurfaceSpeed := SurfaceSpeed;
     NewClone^.StepLength := StepLength;
     NewClone^.MaxYStepLength := MaxYStepLength;
     NewClone^.MaxXStepLength := MaxXStepLength;
     NewClone^.SpeedAuto := SpeedAuto;
     Clone := NewClone;
end;

procedure TMachineSettings.Save( AStream: PStream);
begin
     if ( AStream <> nil)
     then begin
          AStream^.Write( SurfaceSpeed, SizeOf( SurfaceSpeed));
          AStream^.Write( StepLength, SizeOf( StepLength));
          AStream^.Write( MaxYStepLength, SizeOf( MaxYStepLength));
          AStream^.Write( MaxXStepLength, SizeOf( MaxXStepLength));
          AStream^.Write( SpeedAuto, SizeOf( SpeedAuto));
          end;
end;

constructor TMachineSettings.Load( AStream: PStream);
begin
     inherited Create;
     if ( AStream <> nil)
     then begin
          AStream^.Read( SurfaceSpeed, SizeOf( SurfaceSpeed));
          AStream^.Read( StepLength, SizeOf( StepLength));
          AStream^.Read( MaxYStepLength, SizeOf( MaxYStepLength));
          AStream^.Read( MaxXStepLength, SizeOf( MaxXStepLength));
          AStream^.Read( SpeedAuto, SizeOf( SpeedAuto));
          end
     else begin
          SurfaceSpeed := DEF_SURFACESPEED;
          StepLength := DEF_STEPLENGTH;
          MaxYStepLength := DEF_MAXYSTEPLENGTH;
          MaxXStepLength := DEF_MAXXSTEPLENGTH;
          SpeedAuto := True;
          end;
end;

function TMachineSettings.GetStepPulsesCount: Word;
var Count: Word;
begin
     Count := Round( StepLength / PULSE_LINEAR_LENGTH);
     if ( Count > MINIMUM_STEP_PULSES_COUNT)
     then GetStepPulsesCount := Count
     else GetStepPulsesCount := MINIMUM_STEP_PULSES_COUNT;
end;

function TMachineSettings.GetStepLength: Float;
begin
     GetStepLength := PULSE_LINEAR_LENGTH * GetStepPulsesCount;
end;

function TMachineSettings.GetFeedSpeed: Word;
begin
     if ( SurfaceSpeed <= MINIMUM_ANALOG_SPEED_VALUE)
     then GetFeedSpeed := MINIMUM_ANALOG_SPEED_VALUE
     else if ( SurfaceSpeed >= MAXIMUM_ANALOG_SPEED_VALUE)
     then GetFeedSpeed := MAXIMUM_ANALOG_SPEED_VALUE
     else GetFeedSpeed := SurfaceSpeed;
end;

function TMachineSettings.GetSpeedAuto: Boolean;
begin
     GetSpeedAuto := SpeedAuto;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

const LastTime: Longint = 0;
      TIMESTEP = 200;

function IsTimePassed( ARestart: Boolean): Boolean;
var Hour, Minute, Second, Sec100: Word;
    NewTime: Longint;
begin
     GetTime( Hour, Minute, Second, Sec100);
     NewTime := ((Hour * 60 + Minute) * 60 + Second) * 100 + Sec100;
     if (NewTime - LastTime >= TIMESTEP)
     then begin
          if ARestart
          then LastTime := NewTime
          else LastTime := LastTime + TIMESTEP;
          IsTimePassed := True;
          end
     else IsTimePassed := False;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TMachine.Create;
begin
     inherited Create;
{$IFDEF _DEBUG}
     Assign( F, 'DEBUG.TXT');
     Rewrite( F);
{$ENDIF}

     Actions.Create;
     BusyDoingActions := False;

     CurrentActionStep := 0;

     DrawnRepeats := 0;
     Moves := nil;
     NextStep.X := 0;
     NextStep.Y := 0;

     OpenInterface;

     Engaged := False;

     HeadXPos := 2;
     HeadYPos := 2;

     HeadXError := 0;
     HeadYError := 0;

     State := $00000000;
     FeedSpeed := 0;
     OldFeedSpeed := MAXIMUM_ANALOG_SPEED_VALUE;

     XAcc := 0;
     YAcc := 0;

     {LastSentToX.Word := 0;
     LastSentToY.Word := 0;}

     PPI1A := 0;
     PPI1B := 0;
     PPI1C := 0;
     PPI2A := 0;
     PPI2B := 0;
     PPI2C := 0;
     PPI3A := 0;
     PPI3B := 0;
     PPI3C := 0;

     FeedCounter := 0;
     FeedWaitCounter := 0;
     {CurrectWaitCounter := 0;}
     LoadMeasurements;

     Syncronize;
     Release;
end;

destructor TMachine.Destroy;
begin
     UninstallAllRelatedProcesses;

     Actions.Destroy;

     CloseInterface;

     if ( Moves <> nil)
     then Moves^.Free;

{$IFDEF _DEBUG}
     Close( F);
{$ENDIF}

     inherited Destroy;
end;

function TMachine.GetSizeX: Longint;
begin
     GetSizeX := Measurements.SizeX;
end;

function TMachine.GetSizeY: Longint;
begin
     GetSizeY := Measurements.SizeY;
end;

function TMachine.GetSizeXMM: Longint;
begin
     GetSizeXMM := Measurements.SizeX div PULSES_PER_MM_X;
end;

function TMachine.GetSizeYMM: Longint;
begin
     GetSizeYMM := Measurements.SizeY div PULSES_PER_MM_Y;
end;

const SIGNATURE = 2001;
      MEASUREMENTSFN = 'MACHINE.MSR';

function TMachine.LoadMeasurements: Boolean;
var TempMeasures: TMachineMeasurments;
    MF: File;
    FileSignature: Word;
    ReadCount: Word;
begin
     Measurements.SizeX := DEF_MACHINE_WINDOW_WIDTH;
     Measurements.SizeY := DEF_MACHINE_WINDOW_HEIGHT;
     Measurements.HeadXCenterStart := 0;
     Measurements.HeadXCenterEnd := Measurements.SizeX;
     Measurements.HeadYCenterStart := 0;
     Measurements.HeadYCenterEnd := Measurements.SizeY;
     {Measurements.SpeedTimeFactor := 0;
     Measurements.HeadXSpeed := 0;
     Measurements.HeadYSpeed := 0;}
     LoadMeasurements := False;
     Assign( MF, MEASUREMENTSFN);
     {$I-}
     Reset( MF, 1);
     if ( IOResult = 0)
     then begin
          BlockRead(MF, FileSignature, SizeOf( FileSignature), ReadCount);
          if ((ReadCount = SizeOf( FileSignature)) and ( FileSignature = Signature))
          then begin
               BlockRead(MF, TempMeasures, SizeOf( TempMeasures), ReadCount);
               if ( ReadCount = SizeOf( TempMeasures))
               then begin
                    Measurements := TempMeasures;
                    LoadMeasurements := True;
                    end
               end;
          Close( MF);
          end;
     MeasurementsChanged := False;
end;

function TMachine.SaveMeasurements: Boolean;
var MF: File;
    FileSignature: Word;
    WriteCount: Word;
begin
     Assign( MF, MEASUREMENTSFN);
     SaveMeasurements := False;
     {$I-}
     Rewrite( MF, 1);
     if ( IOResult = 0)
     then begin
          FileSignature := SIGNATURE;
          BlockWrite(MF, FileSignature, SizeOf( FileSignature), WriteCount);
          if ( WriteCount = SizeOf( FileSignature))
          then begin
               BlockWrite(MF, Measurements, SizeOf( Measurements), WriteCount);
               if ( WriteCount = SizeOf( Measurements))
               then SaveMeasurements := True
               else SaveMeasurements := False;
               end;
          Close( MF);
          end;
     MeasurementsChanged := False;
end;

function TMachine.AreChangedMeasurements: Boolean;
begin
     AreChangedMeasurements := MeasurementsChanged;
end;

procedure TMachine.OpenInterface;
var Frequency: TWord;
    Delta: TWord;
begin
{$IFDEF _USEPORTS}
     Port[ ControlPPI1{31B}] := $9A;
     Port[ ControlCTC1{31F}] := $30{The old was 30};
     Port[ ControlCTC1{31F}] := $70{The old was 70};
     Port[ ControlCTC1{31F}] := $B6{New};
     Port[ ControlPPI2{307}] := $82{The old was 82};
     Port[ ControlPPI3{30B}] := $80{The old was 80};
     Port[ ControlCTC2{30F}] := $36;
     Port[ ControlPPI4{32B}] := $90;{New PPI}

     Delta.Word := 1;
     Port[ DataCTC1_1] := Delta.Lo;
     Port[ DataCTC1_1] := Delta.Hi;

     Port[ DataCTC1_2] := Delta.Lo;
     Port[ DataCTC1_2] := Delta.Hi;

     Port[ DataCTC2_1] := $04;
     Port[ DataCTC2_1] := $00;

     Frequency.Word := STEPPERFREQUENCY;
     Port[ DataCTC1_3] := Frequency.Lo;
     Port[ DataCTC1_3] := Frequency.Hi;

     State := $00000000;
     PPI4C := $00;{ Speed up OFF / Speed down OFF / Feed OFF / Mani power OFF }
     PPI1C := $00;{ Y Down / X Right / X OFF / Y1 OFF}
     PPI4B := $00;{ Y2 OFF }
     PPI3A := $00;{ Low 8 bits of speed }
     PPI3C := $00;{ Hi 4 bits if speed }
     Port[ DataPPI4C] := PPI4C;
     Port[ DataPPI1C] := PPI1C;
     Port[ DataPPI4B] := PPI4B;
     Port[ DataPPI3A] := PPI3A;
     Port[ DataPPI3C] := PPI3C;

     Delay( 1000);

     PPI4C := $08;
     Port[ DataPPI4C] := PPI4C;
{$ENDIF}
end;

function TMachine.SetFeedSpeed( ASpeed: Word): Boolean;
begin
     if ASpeed < MINIMUM_ANALOG_SPEED_VALUE
     then FeedSpeed := MINIMUM_ANALOG_SPEED_VALUE
     else if ASpeed > MAXIMUM_ANALOG_SPEED_VALUE
     then FeedSpeed := MAXIMUM_ANALOG_SPEED_VALUE
     else FeedSpeed := ASpeed;
     SetFeedSpeed := Syncronize;
end;

function TMachine.SetFeedBackCounter( ACount: Word): Boolean;
begin
{$IFDEF _USEPORTS}
     Port[ DataCTC2_1] := LO(ACount);
     Port[ DataCTC2_1] := HI(ACount);
{$ENDIF}
     FeedCounter := 0;
     SetFeedBackCounter := Syncronize;
end;

function TMachine.MachineOn: Boolean;
begin
     State := ( State or mstRUNNING);
     FeedCounter := 0;
     MachineOn := Syncronize;
end;

function TMachine.MachineOff: Boolean;
begin
     State := (State and (not ( mstRUNNING or mstFEEDMOTORON or mstLASTLAPREQUEST)));
     FeedCounter := 0;
     MachineOff := Syncronize;
end;

function TMachine.IsMachineOn: Boolean;
begin
     IsMachineOn := (( State and mstRUNNING) <> $00000000)
end;

function TMachine.GetState: Word;
begin
     GetState := State;
end;

function TMachine.Syncronize: Boolean;
var B1, B2: Byte;
    Result: Boolean;
    NextXPos, NextYPos: Longint;
{$IFNDEF _USEPORTS}
    E: TEvent;
{$ENDIF}
    Temp: Byte;
    HeadNotMoving: Boolean;
    CurrectPosX: Boolean;
    CurrectPosY: Boolean;
begin
{$IFDEF _USEPORTS}
     PPI2B := Port[ DataPPI2B];
{$ELSE}
     if ( FeedSpeed > 0)
     then begin
          {if TimeTicker
          then PPI2B := PPI2B or $08
          else PPI2B := PPI2B and not $08;}
          PPI2B := PPI2B xor $08;
          end;

     if ( MotionXCounter >= MotionYCounter)
     then TimeCounter := TimeCounter + MotionXCounter
     else TimeCounter := TimeCounter + MotionYCounter;
     MotionXCounter := 0;
     MotionYCounter := 0;
{$ENDIF}

     if ((PPI2B and $08) <> $00)
     then begin
          if (( State and mstSHIFTREQUESTON) = $00000000)
          then begin
               if FeedCounter < MAX_FEEDCOUNTER_VALUE
               then FeedCounter := FeedCounter + 1;
               State := ( State or mstSHIFTREQUESTON {or mstSHIFTREQUEST});
               if ( FeedCounter < 2)
               then State := State and not mstOVERSPEED
               else State := State or mstOVERSPEED;
               end;
          end
     else State := ( State and (not mstSHIFTREQUESTON));

{$IFDEF _USEPORTS}
     PPI1B := Port[ DataPPI1B]; { Check emergency }
{$ELSE}
     PPI1B := 0;
{$ENDIF}

     {if ((PPI1B and $80) <> $00) { Mapping to emergency flag }
     {then State := State or mstSTOPREQUEST or mstEMERGENCY
     else State := ( State and not ( mstEMERGENCY));}

     if ((State and mstXDIR) <> $00000000)
     then PPI1C := (PPI1C and (not $01))
     else PPI1C := PPI1C or $01;

     if ((State and mstYDIR) <> $00000000)
     then PPI1C := (PPI1C or $02)
     else PPI1C := (PPI1C and (not $02));

     case ( State and (mstENABLEY2 or mstENABLEY1))
     of (mstENABLEY2 or mstENABLEY1): PPI1C := ((PPI1C or $04) and (not $08));
        (mstENABLEY2): PPI1C := (PPI1C or $0C);
        (mstENABLEY1): PPI1C := (PPI1C and (not $0C));
        else PPI1C := ((PPI1C or $08) and (not $04));
        end;

     {if ((State and mstENABLEY2) <> $00000000)
     then PPI1C := (PPI1C or $08)
     else PPI1C := (PPI1C and ( not $08));

     if ((State and mstENABLEY1) <> $00000000)
     then PPI1C := (PPI1C or $04)
     else PPI1C := (PPI1C and ( not $04));}

     PPI4B := PPI4B or $01; { X Always On }

{$IFDEF _USEPORTS}
     Port[ DataPPI4B] := PPI4B;
     Port[ DataPPI1C] := (PPI1C and $0F);
     Temp := Port[ DataPPI1C];
     PPI1C := (( PPI1C and $0F) or (Temp and $F0));
{$ELSE}
     PPI1C := PPI1C or $20;
{$ENDIF}

     if (( PPI1C and $20) <> $00)
     then begin
          State := (State and (not mstHEADMOVING));
          HeadNotMoving := True;
          end
     else begin
          State := (State or mstHEADMOVING);
          HeadNotMoving := False;
          end;

{$IFDEF _USEPORTS}
     PPI1A := Port[ DataPPI1A]; { Cheking sensors }

     NextXPos := HeadXPos + XAcc;
     NextYPos := HeadYPos + YAcc;

     if ((PPI1A and $01) <> $00)
     then State := State or mstXHILIMIT or mstXHILIMITSENSOR
     else begin
          State := State and ( not mstXHILIMITSENSOR);
          if ( NextXPos >= Measurements.SizeX)
          then State := State or mstXHILIMIT
          else State := State and (not mstXHILIMIT);
          end;

     if ((PPI1A and $02) <> $00)
     then begin
          State := State or mstXLOLIMIT or mstXLOLIMITSENSOR;
          HeadXPos := - SAFTEY_LIMIT_X;
          end
     else begin
          State := State and ( not mstXLOLIMITSENSOR);
          if ( NextXPos <= 0)
          then State := State or mstXLOLIMIT
          else State := State and (not mstXLOLIMIT);
          end;

     if ((PPI1A and $08) <> $00)
     then begin
          State := State or mstY1LOLIMIT or mstY1LOLIMITSENSOR;
          HeadYPos := - SAFTEY_LIMIT_Y;
          end
     else begin
          State := State and ( not mstY1LOLIMITSENSOR);
          if ( NextYPos <= 0)
          then State := State or mstY1LOLIMIT
          else State := State and (not mstY1LOLIMIT);
          end;

     if ((PPI1A and $04) <> $00)
     then State := State or mstY1HILIMIT or mstY1HILIMITSENSOR
     else begin
          State := State and ( not mstY1HILIMITSENSOR);
          if ( NextYPos >= Measurements.SizeY)
          then State := State or mstY1HILIMIT
          else State := State and (not mstY1HILIMIT);
          end;

     if ((PPI1A and $40) <> $00)
     then State := State or mstY2LOLIMITSENSOR
     else State := State and (not mstY2LOLIMITSENSOR);

     if ((PPI1A and $10) <> $00)
     then begin
          State := State or mstXCENTER;
          if (( HeadNotMoving) and ( HeadXError = 0))
          then begin
               if ( HeadXPos < Measurements.HeadXCenterStart)
               then begin
                    HeadXError := HeadXPos - Measurements.HeadXCenterStart - OFFSET_TOLERANCE_X;
                    end
               else if ( HeadXPos > Measurements.HeadXCenterEnd)
               then begin
                    HeadXError := HeadXPos - Measurements.HeadXCenterEnd + OFFSET_TOLERANCE_X;
                    end;
               end;
          end
     else State := State and (not mstXCENTER);

     if ( HeadXError = 0)
     then State := (State and (not mstXOFFSETERROR))
     else State := (State  or mstXOFFSETERROR);

     if ((PPI1A and $20) <> $00)
     then begin
          State := State or mstYCENTER;

          if (( HeadNotMoving) and ( HeadYError = 0))
          then begin
               if ( HeadYPos < Measurements.HeadYCenterStart)
               then begin
                    HeadYError := HeadYPos - Measurements.HeadYCenterStart - OFFSET_TOLERANCE_Y;
                    end
               else if ( HeadYPos > Measurements.HeadYCenterEnd)
               then begin
                    HeadYError := HeadYPos - Measurements.HeadYCenterEnd + OFFSET_TOLERANCE_Y;
                    end;
               end;
          end
     else State := State and (not mstYCENTER);

     if ( HeadYError = 0)
     then State := (State and (not mstYOFFSETERROR))
     else State := (State  or mstYOFFSETERROR);

{$ELSE}

     NextXPos := HeadXPos + XAcc;
     NextYPos := HeadYPos + YAcc;

     if ( NextXPos <= 0)
     then State := ( State or mstXLOLIMIT or mstXLOLIMITSENSOR)
     else State := ( State and (not (mstXLOLIMIT or mstXLOLIMITSENSOR)));

     if ( NextXPos >= Measurements.SizeX)
     then State := ( State or mstXHILIMIT or mstXHILIMITSENSOR)
     else State := ( State and ( not (mstXHILIMIT or mstXHILIMITSENSOR)));

     if ( NextYPos <= 0)
     then State := ( State or mstYLOLIMIT or mstY1LOLIMITSENSOR or mstY2LOLIMITSENSOR)
     else State := ( State and ( not (mstYLOLIMIT or mstY1LOLIMITSENSOR or mstY2LOLIMITSENSOR)));

     if ( NextYPos >= Measurements.SizeY)
     then State := ( State or mstYHILIMIT or mstY1HILIMITSENSOR)
     else State := ( State and ( not (mstYHILIMIT or mstY1HILIMITSENSOR)));

{$ENDIF}

     if ((State and mstFEEDMOTORON) <> $00000000)
     then begin
          PPI4C := (PPI4C or $04);
          if ((State and mstSPEEDAUTO) <> $00000000)
          then begin
               if ( FeedCounter > 1)
               then begin
                    if ( FeedSpeed > MINIMUM_ANALOG_SPEED_VALUE)
                    then FeedSpeed := FeedSpeed - 1
                    else FeedSpeed := MINIMUM_ANALOG_SPEED_VALUE;
                    end
               else begin
                    if (( State and mstWAITINGFEED) <> $00000000)
                    then begin
                         if HeadNotMoving
                         then begin
                              if ( FeedCounter = 0)
                              then begin
                                   if ( FeedWaitCounter < MAXFEEDWAIT)
                                   then FeedWaitCounter := FeedWaitCounter + 1
                                   else begin
                                        FeedWaitCounter := 0;
                                        if ( FeedSpeed < MAXIMUM_ANALOG_SPEED_VALUE)
                                        then FeedSpeed := FeedSpeed + 1
                                        else FeedSpeed := MAXIMUM_ANALOG_SPEED_VALUE;
{$IFNDEF _USEPORTS}
                                        E.What := evCommand;
                                        E.Command := cmUpdateMachineStateView;
                                        PushEvent( E);
{$ENDIF}
                                        end;
                                   end
                              else FeedWaitCounter := 0;
                              end
                         else FeedWaitCounter := 0;
                         end;
                    end
               end;
          end
     else begin
          PPI4C := (PPI4C and (not $04));
          FeedCounter := 0;
          end;

     {if ((State and mstSPEEDDOWN) <> $00000000)
     then PPI4C := ((PPI4C or $02) and (not $01))
     else if ((State and mstSPEEDUP) <> $00000000)
     then PPI4C := ((PPI4C or $01) and (not $02))
     else PPI4C := PPI4C and not $03;}

     PPI4C := ((PPI4C or $08) and (not $10)); { Switch all on always }

{$IFDEF _USEPORTS}
     Port[ DataPPI4C] := PPI4C;
{$ENDIF}

     if ( OldFeedSpeed <> FeedSpeed)
     then begin
          PPI3A := Byte( FeedSpeed and $00FF);
          PPI3C := Byte( (( FeedSpeed and $0F00) shr 4));

{$IFDEF _USEPORTS}
          Port[ DataPPI3A] := PPI3A;
          Port[ DataPPI3C] := PPI3C;
{$ENDIF}
          OldFeedSpeed := FeedSpeed;
          end;

     Result := ((State and mstANYERROR) = $00000000);

     Syncronize := Result;
end;

function TMachine.ResetErrors: Boolean;
begin
     State := ( State and ( not (mstANYERROR or mstLASTLAPREQUEST)));

     {if ( HeadXPos < 0)
     then HeadXPos := 0
     else if ( HeadXPos > Measurements.SizeX)
     then HeadXPos := Measurements.SizeX;

     if ( HeadYPos < 0)
     then HeadYPos := 0
     else if ( HeadYPos > Measurements.SizeY)
     then HeadYPos := Measurements.SizeY;}

     XAcc := 0;
     YAcc := 0;
     HeadXError := 0;
     HeadYError := 0;

     ResetErrors := Syncronize;
end;

function TMachine.MoveToStartPos( var ADrawnRect: TRect): Boolean;
var Width, Height: Longint;
    XMargin, YMargin: Longint;
    HeadStartPosX, HeadStartPosY: Longint;
    MutionDeltaX, MutionDeltaY: Longint;
begin
     Width := ADrawnRect.B.X - ADrawnRect.A.X;
     Height := ADrawnRect.B.Y - ADrawnRect.A.Y;

     if ((Width < Measurements.SizeX - 0 * SAFTEY_LIMIT_X)
        and (Height < Measurements.SizeY - 0 * SAFTEY_LIMIT_Y))
     then begin
          XMargin := ( Measurements.SizeX - Width) div 2;
          YMargin := ( Measurements.SizeY - Height) div 2;

          HeadStartPosX := XMargin - ADrawnRect.A.X;
          HeadStartPosY := YMargin - ADrawnRect.A.Y;

          MutionDeltaX := HeadStartPosX - HeadXPos;
          MutionDeltaY := HeadStartPosY - HeadYPos;

          ForceMoveHead( MutionDeltaX, MutionDeltaY, motBoth, False);

          {HeadXPos := HeadXPos + MutionDeltaX;}
          {HeadYPos := HeadYPos + MutionDeltaY;}

          MoveToStartPos := True;
          end
     else begin
          State := State or mstLIMIT;
          MoveToStartPos := False;
          end;
end;


function TMachine.MoveHead( AX, AY: Integer; AYMotors: TMotorsSel): Boolean;
var Result: Boolean;
    DeltaX: TWord;
    DeltaY: TWord;

    function WaitMovementFinishing: Boolean;
    var Result: Boolean;
    begin
         Result := Syncronize;
         while ( Result)
         do begin
            if ((( State and mstHEADMOVING) = $00000000) and (FeedCounter > 0))
            then Break;
            Result := Syncronize;
            end;
         WaitMovementFinishing := Result;
    end;

begin
     XAcc := XAcc + AX;
     YAcc := YAcc + AY;

     if WaitMovementFinishing
     then begin
          if (XAcc > 0)
          then State := ( State or mstXDIR)
          else State := ( State and (not mstXDIR));
          if (YAcc > 0)
          then State := ( State or mstYDIR)
          else State := ( State and (not mstYDIR));

          State := State or mstENABLEY2 or mstENABLEY1;

          if AYMotors = motY2
          then State := ( State and ( not mstENABLEY1))
          else if AYMotors = motY1
          then State := ( State and ( not mstENABLEY2));

          Syncronize;

          DeltaX.Word := Abs( XAcc);
          DeltaY.Word := Abs( YAcc);
          if ( DeltaX.Word > 1)
          then begin
               DeltaX.Word := DeltaX.Word - 1;
{$IFDEF _USEPORTS}
               Port[ DataCTC1_1] := DeltaX.Lo;
               Port[ DataCTC1_1] := DeltaX.Hi;
{$ELSE}
               MotionXCounter := DeltaX.Word;
{$ENDIF}
               HeadXPos := HeadXPos + XAcc;
               XAcc := 0;
               end;

         if ( DeltaY.Word > 1)
         then begin
              DeltaY.Word := DeltaY.Word - 1;

{$IFDEF _USEPORTS}
              Port[ DataCTC1_2] := DeltaY.Lo;
              Port[ DataCTC1_2] := DeltaY.Hi;
{$ELSE}
              MotionYCounter := DeltaY.Word;
{$ENDIF}
              HeadYPos := HeadYPos + YAcc;
              YAcc := 0;
              end;

         if ( FeedCounter > 0)
         then FeedCounter := FeedCounter - 1;
         MoveHead := Syncronize;
         end
     else MoveHead := False;
end;

function TMachine.ForceMoveHead( AX, AY: Integer; AYMotors: TMotorsSel; ASkipLimitsCheck: Boolean): Boolean;
var Result: Boolean;

    procedure MoveOnX;
    var DoMove: Boolean;
        DeltaX: TWord;
    begin
         Syncronize;
         DoMove := False;
         if ASkipLimitsCheck
         then begin
              if Abs( AX) > 1
              then DoMove := True;
              end
         else begin
              if (AX > 1)
              then begin
                   if ((State and mstXHILIMIT) = $00000000)
                   then begin
                        if ( HeadXPos + AX > Measurements.SizeX)
                        then begin
                             AX := Measurements.SizeX - HeadXPos;
                             if ( AX > 1)
                             then DoMove := True;
                             end
                        else DoMove := True;
                        end;
                   end
              else if ( AX < -1)
              then begin
                   if ((State and mstXLOLIMIT) = $00000000)
                   then begin
                        if ( HeadXPos + AX < 0)
                        then begin
                             AX := - HeadXPos;
                             if ( AX < -1)
                             then DoMove := True;
                             end
                        else DoMove := True;
                        end
                   end
              else DoMove := False;
              end;

         if DoMove
         then begin
              DeltaX.Word := Abs( AX);

              if (AX > 0)
              then State := ( State or mstXDIR)
              else State := ( State and (not mstXDIR));

              Syncronize;

              DeltaX.Word := DeltaX.Word - 1;
{$IFDEF _USEPORTS}
              Port[ DataCTC1_1] := DeltaX.Lo;
              Port[ DataCTC1_1] := DeltaX.Hi;
{$ELSE}
              MotionXCounter := DeltaX.Word;
{$ENDIF}
              HeadXPos := HeadXPos + AX;
              end
         else DeltaX.Word := 0;
    end;

    procedure MoveOnY;
    var DoMove: Boolean;
        DeltaY: TWord;
    begin
         Syncronize;
         DoMove := False;
         if ASkipLimitsCheck
         then begin
              if Abs( AY) > 1
              then DoMove := True;
              end
         else begin
              if (AY > 1)
              then begin
                   if ((State and mstYHILIMIT) = $00000000)
                   then begin
                        if ( HeadYPos + AY > Measurements.SizeY)
                        then begin
                             AY := Measurements.SizeY - HeadYPos;
                             if ( AY > 1)
                             then DoMove := True;
                             end
                        else DoMove := True;
                        end;
                   end
              else if ( AY < -1)
              then begin
                   if ((State and mstYLOLIMIT) = $00000000)
                   then begin
                        if ( HeadYPos + AY < 0)
                        then begin
                             AY := - HeadYPos;
                             if ( AY < -1)
                             then DoMove := True;
                             end
                        else DoMove := True;
                        end;
                   end
              else DoMove := False;
              end;

         if DoMove
         then begin
              DeltaY.Word := Abs( AY);
              if (AY > 0)
              then State := ( State or mstYDIR)
              else State := ( State and (not mstYDIR));

              Syncronize;

              DeltaY.Word := DeltaY.Word - 1;
{$IFDEF _USEPORTS}
              Port[ DataCTC1_2] := DeltaY.Lo;
              Port[ DataCTC1_2] := DeltaY.Hi;
{$ELSE}
              MotionYCounter := DeltaY.Word;
{$ENDIF}
              HeadYPos := HeadYPos + AY;
              end
         else DeltaY.Word := 0;
    end;

    function WaitMovementFinishing: Boolean;
    var Result: Boolean;
    begin
         Result := Syncronize;
         while ( Result)
         do begin
            if (( State and mstHEADMOVING) = $00000000)
            then begin
                 Result := Syncronize;
                 Break;
                 end;
            Result := Syncronize;
            end;
         WaitMovementFinishing := Result;
    end;
begin
     XAcc := 0;
     YAcc := 0;
     if WaitMovementFinishing
     then begin
          MoveOnX;
          if WaitMovementFinishing
          then begin
               State := State or mstENABLEY2 or mstENABLEY1;

               if AYMotors = motY2
               then State := ( State and ( not mstENABLEY1))
               else if AYMotors = motY1
               then State := ( State and ( not mstENABLEY2));

               MoveOnY;
               ForceMoveHead := Syncronize;
               end
          else ForceMoveHead := False;
          end
     else ForceMoveHead := False;
end;

{
procedure TMachine.ChangeSpeedUp;
begin
     State := ((State or mstSPEEDUP) and not mstSPEEDDOWN);
     Syncronize;
end;

procedure TMachine.ChangeSpeedDown;
begin
     State := ((State or mstSPEEDDOWN) and not mstSPEEDUP);
     Syncronize;
end;

procedure TMachine.StopChangeSpeed;
begin
     State := (State and not ( mstSPEEDUP or mstSPEEDDOWN));
     Syncronize;
end;
}

function TMachine.SwitchFeedOn: Boolean;
begin
     State := State or mstFEEDMOTORON;
     FeedCounter := 0;
     SwitchFeedOn := Syncronize;
end;

function TMachine.SwitchFeedOff: Boolean;
begin
     State := (State and (not mstFEEDMOTORON));
     FeedCounter := 0;
     SwitchFeedOff := Syncronize;
end;

function TMachine.GetFeedState( var AState: Boolean): Boolean;
begin
     AState := (( State and mstFEEDMOTORON) <> $00000000);
     GetFeedState := Syncronize;
end;

procedure TMachine.CloseInterface;
begin
     PPI4C := $00;
     Port[ DataPPI4C] := PPI4C;
end;

procedure DoNextMachineIdleCycle_; far;
begin
     TheMachine.DoNextIdleCycle;
end;

function TMachine.Engage: Boolean;
begin
     if Engaged
     then Engage := False
     else begin
          UninstallProcess( DoNextMachineIdleCycle_);
          Engaged := True;
          Engage := True;
          end;
end;

procedure TMachine.Release;
begin
     Engaged := False;
     InstallProcess( DoNextMachineIdleCycle_, NORMALNICEVALUE);
end;

function TMachine.IsEngaged: Boolean;
begin
     IsEngaged := Engaged;
end;

function TMachine.PickCountersValues( var AXCounter: TWord; var AYCounter: TWord): Boolean;
begin
     AXCounter.Word := 0;
     AYCounter.Word := 0;
     PickCountersValues := True;
end;

function TMachine.GetRealPos( var AX: Longint; var AY: Longint): Boolean;
var XCounter: TWord;
    YCounter: TWord;
begin
     if Syncronize
     then begin
          if (( State and mstHEADMOVING) <> $00000000)
          then begin
               PickCountersValues( XCounter, YCounter);
               if (( State and mstYDIR) <> $00000000)
               then
               else;
               if (( State and mstXDIR) <> $00000000)
               then
               else;
               end
          else begin
               AX := HeadXPos;
               AY := HeadYPos;
               end;
          GetRealPos := True;
          end
     else begin
          AX := HeadXPos;
          AY := HeadYPos;
          GetRealPos := False;
          end;
end;

function TMachine.GetHeadXPos: Longint;
begin
     GetHeadXPos := HeadXPos;
end;

function TMachine.GetHeadYPos: Longint;
begin
     GetHeadYPos := HeadYPos;
end;

procedure TMachine.SetMoves( AMoves: PRPath);
begin
     if ( Moves <> nil)
     then Moves^.Free;

     Moves := AMoves;

     if ( Moves <> nil)
     then begin
          if not Moves^.GetFirstDelta( NextStep)
          then begin
               NextStep.X := 0;
               NextStep.Y := 0;
               end
          end
     else begin
          NextStep.X := 0;
          NextStep.Y := 0;
          end;
end;

function TMachine.DoNextPathStep: Boolean;
var {DeltaX, DeltaY: TWord;}
{$IFDEF _POSPANEL}
    E: TEvent;
{$ENDIF}
    DeltaX: TWord;
    DeltaY: TWord;
{$IFDEF _DEBUG}
    OutputNewPos: Boolean;
{$ENDIF}
begin
     if ( Moves <> nil)
     then begin
          State := State or mstWAITINGFEED;
          if Syncronize
          then begin
               if (( State and mstLIMIT) = $00000000)
               then begin
                    if ((( State and mstHEADMOVING) = $00000000) and ( FeedCounter > 0))
                    then begin
{$IFDEF _DEBUG}
                         OutputNewPos := False;
{$ENDIF}
                         XAcc := XAcc + NextStep.X;
                         YAcc := YAcc + NextStep.Y;
                         State := State or mstENABLEY2 or mstENABLEY1;
                         if Syncronize
                         then begin
                              DeltaX.Word := Abs( XAcc);
                              DeltaY.Word := Abs( YAcc);

                              if ( XAcc > 0)
                              then begin
                                   State := ( State or mstXDIR);
{$IFDEF _OFFSETERROR}
                                   if ( HeadXError > 0)
                                   then begin
                                        DeltaX.Word := DeltaX.Word + 1;
                                        HeadXError := HeadXError - 1;
                                        end
                                   else if ( HeadXError < 0)
                                   then begin
                                        if (DeltaX.Word > 2)
                                        then begin
                                             DeltaX.Word := DeltaX.Word - 1;
                                             HeadXError := HeadXError + 1;
                                             end;
                                        end;
{$ENDIF}
                                   end
                              else if ( XAcc < 0)
                              then begin
                                   State := ( State and (not mstXDIR));
{$IFDEF _OFFSETERROR}
                                   if ( HeadXError < 0)
                                   then begin
                                        DeltaX.Word := DeltaX.Word + 1;
                                        HeadXError := HeadXError + 1;
                                        end
                                   else if ( HeadXError > 0)
                                   then begin
                                        if (DeltaX.Word > 2)
                                        then begin
                                             DeltaX.Word := DeltaX.Word - 1;
                                             HeadXError := HeadXError - 1;
                                             end;
                                        end;
{$ENDIF}
                                   end;

                              if ( YAcc > 0)
                              then begin
                                   State := ( State or mstYDIR);
{$IFDEF _OFFSETERROR}
                                   if ( HeadYError > 0)
                                   then begin
                                        DeltaY.Word := DeltaY.Word + 1;
                                        HeadYError := HeadYError - 1;
                                        end
                                   else if ( HeadYError < 0)
                                   then begin
                                        if ( DeltaY.Word > 2)
                                        then begin
                                             DeltaY.Word := DeltaY.Word - 1;
                                             HeadYError := HeadYError + 1;
                                             end;
                                        end;
{$ENDIF}
                                   end
                              else if ( YAcc < 0)
                              then begin
                                   State := ( State and (not mstYDIR));
{$IFDEF _OFFSETERROR}
                                   if ( HeadYError < 0)
                                   then begin
                                        DeltaY.Word := DeltaY.Word + 1;
                                        HeadYError := HeadYError + 1;
                                        end
                                   else if ( HeadYError > 0)
                                   then begin
                                        if ( DeltaY.Word > 2)
                                        then begin
                                             DeltaY.Word := DeltaY.Word - 1;
                                             HeadYError := HeadYError - 1;
                                             end;
                                        end;
{$ENDIF}
                                   end;

                              Syncronize;

                              if ( DeltaX.Word > 1)
                              then begin
                                   DeltaX.Word := DeltaX.Word - 1;
{$IFDEF _USEPORTS}
                                   Port[ DataCTC1_1] := DeltaX.Lo;
                                   Port[ DataCTC1_1] := DeltaX.Hi;
{$ELSE}
                                   MotionXCounter := DeltaX.Word;
{$ENDIF}
                                   HeadXPos := HeadXPos + XAcc;
                                   {if YAcc > 0
                                   then Dec( XAcc)
                                   else Inc( XAcc);}
{$IFDEF _DEBUG}
                                   WriteLn( F, XAcc, '    ', 0);
                                   OutputNewPos := True;
{$ENDIF}
                                   XAcc := 0;
                                   end;

                              if ( DeltaY.Word > 1)
                              then begin
                                   DeltaY.Word := DeltaY.Word - 1;
{$IFDEF _USEPORTS}
                                   Port[ DataCTC1_2] := DeltaY.Lo;
                                   Port[ DataCTC1_2] := DeltaY.Hi;
{$ELSE}
                                   MotionYCounter := DeltaY.Word;
{$ENDIF}
                                   {if YAcc > 0
                                   then Dec( YAcc)
                                   else Inc( YAcc);}
                                   HeadYPos := HeadYPos + YAcc;
{$IFDEF _DEBUG}
                                   WriteLn( F, 0, '    ', YAcc);
                                   OutputNewPos := True;
{$ENDIF}
                                   YAcc := 0;
                                   end;
{$IFDEF _DEBUG}
                              {if ( OutputNewPos)
                              then WriteLn( F, '(',HeadXPos:5,',', HeadYPos:5,')');}
{$ENDIF}
                              if ( FeedCounter > 0)
                              then FeedCounter := FeedCounter - 1;

                              if not Moves^.GetNextDelta( NextStep)
                              then begin
                                   NextStep.X := 0;
                                   NextStep.Y := 0;
                                   end;

                              if (( State and mstLASTLAPREQUEST) <> $00000000)
                              then DrawnRepeats := 1;

                              if ( DrawnRepeats > 0)
                              then begin
                                   if Moves^.IsCurrentFirst
                                   then begin
                                        if ( DrawnRepeats > 1)
                                        then begin
                                             DrawnRepeats := DrawnRepeats - 1;
                                             DoNextPathStep := Syncronize;
                                             end
                                        else begin
                                             Syncronize;
                                             DrawnRepeats := 0;
                                             DoNextPathStep := False;
                                             end;
                                        end
                                   else DoNextPathStep := Syncronize;
                                   end
                              else begin
                                   DoNextPathStep := Syncronize
                                   end;
{$IFDEF _POSPANEL}
                              E.What := evCommand;
                              E.Command := cmUpdateHeadPos;
                              PushEvent( E);
{$ENDIF}
                              UpdateStateView;
                              end
                         else begin
                              UpdateStateView;
                              DoNextPathStep := False;
                              end;
                         end
                    else begin
                         DoNextPathStep := True;
                         end;
                    end
               else begin
                    State := State and mstERROR;
                    DoNextPathStep := False;
                    end;
               end
          else begin
               UpdateStateView;
               DoNextPathStep := False;
               end;
          State := State and (not mstWAITINGFEED);
          end
     else begin
          UpdateStateView;
          DoNextPathStep := False;
          end;
end;

procedure DoNextPathStep_; far;
begin
     if not TheMachine.DoNextPathStep
     then begin
          UninstallProcess( DoNextPathStep_);
          TheMachine.SwitchFeedOff;
          TheMachine.MachineOff;
          TheMachine.Release;
          TheMachine.UpdateStateView;
          TheMachine.SetMoves( nil);
{$IFDEF _USEPORTS}
{$IFDEF _POSPANEL}
          TheScreen.ShowMouseCursor;
{$ENDIF}
{$ENDIF}
          end;
end;

function TMachine.RunPath( AMoves: PRPath; ACount: Longint; AMachineSettings: PMachineSettings): Boolean;
var DrawnRect: TRect;
{$IFDEF _POSPANEL}
    E: TEvent;
{$ENDIF}
label SkipRun;
begin
     RunPath := False;

     if ( AMachineSettings = nil)
     then begin
          {Writeln('AMachineSettings = nil');}
          goto SkipRun;
          end;

     if IsEngaged
     then begin
          {Writeln('IsEngaged');}
          goto SkipRun;
          end;

     if (AMoves = nil)
     then begin
          {Writeln('AMoves = nil');}
          goto SkipRun;
          end;

     if not ResetErrors
     then begin
          {Writeln('not ResetErrors');}
          goto SkipRun;
          end;

     if not Engage
     then begin
          {WriteLn('not Engage');}
          Release;
          goto SkipRun;
          end;

     if not MachineOn
     then begin
          {WriteLn('not MachineOn');}
          MachineOff;
          Release;
          goto SkipRun;
          end;

     if not SetSpeedAuto( False{AMachineSettings^.GetSpeedAuto})
     then begin
          {WriteLn('not SetSpeedAuto( False)');}
          MachineOff;
          Release;
          goto SkipRun;
          end;

     if not SetFeedSpeed( AMachineSettings^.GetFeedSpeed)
     then begin
          {WriteLn('not SetFeedSpeed( AMachineSettings^.GetFeedSpeed)');}
          MachineOff;
          Release;
          goto SkipRun;
          end;

     {if not ResetHeadPos
     then begin
          MachineOff;
          Release;
          goto SkipRun;
          end;}

     AMoves^.GetFitRect( DrawnRect, True);

     if not MoveToStartPos( DrawnRect)
     then begin
          {WriteLn('not MoveToStartPos( DrawnRect)');}
          MachineOff;
          Release;
          goto SkipRun;
          end;

     if not SetFeedBackCounter( AMachineSettings^.GetStepPulsesCount)
     then begin
          {WriteLn('not SetFeedBackCounter( AMachineSettings^.GetStepPulsesCount)');}
          MachineOff;
          Release;
          goto SkipRun;
          end;

     SetMoves( AMoves);
     AMoves := nil;
     DrawnRepeats := ACount;

     if not SwitchFeedOn
     then begin
          SwitchFeedOff;
          MachineOff;
          Release;
          goto SkipRun;
          end;

{$IFDEF _POSPANEL}
     E.What := evCommand;
     E.Command := cmUpdateHeadPos;
     PushEvent( E);
{$ENDIF}

{$IFDEF _USEPORTS}
{$IFDEF _POSPANEL}
     TheScreen.HideMouseCursor;
{$ENDIF}
{$ENDIF}
     InstallProcess( DoNextPathStep_, MINNICEVALUE);
     RunPath := True;
SkipRun:
     if ( AMoves <> nil)
     then AMoves^.Free;
     UpdateStateView;
end;

function TMachine.StopRequest: Boolean;
begin
     State := State or mstSTOPREQUEST;
     StopRequest := Syncronize;
     UpdateStateView;
end;

function TMachine.DoNextGotoFromZeroStep: Boolean;
var E: TEvent;
begin
     if Syncronize
     then begin
          case CurrentActionStep
          of 0: begin
                CurrentActionStep := 1;
                DoNextGotoFromZeroStep := True;
                end;
             1: begin
                if (( State and mstHEADMOVING) = $00000000)
                then begin
                     if (( State and ( mstY1LOLIMITSENSOR or mstY2LOLIMITSENSOR)) = $00000000)
                     then begin
                          ForceMoveHead( 0, - SEARCH_STEP_Y, motBoth, True);
                          end
                     else if (( State and ( mstY2LOLIMITSENSOR)) = $00000000)
                     then begin
                          ForceMoveHead( 0, - PULSES_PER_MM_Y, motY2, True);
                          end
                     else if (( State and ( mstY1LOLIMITSENSOR)) = $00000000)
                     then begin
                          ForceMoveHead( 0, - PULSES_PER_MM_Y, motY1, True);
                          end
                     else begin
                          ForceMoveHead( 0, + SAFTEY_LIMIT_Y, motBoth, True);
                          HeadYPos := 0;
                          CurrentActionStep := 2;
                          end;
{$IFDEF _POSPANEL}
                     E.What := evCommand;
                     E.Command := cmUpdateHeadPos;
                     PushEvent( E);
{$ENDIF}
                     DoNextGotoFromZeroStep := Syncronize;{True}
                     end
                else DoNextGotoFromZeroStep := True;
                end;
             2: begin
                if (( State and mstHEADMOVING) = $00000000)
                then begin
                     if (( State and mstXLOLIMITSENSOR) = $00000000)
                     then ForceMoveHead( - SEARCH_STEP_X, 0, motBoth, True)
                     else begin
                          State := State and not mstXLOLIMIT;
                          ForceMoveHead( + SAFTEY_LIMIT_X, 0, motBoth, True);

                          CurrentActionStep := 3;
                          end;
{$IFDEF _POSPANEL}
                     E.What := evCommand;
                     E.Command := cmUpdateHeadPos;
                     PushEvent( E);
{$ENDIF}
                     DoNextGotoFromZeroStep := Syncronize;{True}
                     end
                else DoNextGotoFromZeroStep := True;
                end;
             3: begin
                if (( State and mstHEADMOVING) = $00000000)
                then begin
                     HeadXPos := 0;
                     HeadYPos := 0;
                     XAcc := 0;
                     YAcc := 0;
{$IFDEF _POSPANEL}
                     E.What := evCommand;
                     E.Command := cmUpdateHeadPos;
                     PushEvent( E);
{$ENDIF}
                     CurrentActionStep := 4;
                     DoNextGotoFromZeroStep := Syncronize;
                     end
                else DoNextGotoFromZeroStep := True;
                end;
             4: begin
                if (( State and mstHEADMOVING) = $00000000)
                then begin
                     ForceMoveHead( GotoFromZeroPosX, GotoFromZeroPosY, motBoth, True);
{$IFDEF _POSPANEL}
                     E.What := evCommand;
                     E.Command := cmUpdateHeadPos;
                     PushEvent( E);
{$ENDIF}
                     CurrentActionStep := 5;
                     DoNextGotoFromZeroStep := Syncronize;
                     end
                else DoNextGotoFromZeroStep := True;
                end;
             5: begin
                if (( State and mstHEADMOVING) = $00000000)
                then begin
                     CurrentActionStep := 6;
                     DoNextGotoFromZeroStep := Syncronize;
                     end
                else DoNextGotoFromZeroStep := True;
                end;
             6: begin
                HeadXPos := GotoFromZeroPosX;
                HeadYPos := GotoFromZeroPosY;
                XAcc := 0;
                YAcc := 0;
                CurrentActionStep := 0;
                DoNextGotoFromZeroStep := False;
                end;
             else
                 GotoFromZeroPosX := 0;
                 GotoFromZeroPosY := 0;
                 DoNextGotoFromZeroStep := False;
             end;
          end
     else begin
          GotoFromZeroPosX := 0;
          GotoFromZeroPosY := 0;
          CurrentActionStep := 0;
          DoNextGotoFromZeroStep := False;
          end;
     UpdateStateView;
end;

procedure DoNextGotoFromZeroStep_; far;
begin
     if not TheMachine.DoNextGotoFromZeroStep
     then begin
          UninstallProcess( DoNextGotoFromZeroStep_);
          TheMachine.SwitchFeedOff;
          TheMachine.MachineOff;
          TheMachine.Release;
          TheMachine.UpdateStateView;
{$IFDEF _USEPORTS}
{$IFDEF _POSPANEL}
          TheScreen.ShowMouseCursor;
{$ENDIF}
{$ENDIF}
          end;
end;

function TMachine.RunGotoFromZero( AX, AY: Longint): Boolean;
label SkipRun;
begin
     RunGotoFromZero := False;

     if IsEngaged
     then goto SkipRun;
     if not ResetErrors
     then goto SkipRun;
     if not Engage
     then begin
          Release;
          goto SkipRun;
          end;
     if not MachineOn
     then begin
          MachineOff;
          Release;
          goto SkipRun;
          end;
{$IFDEF _USEPORTS}
{$IFDEF _POSPANEL}
     TheScreen.HideMouseCursor;
{$ENDIF}
{$ENDIF}
     CurrentActionStep := 0;
     GotoFromZeroPosX := Abs(AX);
     GotoFromZeroPosY := Abs(AY);


     InstallProcess( DoNextGotoFromZeroStep_, MINNICEVALUE);
     RunGotoFromZero := True;
SkipRun:
     UpdateStateView;
end;

function TMachine.DoNextMeasurementStep: Boolean;
begin
     if Syncronize
     then begin
          case CurrentActionStep
          of 0: begin
                CurrentActionStep := 1;
                DoNextMeasurementStep := True;
                end;
             1: begin
                if (( State and mstHEADMOVING) = $00000000)
                then begin
                     if (( State and ( mstY1LOLIMITSENSOR or mstY2LOLIMITSENSOR)) = $00000000)
                     then begin
                          ForceMoveHead( 0, - SEARCH_STEP_Y, motBoth, True)
                          end
                     else if (( State and ( mstY2LOLIMITSENSOR)) = $00000000)
                     then begin
                          ForceMoveHead( 0, - PULSES_PER_MM_Y, motY2, True);
                          end
                     else if (( State and ( mstY1LOLIMITSENSOR)) = $00000000)
                     then begin
                          ForceMoveHead( 0, - PULSES_PER_MM_Y, motY1, True);
                          end
                     else begin
                          ForceMoveHead( 0, + SAFTEY_LIMIT_Y, motBoth, True);
                          TempMeasurements.HeadYCenterStart := 0;
                          TempMeasurements.HeadYCenterEnd := 0;
                          TempMeasurements.SizeY := 0;
                          CurrentActionStep := 2;
                          end;
                     DoNextMeasurementStep := Syncronize;{True}
                     end
                else DoNextMeasurementStep := True;
                end;
             2: begin
                if (( State and mstHEADMOVING) = $00000000)
                then begin
                     HeadYPos := 0;
                     YAcc := 0;
                     CurrentActionStep := 3;
                     DoNextMeasurementStep := Syncronize;
                     end
                else DoNextMeasurementStep := True;
                end;
             3: begin
                if (( State and mstHEADMOVING) = $00000000)
                then begin
                     if ((( State and mstY1HILIMITSENSOR) = $00000000)
                        and ( TempMeasurements.SizeY + SEARCH_STEP_Y <= DEF_MACHINE_WINDOW_HEIGHT))
                     then begin
                          if ((State and mstYCENTER) <> $00000000)
                          then begin
                               TempMeasurements.HeadYCenterEnd := TempMeasurements.SizeY + OFFSET_TOLERANCE_Y;
                               if TempMeasurements.HeadYCenterStart = 0
                               then TempMeasurements.HeadYCenterStart := TempMeasurements.SizeY - OFFSET_TOLERANCE_Y;
                               end;
                          ForceMoveHead( 0, + SEARCH_STEP_Y, motBoth, True);
                          TempMeasurements.SizeY := TempMeasurements.SizeY + SEARCH_STEP_Y;
                          end
                     else begin
                          ForceMoveHead( 0, - SAFTEY_LIMIT_Y, motBoth, True);
                          TempMeasurements.SizeY := TempMeasurements.SizeY - SAFTEY_LIMIT_Y;
                          CurrentActionStep := 4;
                          end;
                     DoNextMeasurementStep := Syncronize;{True}
                     end
                else DoNextMeasurementStep := True;
                end;
             4: begin
                if (( State and mstHEADMOVING) = $00000000)
                then begin
                     if (( State and mstXLOLIMITSENSOR) = $00000000)
                     then begin
                          ForceMoveHead( - SEARCH_STEP_X, 0, motBoth, True);
                          {Delay( 200);}
                          end
                     else begin
                          ForceMoveHead( + SAFTEY_LIMIT_X, 0, motBoth, True);
                          TempMeasurements.HeadXCenterStart := 0;
                          TempMeasurements.HeadXCenterEnd := 0;
                          TempMeasurements.SizeX := 0;
                          CurrentActionStep := 5;
                          end;
                     DoNextMeasurementStep := Syncronize;{True}
                     end
                else DoNextMeasurementStep := True;
                end;
             5: begin
                if (( State and mstHEADMOVING) = $00000000)
                then begin
                     HeadXPos := 0;
                     XAcc := 0;
                     CurrentActionStep := 6;
                     DoNextMeasurementStep := Syncronize;
                     end
                else DoNextMeasurementStep := True;
                end;
             6: begin
                if (( State and mstHEADMOVING) = $00000000)
                then begin
                     if ((( State and mstXHILIMITSENSOR) = $00000000)
                        and ( TempMeasurements.SizeX + SEARCH_STEP_X < DEF_MACHINE_WINDOW_WIDTH))
                     then begin
                          if ((State and mstXCENTER) <> $00000000)
                          then begin
                               TempMeasurements.HeadXCenterEnd := TempMeasurements.SizeX + OFFSET_TOLERANCE_X;
                               if TempMeasurements.HeadXCenterStart = 0
                               then TempMeasurements.HeadXCenterStart := TempMeasurements.SizeX - OFFSET_TOLERANCE_X;
                               end;
                          ForceMoveHead( + SEARCH_STEP_X, 0, motBoth, True);
                          {Delay( 200);}
                          TempMeasurements.SizeX := TempMeasurements.SizeX + SEARCH_STEP_X;
                          end
                     else begin
                          ForceMoveHead( - SAFTEY_LIMIT_X, 0 , motBoth, True);
                          TempMeasurements.SizeX := TempMeasurements.SizeX - SAFTEY_LIMIT_X;
                          CurrentActionStep := 7;
                          end;
                     DoNextMeasurementStep := Syncronize;{True}
                     end
                else DoNextMeasurementStep := True;
                end;
             7: begin
                if (( State and mstHEADMOVING) = $00000000)
                then begin
                     CurrentActionStep := 8;
                     DoNextMeasurementStep := Syncronize;{True}
                     end
                else DoNextMeasurementStep := True;
                end;
{             8: begin
                FeedCounter := 0;
                SetFeedSpeed( 130);
                if SwitchFeedOn
                then begin
                     RunTimer( TIMED_STEP_TIME);
                     CurrentActionStep := 9;
                     DoNextMeasurementStep := True;
                     end
                else begin
                     CurrentActionStep := 0;
                     DoNextMeasurementStep := False;
                     end;
                end;
             9: begin
                if IsTimerOn
                then DoNextMeasurementStep := True
                else begin
                     Sound( 1000);
                     FeedCounter := 0;
                     RunTimer( TIMED_STEP_TIME);
                     CurrentActionStep := 10;
                     DoNextMeasurementStep := True
                     end;
                end;
             10: begin
                 if IsTimerOn
                 then DoNextMeasurementStep := True
                 else begin
                      NoSound;
                      TempMeasurements.SpeedTimeFactor := ( MEASURINGPULSESCOUNT * PULSE_LINEAR_LENGTH * FeedCounter)
                                                          / ( TIMED_STEP_TIME * 130);
                      if SwitchFeedOff
                      then begin
                           CurrentActionStep := 11;
                           DoNextMeasurementStep := True;
                           end
                      else begin
                           CurrentActionStep := 0;
                           DoNextMeasurementStep := False;
                           end;
                      end;
                 end;
}
             8: begin
                CurrentActionStep := 0;
                if TempMeasurements.HeadXCenterEnd = 0
                then TempMeasurements.HeadXCenterEnd := TempMeasurements.SizeX;
                if TempMeasurements.HeadYCenterEnd = 0
                then TempMeasurements.HeadYCenterEnd := TempMeasurements.SizeY;
                Measurements := TempMeasurements;
                MeasurementsChanged := True;
                DoNextMeasurementStep := False;
                end;
             else
                 CurrentActionStep := 0;
                 DoNextMeasurementStep := False;
             end;
          end
     else begin
          CurrentActionStep := 0;
          DoNextMeasurementStep := False;
          end;
     UpdateStateView;
end;

procedure DoNextMeasurementStep_; far;
begin
     if not TheMachine.DoNextMeasurementStep
     then begin
          UninstallProcess( DoNextMeasurementStep_);
          TheMachine.SwitchFeedOff;
          TheMachine.MachineOff;
          TheMachine.Release;
          TheMachine.UpdateStateView;
{$IFDEF _USEPORTS}
{$IFDEF _POSPANEL}
          TheScreen.ShowMouseCursor;
{$ENDIF}
{$ENDIF}
          end;
end;

function TMachine.RunMeasurements: Boolean;
label SkipRun;
begin
     RunMeasurements := False;

     if IsEngaged
     then goto SkipRun;
     if not ResetErrors
     then goto SkipRun;
     if not Engage
     then begin
          Release;
          goto SkipRun;
          end;
     if not MachineOn
     then begin
          MachineOff;
          Release;
          goto SkipRun;
          end;
{$IFDEF _USEPORTS}
{$IFDEF _POSPANEL}
     TheScreen.HideMouseCursor;
{$ENDIF}
{$ENDIF}
     CurrentActionStep := 0;
     InstallProcess( DoNextMeasurementStep_, MINNICEVALUE);
     RunMeasurements := True;
SkipRun:
     UpdateStateView;
end;

{
function TMachine.DoNextSetFeedSpeedStep: Boolean;
begin
     if Syncronize
     then begin
          case CurrentActionStep
          of 0: begin
                DoNextSetFeedSpeedStep := True;
                CurrentActionStep := 1;
                end;
             1: begin
                RunTimer( 45);
                DoNextSetFeedSpeedStep := True;
                CurrentActionStep := 2;
                end;
             2: begin
                if IsTimerOn
                then begin
                     DoNextSetFeedSpeedStep := True;
                     end
                else begin
                     DoNextSetFeedSpeedStep := True;
                     CurrentActionStep := 3;
                     end;
                end;
             3: begin
                DoNextSetFeedSpeedStep := True;
                CurrentActionStep := 4;
                end;
             4: begin
                DoNextSetFeedSpeedStep := True;
                CurrentActionStep := 5;
                end;
             5: begin
                DoNextSetFeedSpeedStep := True;
                CurrentActionStep := 6;
                end;
             6: begin
                DoNextSetFeedSpeedStep := True;
                CurrentActionStep := 7;
                end;
             7: begin
                DoNextSetFeedSpeedStep := True;
                CurrentActionStep := 8;
                end;
             8: begin
                DoNextSetFeedSpeedStep := False;
                CurrentActionStep := 0;
                end;
             else
                 CurrentActionStep := 0;
             end;
          end
     else DoNextSetFeedSpeedStep := False;
end;

procedure DoNextSetFeedSpeedStep_; far;
begin
     if not TheMachine.DoNextSetFeedSpeedStep
     then begin
          UninstallProcess( DoNextSetFeedSpeedStep_);
          TheMachine.SwitchFeedOff;
          TheMachine.MachineOff;
          TheMachine.Release;
          TheMachine.UpdateStateView;
          end;
end;

function TMachine.RunSetFeedSpeed: Boolean;
label SkipRun;
begin
     RunSetFeedSpeed := False;
     if IsEngaged
     then goto SkipRun;
     if not ResetErrors
     then goto SkipRun;
     if not Engage
     then begin
          Release;
          goto SkipRun;
          end;
     if not MachineOn
     then begin
          MachineOff;
          Release;
          goto SkipRun;
          end;
     CurrentActionStep := 0;
     InstallProcess( DoNextSetFeedSpeedStep_, MINNICEVALUE);
     RunSetFeedSpeed := True;
SkipRun:
     UpdateStateView;
end;
}

function TMachine.DoNextDelayStep: Boolean;
begin
     if Syncronize
     then begin
          case CurrentActionStep
          of 0: begin
                RunTimer( DelayTime);
                DoNextDelayStep := True;
                CurrentActionStep := 1;
                end;
             1: begin
                if IsTimerOn
                then DoNextDelayStep := True
                else begin
                     CurrentActionStep := 0;
                     DoNextDelayStep := False;
                     end;
                end;
             else
                 CurrentActionStep := 0;
                 DoNextDelayStep := False;
             end;
          end
     else DoNextDelayStep := False;
end;

procedure DoNextDelayStep_; far;
begin
     if not TheMachine.DoNextDelayStep
     then begin
          UninstallProcess( DoNextDelayStep_);
          TheMachine.Release;
          TheMachine.UpdateStateView;
          end;
end;

function TMachine.RunDelay( ATime: Longint): Boolean;
label SkipRun;
begin
     RunDelay := False;
     if IsEngaged
     then goto SkipRun;
     if not ResetErrors
     then goto SkipRun;
     if not Engage
     then begin
          Release;
          goto SkipRun;
          end;
     DelayTime := ATime;
     CurrentActionStep := 0;
     InstallProcess( DoNextDelayStep_, MINNICEVALUE);
     RunDelay := True;
SkipRun:
     UpdateStateView;
end;

function TMachine.DoNextAlarmStep: Boolean;
begin
     if Syncronize
     then begin
          case CurrentActionStep
          of 0: begin
                RunTimer( DelayTime);
                DoNextAlarmStep := True;
                CurrentActionStep := 1;
                end;
             1: begin
                if IsTimerOn
                then DoNextAlarmStep := True
                else begin
                     CurrentActionStep := 0;
                     DoNextAlarmStep := False;
                     end;
                end;
             else
                 CurrentActionStep := 0;
                 DoNextAlarmStep := False;
             end;
          end
     else DoNextAlarmStep := False;
end;

procedure DoNextAlarmStep_; far;
begin
     if not TheMachine.DoNextAlarmStep
     then begin
          NoSound;
          UninstallProcess( DoNextAlarmStep_);
          TheMachine.Release;
          TheMachine.UpdateStateView;
          end;
end;

function TMachine.RunAlarm( ATime: Longint; AFrequency: Integer): Boolean;
label SkipRun;
begin
     RunAlarm := False;
     if IsEngaged
     then goto SkipRun;
     if not ResetErrors
     then goto SkipRun;
     if not Engage
     then begin
          Release;
          goto SkipRun;
          end;
     DelayTime := ATime;
     CurrentActionStep := 0;
     Sound( AFrequency);
     InstallProcess( DoNextAlarmStep_, MINNICEVALUE);
     RunAlarm := True;
SkipRun:
     UpdateStateView;
end;

function TMachine.LastLapRequest: Boolean;
begin
     State := State or mstLASTLAPREQUEST;
     LastLapRequest := Syncronize;
     UpdateStateView;
end;

procedure TMachine.UpdateStateView;
var E: TEvent;
begin
     E.What := evCommand;
     E.Command := cmUpdateMachineStateView;
     PushEvent( E);
end;

const OldState: Longint = $00000000;

procedure TMachine.DoNextIdleCycle;
begin
     Syncronize;
     if ( OldState <> State)
     then begin
          OldState := State;
          UpdateStateView;
          {Sound( 3000);
          Delay( 1);
          NoSound;}
          end;
end;

function TMachine.AppendAction( AAction: PAction): Boolean;
begin
     if ( AAction <> nil)
     then begin
          if not BusyDoingActions
          then begin
               Actions.PushLast( AAction);
               AppendAction := True;
               end
          else begin
               AAction^.Free;
               AppendAction := False;
               end;
          end
     else AppendAction := False;
end;

function TMachine.ClearActions: Boolean;
begin
     if not BusyDoingActions
     then begin
          Actions.Clear;
          ClearActions := True;
          end
     else ClearActions := False;
end;

function TMachine.DoNextAction: Boolean;
var ActionToDo: PAction;
begin
     if not IsEngaged
     then begin
          if Syncronize
          then begin
               ActionToDo := PAction( Actions.PopFirst);
               if ( ActionToDo <> nil)
               then begin
                    if ActionToDo^.RunAction( @Self)
                    then DoNextAction := True
                    else begin
                         BusyDoingActions := False;
                         DoNextAction := False;
                         end;
                    ActionToDo^.Free;
                    end
               else begin
                    BusyDoingActions := False;
                    DoNextAction := False;
                    end;
               end
          else begin
               BusyDoingActions := False;
               DoNextAction := False;
               end;
          end
     else DoNextAction := Syncronize;
end;

procedure DoNextAction_; far;
begin
     if not TheMachine.DoNextAction
     then begin
          UninstallProcess( DoNextAction_);
          end;
end;

function TMachine.RunActions: Boolean;
begin
     if not BusyDoingActions
     then begin
          BusyDoingActions := True;
          ResetErrors;
          InstallProcess( DoNextAction_, NORMALNICEVALUE);
          end
     else RunActions := False;
end;

function TMachine.IsBusy: Boolean;
begin
     if BusyDoingActions
     then IsBusy := True
     else IsBusy := IsEngaged;
end;

function TMachine.SetSpeedAuto( AAuto: Boolean): Boolean;
begin
     if AAuto
     then State := State or mstSPEEDAUTO
     else State := State and (not mstSPEEDAUTO);
     SetSpeedAuto := Syncronize;
end;

function TMachine.IsSpeedAuto: Boolean;
begin
     IsSpeedAuto := ( State and mstSPEEDAUTO) <> $00000000;
end;

procedure TMachine.UninstallAllRelatedProcesses;
begin
     UninstallProcess( DoNextMachineIdleCycle_);
     UninstallProcess( DoNextPathStep_);
     UninstallProcess( DoNextMeasurementStep_);
     UninstallProcess( DoNextGotoFromZeroStep_);
     UninstallProcess( DoNextAction_);
     {UninstallProcess( DoNextSetFeedSpeedStep_);}
     UninstallProcess( DoNextDelayStep_);
     UninstallProcess( DoNextAlarmStep_);
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

{$IFDEF _POSPANEL}

constructor TPosPanel.Create( R: TRect);
begin
     inherited Create( R);
     State := sfVisible or sfEnabled;
     EventMask := $00;

     LastPos.Assign( TheMachine.HeadXPos, TheMachine.HeadYPos);
end;

procedure TPosPanel.Draw;
begin
     BeginDraw;
     SetPFillPattern( clrFIELDBACKINACTIVE , SolidPattern);
     Bar( 0, 0, Size.X - 1, Size.Y - 1);
     SetPColor( clrCURSOR);
     Line( LastPos.X, LastPos.Y - 5, LastPos.X, LastPos.Y + 5);
     Line( LastPos.X - 5, LastPos.Y, LastPos.X + 5, LastPos.Y);
     EndDraw;
end;

procedure TPosPanel.UpdatePos;
var NewPos: TPoint;
begin
     NewPos.X := (Longint(TheMachine.GetHeadXPos) * Longint(Size.X))
                 div ( TheMachine.Measurements.SizeX);
     NewPos.Y := (Longint(TheMachine.GetHeadYPos) * Longint(Size.Y))
                 div ( TheMachine.Measurements.SizeY);
     if (( NewPos.X <> LastPos.X) or ( NewPos.Y <> LastPos.Y))
     then begin
          BeginDraw;
          SetWriteMode( NormalPut);
          SetPColor( clrFIELDBACKINACTIVE);
          Line( LastPos.X, LastPos.Y - 5, LastPos.X, LastPos.Y + 5);
          Line( LastPos.X - 5, LastPos.Y, LastPos.X + 5, LastPos.Y);
          SetPColor( clrCURSOR);
          LastPos := NewPos;
          Line( LastPos.X, LastPos.Y - 5, LastPos.X, LastPos.Y + 5);
          Line( LastPos.X - 5, LastPos.Y, LastPos.X + 5, LastPos.Y);
          EndDraw;
          end;
end;

{$ENDIF}

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TAction.Create;
begin
     inherited Create;
end;

function TAction.RunAction( AMachine: PMachine): Boolean;
begin
     if ( AMachine <> nil)
     then RunAction := True
     else RunAction := False;
end;

{*************************************************************************}

constructor TGotoFromZeroAction.Create( AX, AY: Longint);
begin
     inherited Create;
     GotoPosX := AX;
     GotoPosY := AY;
end;

function TGotoFromZeroAction.RunAction( AMachine: PMachine): Boolean;
begin
     if ( AMachine <> nil)
     then RunAction := AMachine^.RunGotoFromZero( GotoPosX, GotoPosY)
     else RunAction := False;
end;

{*************************************************************************}

constructor TRunPathAction.Create( AMoves: PRPath; ACount: Longint; AMachineSettings: PMachineSettings);
begin
     inherited Create;
     Moves := AMoves;
     Count := ACount;
     if ( AMachineSettings <> nil)
     then MachineSettings := PMachineSettings( AMachineSettings^.Clone)
     else MachineSettings := nil;
end;

destructor TRunPathAction.Destroy;
begin
     if ( Moves <> nil)
     then Moves^.Free;
     if ( MachineSettings <> nil)
     then MachineSettings^.Free;
     inherited Destroy;
end;

function TRunPathAction.RunAction( AMachine: PMachine): Boolean;
begin
     if ( AMachine <> nil)
     then begin
          RunAction := AMachine^.RunPath( Moves, Count, MachineSettings);
          Moves := nil;{ because Machine absorb it }
          end
     else RunAction := False;
end;

{*************************************************************************}

function TDoMeasurmentAction.RunAction( AMachine: PMachine): Boolean;
begin
     if ( AMachine <> nil)
     then RunAction := AMachine^.RunMeasurements
     else RunAction := False;
end;

{*************************************************************************}

{
function TSetFeedSpeedAction.RunAction( AMachine: PMachine): Boolean;
begin
     if ( AMachine <> nil)
     then RunAction := AMachine^.RunSetFeedSpeed
     else RunAction := False;
end;
}

{*************************************************************************}

constructor TDelayAction.Create( ATime: Longint);
begin
     inherited Create;
     DelayTime := ATime;
end;

function TDelayAction.RunAction( AMachine: PMachine): Boolean;
begin
     if ( AMachine <> nil)
     then RunAction := AMachine^.RunDelay( DelayTime)
     else RunAction := False;
end;

{*************************************************************************}

constructor TAlarmAction.Create( ATime: Longint; AFrequency: Integer);
begin
     inherited Create;
     DelayTime := ATime;
     Frequency := AFrequency
end;

function TAlarmAction.RunAction( AMachine: PMachine): Boolean;
begin
     if ( AMachine <> nil)
     then RunAction := AMachine^.RunAlarm( DelayTime, Frequency)
     else RunAction := False;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

const ITEMHEIGHT = 16;
      ITEMSCOUNT = 11;

constructor TMachineStatePanel.Create( AOrigin: TPoint);
var R: TRect;
begin
     R.A := AOrigin;
     R.B.Assign( R.A.X + 120, R.A.Y + ITEMHEIGHT * ITEMSCOUNT + 4);
     inherited Create( R);
     State := sfVisible or sfEnabled;
     EventMask := evMouseDown;
     LastState := $00000000;
     LastFeedSpeed := 0;
     LastValue := 0;
end;

procedure TMachineStatePanel.Draw;
var I: Integer;
begin
     BeginDraw;
     Draw3DInBar( 0, 0, Size.X - 1, Size.Y - 1, clr3D0, clr3D1, clr3D2, clr3D3);
     SetColor( 0);

     for I := 0 to ITEMSCOUNT - 1
     do Rectangle( 3, 3 + ITEMHEIGHT * I, Size.X - 4, 1 + ITEMHEIGHT * ( I + 1) - 1);
     UpdateStateView( False);
     EndDraw;
end;

procedure TMachineStatePanel.UpdateStateView( ACheckLast: Boolean);
var NewState: Longint;
    {NewFeedSpeed: Word;}
    NewValue: Longint;
    S: string;
    procedure DrawItem( AItemNo: Integer; AColor: Integer; ATitle: string);
    begin
         {Rectangle( 2, 2 + ITEMHEIGHT * AItemNo, Size.X - 3, 1 + ITEMHEIGHT * ( AItemNo + 1) - 2);}
         SetFillPattern( SolidPattern, AColor);
         Bar( 4, 4 + ITEMHEIGHT * AItemNo, Size.X - 5, 1 + ITEMHEIGHT * ( AItemNo + 1) - 2);
         OutTextXY( 10, ITEMHEIGHT * AItemNo + (ITEMHEIGHT - metTEXTHEIGHT) div 2 + 2, ATitle);
    end;

    function FlagChanged( AFlag: Longint): Boolean;
    begin
         FlagChanged := ((NewState and AFlag) <> (LastState and AFlag)) or not ACheckLast;
    end;
begin
     NewState := TheMachine.State and ( mstFEEDMOTORON
                                      or mstLIMIT
                                      or mstSTOPREQUEST
                                      or mstERROR
                                      or mstLASTLAPREQUEST
                                      or mstOVERSPEED
                                      or mstRUNNING
                                      or mstXOFFSETERROR
                                      or mstYOFFSETERROR
                                      or mstSPEEDAUTO
                                      or mstEMERGENCY);
     {NewFeedSpeed := TheMachine.FeedSpeed;}
     NewValue := TheMachine.HeadYError;
     if (( NewState <> LastState) or (LastValue <> NewValue){(LastFeedSpeed <> NewFeedSpeed)} or not ACheckLast)
     then begin
          BeginDraw;

          SetColor( 0);

          if ( FlagChanged( mstRUNNING))
          then begin
               if ((NewState and mstRUNNING) <> $00000000)
               then DrawItem( 0, 12, 'RUNNING')
               else DrawItem( 0, 2, 'RUNNING');
               end;

          if ( FlagChanged( mstFEEDMOTORON))
          then begin
               if ((NewState and mstFEEDMOTORON) <> $00000000)
               then DrawItem( 1, 12, 'FEED ON')
               else DrawItem( 1, 2, 'FEED ON');
               end;

          if ( FlagChanged( mstLIMIT))
          then begin
               if ((NewState and mstLIMIT) <> $00000000)
               then DrawItem( 2, 6, 'LIMITS ERROR')
               else DrawItem( 2, 2, 'LIMITS ERROR');
               end;

          if ( FlagChanged( mstSTOPREQUEST))
          then begin
               if ((NewState and mstSTOPREQUEST) <> $00000000)
               then DrawItem( 3, 6, 'USER STOP')
               else DrawItem( 3, 2, 'USER STOP');
               end;

          if ( FlagChanged( mstEMERGENCY))
          then begin
               if ((NewState and mstEMERGENCY) <> $00000000)
               then DrawItem( 4, 6, 'EMERGENCY')
               else DrawItem( 4, 2, 'EMERGENCY');
               end;

          if ( FlagChanged( mstERROR))
          then begin
               if ((NewState and mstERROR) <> $00000000)
               then DrawItem( 5, 6, 'ERROR')
               else DrawItem( 5, 2, 'ERROR');
               end;

          if ( FlagChanged( mstLASTLAPREQUEST))
          then begin
               if ((NewState and mstLASTLAPREQUEST) <> $00000000)
               then DrawItem( 6, 12, 'LAST LAP')
               else DrawItem( 6, 2, 'LAST LAP');
               end;

          if ( FlagChanged( mstOVERSPEED))
          then begin
               if ((NewState and mstOVERSPEED) <> $00000000)
               then DrawItem( 7, 7, 'OVERRUN')
               else DrawItem( 7, 2, 'OVERRUN');
               end;

          if ( FlagChanged( mstXOFFSETERROR))
          then begin
               if ((NewState and mstXOFFSETERROR) <> $00000000)
               then DrawItem( 8, 7, 'OFFSET ON X')
               else DrawItem( 8, 2, 'OFFSET ON X');
               end;

          if ( FlagChanged( mstYOFFSETERROR))
          then begin
               if ((NewState and mstYOFFSETERROR) <> $00000000)
               then DrawItem( 9, 7, 'OFFSET ON Y')
               else DrawItem( 9, 2, 'OFFSET ON Y');
               end;


          if ((LastValue <> NewValue){( LastFeedSpeed <> NewFeedSpeed)} or (not ACheckLast))
          then begin
               {LastFeedSpeed := NewFeedSpeed;}
               LastValue := NewValue;
               Str( NewValue, S);
               DrawItem( 10, 7, S);
               end;

          LastState := NewState;
          EndDraw;
          end;
end;

procedure TMachineStatePanel.HandleEvent( var E: TEvent);
begin
     if ( E.What = evMouseDown)
     then begin
          UpdateStateView( True);
          ClearEvent( E);
          end
     else inherited HandleEvent( E);
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TRunDlg.Create( APath: PFPath; AMachineSettings: PMachineSettings);
var R: TRect;
    Panel: PJustFrame;
    S: TPoint;
begin
     S.Assign( 510, 400);
     inherited Create( S, 'Run');

     Path := nil;
     SetPath( APath);
     MachineSettings := AMachineSettings;

     Lock;

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 10;
     R.B.Y := R.B.Y - R.A.Y - 10;
     R.A.X := 10;
     R.A.Y := 245;
     Panel := New( PJustFrame, Create( R));
     InsertChild( Panel);

     Panel^.GetClientRect( R);
     R.A.X := 0;
     R.A.Y := 0;
     R.B.X := R.B.X - R.A.X - 1;
     R.B.Y := R.B.Y - R.A.Y - 1;
     List := New( PTextList, Create(R));
     Panel^.InsertChild( List);

     R.A.X := 10;
     R.A.Y := 205;
     R.B.X := 10 + 333;
     R.B.Y := 235;

     SpeedScroll := New( PScrollControl, Create( R, 100, 25));
     InsertChild( SpeedScroll);

     InsertChild( New( PButton, Create( 65, 100, 100 + metSHADOWSIZE, 30, '&Up', cmManUp, keyU)));
     InsertChild( New( PButton, Create( 10, 135, 100 + metSHADOWSIZE, 30, '&Left', cmManLeft, keyL)));
     InsertChild( New( PButton, Create( 120, 135, 100 + metSHADOWSIZE, 30, '&Right', cmManRight, keyR)));
     InsertChild( New( PButton, Create( 65, 170, 100 + metSHADOWSIZE, 30, '&Down', cmManDown, keyD)));
     InsertChild( New( PButton, Create( 120, 15, 100 + metSHADOWSIZE, 80, '&Stop', cmStopMachine, keyS)));

     InsertChild( New( PButton, Create( 240, 15, 100 + metSHADOWSIZE, 40, '&Go', cmGo, keyG)));
     InsertChild( New( PButton, Create( 240, 60, 100 + metSHADOWSIZE, 40, '&Finish', cmLastLapRequest, keyF)));
     InsertChild( New( PButton, Create( 240, 135, 100 + metSHADOWSIZE, 30, 'Go Cou&nt', cmGoCount, keyN)));
     InsertChild( New( PButton, Create( 240, 170, 100 + metSHADOWSIZE, 30, 'Re&set Pos.', cmResetPos, keyS)));
     InsertChild( New( PButton, Create( 370, 205, 100 + metSHADOWSIZE, 30, '&Close', cmCancel, keyC)));
     {InsertChild( New( PButton, Create( 10, 205, 100 + metSHADOWSIZE, 30, 'Loc&k speed', cmLockSpeed, keyK)));
     InsertChild( New( PButton, Create( 120, 205, 100 + metSHADOWSIZE, 30, 'Speed &auto', cmUnlockSpeed, keyA)));}

     R.A.X := 15;
     R.A.Y := 15;
     R.B.X := 105;
     R.B.Y := 90;

{$IFDEF _POSPANEL}
     Panel := New( PJustFrame, Create( R));
     Panel^.GetClientRect( R);
     R.A.X := 0;
     R.A.Y := 0;
     R.B.X := R.B.X - R.A.X - 1;
     R.B.Y := R.B.Y - R.A.Y - 1;
     PosPanel := New( PPosPanel, Create( R));
     Panel^.InsertChild( PosPanel);
     InsertChild( Panel);
{$ENDIF}

     R.A.Assign( 360, 15);
     StatePanel := New( PMachineStatePanel, Create( R.A));
     InsertChild( StatePanel);

     CountEdit := New( PIntegerEdit, Create( 240, 103, 100, 1, 1000));
     InsertChild( CountEdit);

     Unselect;

     if ( AMachineSettings <> nil)
     then SpeedScroll^.SetValue( Round(AMachineSettings^.GetFeedSpeed * (100 / ANALOG_SPEED_RANGE)))
     else SpeedScroll^.SetValue( 0);


     UnLock;
end;

destructor TRunDlg.Destroy;
begin
     if ( Path <> nil)
     then Path^.Free;

     if ( MachineSettings <> nil)
     then MachineSettings^.Free;

     inherited Destroy;
end;

procedure TRunDlg.SetPath( APath: PFPath);
begin
     if ( Path <> nil)
     then Path^.Free;

     Path := APath;
end;

procedure TRunDlg.Go( ACount: Longint);
var DeltasPath: PRPath;
    S: string;
    Rect: TRect;
begin
     if (( Path <> nil) and ( MachineSettings <> nil))
     then begin
          List^.WriteLn( '');
          if not TheMachine.IsBusy
          then begin
               List^.WriteLn( '');
               List^.WriteLn( 'Processing the drawn ...');
               List^.WriteLn( '');
               DeltasPath := Path^.ProduceDeltaPath( PULSES_PER_MM_X, PULSES_PER_MM_Y);
               if ( DeltasPath <> nil)
               then begin
                    Str( DeltasPath^.GetCount, S);
                    List^.WriteLn( ' Steps count : ' + S);
                    DeltasPath^.GetFitRect( Rect, True);
                    Str( (( Rect.B.X - Rect.A.X) / PULSES_PER_MM_X):0:2, S);
                    List^.WriteLn( ' Path witdth : ' + S + ' mm.');
                    Str( (( Rect.B.Y - Rect.A.Y) / PULSES_PER_MM_Y):0:2, S);
                    List^.WriteLn( ' Path height : ' + S + ' mm.');
                    Str( (MachineSettings^.GetFeedSpeed * (100 / ANALOG_SPEED_RANGE)):0:1, S);
                    List^.WriteLn( ' Feed speed  : %' + S);
                    if ( ACount > 0)
                    then begin
                         Str( ACount, S);
                         S := ' Repeat      : ' + S + ' times.';
                         end
                    else S := ' Repeats     : until doomsday';
                    List^.WriteLn( S);
                    List^.WriteLn( '');
                    List^.WriteLn( 'Running the machine ...');
                    TheMachine.ClearActions;
{$IFDEF _USEPORTS}
                    TheMachine.AppendAction( New( PAlarmAction, Create( 10, 200)));
                    TheMachine.AppendAction( New( PDelayAction, Create( 45)));
{$ENDIF}
                    TheMachine.AppendAction( New( PRunPathAction, Create( DeltasPath, ACount, MachineSettings)));
{$IFDEF _USEPORTS}
                    TheMachine.AppendAction( New( PAlarmAction, Create( 5, 200)));
{$ENDIF}
                    if not TheMachine.RunActions
                    then List^.WriteLn( 'ERROR: Unable to install RUN process ...');
                    end
               else List^.WriteLn( 'ERROR: Can''t produce head path ...');
               end
          else List^.WriteLn( 'ERROR: Machine is busy ...');
          end;
     StatePanel^.UpdateStateView( True);
end;

function TRunDlg.ManUp( AYMotors: TMotorsSel; ASkipLimits: Boolean): Boolean;
begin
     if not TheMachine.IsBusy
     then begin
          if TheMachine.Engage
          then begin
               if TheMachine.ResetErrors
               then begin
                    if TheMachine.ForceMoveHead( 0, - PULSES_PER_MM_Y {* 5}, AYMotors, False)
                    then ManUp := True
                    else begin
                         ManUp := False
                         end;
                    end
               else begin
                    ManUp := False
                    end;
               TheMachine.Release;
               end
          else ManUp := False;
          end
     else ManUp := False;
     TheMachine.UpdateStateView;
{$IFDEF _POSPANEL}
     PosPanel^.UpdatePos;
{$ENDIF}
end;

function TRunDlg.ManDown( AYMotors: TMotorsSel; ASkipLimits: Boolean): Boolean;
begin
     if not TheMachine.IsBusy
     then begin
          if TheMachine.Engage
          then begin
               if TheMachine.ResetErrors
               then begin
                    TheMachine.ResetErrors;
                    if TheMachine.ForceMoveHead( 0, PULSES_PER_MM_Y {* 5}, AYMotors, False)
                    then ManDown := True
                    else begin
                         ManDown := False
                         end;
                    end
               else begin
                    ManDown := False
                    end;
               TheMachine.Release;
               end
          else ManDown := False;
          end
     else ManDown := False;
     TheMachine.UpdateStateView;
{$IFDEF _POSPANEL}
     PosPanel^.UpdatePos;
{$ENDIF}
end;

function TRunDlg.ManLeft( ASkipLimits: Boolean): Boolean;
begin
     if not TheMachine.IsBusy
     then begin
          if TheMachine.Engage
          then begin
               if TheMachine.ResetErrors
               then begin
                    TheMachine.ResetErrors;
                    if TheMachine.ForceMoveHead( - PULSES_PER_MM_X {* 5}, 0, motBoth, False)
                    then ManLeft := True
                    else begin
                         ManLeft := False
                         end;
                    end
               else begin
                    ManLeft := False
                    end;
               TheMachine.Release;
               end
          else ManLeft := False;
          end
     else ManLeft := False;
     TheMachine.UpdateStateView;
{$IFDEF _POSPANEL}
     PosPanel^.UpdatePos;
{$ENDIF}
end;

function TRunDlg.ManRight( ASkipLimits: Boolean): Boolean;
begin
     if not TheMachine.IsBusy
     then begin
          if TheMachine.Engage
          then begin
               if TheMachine.ResetErrors
               then begin
                    TheMachine.ResetErrors;
                    if TheMachine.ForceMoveHead( PULSES_PER_MM_X {* 5}, 0, motBoth, False)
                    then ManRight := True
                    else begin
                         ManRight := False
                         end;
                    end
               else begin
                    ManRight := False
                    end;
               TheMachine.Release;
               end
          else ManRight := False;
          end
     else ManRight := False;
     TheMachine.UpdateStateView;
{$IFDEF _POSPANEL}
     PosPanel^.UpdatePos;
{$ENDIF}
end;

function TRunDlg.ResetPos: Boolean;
begin
     if not TheMachine.IsBusy
     then begin
          List^.WriteLn( '');
          List^.WriteLn( 'Reseting head position ...');

          TheMachine.ClearActions;
{$IFDEF _USEPORTS}
          TheMachine.AppendAction( New( PAlarmAction, Create( 10, 200)));
          TheMachine.AppendAction( New( PDelayAction, Create( 45)));
{$ENDIF}
          TheMachine.AppendAction( New( PGotoFromZeroAction, Create( TheMachine.GetSizeX div 2,
                                                                     TheMachine.GetSizeY div 2)));
          TheMachine.AppendAction( New( PAlarmAction, Create( 5, 200)));
          if not TheMachine.RunActions
          then List^.WriteLn( 'ERROR: Unable to do reset pos action ...');
          end
     else ResetPos := False;
     TheMachine.UpdateStateView;
{$IFDEF _POSPANEL}
     PosPanel^.UpdatePos;
{$ENDIF}
end;

procedure TRunDlg.HandleEvent( var E: TEvent);
var Count: Longint;
begin
     if E.What = evCommand
     then begin
          case E.Command
          of
{$IFDEF _POSPANEL}
             cmUpdateHeadPos: begin
                              PosPanel^.UpdatePos;
                              ClearEvent( E);
                              end;
{$ENDIF}
             cmMachineError: begin
                             StatePanel^.UpdateStateView( True);
                             ClearEvent( E);
                             end;
             cmStopMachine: begin
                            TheMachine.StopRequest;
                            StatePanel^.UpdateStateView( True);
                            ClearEvent( E);
                            end;
             {cmLockSpeed: begin
                          if ( MachineSettings <> nil)
                          then MachineSettings^.SpeedAuto := False;
                          TheMachine.SetSpeedAuto( False);
                          StatePanel^.UpdateStateView( True);
                          ClearEvent( E);
                          end;
             cmUnlockSpeed: begin
                            if ( MachineSettings <> nil)
                            then MachineSettings^.SpeedAuto := True;
                            TheMachine.SetSpeedAuto( True);
                            StatePanel^.UpdateStateView( True);
                            ClearEvent( E);
                            end;}
             cmLastLapRequest: begin
                               TheMachine.LastLapRequest;
                               StatePanel^.UpdateStateView( True);
                               ClearEvent( E);
                               end;
             cmUpdateMachineStateView: begin
                                       StatePanel^.UpdateStateView( True);
                                       ClearEvent( E);
                                       end;
             cmGo: begin
                   Go( 0);
                   ClearEvent( E);
                   end;
             cmManUp: begin
                      ManUp( motBoth, False);
                      {DisplayPos;}
                      ClearEvent( E);
                      end;
             cmManDown: begin
                        ManDown( motBoth, False);
                        {DisplayPos;}
                        ClearEvent( E);
                        end;
             cmManLeft: begin
                        ManLeft( False);
                        {DisplayPos;}
                        ClearEvent( E);
                        end;
             cmManRight: begin
                         ManRight( False);
                         {DisplayPos;}
                         ClearEvent( E);
                         end;
             cmResetPos: begin
                         ResetPos;
                         {DisplayPos;}
                         ClearEvent( E);
                         end;
             cmGoCount: begin
                        Count := CountEdit^.GetValue;
                        if ( Count > 0)
                        then Go( Count);
                        ClearEvent( E);
                        end;
             end
          end
     else if E.What = evKeyPress
     then begin
          case E.KeyInfo.ScanCode
          of keyUP: begin
                    ManUp( motBoth, False);
                    {DisplayPos;}
                    ClearEvent( E);
                    end;
             keyDOWN: begin
                      ManDown( motBoth, False);
                      {DisplayPos;}
                      ClearEvent( E);
                      end;
             keyLEFT: begin
                      ManLeft( False);
                      {DisplayPos;}
                      ClearEvent( E);
                      end;
             keyRIGHT: begin
                       ManRight( False);
                       {DisplayPos;}
                       ClearEvent( E);
                       end;
             keyHOME: begin
                      ResetPos;
                      {DisplayPos;}
                      ClearEvent( E);
                      end;
             end;
          end;

     if E.What <> evNoThing
     then inherited HandleEvent( E);
end;

procedure TRunDlg.GetAvailableCommands( var ACommands: TCommandsSet);
begin
     ACommands := ACommands + [ cmGo, cmManUp, cmManDown, cmManLeft, cmManRight, cmResetPos, cmGoCount];
     inherited GetAvailableCommands( ACommands);
end;

function TRunDlg.DialogExitQuery( AAccept: Boolean): Boolean;
var E: TEvent;
begin
     if AAccept
     then DialogExitQuery := False
     else begin
          if TheMachine.IsBusy
          then begin
               E.What := evCommand;
               E.Command := cmStopMachine;
               PushEvent( E);
               DialogExitQuery := False;
               end
          else begin
               DialogExitQuery := True;
               end;
          end;
end;

procedure TRunDlg.ChildNotify( AChild: PWindow);
begin
     if (Pointer(AChild) = Pointer(SpeedScroll))
     then begin
          if ( MachineSettings <> nil)
          then begin
               MachineSettings^.SurfaceSpeed := Round(SpeedScroll^.GetValue * ( ANALOG_SPEED_RANGE / 100));
               TheMachine.SetFeedSpeed( MachineSettings^.GetFeedSpeed);
               end;
          end;
end;

{procedure TRunDlg.DisplayPos;
var S: string;
begin
     Str( TheMachine.HeadXPos, S);
     List^.WriteLn( 'X = ' + S);
     Str( TheMachine.HeadYPos, S);
     List^.WriteLn( 'Y = ' + S);
end;
}

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TConfigurationDlg.Create;
var R: TRect;
    S: TPoint;
    Panel: PJustFrame;
begin
     S.Assign( 510, 350);
     inherited Create( S, 'Configuration');
     Lock;

     GetClientRect( R);
     R.B.X := R.B.X - R.A.X - 140;
     R.B.Y := R.B.Y - R.A.Y - 10;
     R.A.X := 10;
     R.A.Y := 125;

     Panel := New( PJustFrame, Create( R));
     InsertChild( Panel);
     Panel^.GetClientRect( R);
     R.A.X := 0;
     R.A.Y := 0;
     R.B.X := R.B.X - R.A.X - 1;
     R.B.Y := R.B.Y - R.A.Y - 1;
     List := New( PTextList, Create(R));
     Panel^.InsertChild( List);

     R.A.Assign( 370, 125);
     StatePanel := New( PMachineStatePanel, Create( R.A));
     InsertChild( StatePanel);

     InsertChild( New( PButton, Create( 80, 10, 70 + metSHADOWSIZE, 30, '&Up', cmManUp, keyU)));
     InsertChild( New( PButton, Create( 10, 10, 60 + metSHADOWSIZE, 30, 'U.L.', cmManUpL, keyNONE)));
     InsertChild( New( PButton, Create( 160, 10, 60 + metSHADOWSIZE, 30, 'U.R.', cmManUpR, keyNONE)));
     InsertChild( New( PButton, Create( 10, 45, 100 + metSHADOWSIZE, 30, '&Left', cmManLeft, keyL)));
     InsertChild( New( PButton, Create( 120, 45, 100 + metSHADOWSIZE, 30, '&Right', cmManRight, keyR)));
     InsertChild( New( PButton, Create( 80, 80, 70 + metSHADOWSIZE, 30, '&Down', cmManDown, keyD)));
     InsertChild( New( PButton, Create( 10, 80, 60 + metSHADOWSIZE, 30, 'D.L.', cmManDownL, keyNONE)));
     InsertChild( New( PButton, Create( 160, 80, 60 + metSHADOWSIZE, 30, 'D.R.', cmManDownR, keyNONE)));

     InsertChild( New( PButton, Create( 255, 10, 100 + metSHADOWSIZE, 30, '&Measure', cmRunMeasurments, keyM)));
     InsertChild( New( PButton, Create( 255, 45, 100 + metSHADOWSIZE, 30, 'Sa&ve Cfg.', cmSaveSettings, keyV)));
     InsertChild( New( PButton, Create( 255, 80, 100 + metSHADOWSIZE, 30, 'L&oad Cfg.', cmRestoreLastMeasurments, keyO)));

     InsertChild( New( PButton, Create( 385, 10, 100 + metSHADOWSIZE, 30, '&Stop', cmStopMachine, keyS)));
     InsertChild( New( PButton, Create( 385, 45, 100 + metSHADOWSIZE, 30, '&Reset pos.', cmResetPos, keyR)));
     InsertChild( New( PButton, Create( 385, 80, 100 + metSHADOWSIZE, 30, '&Close', cmCancel, keyC)));
     Unselect;
     DisplayMeasurments( TheMachine.Measurements);
     UnLock;
     LastTask := 0;
end;

destructor TConfigurationDlg.Destroy;
begin
     inherited Destroy;
end;

procedure TConfigurationDlg.HandleEvent( var E: TEvent);
var Count: Longint;
    MotorsSel: TMotorsSel;
    SkipLimits: Boolean;
begin
     if E.What = evCommand
     then begin
          case E.Command
          of cmStopMachine: begin
                            TheMachine.StopRequest;
                            ClearEvent( E);
                            end;
             cmUpdateMachineStateView: begin
                                       StatePanel^.UpdateStateView( True);
                                       if not TheMachine.IsBusy
                                       then begin
                                            case LastTask
                                            of 1: begin
                                                  DisplayMeasurments( TheMachine.Measurements);
                                                  LastTask := 0;
                                                  end;
                                               end;
                                            end;
                                       ClearEvent( E);
                                       end;
             cmManUp: begin
                      ManUp( motBoth, True);
                      ClearEvent( E);
                      end;
             cmManUpL: begin
                       ManUp( motY2, True);
                       ClearEvent( E);
                       end;
             cmManUpR: begin
                       ManUp( motY1, True);
                       ClearEvent( E);
                       end;
             cmManDown: begin
                        ManDown( motBoth, True);
                        ClearEvent( E);
                        end;
             cmManDownL: begin
                         ManDown( motY2, True);
                         ClearEvent( E);
                         end;
             cmManDownR: begin
                         ManDown( motY1, True);
                         ClearEvent( E);
                         end;
             cmManLeft: begin
                        ManLeft( True);
                        ClearEvent( E);
                        end;
             cmSaveSettings: begin
                             ClearEvent( E);
                             if MessageYN( @Self, 'WARNING', 'Are you sure that you want to save new measurements?')
                             then TheMachine.SaveMeasurements;
                             end;
             cmManRight: begin
                         ManRight( True);
                         ClearEvent( E);
                         end;
             cmRunMeasurments: begin
                               RunMeasurements;
                               LastTask := 1;
                               end;
             cmResetPos: begin
                         ResetPos;
                         LastTask := 2;
                         end;
             cmRestoreLastMeasurments: begin
                                       if MessageYN( @Self, 'WARNING',
                                          'Are you sure that you want to restore lst measurments?')
                                       then begin
                                            TheMachine.LoadMeasurements;
                                            DisplayMeasurments( TheMachine.Measurements);
                                            end;
                                       end;
             end
          end
     else if E.What = evKeyPress
     then begin
          SkipLimits := True;
          case E.KeyInfo.ScanCode
          of keyUP: begin
                    if (( E.KeyInfo.ShiftStatus and shkLeftShiftDown) <> $0000)
                    then MotorsSel := motY2
                    else if (( E.KeyInfo.ShiftStatus and shkRightShiftDown) <> $0000)
                    then MotorsSel := motY1
                    else MotorsSel := motBoth;
                    ManUp( MotorsSel, SkipLimits);
                    ClearEvent( E);
                    end;
             keyDOWN: begin
                      if (( E.KeyInfo.ShiftStatus and shkLeftShiftDown) <> $0000)
                      then MotorsSel := motY2
                      else if (( E.KeyInfo.ShiftStatus and shkRightShiftDown) <> $0000)
                      then MotorsSel := motY1
                      else MotorsSel := motBoth;
                      ManDown( MotorsSel, SkipLimits);
                      ClearEvent( E);
                      end;
             keyLEFT: begin
                      ManLeft( SkipLimits);
                      ClearEvent( E);
                      end;
             keyRIGHT: begin
                       ManRight( SkipLimits);
                       ClearEvent( E);
                       end;
             end;
          end;

     if E.What <> evNoThing
     then inherited HandleEvent( E);
end;

procedure TConfigurationDlg.GetAvailableCommands( var ACommands: TCommandsSet);
begin
     ACommands := ACommands + [ cmManUp,
                                cmManDown,
                                cmManLeft,
                                cmManRight,
                                cmStopMachine,
                                cmUpdateMachineStateView];
     inherited GetAvailableCommands( ACommands);
end;

function TConfigurationDlg.ManUp( AYMotors: TMotorsSel; ASkipLimits: Boolean): Boolean;
begin
     if not TheMachine.IsBusy
     then begin
          if TheMachine.Engage
          then begin
               if TheMachine.ResetErrors
               then begin
                    if TheMachine.ForceMoveHead( 0, - PULSES_PER_MM_Y {* 5}, AYMotors, ASkipLimits{False})
                    then ManUp := True
                    else begin
                         ManUp := False
                         end;
                    end
               else begin
                    ManUp := False
                    end;
               TheMachine.Release;
               end
          else ManUp := False;
          end
     else ManUp := False;
     TheMachine.UpdateStateView;
end;

function TConfigurationDlg.ManDown( AYMotors: TMotorsSel; ASkipLimits: Boolean): Boolean;
begin
     if not TheMachine.IsBusy
     then begin
          if TheMachine.Engage
          then begin
               if TheMachine.ResetErrors
               then begin
                    TheMachine.ResetErrors;
                    if TheMachine.ForceMoveHead( 0, PULSES_PER_MM_Y {* 5}, AYMotors, ASkipLimits{False})
                    then ManDown := True
                    else begin
                         ManDown := False
                         end;
                    end
               else begin
                    ManDown := False
                    end;
               TheMachine.Release;
               end
          else ManDown := False;
          end
     else ManDown := False;
     TheMachine.UpdateStateView;
end;

function TConfigurationDlg.ManLeft( ASkipLimits: Boolean): Boolean;
begin
     if not TheMachine.IsBusy
     then begin
          if TheMachine.Engage
          then begin
               if TheMachine.ResetErrors
               then begin
                    TheMachine.ResetErrors;
                    if TheMachine.ForceMoveHead( - PULSES_PER_MM_X {* 5}, 0, motBoth, ASkipLimits{False})
                    then ManLeft := True
                    else begin
                         ManLeft := False
                         end;
                    end
               else begin
                    ManLeft := False
                    end;
               TheMachine.Release;
               end
          else ManLeft := False;
          end
     else ManLeft := False;
     TheMachine.UpdateStateView;
end;

function TConfigurationDlg.ManRight( ASkipLimits: Boolean): Boolean;
begin
     if not TheMachine.IsBusy
     then begin
          if TheMachine.Engage
          then begin
               if TheMachine.ResetErrors
               then begin
                    TheMachine.ResetErrors;
                    if TheMachine.ForceMoveHead( PULSES_PER_MM_X {* 5}, 0, motBoth, ASkipLimits{False})
                    then ManRight := True
                    else begin
                         ManRight := False
                         end;
                    end
               else begin
                    ManRight := False
                    end;
               TheMachine.Release;
               end
          else ManRight := False;
          end
     else ManRight := False;
     TheMachine.UpdateStateView;
end;

function TConfigurationDlg.DialogExitQuery( AAccept: Boolean): Boolean;
var E: TEvent;
begin
     if AAccept
     then DialogExitQuery := False
     else begin
          if TheMachine.IsBusy
          then begin
               E.What := evCommand;
               E.Command := cmStopMachine;
               PushEvent( E);
               DialogExitQuery := False;
               end
          else begin
               if TheMachine.AreChangedMeasurements
               then Message( @Self, 'WARNING', 'New mesaurements are not saved yet ...');
               DialogExitQuery := True;
               end;
          end;
end;

procedure TConfigurationDlg.DisplayMeasurments( var MachineMeasurments: TMachineMeasurments);
var S1: string;
    S2: string;
begin
     if ( List <> nil)
     then begin
          with MachineMeasurments
          do begin
             List^.WriteLn( '');
             Str( (SizeX / PULSES_PER_MM_X):0:2, S1);
             S2 := 'Window width : ' + S1 + ' mm.';
             List^.WriteLn( S2);
             Str( (SizeY / PULSES_PER_MM_Y):0:2, S1);
             S2 := 'Window height : ' + S1 + ' mm.';
             List^.WriteLn( S2);
             Str( ( HeadXCenterStart / PULSES_PER_MM_X):0:2, S1);
             Str( ( HeadXCenterEnd / PULSES_PER_MM_X):0:2, S2);
             S2 := 'Center X : ' + S1 + ' - ' + S2 + ' mm.';
             List^.WriteLn( S2);
             Str( ( HeadYCenterStart / PULSES_PER_MM_Y):0:2, S1);
             Str( ( HeadYCenterEnd / PULSES_PER_MM_Y):0:2, S2);
             S2 := 'Center Y : ' + S1 + ' - ' + S2 + ' mm.';
             List^.WriteLn( S2);
             {Str( (SpeedTimeFactor):0:3, S1);
             S2 := 'Feed speed to time factor : ' + S1;
             List^.WriteLn( S2);
             Str(( HeadXSpeed / TIMERUNIT):0:3, S1);
             S2 := 'Head speed on X : ' + S1 + ' mm./Sec.';
             List^.WriteLn( S2);
             Str(( HeadYSpeed / TIMERUNIT):0:3, S1);
             S2 := 'Head speed on Y : ' + S1 + ' mm./Sec.';
             List^.WriteLn( S2);}
             end;
          end;
end;

function TConfigurationDlg.ResetPos: Boolean;
begin
     if not TheMachine.IsBusy
     then begin
          List^.WriteLn( '');
          List^.WriteLn( 'Reseting head position ...');
          TheMachine.ClearActions;
{$IFDEF _USEPORTS}
          TheMachine.AppendAction( New( PAlarmAction, Create( 10, 200)));
          TheMachine.AppendAction( New( PDelayAction, Create( 45)));
{$ENDIF}
          TheMachine.AppendAction( New( PGotoFromZeroAction, Create( TheMachine.GetSizeX div 2,
                                                                     TheMachine.GetSizeY div 2)));
          TheMachine.AppendAction( New( PAlarmAction, Create( 5, 200)));
          if not TheMachine.RunActions
          then List^.WriteLn( 'ERROR: Unable to do reset pos action ...');
          end
     else begin
          List^.WriteLn( 'ERROR: Machine is busy ...');
          ResetPos := False;
          end;
     TheMachine.UpdateStateView;
end;

function TConfigurationDlg.RunMeasurements: Boolean;
begin
     if not TheMachine.IsBusy
     then begin
          List^.WriteLn( '');
          List^.WriteLn( 'Running measuring ...');
          TheMachine.ClearActions;
{$IFDEF _USEPORTS}

          TheMachine.AppendAction( New( PAlarmAction, Create( 10, 200)));
          TheMachine.AppendAction( New( PDelayAction, Create( 45)));
{$ENDIF}
          TheMachine.AppendAction( New( PDoMeasurmentAction, Create));
          TheMachine.AppendAction( New( PGotoFromZeroAction, Create( TheMachine.GetSizeX div 2,
                                                                     TheMachine.GetSizeY div 2)));
          TheMachine.AppendAction( New( PAlarmAction, Create( 5, 200)));
          if not TheMachine.RunActions
          then List^.WriteLn( 'ERROR: Unable to run reset measurment action ...');
          end
     else begin
          List^.WriteLn( 'ERROR: Machine is busy ...');
          RunMeasurements := False;
          end;
     TheMachine.UpdateStateView;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

begin
     IsTimePassed( True);
end.