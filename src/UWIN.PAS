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
{*  FILE: UWIN.PAS                                                         *}
{*                                                                         *}
{***************************************************************************}

unit UWin;

Interface

{DEFINE _DEBUG}

uses Graph, Strings, Generics, Crt, {UCrt,} WinDos, IntDriver;

{*************************************************************************}

const ofTopSelect           = $0001;
      ofCenteredX           = $0002;
      ofCenteredY           = $0004;
      ofCentered            = $0006;
      ofSelectable          = $0008;
      ofTopWindow           = $0010;
      ofFramed              = $0020;
      ofFirstClick          = $0040;
      ofMovable             = $0080;
      ofRedispachDragEvents = $0100;

{*************************************************************************}
      met3DFRAME            = 4;
      metTEXTWIDTH          = 8;
      metTEXTHEIGHT         = 8;
      metSHADOWSIZE         = 4;
      metCAPTIONHEIGHT      = 18;
      metMENUITEMHEIGHT     = 20;
      metLISTBOXITEMHEIGHT  = 20;
      mstSCROLLBTNWIDTH     = 30;
      mstCHECKBOXSIZE       = 25;

{*************************************************************************}

      sfEnabled             = $0001;
      sfSelected            = $0002;
      sfFocused             = $0004;
      sfModal               = $0008;
      sfVisible             = $0010;
      sfDrag                = $0020;
      sfExecuted            = $0040;
      sfMove                = $0080;
      sfResize              = $0100;

{*************************************************************************}

     PositionalEvent : Word  = evMouse;
     FocusedEvent    : Word  = evKeyPress or evCommand;

{*************************************************************************}

      cmNone              = 0;
      cmExitApplication   = 1;
      cmScrollUp          = 2;
      cmScrollDown        = 3;
      cmScrollLeft        = 4;
      cmScrollRight       = 5;
      cmScrollPageUp      = 6;
      cmScrollPageDown    = 7;
      cmScrollPageLeft    = 8;
      cmScrollPageRight   = 9;
      cmOk                = 10;
      cmCancel            = 11;
      cmSelectNext        = 12;
      cmSelectPrev        = 13;
      cmMenuBack         = 14;
      cmUserCommand       = 100;

{*************************************************************************}

      clr3D0                         = 1;{}
      clr3D1                         = 2;{}
      clr3D2                         = 3;{}
      clr3D3                         = 4;{}
      clr3DBACK                      = 5;{}
      clr3DTEXT                      = 6;{}
      clr3DTEXTINACTIVE              = 7;{}
      clrSHADOW                      = 8;{}
      clrCAPTION                     = 9;{}
      clrCAPTIONTEXT                 = 10;{}
      clrCAPTIONINACTIVE             = 11;{}
      clrLISTTEXT                    = 12;{}
      clrGUIDELINES                  = 13;{}
      clrGRID1                       = 14;
      clrGRID2                       = 15;
      clrCURSOR                      = 16;
      clrSELECTION                   = 17;
      clrBACKGROUND                  = 18;
      clrFIELDBACK                   = 19;
      clrFIELDBACKINACTIVE           = 20;
      clrFIELDTEXT                   = 21;
      clrFIELDTEXTINACTIVE           = 22;
      clrSHAPE                       = 23;
      clrSHAPESELECTED               = 24;

{*************************************************************************}

      cwsCOLSEABLE        = $01;
      cwsSIZEABLE         = $02;
      cwsMAXIMIZEABEL     = $04;
      cwsMINIMIZEABEL     = $08;

{*************************************************************************}

const {ViewDeltaX  : Integer = 0;
      ViewDeltaY  : Integer = 0;
      ViewSizeX   : Integer = 0;
      ViewSizeY   : Integer = 0;}
      DisplayLock : Integer = 0;

{*************************************************************************}




{*************************************************************************}

type PMenuItem = ^TMenuItem;
     TMenuItem = record
         Title: PString;
         Next: PMenuItem;
         Sub: PMenuItem;
         Key: Byte;
         Command: Word;
         Enabled: Boolean;
         end;

{*************************************************************************}

     PGroupWindow = ^TGroupWindow;

{*************************************************************************}

     PWindow = ^TWindow;
     TWindow = object( TGeneric)
          Options: Word;
          State: Word;
          Next, Prev: PWindow;
          Parent: PGroupWindow;
          Origin: TPoint;
          Size: TPoint;
          EventMask: Word;

          constructor Create( R: TRect);
          destructor Destroy; virtual;
          procedure ClearEvent( var E: TEvent); virtual;
          procedure HandleEvent( var E: TEvent); virtual;
          procedure SetState( AState: Word; Enable: Boolean); virtual;
          function GetState( AState: Word): Boolean; virtual;
          procedure SetOption( AOption: Word; Enable: Boolean); virtual;
          function GetOption( AOption: Word): Boolean; virtual;
          procedure RemoveFromChain; virtual;
          procedure Draw; virtual;
          procedure MakeLocal( var P: TPoint); virtual;
          procedure MakeGlobal( var P: TPoint); virtual;
          function ContainsPoint( P: TPoint): Boolean; virtual;
          procedure GetExposedRect(var R: TRect); virtual;
          procedure InitViewPort; virtual;
          procedure LoseFocus; virtual;
          procedure GainFocus; virtual;
          procedure DrawView; virtual;
          procedure Update; virtual;
          procedure Lock; virtual;
          procedure Unlock; virtual;
          procedure BeginDrag; virtual;
          procedure EndDrag; virtual;
          procedure GetEvent( var E: TEvent); virtual;
          procedure PutEvent(var E: TEvent); virtual;
          procedure RedispacheEvent( var E: TEvent); virtual;
          procedure Execute; virtual;
          procedure BeforeExecuteDlg; virtual;
          procedure AfterExecuteDlg; virtual;
          procedure ExecuteDlg( AParent: PWindow); virtual;
          procedure Move( P: TPoint); virtual;
          procedure BeginDraw;
          procedure EndDraw;
          procedure SetFocus;
          procedure SetPColor( AColor: Byte);
          function GetPColor( AColor: Byte): Byte;
          procedure SetPFillPattern( AColor: Byte; var AParrern: TFillPattern);
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
          procedure Draw3DBar( AX1, AY1, AX2, AY2: Integer; AClr0, AClr1, AClr2, AClr3: Integer);
          procedure Draw3DInBar( AX1, AY1, AX2, AY2: Integer; AClr0, AClr1, AClr2, AClr3: Integer);
          procedure Draw3DInFrame( AX1, AY1, AX2, AY2: Integer; AClr0, AClr1, AClr2, AClr3: Integer);
          procedure Draw3DOutFrame( AX1, AY1, AX2, AY2: Integer; AClr0, AClr1, AClr2, AClr3: Integer);
          procedure PutPixel( X, Y: Integer; Color: Word);
          procedure ScroolUp( APixels: Integer);
          procedure ScroolDown( APixels: Integer);
          procedure ScroolLeft( APixels: Integer);
          procedure ScroolRight( APixels: Integer);
          procedure ClearViewPort;
          {procedure SetViewPort( AX1, AY1, AX2, AY2: Integer; AClip: Boolean);}
          function IsGroupWindow: Boolean; virtual;
          procedure InsertTopWindow( W: PWindow); virtual;
          procedure GetAvailableCommands( var ACommands: TCommandsSet); virtual;
          procedure EnableCommands( var ACommands: TCommandsSet); virtual;
          procedure UpdateCommands; virtual;
          procedure DrawTradeMark( AX, AY: Integer);
          procedure ChildNotify( AChild: PWindow); virtual;
          function AbleToDraw: Boolean;
          end;

{*************************************************************************}

     TGroupWindow = object( TWindow)
        First, Current: PWindow;
        constructor Create( R:TRect);
        destructor Destroy; virtual;
        procedure InsertChild( W: PWindow); virtual;
        procedure InsertBefore( W1, W2: PWindow); virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure DrawView; virtual;
        procedure DrawChilds; virtual;
        procedure DrawChildsFrom( W: PWindow); virtual;
        procedure Select( W: PWindow); virtual;
        procedure Unselect; virtual;
        procedure SelectNext( W: PWindow); virtual;
        procedure SelectPrev( W: PWindow); virtual;
        procedure MakeTop( W: PWindow); virtual;
        procedure LoseFocus; virtual;
        procedure GainFocus; virtual;
        procedure ClientGetExposedRect( var R: TRect); virtual;
        procedure ClientMakeLocal( var P: TPoint); virtual;
        procedure ClientMakeGlobal( var P: TPoint); virtual;
        procedure GetClientRect( var R: TRect); virtual;
        procedure InitClientViewPort; virtual;
        function IsGroupWindow: Boolean; virtual;
        procedure InsertTopWindow( W: PWindow); virtual;
        procedure GetAvailableCommands( var ACommands: TCommandsSet); virtual;
        procedure EnableCommands( var ACommands: TCommandsSet); virtual;
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

     PMenu = ^TMenu;
     TMenu = object( TWindow)
        Menu: PMenuItem;
        Current: PMenuItem;
        LastItemNo: Integer;
        NumItems: Integer;
        constructor Create( AOrigin: TPoint; AMenu: PMenuItem);
        destructor Destroy; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure Draw; virtual;
        procedure CalcSize( var ASize: TPoint);
        function ItemsCount: Integer;
        {function CommandAvailable( ACommand: Word): Boolean; virtual;}
        end;

{*************************************************************************}

     PMenuBar = ^TMenuBar;
     TMenuBar = object( TWindow)
        Menu: PMenuItem;
        constructor Create( APos: TPoint; AMenu: PMenuItem);
        destructor Destroy; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        function GetPosItem( P: TPoint): PMenuItem; virtual;
        function GetItemRect( AItem: PMenuItem; var ARect: TRect): Boolean; virtual;
        procedure DisplayOptions;
        procedure Draw; virtual;
        procedure ModifyParentClientRect( var R: TRect); virtual;
        procedure EnableCommands( var ACommands: TCommandsSet); virtual;
        procedure UpdateCommandsEnabling; virtual;
        end;

{*************************************************************************}

     PDesktopClientsArea = ^TDesktopClientsArea;
     TDesktopClientsArea = object( TGroupWindow)
        constructor Create( R: TRect);
        procedure Draw; virtual;
        end;

{*************************************************************************}

     PDeskTop = ^TDeskTop;
     TDeskTop = object( TGroupWindow)
        Title: PString;
        ClientArea: PDesktopClientsArea;
        MenuBar: PMenuBar;
        constructor Create( ATitle: string; AMenu: PMenuItem);
        destructor Destroy; virtual;
        procedure Draw; virtual;
        procedure GetClientRect( var R: TRect); virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure InsertTopWindow( W: PWindow); virtual;
        function CreateClientsArea( var R: TRect): PDesktopClientsArea; virtual;
        procedure GetAvailableCommands( var ACommands: TCommandsSet); virtual;
        {procedure UpdateCommands; virtual;}
        {function CommandAvailable( ACommand: Word): Boolean; virtual;}
        end;

{*************************************************************************}

     PApplication = ^TApplication;
     TApplication = object( TGeneric)
        Desktop: PDeskTop;
        constructor Create;
        destructor Destroy; virtual;
        procedure Run; virtual;
        function CreateDesktop: PDeskTop; virtual;
        end;

{*************************************************************************}

     PButton = ^TButton;
     TButton = object( TWindow)
        Title: PString;
        Command: Word;
        Key: Byte;
        constructor Create( X, Y, W, H: Integer; ATitle: string; ACommand: Word; AKey: Byte);
        destructor Destroy; virtual;
        {procedure DrawFrame; virtual;}
        procedure DrawDown; virtual;
        procedure DrawUp; virtual;
        procedure Draw; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        function ContainsPoint( P: TPoint): Boolean; virtual;
        end;

{*************************************************************************}

     PScrollBar = ^TScrollBar;
     TScrollBar = object( TWindow)
        LineMagnitude: Integer;
        PageMagnitude: Integer;
        Pos: Integer;
        Window: PWindow;
        Vertical: Boolean;
        UpBtn: TRect;
        DownBtn: TRect;
        TuchPos: TPoint;
        constructor Create( R: TRect; P: PWindow; AVertical: Boolean; ALineMagnitude, APageMagnitude, APos: Integer);
        procedure HandleEvent( var E: TEvent); virtual;
        procedure Draw; virtual;
        procedure ScrollTo( APos: Integer); virtual;
        procedure ScrollUp; virtual;
        procedure ScrollDown; virtual;
        procedure ScrollPageUp; virtual;
        procedure ScrollPageDown; virtual;
        end;

{*************************************************************************}

const MaxStackSize = 10;

{*************************************************************************}

type TPathStack = object( TGeneric)
        Top: Integer;
        Items: array[ 1..MaxStackSize] of PMenuItem;
        Titles: array[ 1..MaxStackSize] of PString;
        constructor Create;
        destructor Destroy; virtual;
        procedure Push( P: PMenuItem; ATitle: PString);
        procedure Pop( var P: PMenuItem; var ATitle: PString);
        function Empty: Boolean;
        end;

{*************************************************************************}

     PMenuList = ^TMenuList;
     TMenuList = object( TWindow)
        Menu: PMenuItem;
        Title: PString;
        Stack: TPathStack;
        Current: PMenuItem;
        CurrentTitle: PString;
        LastItemNo: Integer;
        NumItems: Integer;
        constructor Create( R: TRect; ATitle: string; AMenu: PMenuItem);
        destructor Destroy; virtual;
        procedure DrawItems( AInitViewPort: Boolean);
        procedure DisplayOptions;
        procedure Draw; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure UpdateCommandsEnabling; virtual;
        procedure EnableCommands( var ACommands: TCommandsSet); virtual;
        procedure GetAvailableCommands( var ACommands: TCommandsSet); virtual;
        end;

{*************************************************************************}

     PCaptionWindow = ^TCaptionWindow;
     TCaptionWindow = object( TGroupWindow)
        Caption: PString;
        TuchPos: TPoint;
        DragPos: TPoint;
        Style: Byte;
        constructor Create( ACaption: string; AOrigin: TPoint; ASize: TPoint);
        destructor Destroy; virtual;
        procedure Draw; virtual;
        procedure DrawFrame( AInitViewPort: Boolean); virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure GetClientRect( var R: TRect); virtual;
        procedure DrawDragFrame;
        function ContainsPoint( P: TPoint): Boolean; virtual;
        procedure Close; virtual;
        procedure LoseFocus; virtual;
        procedure GainFocus; virtual;
        function GetCaption: string; virtual;
        procedure ChildNotify( AChild: PWindow); virtual;
        end;

{*************************************************************************}

     PLabel = ^TLabel;
     TLabel = object( TGeneric)
     private
        Caption: PString;
        Origin: TPoint;
     public
        constructor Create( AX, AY: Integer; AStr: string);
        destructor Destroy; virtual;
        function GetCaption: string;
        function GetPosX: Integer; virtual;
        function GetPosY: Integer; virtual;
        end;

{*************************************************************************}

     PDialog = ^TDialog;
     TDialog = object( TGroupWindow)
     private
        Caption: PString;
        Labels: TContainerCollection;
     public
        constructor Create( ASize: TPoint; ACaption: string);
        destructor Destroy; virtual;
        procedure GetClientRect( var R: TRect); virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        function DialogExitQuery( AAccept: Boolean): Boolean; virtual;
        function ValidateData: Boolean; virtual;
        procedure Draw; virtual;
        procedure AddLabel( AX, AY: Integer; ACaption: string);
        procedure ChildNotify( AChild: PWindow); virtual;
        end;

{*************************************************************************}

     PAboutDlg = ^TAboutDlg;
     TAboutDlg = object( TDialog)
     public
        constructor Create( ACaption: string);
        end;

{*************************************************************************}

     PMessageDlg = ^TMessageDlg;
     TMessageDlg = object( TDialog)
     private
         Message: PString;
     public
         constructor Create( ACaption: string; AMessage: string);
         destructor Destroy; virtual;
         procedure Draw; virtual;
         end;

{*************************************************************************}

     PAskingDlg = ^TAskingDlg;
     TAskingDlg = object( TDialog)
     private
         Message: PString;
         Accept: Boolean;
     public
         constructor Create( ACaption: string; AMessage: string);
         destructor Destroy; virtual;
         procedure Draw; virtual;
         function DialogExitQuery( AAccept: Boolean): Boolean; virtual;
         function IsAccepted: Boolean;
         end;

{*************************************************************************}

     PEdit = ^TEdit;
     TEdit = object( TWindow)
     private
        Str: string;
        Pos: Word;
        MaxLength: Byte;

        function Insert( AChar: Char): Boolean;
        function OverWrite( AChar: Char): Boolean;
        function BackDel: Boolean;
        function Del: Boolean;
        function GoLeft: Boolean;
        function GoRight: Boolean;
        function GoHome: Boolean;
        function GoEnd: Boolean;
        procedure UpdateView( AActivateViewPort: Boolean);
     public
        constructor Create( AX, AY, AWidth: Integer; AMaxLength: Integer);
        destructor Destroy; virtual;
        procedure Draw; virtual;
        procedure LoseFocus; virtual;
        procedure GainFocus; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        function GetText: string;
        procedure SetText( AStr: string);
        function ValidateChar( AChar: Char): Boolean; virtual;
        function ValidateString: Boolean; virtual;
        end;

{*************************************************************************}

     PIntegerEdit = ^TIntegerEdit;
     TIntegerEdit = object( TEdit)
     private
        MaxValue, MinValue: Longint;
     public
        constructor Create( AX, AY, AWidth: Integer; AMinValue, AMaxValue: Longint);
        function ValidateChar( AChar: Char): Boolean; virtual;
        function ValidateString: Boolean; virtual;
        procedure SetValue( AValue: Longint); virtual;
        function GetValue: Longint; virtual;
        end;

{*************************************************************************}

     PFloatEdit = ^TFloatEdit;
     TFloatEdit = object( TEdit)
     private
        MaxValue, MinValue: Float;
     public
        constructor Create( AX, AY, AWidth: Integer; AMinValue, AMaxValue: Float);
        function ValidateChar( AChar: Char): Boolean; virtual;
        function ValidateString: Boolean; virtual;
        procedure SetValue( AValue: Float); virtual;
        function GetValue: Float; virtual;
        end;

{*************************************************************************}

     PCheckBox = ^TCheckBox;
     TCheckBox = object( TWindow)
     private
        Value: Boolean;
     public
        constructor Create( AX, AY: Integer);
        procedure SetValue( AValue: Boolean);
        function GetValue: Boolean;
        procedure Draw; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        end;

{*************************************************************************}

     PTextListLine = ^TTextListLine;
     TTextListLine = object( TGeneric)
     private
        Str: PString;
     public
        constructor Create( AStr: string);
        destructor Destroy; virtual;
        function GetString: string;
        procedure SetString( AStr: string);
        end;

{*************************************************************************}

     PTextList = ^TTextList;
     TTextList = object( TWindow)
     private
        Lines: TContainerCollection;
        CursorPos: TPoint;
     public
        constructor Create( R: TRect);
        destructor Destroy; virtual;
        procedure Draw; virtual;
        procedure WriteLn( AStr: string);
        end;

{*************************************************************************}

     PListBoxListItem = ^TListBoxListItem;
     TListBoxListItem = object( TTextListLine)
        end;

{*************************************************************************}

     PListBox = ^TListBox;

     PListBoxList = ^TListBoxList;
     TListBoxList = object( TWindow)
     private
        Items: TContainerCollection;
        FirstVisibleItem: PListBoxListItem;
        LastVisibleItem: PListBoxListItem;
        SelectedItem: PListBoxListItem;
        SelectedItemViewNo: Integer;
        VisibleItemsCount: Integer;
        OwnerListBox: PListBox;
     public
        constructor Create( R: TRect; AOwnerListBox: PListBox);
        destructor Destroy; virtual;
        procedure Draw; virtual;
        procedure AddItem( AItem: PListBoxListItem; AUpdate: Boolean);
        procedure ClearItems;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure DrawSelectionFrame( AViewItemNo: Integer; ASelected: Boolean; AInitViewPort: Boolean);
        function GetViewItemNoByPos( APos: TPoint): Integer;
        procedure SelectItem( AItem: PListBoxListItem); virtual;
        end;

{*************************************************************************}

     TListBox = object( TGroupWindow)
     private
        List: PListBoxList;
        Scroller: PScrollBar;
     public
        constructor Create( R: TRect);
        destructor Destroy; virtual;
        procedure Draw; virtual;
        procedure AddItem( AItem: PListBoxListItem; AUpdate: Boolean);
        procedure ClearItems;
        procedure HandleEvent( var E: TEvent); virtual;
        procedure SelectItem( AItem: PListBoxListItem); virtual;
        end;

{*************************************************************************}

     PScrollControl = ^TScrollControl;
     TScrollControl = object( TWindow)
     private
        Range: Integer;
        Pos: Integer;
        TuchPos: TPoint;
        TuchBttn: Integer;
     public
        constructor Create( R: TRect; ARange: Integer; AValue: Integer);
        destructor Destroy; virtual;
        procedure Draw; virtual;
        procedure HandleEvent( var E: TEvent); virtual;
        function GetValue: Integer;
        procedure SetValue( AValue: Integer);
        end;

{*************************************************************************}

     PFileDlg = ^TFileDlg;

     TFileType = ( ftDir, ftFile);

     PFilesListBox = ^TFilesListBox;
     TFilesListBox = object( TListBox)
     private
        Dialog: PFileDlg;
        FilesType: TFileType;
     public
        constructor Create( ADialog: PFileDlg; R: TRect; AFilesType: TFileType);
        destructor Destroy; virtual;
        procedure FillWithFiles( AMask: string);
        procedure HandleEvent( var E: TEvent); virtual;
        procedure SelectItem( AItem: PListBoxListItem); virtual;
        end;

{*************************************************************************}

     TFileDlg = object( TDialog)
     private
        FileNameEdit: PEdit;
        FilterEdit: PEdit;
        FileName: string;
        FilePath: string;
        FileSelected: Boolean;
        FilesList: PFilesListBox;
        DirsList: PFilesListBox;
        StartPath: string;
        Open: Boolean;
        Extention: string;
     public
        constructor Create( ADefFileName: string; AOpen: Boolean; AExtention: string);
        procedure FillLists;
        procedure BeforeExecuteDlg; virtual;
        procedure AfterExecuteDlg; virtual;
        function ValidateData: Boolean; virtual;
        procedure SetFile( AFileName: string);
        procedure SetDir( ADirName: string);
        function GetFileNameFP: string;
        function GetFileName: string;
        function IsFileSelected: Boolean;
        end;

{*************************************************************************}

function NewMenuItem( ATitle: string; AKey: Byte; ACommand: Word; ASub: PMenuItem; ANext: PMenuItem): PMenuItem;
procedure EnableCommandsInMenuTree( P: PMenuItem; ACommands: TCommandsSet);
procedure FreeMenuTree( var P: PMenuItem);
procedure Message( AWindow: PWindow; ACaption: string; AMessage: string);
function MessageYN( AWindow: PWindow; ACaption: string; AMessage: string): Boolean;
function AddExtentionIfNeeded( AFullName: string; ADefaultName: string; AExtention: string): string;
function RetriveFilePath( AFullName: string): string;
function RetriveFileName( AFullName: string): string;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

{$IFDEF _DEBUG}

var DebugFile: Text;

{$ENDIF}

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

Implementation

const
      PALETTESIZE = 24;

type PPalette = ^TPalette;
     TPalette = array[1..PALETTESIZE] of Byte;

const Palette: TPalette = (

      {clr3D0                         = 1;}0,
      {clr3D1                         = 2;}1,
      {clr3D2                         = 3;}2,
      {clr3D3                         = 4;}3,
      {clr3DBACK                      = 5;}2,
      {clr3DTEXT                      = 6;}8{15},
      {clr3DTEXTINACTIVE              = 7;}1,
      {clrSHADOW                      = 5;}0,
      {clrCAPTION                     = 6;}1,
      {clrCAPTIONTEXT                 = 7;}4{7}{8},{15}
      {clrCAPTIONINACTIVE             = 8;}2,
      {clrLISTTEXT                    = 9;}13,
      {clrGUIDELINES                  = 22;}6,
      {clrGRID1                       = 24;}2,
      {clrGRID2                       = 24;}2,
      {clrCURSOR                      = 29;}6,
      {clrSELECTION                   = 34;}6,
      {clrBACKGROUND                  = 36;}9{14},
      {clrFIELDBACK                   = 38;}4,
      {clrFIELDBACKINACTIVE           = 39;}3,
      {clrFIELDTEXT                   = 40;}0,
      {clrFIELDTEXTINACTIVE           = 41;}2,
      {clrSHAPE                       = 23;}7,
      {clrSHAPESELECTED               = 24;}15
     );

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TWindow.Create( R: TRect);
begin
     inherited Create;
     Parent := nil;
     Next := nil;
     Prev := nil;

     State := 0;
     Options := 0;

     Origin.X := R.A.X;
     Origin.Y := R.A.Y;
     Size.X := R.B.X - R.A.X;
     Size.Y := R.B.Y - R.A.Y;

     EventMask := $00;
end;

destructor TWindow.Destroy;
begin
     Lock;
     if ( Parent <> nil)
     then if ( Parent^.Current = @Self)
          then begin
               Parent^.SelectNext( @Self)
               end;
     Unlock;
     RemoveFromChain;
     inherited Destroy;
end;

procedure TWindow.Move( P: TPoint);
begin
     Origin := P;
     if ( Parent <> nil)
     then Parent^.DrawView
     else DrawView;
end;

procedure TWindow.BeginDraw;
begin
     TheScreen.HideMouseCursor;
     TheScreen.PushViewPortInfo;
     InitViewPort;
     SetWriteMode( NormalPut);
end;

procedure TWindow.EndDraw;
begin
     TheScreen.PopViewPortInfo;
     TheScreen.ShowMouseCursor;
end;

procedure TWindow.Execute;
var E: TEvent;
begin
     SetState( sfExecuted, True);
     repeat
        GetEvent( E);
        HandleEvent( E);
     until not GetState( sfExecuted);
end;

procedure TWindow.BeforeExecuteDlg;
begin
end;

procedure TWindow.AfterExecuteDlg;
begin
end;

procedure TWindow.ExecuteDlg( AParent: PWindow);
var BackImage: PScreenImage;
    OldParent: PGroupWindow;
    OldCurrent: PWindow;
    ScanParent: PGroupWindow;
    R: TRect;
begin
     if (AParent <> nil)
     then begin
          if AParent^.IsGroupWindow
          then ScanParent := PGroupWindow( AParent)
          else ScanParent := AParent^.Parent;

          while ( ScanParent <> nil)
          do begin
             if ScanParent^.GetOption( ofTopWindow)
             then Break
             else ScanParent := ScanParent^.Parent;
             end;

          if ( ScanParent <> nil)
          then begin
               OldParent := Parent;
               Parent := ScanParent;
               OldCurrent := Parent^.Current;
               Parent^.Current := @Self;
               Parent^.GetClientRect( R);
               if GetOption( ofCenteredX)
               then Origin.X := ( R.B.X - R.A.X - Size.X) div 2;
               if GetOption( ofCenteredY)
               then Origin.Y := ( R.B.Y - R.A.Y - Size.Y) div 2;
               BackImage := New( PScreenImage, Create);
               Parent^.InitClientViewPort;
               Lock;
               TheScreen.HideMouseCursor;
               BackImage^.Get( Origin.X, Origin.Y, Origin.X + Size.X - 1, Origin.Y + Size.Y - 1);
               TheScreen.ShowMouseCursor;
               BeforeExecuteDlg;
               GainFocus;
               Unlock;
               DrawView;
               Execute;
               Lock;
               AfterExecuteDlg;
               Unlock;
               Parent^.InitClientViewPort;
               TheScreen.HideMouseCursor;
               BackImage^.Put( Origin.X, Origin.Y);
               TheScreen.ShowMouseCursor;
               BackImage^.Free;
               Parent^.Current := OldCurrent;
               Parent := OldParent;
               end;
          end;
end;

procedure TWindow.BeginDrag;
var E:TEvent;
begin
     SetState( sfDrag, True);
     repeat
        GetEvent( E);
        HandleEvent( E);

        if E.What <> evNothing
        then begin
             if GetOption( ofRedispachDragEvents)
             then RedispacheEvent( E);
             end;
     until not GetState( sfDrag);
end;


procedure TWindow.EndDrag;
begin
     SetState( sfDrag, False);
end;

procedure TWindow.GetEvent( var E: TEvent);
begin
     if ( Parent<> nil)
     then begin
          Parent^.GetEvent( E);
          end
     else begin
          if GetOption( ofTopWindow)
          then WaitEvent( E);
          end;
end;

procedure TWindow.PutEvent( var E: TEvent);
begin
     if ( Parent <> nil)
     then begin
          Parent^.PutEvent( E);
          end
     else begin
          if GetOption( ofTopWindow)
          then PushEvent( E);
          end;
end;

procedure TWindow.RedispacheEvent( var E: TEvent);
begin
     if ( Parent <> nil)
     then begin
          Parent^.RedispacheEvent( E);
          end
     else begin
          if (( E.What <> evNothing) and GetOption( ofTopWindow))
          then HandleEvent( E);
          end;
end;

procedure TWindow.Lock;
begin
     DisplayLock := DisplayLock + 1;
end;

procedure TWindow.Unlock;
begin
     DisplayLock := DisplayLock - 1;
end;

procedure TWindow.DrawView;
begin
     if ( AbleToDraw)
     then begin
          Draw;
          end;
end;

procedure TWindow.Update;
begin
     if (( Parent <> nil) or ( GetOption( ofTopWindow)))
     then DrawView;
end;

procedure TWindow.LoseFocus;
begin
     SetState( sfFocused, False);
end;

procedure TWindow.GainFocus;
begin
     SetState( sfFocused, True);
end;

procedure TWindow.InitViewPort;
var R: TRect;
    Offset: TPoint;
begin
     GetExposedRect( R);
     R.B.X := R.B.X - 1;
     R.B.Y := R.B.Y - 1;
     MakeGlobal( R.A);
     MakeGlobal( R.B);
     Offset.Assign( 0, 0);
     MakeGlobal( Offset);
     TheScreen.SetViewPortRange( R, Offset);
end;

procedure TWindow.GetExposedRect( var R:TRect);
var OwnerExposedRect: TRect;
begin
     if GetState( sfVisible)
     then begin
          if Parent<>nil
          then begin
               Parent^.ClientGetExposedRect( OwnerExposedRect);
               if Origin.X >= OwnerExposedRect.A.X
               then R.A.X := 0
               else R.A.X := OwnerExposedRect.A.X - Origin.X;

               if Origin.Y >= OwnerExposedRect.A.Y
               then R.A.Y := 0
               else R.A.Y := OwnerExposedRect.A.Y - Origin.Y;

               if (( Origin.X + Size.X) < OwnerExposedRect.B.X)
               then R.B.X := Size.X
               else R.B.X := OwnerExposedRect.B.X - Origin.X;

               if (( Origin.Y + Size.Y) < OwnerExposedRect.B.Y)
               then R.B.Y := Size.Y
               else R.B.Y := OwnerExposedRect.B.Y - Origin.Y;

               end
          else if GetOption( ofTopWindow)
               then begin
                    R.A.X := 0;
                    R.A.Y := 0;
                    R.B := Size;
                    end
               else begin
                    R.A.X := 0;
                    R.A.Y := 0;
                    R.B := R.A;
                    end;
          end
     else begin
          R.A.X := 0;
          R.A.Y := 0;
          R.B := R.A;
          end;
end;

procedure TWindow.ClearEvent( var E: TEvent);
begin
     E.What := evNoThing;
     E.Info := @Self;
end;

procedure TWindow.HandleEvent( var E: TEvent);
begin
end;

procedure TWindow.SetState( AState: Word; Enable: Boolean);
begin
     if Enable
     then State := State or AState
     else State := State and not AState;
end;

function TWindow.GetState( AState: Word): Boolean;
begin
     GetState := (( State and AState) = AState);
end;

procedure TWindow.SetOption( AOption: Word; Enable: Boolean);
begin
     if Enable
     then Options := Options or AOption
     else Options := Options and not AOption
end;

function TWindow.GetOption( AOption: Word): Boolean;
begin
     GetOption := (( Options and AOption) = AOption);
end;

procedure TWindow.RemoveFromChain;
begin
     if ( Parent<>nil)
     then begin
          if Parent^.Current = @Self
          then Parent^.Current := nil;
          if ( Parent^.First = @Self)
          then begin
               if ( Next <> @Self)
               then Parent^.First := Next
               else Parent^.First := nil;
               end;

          if ( Next <> nil)
          then Next^.Prev := Prev;

          if ( Prev <> nil)
          then Prev^.Next := Next;

          {Parent^.Current := Parent^.First;}{?....}
          {Parent^.SelectNext( Prev);}
          Parent^.DrawView;
          Prev := nil;
          Next := nil;
          Parent := nil;
          end;
end;

procedure TWindow.Draw;
begin
end;

procedure TWindow.MakeLocal( var P: TPoint);
begin
     if ( Parent <> nil)
     then Parent^.ClientMakeLocal( P);
     P.X := P.X - Origin.X;
     P.Y := P.Y - Origin.Y;
end;

procedure TWindow.MakeGlobal( var P: TPoint);
begin
     if ( Parent <> nil)
     then Parent^.ClientMakeGlobal( P);
     P.X := P.X + Origin.X;
     P.Y := P.Y + Origin.Y;
end;

function TWindow.ContainsPoint( P: TPoint): Boolean;
begin
     if GetState( sfVisible)
     then begin
          MakeLocal( P);
          ContainsPoint := ( P.X >= 0) and ( P.Y >= 0) and ( P.X < Size.X) and ( P.Y < Size.Y);
          end
     else begin
          ContainsPoint := False;
          end;
end;

procedure TWindow.SetPColor( AColor: Byte);
begin
     Graph.SetColor( Palette[AColor]);
end;

function TWindow.GetPColor( AColor: Byte): Byte;
begin
     GetPColor := Palette[AColor];
end;

procedure TWindow.SetPFillPattern( AColor: Byte; var AParrern: FillPatternType);
begin
     Graph.SetFillPattern( AParrern, Palette[AColor]);
end;

function TWindow.TextWidth( AStr: string): Word;
begin
     TextWidth := Graph.TextWidth( AStr);
end;

function TWindow.TextWidthEx( AStr: string): Word;
var UPos: Integer;
begin
     UPos := Pos( '&', AStr);
     if ( UPos > 0)
     then TextWidthEx := Graph.TextWidth( AStr) - Graph.TextWidth( '&')
     else TextWidthEx := Graph.TextWidth( AStr);
end;

procedure TWindow.OutTextXY( AX, AY: Integer; AStr: string);
begin
     TheScreen.OutTextXY( AX, AY, AStr);
end;

procedure TWindow.OutTextXYEx( AX, AY: Integer; AStr: string);
var S: string;
    UPos: Integer;
    Len: Integer;
begin
     TheScreen.OutTextXYEx( AX, AY, AStr);
end;

procedure TWindow.OutFramedTextXY( AX, AY: Integer; AStr: string; ATextColor, AFrameColor: Integer);
begin
     TheScreen.OutFramedTextXY( AX, AY, AStr, ATextColor, AFrameColor);
end;


procedure TWindow.MoveTo( AX, AY: Integer);
begin
     TheScreen.MoveTo( AX, AY);
end;

procedure TWindow.OutText( AStr: string);
begin
     TheScreen.OutText( AStr);
end;

procedure TWindow.SetFocus;
begin
     if not GetState( sfFocused)
     then begin
          if ( Parent <> nil)
          then begin
               Parent^.SetFocus;
               if not GetState( sfFocused)
               then Parent^.Select( @Self);
               end;
          end;
end;


procedure TWindow.Pixel( X1, Y1: Integer; AColor: Integer);
begin
     TheScreen.Pixel( X1, Y1, AColor);
end;

procedure TWindow.Line( X1, Y1, X2, Y2: Integer);
begin
     TheScreen.Line( X1, Y1, X2, Y2);
end;

procedure TWindow.Arc( AX, AY, AStartAngle, AStopAngle, ARadius: Integer);
begin
     TheScreen.Arc( AX, AY, AStartAngle, AStopAngle, ARadius);
end;

procedure TWindow.ArcEx( AX, AY: Integer; AStartAngle, AStopAngle, AStartRadius, AStopRadius: Float);
begin
     TheScreen.ArcEx( AX, AY, AStartAngle, AStopAngle, AStartRadius, AStopRadius);
end;

procedure TWindow.Circle( X1, Y1, R: Integer);
begin
     TheScreen.Circle( X1, Y1, R);
end;

procedure TWindow.Rectangle( X1, Y1, X2, Y2: Integer);
begin
     TheScreen.Rectangle( X1, Y1, X2, Y2);
end;

procedure TWindow.Bar( X1, Y1, X2, Y2: Integer);
begin
     TheScreen.Bar( X1, Y1, X2, Y2);
end;

procedure TWindow.Draw3DBar( AX1, AY1, AX2, AY2: Integer; AClr0, AClr1, AClr2, AClr3: Integer);
begin
     SetPFillPattern( AClr2, SolidPattern);
     Bar( AX1, AY1, AX2, AY2);
     SetPColor( AClr3);
     Line( AX1 + 1, AY1 + 1, AX2 - 1, AY1 + 1);
     Line( AX1 + 1, AY1 + 1, AX1 + 1, AY2 - 1);
     SetPColor( AClr1);
     Line( AX2 - 1, AY1 + 1, AX2 - 1, AY2 - 1);
     Line( AX1 + 1, AY2 - 1, AX2 - 1, AY2 - 1);
     SetPColor( AClr0);
     Line( AX2 - 0, AY1 + 0, AX2 - 0, AY2 - 0);
     Line( AX1 + 0, AY2 - 0, AX2 - 0, AY2 - 0);
end;

procedure TWindow.Draw3DInBar( AX1, AY1, AX2, AY2: Integer; AClr0, AClr1, AClr2, AClr3: Integer);
begin
     SetPFillPattern( AClr2, SolidPattern);
     Bar( AX1, AY1, AX2, AY2);
     SetPColor( AClr1);
     Line( AX1, AY1, AX2, AY1);
     Line( AX1, AY1, AX1, AY2);
     SetPColor( AClr0);
     Line( AX1 + 1, AY1 + 1, AX2 - 1, AY1 + 1);
     Line( AX1 + 1, AY1 + 1, AX1 + 1, AY2 - 1);
     SetPColor( AClr3);
     Line( AX2, AY1, AX2, AY2);
     Line( AX1, AY2, AX2, AY2);
end;

procedure TWindow.Draw3DInFrame( AX1, AY1, AX2, AY2: Integer; AClr0, AClr1, AClr2, AClr3: Integer);
begin
     SetPColor( AClr1);
     Line( AX1, AY1, AX2, AY1);
     Line( AX1, AY1, AX1, AY2);
     SetPColor( AClr0);
     Line( AX1 + 1, AY1 + 1, AX2 - 1, AY1 + 1);
     Line( AX1 + 1, AY1 + 1, AX1 + 1, AY2 - 1);
     SetPColor( AClr2);
     Line( AX2 - 1, AY1 + 1, AX2 - 1, AY2 - 1);
     Line( AX1 + 1, AY2 - 1, AX2 - 1, AY2 - 1);
     SetPColor( AClr3);
     Line( AX2, AY1, AX2, AY2);
     Line( AX1, AY2, AX2, AY2);
end;

procedure TWindow.Draw3DOutFrame( AX1, AY1, AX2, AY2: Integer; AClr0, AClr1, AClr2, AClr3: Integer);
begin
     SetPColor( AClr2);
     Line( AX1, AY1, AX2, AY1);
     Line( AX1, AY1, AX1, AY2);
     SetPColor( AClr3);
     Line( AX1 + 1, AY1 + 1, AX2 - 1, AY1 + 1);
     Line( AX1 + 1, AY1 + 1, AX1 + 1, AY2 - 1);
     SetPColor( AClr1);
     Line( AX2 - 1, AY1 + 1, AX2 - 1, AY2 - 1);
     Line( AX1 + 1, AY2 - 1, AX2 - 1, AY2 - 1);
     SetPColor( AClr0);
     Line( AX2, AY1, AX2, AY2);
     Line( AX1, AY2, AX2, AY2);
end;

procedure TWindow.PutPixel( X, Y: Integer; Color: Word);
begin
     TheScreen.PutPixel( X, Y, Color);
end;

procedure TWindow.ScroolUp( APixels: Integer);
begin
     TheScreen.ScroolUp( APixels);
end;

procedure TWindow.ScroolDown( APixels: Integer);
begin
     TheScreen.ScroolDown( APixels);
end;

procedure TWindow.ScroolLeft( APixels: Integer);
begin
     TheScreen.ScroolLeft( APixels);
end;

procedure TWindow.ScroolRight( APixels: Integer);
begin
     TheScreen.ScroolRight( APixels);
end;

procedure TWindow.ClearViewPort;
begin
     TheScreen.ClearViewPort;
end;

function TWindow.IsGroupWindow: Boolean;
begin
     IsGroupWindow := False;
end;

procedure TWindow.InsertTopWindow( W: PWindow);
begin
     if ( Parent <> nil)
     then Parent^.InsertTopWindow( W);
end;

procedure TWindow.GetAvailableCommands( var ACommands: TCommandsSet);
begin
end;

procedure TWindow.EnableCommands( var ACommands: TCommandsSet);
begin
end;

procedure TWindow.UpdateCommands;
var Commands: TCommandsSet;
begin
     if ( Parent <> nil)
     then Parent^.UpdateCommands
     else begin
          if GetOption( ofTopWindow)
          then begin
               Commands := [];
               GetAvailableCommands( Commands);
               EnableCommands( Commands);
               end;
          end;
end;

{function TWindow.CommandAvailable( ACommand: Word): Boolean;
begin
     CommandAvailable := False;
end;

function TWindow.AskForCommand( ACommand: Word): Boolean;
begin
     if ( Parent <> nil)
     then AskForCommand := Parent^.AskForCommand( ACommand)
     else begin
          if GetOption( ofTopWindow)
          then AskForCommand := CommandAvailable( ACommand);
          end;
end;

procedure TWindow.UpdateCommands;
begin
     if ( Parent <> nil)
     then Parent^.UpdateCommands
     else begin
          if GetOption( ofTopWindow)
          then UpdateCommandsEnabling;
          end;
end;

procedure TWindow.UpdateCommandsEnabling;
begin
end;}

procedure TWindow.DrawTradeMark( AX, AY: Integer);
begin
     SetColor( 0);
     OutTextXY( AX + 1, AY + 1, 'Ultra');
     OutTextXY( AX + 42 + 1, AY + 1, 'Soft');
     SetColor( 6);
     OutTextXY( AX, AY, 'Ultra');
     SetColor( 15);
     OutTextXY( AX + 42, AY, 'Soft');
end;

procedure TWindow.ChildNotify( AChild: PWindow);
begin
     if ( Parent <> nil)
     then Parent^.ChildNotify( AChild);
end;

function TWindow.AbleToDraw: Boolean;
begin
     if DisplayLock <= 0
     then begin
          if GetState( sfVisible)
          then AbleToDraw := True
          else AbleToDraw := False;
          end
     else AbleToDraw := False
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TGroupWindow.Create( R: TRect);
begin
     inherited Create( R);
     First := nil;
     Current := nil;
end;

procedure TGroupWindow.GetClientRect( var R: TRect);
begin
     R.A.X := 0;
     R.A.Y := 0;
     R.B.X := Size.X;
     R.B.Y := Size.Y;
end;

procedure TGroupWindow.ClientMakeLocal( var P: TPoint);
var ClientRect: TRect;
begin
     if ( Parent <> nil)
     then Parent^.ClientMakeLocal( P);
     GetClientRect( ClientRect);
     P.X := P.X - Origin.X - ClientRect.A.X;
     P.Y := P.Y - Origin.Y - ClientRect.A.Y;
end;

procedure TGroupWindow.ClientMakeGlobal( var P: TPoint);
var ClientRect: TRect;
begin
     if ( Parent <> nil)
     then Parent^.ClientMakeGlobal( P);
     GetClientRect( ClientRect);
     P.X := P.X + Origin.X + ClientRect.A.X;
     P.Y := P.Y + Origin.Y + ClientRect.A.Y;
end;

procedure TGroupWindow.ClientGetExposedRect( var R: TRect);
var ClientRect: TRect;
begin
     GetExposedRect( R);
     GetClientRect( ClientRect);
     if GetOption( ofFramed)
     then begin
          if R.A.X > ClientRect.A.X
          then R.A.X := R.A.X - ClientRect.A.X
          else R.A.X := 0;

          if R.A.Y > ClientRect.A.Y
          then R.A.Y := R.A.Y - ClientRect.A.Y
          else R.A.Y := 0;

          if R.B.X > ClientRect.B.X
          then R.B.X := ClientRect.B.X - ClientRect.A.X
          else R.B.X := R.B.X - ClientRect.A.X;

          if R.B.Y > ClientRect.B.Y
          then R.B.Y := ClientRect.B.Y - ClientRect.A.Y
          else R.B.Y := R.B.Y - ClientRect.A.Y;
          end;
end;

procedure TGroupWindow.LoseFocus;
begin
     Lock;
     SetState( sfFocused, False);
     if ( Current <> nil)
     then Current^.LoseFocus;
     Unlock;
     DrawChilds;
end;

procedure TGroupWindow.GainFocus;
begin
     Lock;
     SetState( sfFocused, True);
     if ( Current <> nil)
     then Current^.GainFocus;
     Unlock;
     DrawChilds;
end;

procedure TGroupWindow.MakeTop( W: PWindow);
var WasCurrent: Boolean;
begin
     if ( W <> nil)
     then if ( W^.Parent = @Self)
          then if ( First <> W)
               then begin
                    Lock;
                    WasCurrent := Current = W;
                    W^.RemoveFromChain;
                    InsertBefore( W, First);
                    First := W;
                    if WasCurrent
                    then Current := W;
                    Unlock;
                    DrawChilds;
                    end;
end;

procedure TGroupWindow.Select( W:PWindow);
   procedure MakeCurrent;
   var Update: Boolean;
       LastCurrent: PWindow;
   begin
        Lock;
        Update := False;
        LastCurrent := Current;
        if (Current<>nil)
        then begin
             Current^.LoseFocus;
             Current^.SetState( sfSelected, False);
             Update := True;
             end;
        Current := W;
        Current^.SetState( sfSelected, True);
        if (GetState( sfFocused) and Current^.GetState( sfEnabled))
        then begin
             Current^.GainFocus;
             Update := True;
             end;

        if Current^.GetOption( ofTopSelect)
        then begin
             MakeTop( Current);
             Update := True;
             end;

        Unlock;

        if Update
        then if ( LastCurrent <> nil)
             then DrawChildsFrom( LastCurrent)
             else DrawChilds;
   end;

begin
     if ( W <> nil)
     then if (( W^.Parent = @Self) and ( W^.GetOption( ofSelectable)))
          then begin
               if ( Current = nil)
               then MakeCurrent
               else if not Current^.GetState( sfModal)
                    then MakeCurrent;
               end
end;

procedure TGroupWindow.Unselect;
var UpdateChilds: Boolean;
    LastCurrent: PWindow;
begin
     Lock;
     UpdateChilds := False;
     LastCurrent := Current;
     if (Current <> nil)
     then begin
          Current^.LoseFocus;
          Current^.SetState( sfSelected, False);
          UpdateChilds := True;
          end;

     Current := nil;
     Unlock;

     if UpdateChilds
     then if ( LastCurrent <> nil)
          then DrawChildsFrom( LastCurrent)
          else DrawChilds;
end;

procedure TGroupWindow.SelectNext( W: PWindow);
var Scan: PWindow;
begin
     if ( W <> nil)
     then begin
          if ( W^.Parent = @Self)
          then begin
               Scan := W^.Next;
               while (( Scan <> W) and ( Scan <> nil))
               do begin
                  if not Scan^.GetOption( ofSelectable)
                  then Scan := Scan^.Next
                  else Break;
                  end;
               if ( Scan <> nil)
               then Select( Scan);
               end;
          end;
end;

procedure TGroupWindow.SelectPrev( W: PWindow);
var Scan: PWindow;
begin
     if ( W <> nil)
     then begin
          if ( W^.Parent = @Self)
          then begin
               Scan := W^.Prev;
               while (( Scan <> W) and ( Scan <> nil))
               do begin
                  if not Scan^.GetOption( ofSelectable)
                  then Scan := Scan^.Prev
                  else Break;
                  end;
               if ( Scan <> nil)
               then Select( Scan);
               end;
          end;
end;

destructor TGroupWindow.Destroy;
begin
     Lock;
     while ( First <> nil)
     do First^.Free;
     UnLock;
     inherited Destroy;
end;

procedure TGroupWindow.InsertChild( W: PWindow);
begin
     if ( W <> nil)
     then begin
          Lock;
          W^.Parent := @Self;
          if ( First = nil)
          then begin
               First := W;
               W^.Next := W;
               W^.Prev := W;
               if ( W^.GetState( sfEnabled) and ( W^.GetOption( ofSelectable)))
               then begin
                    Current := W;
                    if GetState( sfFocused)
                    then W^.GainFocus;
                    end;
               end
          else begin
               W^.Next := First;
               W^.Prev := First^.Prev;

               W^.Next^.Prev := W;
               W^.Prev^.Next := W;
               if (( Current = nil) and ( W^.GetState( sfEnabled) and ( W^.GetOption( ofSelectable))))
               then begin
                    Current := W;
                    if GetState( sfFocused)
                    then W^.GainFocus;
                    end;
               end;
          Unlock;
          DrawChilds;
          end;
end;

procedure TGroupWindow.InsertBefore( W1, W2: PWindow);
begin
     if ( W2 = nil)
     then begin
          InsertChild( W1);
          DrawChilds;
          end
     else begin
          if (( W1 <> nil) and ( W2^.Parent = @Self))
          then begin
               W1^.Parent := @Self;
               W1^.Next := W2;
               W1^.Prev := W2^.Prev;

               W1^.Prev^.Next := W1;
               W1^.Next^.Prev := W1;
               DrawChilds;
               end;
          end;
end;

procedure TGroupWindow.HandleEvent( var E: TEvent);
var Temp: PWindow;
    TempPoint: TPoint;
begin
     if ( E.What <> evNothing)
     then begin
          if (( E.What and evMouse) <> 0)
          then begin
               if ( Current <> nil)
               then if ( Current^.ContainsPoint( E.MouseInfo.Where) and (( Current^.EventMask and E.What) <> 0))
                    then begin
                         Current^.HandleEvent( E);
                         if ( E.What <> evNothing)
                         then ClearEvent( E);
                         end;
               if (( E.What = evMouseDown) or ( Current = nil))
               then begin
                    Temp := First;
                    if ( Temp <> nil)
                    then repeat
                         if ( Temp^.ContainsPoint( E.MouseInfo.Where))
                         then begin
                              if ( Temp^.GetOption( ofSelectable) and GetState( sfFocused) and (E.What = evMouseDown))
                              then begin
                                   Select( Temp);
                                   if Temp^.GetOption( ofFirstClick) and (( Temp^.EventMask and E.What) <> 0)
                                   then Temp^.HandleEvent( E);
                                   end
                              else begin
                                   if (( Temp^.EventMask and E.What) <> 0)
                                   then Temp^.HandleEvent( E);
                                   end;

                              if ( E.What <> evNothing)
                              then ClearEvent( E);
                              end;
                         Temp := Temp^.Next;
                         until (( Temp = First) or ( E.What = evNothing))
                    end;
               end
          else if ( E.What = evCommand)
          then begin
               { This is the original command dispacher, and working properly

               if ( Current <> nil)
               then Current^.HandleEvent( E)
               else begin
                    Temp := First;
                    if (( Temp <> nil) and ( E.What <> evNothing))
                    then repeat
                         Temp^.HandleEvent( E);
                         Temp := Temp^.Next;
                         until (( Temp = First) or ( E.What = evNothing) or ( Temp = nil));
                    end;
               }

               { This is the modified command dispacher, and it is under test now }
               if ( Current <> nil)
               then Current^.HandleEvent( E);
               if E.What <> evNothing
               then begin
                    Temp := First;
                    if (( Temp <> nil) and ( E.What <> evNothing))
                    then repeat
                         Temp^.HandleEvent( E);
                         Temp := Temp^.Next;
                         until (( Temp = First) or ( E.What = evNothing) or ( Temp = nil));
                    end;

               end
          else begin
               {if ( Current<> nil)
               then if Current^.GetState( sfFocused)
                    then Current^.HandleEvent( E);}
               if ( Current<> nil)
               then Current^.HandleEvent( E);
               Temp := First;
               if (( Temp <> nil) and ( E.What <> evNothing))
               then repeat
                    Temp^.HandleEvent( E);
                    Temp := Temp^.Next;
                    until (( Temp = First) or ( E.What = evNothing) or ( Temp = nil));
               end
          end;
end;

procedure TGroupWindow.DrawChildsFrom( W: PWindow);
var Temp: PWindow;
begin
     if ( AbleToDraw)
     then begin
          TheScreen.HideMouseCursor;

          if ( W <> nil)
          then begin
               if ( W^.Parent = @Self)
               then Temp := W
               else Temp := nil
               end
          else Temp := nil;

          while ( Temp <> nil)
          do begin
             if ( Temp <> Current)
             then begin
                  Temp^.DrawView;
                  {Delay(300);}
                  end;

             if Temp = First
             then Temp := nil
             else Temp := Temp^.Prev;

             end;

          {Delay(300);}

          if ( Current <> nil)
          then Current^.DrawView;

          TheScreen.ShowMouseCursor;
          end;
end;

procedure TGroupWindow.DrawChilds;
var Temp: PWindow;
begin
     if ( AbleToDraw)
     then begin
          TheScreen.HideMouseCursor;

          if ( First <> nil)
          then Temp := First^.Prev
          else Temp := nil;

          while ( Temp <> nil)
          do begin
             if ( Temp <> Current)
             then Temp^.DrawView;

             if Temp = First
             then Temp := nil
             else Temp := Temp^.Prev;
             end;

          if ( Current <> nil)
          then Current^.DrawView;

          TheScreen.ShowMouseCursor;
          end;
end;

procedure TGroupWindow.DrawView;
begin
     {UpdateCommands;}
     inherited DrawView;
     DrawChilds;
end;

procedure TGroupWindow.InitClientViewPort;
var R, ClientRect: TRect;
    Offset: TPoint;
begin
     ClientGetExposedRect( R);
     GetClientRect( ClientRect);
     R.A.X := R.A.X + ClientRect.A.X;
     R.A.Y := R.A.Y + ClientRect.A.Y;
     R.B.X := R.B.X + ClientRect.A.X;
     R.B.Y := R.B.Y + ClientRect.A.Y;
     R.B.X := R.B.X - 1;
     R.B.Y := R.B.Y - 1;
     MakeGlobal( R.A);
     MakeGlobal( R.B);
     Offset := ClientRect.A;
     MakeGlobal( Offset);
     TheScreen.SetViewPortRange( R, Offset);
end;

function TGroupWindow.IsGroupWindow: Boolean;
begin
     IsGroupWindow := True;
end;

procedure TGroupWindow.InsertTopWindow( W: PWindow);
begin
     if ( Parent <> nil)
     then begin
          Parent^.InsertTopWindow( W);
          end
     else begin
          if GetOption( ofTopWindow)
          then InsertChild( W);
          end;
end;

procedure TGroupWindow.GetAvailableCommands( var ACommands: TCommandsSet);
var ScanChild: PWindow;
begin
     if ( Current <> nil)
     then Current^.GetAvailableCommands( ACommands)
     else begin
          if (First <> nil)
          then begin
               ScanChild := First;
               repeat
                     ScanChild^.GetAvailableCommands( ACommands);
                     ScanChild := ScanChild^.Next;
               until ( ScanChild = First);
               end;
          end;
end;

procedure TGroupWindow.EnableCommands( var ACommands: TCommandsSet);
var ScanChild: PWindow;
begin
     if (First <> nil)
     then begin
          ScanChild := First;
          repeat
                ScanChild^.EnableCommands( ACommands);
                ScanChild := ScanChild^.Next;
          until ( ScanChild = First);
          end;
end;


{function TGroupWindow.CommandAvailable( ACommand: Word): Boolean;
var ScanChild: PWindow;
begin
     if ( Current <> nil)
     then CommandAvailable := Current^.CommandAvailable( ACommand)
     else begin
          CommandAvailable := False;
          ScanChild := First;
          repeat
                if ScanChild^.CommandAvailable( ACommand)
                then begin
                     CommandAvailable := True;
                     Break;
                     end;
                ScanChild := ScanChild^.Next;
          until ( ScanChild = First);
          end;
end;

procedure TGroupWindow.UpdateCommandsEnabling;
var ScanChild: PWindow;
begin
     if (First <> nil)
     then begin
          ScanChild := First;
          repeat
                ScanChild^.UpdateCommandsEnabling;
                ScanChild := ScanChild^.Next;
          until ( ScanChild = First)
          end;
end;}

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TDesktopClientsArea.Create( R: TRect);
begin
     inherited Create( R);
     EventMask := $FF;
     State := sfVisible or sfEnabled or sfFocused or sfSelected;
     Options := ofSelectable;
end;

procedure TDesktopClientsArea.Draw;
var R: TRect;
    I: Integer;
begin
     BeginDraw;
     GetClientRect( R);
     SetPFillPattern( clrBACKGROUND, LightPattern);
     Bar( R.A.X, R.A.Y, R.B.X, R.B.Y);
     {for I := 0 to 15
     do begin
        SetFillPattern( SolidPattern, I);
        Bar( 0, I * 20, 100, I * 20 + 19);
        end;}
     EndDraw;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TDeskTop.Create( ATitle: string; AMenu: PMenuItem);
var R: TRect;
    Pos: TPoint;
begin
{$IFDEF _DEBUG}
     Assign( DebugFile, 'DEBUG.TXT');
     Rewrite( DebugFile);
{$ENDIF}
     R.A.Assign( 0, 0);
     R.B.Assign( GetMaxX + 1, GetMaxY + 1);
     inherited Create( R);
     EventMask := $FF;
     Options := ofTopWindow or ofFramed;
     State := sfVisible or sfEnabled or sfFocused {or sfSelected};
     Title := AllocateString( ATitle);
     Lock;
     GetClientRect( R);
     R.B.X := R.B.X - R.A.X;
     R.B.Y := R.B.Y - R.A.Y;
     R.A.Assign(0, 0);
     if ( AMenu <> nil)
     then begin
          Pos.Assign( 0, 0);
          MenuBar := New( PMenuBar, Create( Pos, AMenu));
          InsertChild( MenuBar);
          R.A.Assign( 0, MenuBar^.Size.Y);
          end
     else MenuBar := nil;

     ClientArea := CreateClientsArea( R);
     InsertChild( ClientArea);
     UnLock;
end;

procedure TDeskTop.Draw;
var R: TRect;
begin
     if ( Title <> nil)
     then begin
          BeginDraw;
          SetColor( 0);
          Rectangle( 1, 1, Size.X - 1, 25);
          SetColor( 2);
          Rectangle( 0, 0, Size.X - 2, 24);
          SetWriteMode( NormalPut);
          SetFillPattern( SolidPattern, 1);
          Bar( 2, 2, Size.X - 3, 23);
          SetTextStyle( 7, HorizDir,1);
          SetColor( 0);
          OutTextXY( 11, 1, Title^);
          SetColor( 14);
          OutTextXY( 10, 0, Title^);
          SetTextStyle( 0, HorizDir, 0);
          SetColor( 0);
          OutTextXY( 558 + 0, 9 + 1, 'UltraSoft');
          OutTextXY( 558 + 1, 9 + 0, 'UltraSoft');
          OutTextXY( 558 - 0, 9 - 1, 'UltraSoft');
          OutTextXY( 558 - 1, 9 - 0, 'UltraSoft');
          SetColor( 4);
          OutTextXY( 558 + 0, 9 + 0, 'Ultra');
          SetColor( 15);
          OutTextXY( 598 + 0, 9 + 0, 'Soft');
          EndDraw;
          end;
end;

procedure TDeskTop.GetClientRect( var R: TRect);
begin
     if ( Title <> nil)
     then begin
          R.A.Assign( 0, 26);
          R.B.Assign( Size.X, Size.Y);
          end
     else begin
          R.A.Assign( 0, 0);
          R.B.Assign( Size.X, Size.Y);
          end;
end;

destructor TDeskTop.Destroy;
begin
     FreeString( Title);
     inherited Destroy;
{$IFDEF _DEBUG}
     Close( DebugFile);
{$ENDIF}
end;

procedure TDeskTop.HandleEvent( var E: TEvent);
begin
     inherited HandleEvent( E);
     if ( E.What = evCommand)
     then begin
          if ( E.Command = cmExitApplication)
          then begin
               SetState( sfExecuted, False);
               ClearEvent( E);
               end;
          end;
end;

procedure TDeskTop.InsertTopWindow( W: PWindow);
begin
     if (W <> nil)
     then begin
          if ( ClientArea <> nil)
          then begin
               Lock;
               ClientArea^.InsertChild( W);
               W^.SetFocus;
               UnLock;
               ClientArea^.Update;
               UpdateCommands;
               end
          else W^.Free;
          end;
end;

function TDeskTop.CreateClientsArea( var R: TRect): PDesktopClientsArea;
begin
     CreateClientsArea := New( PDesktopClientsArea, Create( R));
end;

procedure TDeskTop.GetAvailableCommands( var ACommands: TCommandsSet);
begin
     ACommands := ACommands + [cmExitApplication];
     inherited GetAvailableCommands( ACommands);
end;

{
const LastCommandsAvailable: TCommandsSet = [];

procedure TDeskTop.UpdateCommands;
var Commands: TCommandsSet;
begin
     Commands := [];
     GetAvailableCommands( Commands);
     if ( Commands <> LastCommandsAvailable)
     then begin
          LastCommandsAvailable := Commands;
          EnableCommands( Commands);
          end;
end;
}

{function TDeskTop.CommandAvailable( ACommand: Word): Boolean;
begin
     case ACommand
     of cmExitApplication: begin
                           CommandAvailable := True;
                           end;
     else
         CommandAvailable := inherited CommandAvailable( ACommand);
     end;
end;}

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TApplication.Create;
begin
     inherited Create;
     Desktop := CreateDesktop;
     InstallProcess( Timer, TIMERNICEVALUE);
     InstallProcess( MouseEventGenerator, MOUSENICEVALUE);
     InstallProcess( KeyboardEventGenerator, KEBOARDNICEVALUE);
     InstallInterrupts;
end;

destructor TApplication.Destroy;
begin
     UninstallInterrupts;
     UninstallProcess( Timer);
     UninstallProcess( MouseEventGenerator);
     UninstallProcess( KeyboardEventGenerator);
     if ( Desktop <> nil)
     then Desktop^.Free;
     inherited Destroy;
end;

procedure TApplication.Run;
begin
     if ( Desktop <> nil)
     then begin
          TheScreen.HideMouseCursor;
          Desktop^.DrawView;
          TheScreen.ShowMouseCursor;
          Desktop^.Execute;
          end;
end;

function TApplication.CreateDesktop: PDeskTop;
begin
     CreateDesktop := nil;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TButton.Create( X, Y, W, H: Integer; ATitle: string; ACommand: Word; AKey: Byte);
var R:TRect;
begin
     R.A.Assign( X, Y);
     R.B.Assign( X + W - 1, Y + H - 1);
     inherited Create( R);
     State := sfEnabled or sfVisible;
     Options := 0;
     EventMask := evMouse;
     Title := AllocateString( ATitle);
     Command := ACommand;
     Key := AKey;
end;

{procedure TButton.DrawFrame;
begin
     BeginDraw;
     SetWriteMode( XORPut);
     SetPColor( clrSELECTION);
     Rectangle(5, 5, Size.X - 6, Size.Y - 6);
     Rectangle(6, 6, Size.X - 7, Size.Y - 7);
     Rectangle(7, 7, Size.X - 8, Size.Y - 8);
     SetWriteMode( NormalPut);
     EndDraw;
end;}

procedure TButton.DrawDown;
begin
     BeginDraw;
     SetPColor( clr3D0);
     Rectangle(2, 2, Size.X - 3, Size.Y - 3);
     SetPColor( clr3D2);
     Rectangle(3, 3, Size.X - 4, Size.Y - 4);
     EndDraw;
end;

procedure TButton.DrawUp;
begin
     BeginDraw;
     Draw3DOutFrame( 2, 2, Size.X - 3, Size.Y - 3, clr3D0, clr3D1, clr3D2, clr3D3);
     EndDraw;
end;

procedure TButton.Draw;
var W, H, X, Y: Integer;
begin
     BeginDraw;
     Draw3DInFrame( 0, 0, Size.X - 1, Size.Y - 1, clr3D0, clr3D1, clr3D2, clr3D3);
     Draw3DBar( 2, 2, Size.X - 3, Size.Y - 3, clr3D0, clr3D1, clr3D2, clr3D3);
     if ( Title <> nil)
     then begin
          SetPColor( clr3DTEXT);
          SetTextStyle( 0, HorizDir, 0);
          W := TextWidthEx( Title^);
          H := TextHeight( Title^);
          X := (Size.X - W) div 2;
          Y := (Size.Y - H) div 2;
          OutTextXYEx( X, Y, Title^);
          end;
     EndDraw;
end;

procedure TButton.HandleEvent(var E: TEvent);
begin
     if GetState( sfDrag)
     then begin
          if (E.What = evMouseUp)
          then begin
               if ContainsPoint( E.MouseInfo.Where)
               then begin
                    E.What := evCommand;
                    E.Command := Command;
                    E.Info := nil;
                    PutEvent( E);
                    ClearEvent( E);
                    {Sound( 7000);
                    delay( 10);
                    Nosound;}
                    end;
               DrawUp;
               EndDrag;
               end;
          ClearEvent(E);
          end
     else begin
          if ( E.What = evMouseDown)
          then begin
               DrawDown;
               BeginDrag;
               end
          else if ( E.What = evKeyPress)
          then begin
               if (((E.KeyInfo.ShiftStatus and shkControlDown) <> 0) and (E.KeyInfo.ScanCode = Key))
               then begin
                    E.What := evCommand;
                    E.Command := Command;
                    E.Info := nil;
                    PutEvent( E);
                    ClearEvent( E);
                    end;
               end;
          end;
end;

destructor TButton.Destroy;
begin
     FreeString( Title);
     inherited Destroy;
end;

function TButton.ContainsPoint( P: TPoint): Boolean;
begin
     if Inherited ContainsPoint( P)
     then begin
          MakeLocal( P);
          if (( P.X < Size.X - metSHADOWSIZE) and ( P.Y < Size.Y - metSHADOWSIZE))
          then ContainsPoint := True
          else ContainsPoint := False;
          end
     else ContainsPoint := False;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TScrollBar.Create( R: TRect; P: PWindow; AVertical: Boolean; ALineMagnitude, APageMagnitude, APos: Integer);
begin
     inherited Create( R);
     State := sfEnabled or sfVisible;
     Options := 0;
     LineMagnitude := ALineMagnitude;
     PageMagnitude := APageMagnitude;
     EventMask := evMouse;
     Pos := APos;
     Window := P;
     Vertical := AVertical;
     TuchPos.Assign( 0, 0);
     if Vertical
     then begin
          UpBtn.A.Assign( 0, 0);
          UpBtn.B.Assign( Size.X, mstSCROLLBTNWIDTH);
          DownBtn.A.Assign( 0, Size.Y - mstSCROLLBTNWIDTH);
          DownBtn.B.Assign( Size.X, Size.Y);
          end
     else begin
          UpBtn.A.Assign( 0, 0);
          UpBtn.B.Assign( mstSCROLLBTNWIDTH, Size.Y);
          DownBtn.A.Assign( Size.X - mstSCROLLBTNWIDTH, 0);
          DownBtn.B.Assign( Size.X, Size.Y);
          end;
end;

procedure TScrollBar.HandleEvent( var E: TEvent);
    procedure ProcessMouseEvent;
    begin
         MakeLocal( E.MouseInfo.Where);
         if UpBtn.PointIn(E.MouseInfo.Where)
         then begin
              BeginDraw;
              SetWriteMode(XORPut);
              Rectangle( UpBtn.A.X + 1, UpBtn.A.Y + 1, UpBtn.B.X - 2, UpBtn.B.Y - 2);
              Rectangle( UpBtn.A.X + 2, UpBtn.A.Y + 2, UpBtn.B.X - 3, UpBtn.B.Y - 3);
              Rectangle( UpBtn.A.X + 3, UpBtn.A.Y + 3, UpBtn.B.X - 4, UpBtn.B.Y - 4);
              EndDraw;
              ScrollUp;
              BeginDraw;
              SetWriteMode( XORPut);
              Rectangle( UpBtn.A.X + 1, UpBtn.A.Y + 1, UpBtn.B.X - 2, UpBtn.B.Y - 2);
              Rectangle( UpBtn.A.X + 2, UpBtn.A.Y + 2, UpBtn.B.X - 3, UpBtn.B.Y - 3);
              Rectangle( UpBtn.A.X + 3, UpBtn.A.Y + 3, UpBtn.B.X - 4, UpBtn.B.Y - 4);
              EndDraw;
              end
         else if DownBtn.PointIn( E.MouseInfo.Where)
              then begin
                   BeginDraw;
                   SetWriteMode( XORPut);
                   Rectangle( DownBtn.A.X + 1, DownBtn.A.Y + 1, DownBtn.B.X - 2, DownBtn.B.Y - 2);
                   Rectangle( DownBtn.A.X + 2, DownBtn.A.Y + 2, DownBtn.B.X - 3, DownBtn.B.Y - 3);
                   Rectangle( DownBtn.A.X + 3, DownBtn.A.Y + 3, DownBtn.B.X - 4, DownBtn.B.Y - 4);
                   EndDraw;
                   ScrollDown;
                   BeginDraw;
                   SetWriteMode( XORPut);
                   Rectangle( DownBtn.A.X + 1, DownBtn.A.Y + 1, DownBtn.B.X - 2, DownBtn.B.Y - 2);
                   Rectangle( DownBtn.A.X + 2, DownBtn.A.Y + 2, DownBtn.B.X - 3, DownBtn.B.Y - 3);
                   Rectangle( DownBtn.A.X + 3, DownBtn.A.Y + 3, DownBtn.B.X - 4, DownBtn.B.Y - 4);
                   EndDraw;
                   end;
    end;
begin
     if GetState( sfDrag)
     then begin
          if ( E.What = evMouseUp)
          then begin
               ClearEvent( E);
               EndDrag
               end
          else begin
               if ( E.What = evMouseRepeat)
               then ProcessMouseEvent;
               ClearEvent( E);
               end;
          end
     else begin
          if ( E.What = evMouseDown)
          then begin
               ProcessMouseEvent;
               ClearEvent( E);
               BeginDrag;
               end;
          end;
end;

procedure TScrollBar.Draw;
var Active: Boolean;
    UpCen,
    DownCen: TPoint;
begin
     if ( Parent <> nil)
     then begin
          if Parent^.GetState( sfFocused)
          then Active := True
          else Active := False;
          end
     else Active := False;
     BeginDraw;
     {SetPFillPattern( clrSCROLLBARSURFACE, VeryLightPattern);
     Bar( 2, 2, Size.X - 3, Size.Y - 3);}
     Draw3DInFrame( 0, 0, Size.X - 1, Size.Y - 1, clr3D0, clr3D1, clr3D2, clr3D3);
     SetPFillPattern( clr3D3, SolidPattern);
     Bar( 2, 2, Size.X - 3, Size.Y - 3);
     Draw3DBar( UpBtn.A.X + 2, UpBtn.A.Y + 2, UpBtn.B.X - 3, UpBtn.B.Y - 3, clr3D0, clr3D1, clr3D2, clr3D3);
     Draw3DBar( DownBtn.A.X + 2, DownBtn.A.Y + 2, DownBtn.B.X - 3, DownBtn.B.Y - 3, clr3D0, clr3D1, clr3D2, clr3D3);
     UpCen.X := ( UpBtn.A.X + UpBtn.B.X) div 2;
     UpCen.Y := ( UpBtn.A.Y + UpBtn.B.Y) div 2;
     DownCen.X := ( DownBtn.A.X + DownBtn.B.X) div 2;
     DownCen.Y := ( DownBtn.A.Y + DownBtn.B.Y) div 2;
     SetPColor( clr3DTEXT);
     if Vertical
     then begin
          Line( UpCen.X, UpCen.Y - 2, UpCen.X - 4, UpCen.Y + 2);
          Line( UpCen.X, UpCen.Y - 2, UpCen.X + 4, UpCen.Y + 2);
          Line( UpCen.X, UpCen.Y - 3, UpCen.X - 4, UpCen.Y + 1);
          Line( UpCen.X, UpCen.Y - 3, UpCen.X + 4, UpCen.Y + 1);
          Line( UpCen.X, UpCen.Y - 4, UpCen.X - 4, UpCen.Y + 0);
          Line( UpCen.X, UpCen.Y - 4, UpCen.X + 4, UpCen.Y + 0);

          Line( DownCen.X, DownCen.Y + 2, DownCen.X - 4, DownCen.Y - 2);
          Line( DownCen.X, DownCen.Y + 2, DownCen.X + 4, DownCen.Y - 2);
          Line( DownCen.X, DownCen.Y + 1, DownCen.X - 4, DownCen.Y - 3);
          Line( DownCen.X, DownCen.Y + 1, DownCen.X + 4, DownCen.Y - 3);
          Line( DownCen.X, DownCen.Y + 0, DownCen.X - 4, DownCen.Y - 4);
          Line( DownCen.X, DownCen.Y + 0, DownCen.X + 4, DownCen.Y - 4);
          end
     else begin
          Line( UpCen.X - 2, UpCen.Y, UpCen.X + 2, UpCen.Y - 4);
          Line( UpCen.X - 2, UpCen.Y, UpCen.X + 2, UpCen.Y + 4);
          Line( UpCen.X - 3, UpCen.Y, UpCen.X + 1, UpCen.Y - 4);
          Line( UpCen.X - 3, UpCen.Y, UpCen.X + 1, UpCen.Y + 4);
          Line( UpCen.X - 4, UpCen.Y, UpCen.X + 0, UpCen.Y - 4);
          Line( UpCen.X - 4, UpCen.Y, UpCen.X + 0, UpCen.Y + 4);

          Line( DownCen.X + 2, DownCen.Y, DownCen.X - 2, DownCen.Y - 4);
          Line( DownCen.X + 2, DownCen.Y, DownCen.X - 2, DownCen.Y + 4);
          Line( DownCen.X + 1, DownCen.Y, DownCen.X - 3, DownCen.Y - 4);
          Line( DownCen.X + 1, DownCen.Y, DownCen.X - 3, DownCen.Y + 4);
          Line( DownCen.X + 0, DownCen.Y, DownCen.X - 4, DownCen.Y - 4);
          Line( DownCen.X + 0, DownCen.Y, DownCen.X - 4, DownCen.Y + 4);
          end;
     EndDraw;
end;

procedure TScrollBar.ScrollTo( APos: Integer);
begin
end;

procedure TScrollBar.ScrollUp;
var E: TEvent;
    NewPos: Integer;
begin
     if ( Window <> nil)
     then begin
          NewPos := Pos;
          E.What := evCommand;
          E.Info := @NewPos;
          if Vertical
          then E.Command := cmScrollUp
          else E.Command := cmScrollLeft;
          Window^.HandleEvent( E);
          end;
end;

procedure TScrollBar.ScrollDown;
var E: TEvent;
    NewPos: Integer;
begin
     if ( Window <> nil)
     then begin
          NewPos := Pos;
          E.What := evCommand;
          E.Info := @NewPos;
          if Vertical
          then E.Command := cmScrollDown
          else E.Command := cmScrollRight;
          Window^.HandleEvent( E);
          end;
end;

procedure TScrollBar.ScrollPageUp;
begin
end;

procedure TScrollBar.ScrollPageDown;
begin
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

function NewMenuItem( ATitle: string; AKey: Byte; ACommand: Word; ASub: PMenuItem; ANext: PMenuItem): PMenuItem;
var P: PMenuItem;
begin
     New(P);
     P^.Title := AllocateString( ATitle);
     P^.Key := AKey;
     P^.Next := ANext;
     P^.Sub := ASub;
     P^.Command := ACommand;
     P^.Enabled := False;
     NewMenuItem := P;
end;

procedure EnableCommandsInMenuTree( P: PMenuItem; ACommands: TCommandsSet);
    function EnableSub( P: PMenuItem): Boolean;
    var ScanMenuItem: PMenuItem;
    begin
         EnableSub := False;
         if (P <> nil)
         then begin
              ScanMenuItem := P;
              while ( ScanMenuItem <> nil)
              do begin
                 if ( ScanMenuItem^.Sub <> nil)
                 then begin
                      if EnableSub( ScanMenuItem^.Sub)
                      then begin
                           ScanMenuItem^.Enabled := True;
                           EnableSub := True;
                           end
                      else ScanMenuItem^.Enabled := False
                      end
                 else begin
                      if ScanMenuItem^.Command in ACommands
                      then begin
                           ScanMenuItem^.Enabled := True;
                           EnableSub := True;
                           end
                      else ScanMenuItem^.Enabled := False;
                      end;
                 ScanMenuItem := ScanMenuItem^.Next;
                 end;
              end;
    end;
begin
     EnableSub( P);
end;

procedure FreeMenuTree( var P:PMenuItem);
var Temp: PMenuItem;
begin
     while ( P <> nil)
     do begin
        if ( P^.Sub <> nil)
        then FreeMenuTree( P^.Sub);
        FreeString( P^.Title);
        Temp := P;
        P := P^.Next;
        Dispose( Temp);
        end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TPathStack.Create;
begin
     inherited Create;
     Top := 0;
end;

destructor TPathStack.Destroy;
begin
     Top := 0;
     inherited Destroy;
end;

procedure TPathStack.Push( P: PMenuItem; ATitle: PString);
begin
     if (Top < MaxStackSize)
     then begin
          Top := Top + 1;
          Items[Top] := P;
          Titles[Top] := ATitle;
          end;
end;

procedure TPathStack.Pop( var P: PMenuItem; var ATitle: PString);
begin
     if (Top > 0)
     then begin
          P := Items[Top];
          ATitle := Titles[Top];
          Top := Top - 1;
          end
     else begin
          P := nil;
          ATitle := nil;
          end;
end;

function TPathStack.Empty:Boolean;
begin
     Empty := Top = 0;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TMenuList.Create( R: TRect; ATitle: string; AMenu: PMenuItem);
begin
     inherited Create(R);
     State := sfVisible or sfEnabled;
     Options := 0;
     EventMask := $FF;
     Stack.Create;
     Menu := AMenu;
     Title := AllocateString( ATitle);
     Current := Menu;
     CurrentTitle := Title;
     LastItemNo := 0;
     NumItems := 0;
end;

procedure TMenuList.DrawItems( AInitViewPort: Boolean);
var TempItem: PMenuItem;
    Active: Boolean;
    TextColor: Byte;
    I: Integer;
begin
     if AInitViewPort
     then BeginDraw;

     if ( Parent <> nil)
     then begin
          if Parent^.GetState( sfFocused)
          then Active := True
          else Active := False;
          end
     else Active := False;

     if Active
     then begin
          TextColor := clr3DTEXT;
          end
     else begin
          TextColor := clr3DTEXTINACTIVE;
          end;

     NumItems := 0;
     I := 0;
     TempItem := Current;
     while ( TempItem <> nil)
     do begin
        NumItems := NumItems + 1;
        if TempItem^.Title <> nil
        then begin
             if Active
             then begin
                  if TempItem^.Enabled
                  then SetPColor( TextColor)
                  else SetPColor( clr3DTEXTINACTIVE);
                  end
             else SetPColor( TextColor);
             OutTextXYEx( 5, metLISTBOXITEMHEIGHT + ( metMENUITEMHEIGHT - metTEXTHEIGHT) div 2 + I * metMENUITEMHEIGHT - 2,
                          TempItem^.Title^);
             I := I + 1;
             TempItem := TempItem^.Next;
             end;
        end;

     Draw3DInFrame( 0, 0, Size.X - 1, Size.Y - 1, clr3D0, clr3D1, clr3D2, clr3D3);

     if AInitViewPort
     then EndDraw;
end;

procedure TMenuList.DisplayOptions;
var X, Y, W: Integer;
    PanelColor: Integer;
    Active: Boolean;
begin
     if ( Parent <> nil)
     then begin
          if Parent^.GetState( sfFocused)
          then Active := True
          else Active := False;
          end
     else Active := False;

     BeginDraw;
     {Draw3DInFrame( 0, 0, Size.X - 1, Size.Y - 1, clr3D0, clr3D1, clr3D2, clr3D3);}

     Draw3DBar( 2, 2, Size.X - 3, metLISTBOXITEMHEIGHT - 1, clr3D0, clr3D1, clr3D2, clr3D3);
     SetWriteMode( NormalPut);
     SetPFillPattern( clr3DBACK, SolidPattern);
     Bar( 2, metLISTBOXITEMHEIGHT, Size.X - 3, Size.Y - 2);

     SetPColor( clr3DTEXT);
     SetTextStyle( 0{7}, HorizDir, 1);
     if ( CurrentTitle <> nil)
     then begin
          W := TextWidthEx( CurrentTitle^);
          X := ( Size.X - W) div 2;
          Y := ( metLISTBOXITEMHEIGHT - TextHeight( CurrentTitle^)) div 2;
          OutTextXYEx( X, Y, CurrentTitle^);
          end;

     DrawItems( False);

     EndDraw;
end;

procedure TMenuList.Draw;
var R: TRect;
begin
     BeginDraw;
     DisplayOptions;
     EndDraw;
end;

procedure TMenuList.HandleEvent( var E: TEvent);
var ItemNo: Integer;
    R: TRect;
    TempItem: PMenuItem;

    function GetItemNo( P: TPoint): Integer;
    begin
         if ContainsPoint( P)
         then begin
              MakeLocal( P);
              GetItemNo := (( P.Y - 20) div metMENUITEMHEIGHT) + 1;
              end
         else GetItemNo := 0;
    end;

    procedure DrawSelectionFrame( AItemNo: Integer);
    begin
         if ( AItemNo > 0)
         then begin
              InitViewPort;
              SetWriteMode( XORPut);
              SetPColor( clrSELECTION);
              R.A.Assign( 2,(( AItemNo - 1) * metMENUITEMHEIGHT + 17));
              R.B.Assign( Size.X - 3,(( AItemNo - 1) * metMENUITEMHEIGHT + 19) + metMENUITEMHEIGHT - 1);
              Rectangle( R.A.X, R.A.Y, R.B.X, R.B.Y);
              R.A.Assign(3,(( AItemNo - 1) * metMENUITEMHEIGHT + 18));
              R.B.Assign( Size.X - 4,(( AItemNo - 1) * metMENUITEMHEIGHT + 19) + metMENUITEMHEIGHT - 2);
              Rectangle( R.A.X, R.A.Y, R.B.X, R.B.Y);
              end;
    end;

    procedure Select( AItemNo: Integer);
    var I: Integer;
        E: TEvent;
    begin
         TempItem := Current;
         I := 1;
         while (( I < AItemNo) and ( TempItem <> nil))
         do begin
            I := I + 1;
            TempItem := TempItem^.Next;
            end;
         if ( TempItem <> nil)
         then if TempItem^.Enabled
              then begin
                   if TempItem^.Enabled
                   then begin
                        if ( TempItem^.Sub = nil)
                        then begin
                             E.What := evCommand;
                             E.Command := TempItem^.Command;
                             E.Info := nil;
                             PutEvent( E);
                             ClearEvent( E);
                             end
                        else begin
                             Stack.Push( Current, CurrentTitle);
                             CurrentTitle := TempItem^.Title;
                             Current := TempItem^.Sub;
                             DisplayOptions;
                             end;
                        end;
                   end;
    end;

    procedure ChooseItem;
    begin
         ItemNo := GetItemNo( E.MouseInfo.Where);
         if ( LastItemNo <> ItemNo)
         then if (( ItemNo > 0) and ( ItemNo <= NumItems))
              then begin
                   TheScreen.HideMouseCursor;
                   DrawSelectionFrame( LastItemNo);
                   if ( ItemNo > 0) and ( ItemNo <= NumItems)
                   then LastItemNo := ItemNo
                   else LastItemNo := 0;
                   DrawSelectionFrame( LastItemNo);
                   TheScreen.ShowMouseCursor;
                   end
              else begin
                   if (( LastItemNo > 0) and ( LastItemNo <= NumItems))
                   then begin
                        TheScreen.HideMouseCursor;
                        DrawSelectionFrame( LastItemNo);
                        LastItemNo := 0;
                        TheScreen.ShowMouseCursor;
                        end;
                   end;
    end;

begin
     if GetState( sfDrag)
     then begin
          if ( E.What = evMouseDrag)
          then begin
               ChooseItem;
               ClearEvent( E);
               end
          else begin
               if ( E.What = evMouseUp)
               then begin
                    if ( LastItemNo > 0)
                    then begin
                         TheScreen.HideMouseCursor;
                         DrawSelectionFrame( LastItemNo);
                         TheScreen.ShowMouseCursor;
                         Select( LastItemNo);
                         LastItemNo := 0;
                         end;
                    EndDrag;
                    ClearEvent( E);
                    end;
               end;
          end
     else if ( E.What = evMouseDown)
     then begin
          if ( E.MouseInfo.Bottons = 1)
          then begin
               ChooseItem;
               ClearEvent( E);
               BeginDrag;
               end
          else if not Stack.Empty
          then begin
               Stack.Pop( Current, CurrentTitle);
               DisplayOptions;
               end;
          ClearEvent( E);
          end
     else if ( E.What = evKeyPress)
     then begin
          if ( Parent <> nil)
          then if not Parent^.GetState( sfFocused) then Exit;
          if ( E.KeyInfo.Scancode = keyESC)
          then begin
               E.What := evCommand;
               E.Command := cmMenuBack;
               PutEvent( E);
               {HandleEvent( E);}
               ClearEvent( E);
               end
          else begin
               if ((E.KeyInfo.ShiftStatus and shkControlDown) <> $00)
               then begin
                    TempItem := Current;
                    while ( TempItem <> nil)
                    do begin
                       if ( TempItem^.Key = E.KeyInfo.ScanCode)
                       then begin
                            if TempItem^.Enabled
                            then begin
                                 if ( TempItem^.Sub = nil)
                                 then begin
                                      E.What := evCommand;
                                      E.Command := TempItem^.Command;
                                      E.Info := nil;
                                      PutEvent( E);
                                      ClearEvent( E);
                                      end
                                 else begin
                                      Stack.Push( Current, CurrentTitle);
                                      CurrentTitle := TempItem^.Title;
                                      Current := TempItem^.Sub;
                                      DisplayOptions;
                                      end;
                                 end;
                            ClearEvent( E);
                            Break;
                            end;
                       TempItem := TempItem^.Next;
                       end;
                  end;
               end;
          end
     else if (E.What = evCommand)
     then begin
          if E.Command = cmMenuBack
          then begin
               if not Stack.Empty
               then begin
                    Stack.Pop( Current, CurrentTitle);
                    DisplayOptions;
                    end;
               ClearEvent( E);
               end;
          end;
end;

destructor TMenuList.Destroy;
begin
     FreeString( Title);
     FreeMenuTree( Menu);
     inherited Destroy;
end;

procedure TMenuList.UpdateCommandsEnabling;
begin
     if ( Parent <> nil)
     then if Parent^.GetState( sfFocused)
          then if AbleToDraw
               then DrawItems( True);
end;

procedure TMenuList.EnableCommands( var ACommands: TCommandsSet);
begin
     inherited EnableCommands( ACommands);
     EnableCommandsInMenuTree( Menu, ACommands);
     UpdateCommandsEnabling;
end;

procedure TMenuList.GetAvailableCommands( var ACommands: TCommandsSet);
begin
     inherited GetAvailableCommands( ACommands);
     ACommands := ACommands + [cmMenuBack];
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

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
     PartialHeight := 50000 div (X2 - X1);
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

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TMenu.Create( AOrigin: TPoint; AMenu: PMenuItem);
var R: TRect;
begin
     Menu := AMenu;
     R.A := AOrigin;
     CalcSize( R.B);
     R.B.X := R.A.X + R.B.X;
     R.B.Y := R.A.Y + R.B.Y;
     inherited Create( R);
     State := sfVisible or sfEnabled;
     Options := 0{ofSelectable};
     EventMask := $FF;


     Current := Menu;
     LastItemNo := 0;
     NumItems := ItemsCount;
end;

destructor TMenu.Destroy;
begin
     inherited Destroy;
end;

procedure TMenu.CalcSize( var ASize: TPoint);
var ScanItem: PMenuItem;
    TW: Integer;
begin
     ASize.Assign( 0, 0);
     ScanItem := Menu;
     while ( ScanItem <> nil)
     do begin
        ASize.Y := ASize.Y + metMENUITEMHEIGHT{11};
        if ( ScanItem^.Title <> nil)
        then begin
             TW := TextWidthEx( ScanItem^.Title^);
             if ( ASize.X < TW)
             then ASize.X := TW;
             end;
        ScanItem := ScanItem^.Next;
        end;
     ASize.Assign( ASize.X + 36{16} + metSHADOWSIZE, ASize.Y + 26{16} + metSHADOWSIZE);
end;

function TMenu.ItemsCount: Integer;
var Count: Integer;
    ScanItem: PMenuItem;
begin
     Count := 0;
     ScanItem := Menu;
     while ( ScanItem <> nil)
     do begin
        Count := Count + 1;
        ScanItem := ScanItem^.Next;
        end;
     ItemsCount := Count;
end;

procedure TMenu.HandleEvent( var E: TEvent);
var ItemNo: Integer;
    R: TRect;
    TempItem: PMenuItem;
    SubMenu: PMenu;
    SubPos: TPoint;

    function GetItemNo( P: TPoint): Integer;
    begin
         if ContainsPoint( P)
         then begin
              MakeLocal( P);
              GetItemNo := (( P.Y - 18{8}) div metMENUITEMHEIGHT{11}) + 1;
              end
         else GetItemNo := 0;
    end;

    procedure DrawSelectionFrame( AItemNo: Integer);
    begin
         if ( AItemNo > 0)
         then begin
              InitViewPort;
              SetWriteMode( XORPut);
              SetPColor( clrSELECTION);
              R.A.Assign( 4, (AItemNo - 1) * metMENUITEMHEIGHT{11} + 15{5} - 5);
              R.B.Assign( Size.X - 5 - metSHADOWSIZE,( AItemNo - 1) * metMENUITEMHEIGHT{11} + 27{17} + 5);
              Rectangle( R.A.X, R.A.Y, R.B.X, R.B.Y);
              R.A.Assign( 5, (AItemNo - 1) * metMENUITEMHEIGHT{11} + 16{6} - 5);
              R.B.Assign( Size.X - 6 - metSHADOWSIZE,( AItemNo - 1) * metMENUITEMHEIGHT{11} + 26{16} + 5);
              Rectangle( R.A.X, R.A.Y, R.B.X, R.B.Y);
              end;
    end;

    procedure Select( AItemNo: Integer);
    var I: Integer;
        E: TEvent;
    begin
         TempItem := Current;
         I := 1;
         while (( I < AItemNo) and ( TempItem <> nil))
         do begin
            I := I + 1;
            TempItem := TempItem^.Next;
            end;
         if ( TempItem <> nil)
         then begin
              if TempItem^.Enabled
              then begin
                   if ( TempItem^.Sub = nil)
                   then begin
                        E.What := evCommand;
                        E.Command := TempItem^.Command;
                        E.Info := nil;
                        PutEvent( E);
                        ClearEvent( E);
                        SetState( sfExecuted, False);
                        end
                   else begin
                        SubPos.Assign( Origin.X + 10, Origin.Y + AItemNo * 10 + 8);
                        SubMenu := New( PMenu, Create( SubPos, TempItem^.Sub));
                        SubMenu^.ExecuteDlg( @Self);
                        SubMenu^.Free;
                        SetState( sfExecuted, False);
                        end;
                   end;
              end;
    end;

    procedure ChooseItem;
    begin
         ItemNo := GetItemNo( E.MouseInfo.Where);
         if ( LastItemNo <> ItemNo)
         then if (( ItemNo > 0) and ( ItemNo <= NumItems))
              then begin
                   TheScreen.HideMouseCursor;
                   DrawSelectionFrame( LastItemNo);
                   if ( ItemNo > 0) and ( ItemNo <= NumItems)
                   then LastItemNo := ItemNo
                   else LastItemNo := 0;
                   DrawSelectionFrame( LastItemNo);
                   TheScreen.ShowMouseCursor;
                   end
              else begin
                   if (( LastItemNo > 0) and ( LastItemNo <= NumItems))
                   then begin
                        TheScreen.HideMouseCursor;
                        DrawSelectionFrame( LastItemNo);
                        LastItemNo := 0;
                        TheScreen.ShowMouseCursor;
                        end;
                   end;
    end;

begin
     if GetState( sfDrag)
     then begin
          if ( E.What = evMouseDrag)
          then begin
               {ItemNo := GetItemNo( E.MouseInfo.Where);
               if ( LastItemNo <> ItemNo)
               then if (( ItemNo > 0) and ( ItemNo <= NumItems))
                    then begin
                         TheScreen.HideMouseCursor;
                         DrawSelectionFrame( LastItemNo);
                         if ( ItemNo > 0) and ( ItemNo <= NumItems)
                         then LastItemNo := ItemNo
                         else LastItemNo := 0;
                         DrawSelectionFrame( LastItemNo);
                         TheScreen.ShowMouseCursor;
                         end
                    else begin
                         if (( LastItemNo > 0) and ( LastItemNo <= NumItems))
                         then begin
                              TheScreen.HideMouseCursor;
                              DrawSelectionFrame( LastItemNo);
                              LastItemNo := 0;
                              TheScreen.ShowMouseCursor;
                              end;
                         end;}
               ChooseItem;
               ClearEvent( E);
               end
          else begin
               if ( E.What = evMouseUp)
               then begin
                    if (( LastItemNo > 0) and ContainsPoint( E.MouseInfo.Where))
                    then begin
                         TheScreen.HideMouseCursor;
                         DrawSelectionFrame( LastItemNo);
                         TheScreen.ShowMouseCursor;
                         Select( LastItemNo);
                         LastItemNo := 0;
                         end
                    else SetState( sfExecuted, False);
                    EndDrag;
                    ClearEvent( E);
                    end;
               end;
          end
     else if ( E.What = evMouseDown)
     then begin
          if (( E.MouseInfo.Bottons = 1) and ContainsPoint( E.MouseInfo.Where))
          then begin
               {ItemNo := GetItemNo( E.MouseInfo.Where);
               if ( LastItemNo <> ItemNo)
               then if (( ItemNo > 0) and ( ItemNo <= NumItems))
                    then begin
                         TheScreen.HideMouseCursor;
                         DrawSelectionFrame( LastItemNo);
                         if ( ItemNo > 0) and ( ItemNo <= NumItems)
                         then LastItemNo := ItemNo
                         else LastItemNo := 0;
                         DrawSelectionFrame( LastItemNo);
                         TheScreen.ShowMouseCursor;
                         end
                    else begin
                         if (( LastItemNo > 0) and ( LastItemNo <= NumItems))
                         then begin
                              TheScreen.HideMouseCursor;
                              DrawSelectionFrame( LastItemNo);
                              LastItemNo := 0;
                              TheScreen.ShowMouseCursor;
                              end;
                         end;}
               ChooseItem;
               ClearEvent( E);
               BeginDrag;
               end
          else begin
               SetState( sfExecuted, False);
               end;
          ClearEvent( E);
          end
     else if ( E.What = evKeyPress)
     then begin
          if ( Parent <> nil)
          then if not Parent^.GetState( sfFocused) then Exit;
          if ( E.KeyInfo.ScanCode = keyESC)
          then begin
               SetState( sfExecuted, False);
               ClearEvent( E);
               end
          else begin
               TempItem := Current;
               while ( TempItem <> nil)
               do begin
                  if ( TempItem^.Key = E.KeyInfo.ScanCode)
                  then begin
                       if TempItem^.Enabled
                       then begin
                            if ( TempItem^.Sub = nil)
                            then begin
                                 E.What := evCommand;
                                 E.Command := TempItem^.Command;
                                 E.Info := nil;
                                 PutEvent( E);
                                 ClearEvent( E);
                                 SetState( sfExecuted, False);
                                 end
                            else begin
                                 SubPos.Assign( Origin.X + 10, Origin.Y + 15);
                                 SubMenu := New( PMenu, Create( SubPos, TempItem^.Sub));
                                 SubMenu^.ExecuteDlg( @Self);
                                 SubMenu^.Free;
                                 SetState( sfExecuted, False);
                                 end;
                            end;
                       ClearEvent( E);
                       Break;
                       end
                  else TempItem := TempItem^.Next;
                  end;
               end;
          end;
end;


(*
procedure TMenu.HandleEvent( var E: TEvent);
var Pos: TPoint;
    Sub: PMenu;
begin
     if (E.What = evMouseDown)
     then begin
          Pos := E.MouseInfo.Where;
          ClearEvent( E);
          if ContainsPoint( Pos)
          then begin
               {Pos.Assign( Origin.X + 20, Origin.Y + 10);
               Sub := New( PMenu, Create( Pos));
               Sub^.ExecuteDlg( @Self);
               Sub^.Free;}
               end
          else SetState( sfExecuted, False)
          end;
end;
*)

procedure TMenu.Draw;
var  ScanMenuItem: PMenuItem;
     Y: Integer;
begin
     BeginDraw;

     SetPFillPattern( clrSHADOW, SolidPattern);
     Bar( Size.X - metSHADOWSIZE, metSHADOWSIZE, Size.X - 1, Size.Y - 1);
     Bar( metSHADOWSIZE, Size.Y - metSHADOWSIZE, Size.X - metSHADOWSIZE - 1, Size.Y - 1);
     Draw3DBar( 0, 0, Size.X - 1 - metSHADOWSIZE, Size.Y - 1 - metSHADOWSIZE, clr3D0, clr3D1, clr3D2, clr3D3);
     SetPColor( clr3DTEXT);
     Y := 18{8};
     ScanMenuItem := Menu;
     while ( ScanMenuItem <> nil)
     do begin
        if ( ScanMenuItem^.Title <> nil)
        then begin
             if (ScanMenuItem^.Enabled)
             then SetPColor( clr3DTEXT)
             else SetPColor( clr3DTEXTINACTIVE);
             OutTextXYEx( 18{8}, Y, ScanMenuItem^.Title^);
             end;
        ScanMenuItem := ScanMenuItem^.Next;
        Y := Y + metMENUITEMHEIGHT{11};
        end;
     EndDraw;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TMenuBar.Create( APos: TPoint; AMenu: PMenuItem);
var R: TRect;
begin
     R.A := APos;
     R.B.Assign( APos.X, APos.Y + 26);
     inherited Create( R);
     State := sfEnabled or sfVisible;
     Options := 0;
     EventMask := $FF;
     Menu := AMenu;
end;

destructor TMenuBar.Destroy;
begin
     if ( Menu <> nil)
     then FreeMenuTree( Menu);
     inherited Destroy;
end;

procedure TMenuBar.HandleEvent( var E: TEvent);
var Rect: TRect;
    Item: PMenuItem;

    procedure SelectItem( AItem: PMenuItem);
    var Rect: TRect;
        SubMenu: PMenu;
        SubPos: TPoint;
    begin
         if ( Item <> nil)
         then begin
              if ( GetItemRect( AItem, Rect))
              then begin
                   if AItem^.Enabled
                   then begin
                        if ( AItem^.Sub <> nil)
                        then begin
                             SubPos.Assign( Rect.A.X + 4, Rect.B.Y + 2);
                             SubMenu := New( PMenu, Create( SubPos, AItem^.Sub));
                             SubMenu^.ExecuteDlg( @Self);
                             SubMenu^.Free;
                             end
                        else begin
                             E.What := evCommand;
                             E.Command := Item^.Command;
                             E.Info := nil;
                             PutEvent( E);
                             ClearEvent( E);
                             end;
                        end;
                   end;
              end;
    end;
begin
     if E.What = evMouseDown
     then begin
          Item := GetPosItem( E.MouseInfo.Where);
          ClearEvent( E);
          SelectItem( Item);
          end
     else if ( E.What = evKeyPress)
     then begin
          if ( Parent <> nil)
          then if not Parent^.GetState( sfFocused) then Exit;

          if (( E.KeyInfo.ShiftStatus and shkAltDown) <> $00)
          then begin
               Item := Menu;
               while ( Item <> nil)
               do begin
                  if ( Item^.Key = E.KeyInfo.ScanCode)
                  then begin
                       ClearEvent( E);
                       SelectItem( Item);
                       Item := nil;
                       end
                  else Item := Item^.Next;
                  end;
               end;
          end;
     end;


function TMenuBar.GetPosItem( P: TPoint): PMenuItem;
var ScanItem: PMenuItem;
    ItemWidth: Integer;
    ItemStartX: Integer;
begin
     if ContainsPoint( P)
     then begin
          MakeLocal( P);
          ItemStartX := 1;
          ScanItem := Menu;
          while ( ScanItem <> nil)
          do begin
             if ( ScanItem^.Title <> nil)
             then ItemWidth := TextWidthEx( ScanItem^.Title^) + 30
             else ItemWidth := 30;
             if (( P.X >= ItemStartX) and ( P.X <= (ItemStartX + ItemWidth)))
             then Break;
             ItemStartX := ItemStartX + ItemWidth;
             ScanItem := ScanItem^.Next;
             end;
          GetPosItem := ScanItem;
          end
     else GetPosItem := nil;
end;

function TMenuBar.GetItemRect( AItem: PMenuItem; var ARect: TRect): Boolean;
var ScanItem: PMenuItem;
    ItemWidth: Integer;
    ItemStartX: Integer;
begin
     ItemStartX := 1;
     ScanItem := Menu;
     while ( ScanItem <> nil)
     do begin
        if ( ScanItem^.Title <> nil)
        then ItemWidth := TextWidthEx( ScanItem^.Title^) + 30
        else ItemWidth := 30;
        if (ScanItem = AItem)
        then begin
             ARect.Assign( ItemStartX, 1, ItemStartX + ItemWidth, Size.Y - 2);
             break;
             end;
        ItemStartX := ItemStartX + ItemWidth;
        ScanItem := ScanItem^.Next;
        end;
     if ( ScanItem = nil)
     then GetItemRect := False
     else GetItemRect := True;
end;

procedure TMenuBar.DisplayOptions;
var ScanItem: PMenuItem;
    ItemStartX: Integer;
    ItemWidth: Integer;
begin
     BeginDraw;
     ItemStartX := 10;
     ScanItem := Menu;
     while (ScanItem <> nil)
     do begin
        if ( ScanItem^.Title <> nil)
        then begin
             ItemWidth := TextWidthEx( ScanItem^.Title^) + 30;
             if (ScanItem^.Enabled)
             then SetPColor( clr3DTEXT)
             else SetPColor( clr3DTEXTINACTIVE);
             OutTextXYEx( ItemStartX, 9, ScanItem^.Title^);
             end
        else ItemWidth := 30;
        ItemStartX := ItemStartX + ItemWidth;
        ScanItem := Scanitem^.Next;
        end;
     EndDraw;
end;

procedure TMenuBar.Draw;
var Rect: Trect;
begin
     if ( Parent <> nil)
     then begin
          Parent^.GetClientRect( Rect);
          Size.X := Rect.B.X - Rect.A.X;
          BeginDraw;
          Draw3DBar( 0, 0, Size.X - 1, Size.Y - 1, clr3D0, clr3D1, clr3D2, clr3D3);
          DisplayOptions;
          EndDraw;
          end;
end;

procedure TMenuBar.ModifyParentClientRect( var R: TRect);
begin
     R.A.Y := R.A.Y + Size.Y;
end;

procedure TMenuBar.UpdateCommandsEnabling;
begin
     if ( Parent <> nil)
     then if Parent^.GetState( sfFocused)
          then if AbleToDraw
               then Displayoptions;
end;

procedure TMenuBar.EnableCommands( var ACommands: TCommandsSet);
begin
     inherited EnableCommands( ACommands);
     EnableCommandsInMenuTree( Menu, ACommands);
     UpdateCommandsEnabling;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TCaptionWindow.Create( ACaption: string; AOrigin: TPoint; ASize: TPoint);
var R: TRect;
begin
     R.A := AOrigin;
     R.B.Assign( AOrigin.X + ASize.X + metSHADOWSIZE, AOrigin.Y + ASize.Y + metSHADOWSIZE);
     inherited Create( R);
     State := sfVisible or sfEnabled;
     Options := ofSelectable or ofFramed or sfMove or ofTopSelect{or ofFirstClick};
     EventMask := $FF;
     Caption := AllocateString( ACaption);
     TuchPos.Assign( 0, 0);
     Style := $00;
end;

destructor TCaptionWindow.Destroy;
begin
     if ( Caption <> nil)
     then FreeString( Caption);
     inherited Destroy;
end;

procedure TCaptionWindow.Draw;
begin
     BeginDraw;
     SetPFillPattern( clrSHADOW, SolidPattern);
     Bar( Size.X - metSHADOWSIZE, metSHADOWSIZE, Size.X - 1, Size.Y - 1);
     Bar( metSHADOWSIZE, Size.Y - metSHADOWSIZE, Size.X - metSHADOWSIZE - 1, Size.Y - 1);
     Draw3DBar( 0, 0, Size.X - 1 - metSHADOWSIZE, Size.Y - 1 - metSHADOWSIZE, clr3D0, clr3D1, clr3D2, clr3D3);
     DrawFrame( False);
     EndDraw;
end;

procedure TCaptionWindow.DrawFrame( AInitViewPort: Boolean);
var CaptionOffset: Integer;
    CaptionColor: Integer;
begin
     if AInitViewPort
     then BeginDraw;

     if GetState( sfFocused)
     then CaptionColor := clrCAPTION
     else CaptionColor := clrCAPTIONINACTIVE;

     if (( Style and cwsCOLSEABLE) <> $00)
     then begin
          CaptionOffset := metCAPTIONHEIGHT + met3DFRAME * 2;
          Draw3DInFrame( met3DFRAME,
                         met3DFRAME,
                         met3DFRAME + metCAPTIONHEIGHT,
                         met3DFRAME + metCAPTIONHEIGHT, clr3D0, clr3D1, clr3D2, clr3D3);
          Draw3DBar( met3DFRAME + 2,
                     met3DFRAME + 2,
                     met3DFRAME + metCAPTIONHEIGHT - 2,
                     met3DFRAME + metCAPTIONHEIGHT - 2,
                     clr3D0, clr3D1, clr3D2, clr3D3);
          SetPColor( clr3DTEXT);

          Rectangle( met3DFRAME + metCAPTIONHEIGHT div 2 - 3, met3DFRAME + metCAPTIONHEIGHT div 2 - 2,
                     met3DFRAME + metCAPTIONHEIGHT div 2 + 3, met3DFRAME + metCAPTIONHEIGHT div 2 + 2);
          Rectangle( met3DFRAME + metCAPTIONHEIGHT div 2 - 2, met3DFRAME + metCAPTIONHEIGHT div 2 - 1,
                     met3DFRAME + metCAPTIONHEIGHT div 2 + 2, met3DFRAME + metCAPTIONHEIGHT div 2 + 1);
          end
     else CaptionOffset := met3DFRAME;

     SetPFillPattern( CaptionColor, SolidPattern);
     Bar( CaptionOffset, met3DFRAME, Size.X - met3DFRAME - 1 - metSHADOWSIZE, met3DFRAME + metCAPTIONHEIGHT);
     SetPColor( clrCAPTIONTEXT);
     if ( Caption <> nil)
     then OutTextXY( CaptionOffset + met3DFRAME, ( metCAPTIONHEIGHT - metTEXTHEIGHT ) div 2 + met3DFRAME, GetCaption);

     if AInitViewPort
     then EndDraw;
end;

procedure TCaptionWindow.HandleEvent( var E: TEvent);
var MousePos: TPoint;
    R: TRect;
begin
     if GetOption(ofMovable)
     then begin
          if (E.What = evMouseDown)
          then begin
               MousePos := E.MouseInfo.Where;
               MakeLocal( MousePos);
               if (( MousePos.Y >= 0) and ( MousePos.X >= 0) and ( MousePos.Y <= metCAPTIONHEIGHT))
               then begin
                    if ((MousePos.X < metCAPTIONHEIGHT) and (( Style and cwsCOLSEABLE) <> $00))
                    then begin
                         {SetState( sfVisible, False);}
                         ClearEvent( E);
                         Close;
                         Exit;
                         end
                    else if (MousePos.X > Size.X - metSHADOWSIZE - metCAPTIONHEIGHT)
                    then begin
                         end
                    else begin
                         TuchPos := MousePos;
                         DragPos := Origin;
                         SetState( sfMove, True);
                         ClearEvent( E);
                         Parent^.InitClientViewPort;
                         SetWriteMode( XORPut);
                         DrawDragFrame;
                         BeginDrag;
                         end;
                    end;
               end
          else if ((E.What = evMouseDrag) and (GetState( sfDrag or sfMove)))
          then begin
               MousePos := E.MouseInfo.Where;
               if ( Parent <> nil)
               then begin
                    Parent^.ClientMakeLocal( MousePos);
                    Parent^.GetClientRect( R);
                    R.B.X := R.B.X - R.A.X;
                    R.B.Y := R.B.Y - R.A.Y;
                    if (MousePos.X < 0)
                    then MousePos.X := 0
                    else if (MousePos.X > R.B.X)
                    then MousePos.X := R.B.X;
                    if (MousePos.Y < 0)
                    then MousePos.Y := 0
                    else if (MousePos.Y > R.B.Y)
                    then MousePos.Y := R.B.Y;
                    if (( MousePos.X - TuchPos.X) <> DragPos.X) or (( MousePos.Y - TuchPos.Y) <> DragPos.Y)
                    then begin
                         DrawDragFrame;
                         DragPos.Assign( MousePos.X - TuchPos.X, MousePos.Y - TuchPos.Y);

                         DrawDragFrame;
                         end;
                    end;
               ClearEvent( E);
               end
          else if ((E.What = evMouseUp) and (GetState( sfDrag or sfMove)))
          then begin
               DrawDragFrame;
               EndDrag;
               SetWriteMode( NormalPut);
               SetState( sfMove, False);
               if (( DragPos.X <> Origin.X) or ( DragPos.Y <> Origin.Y))
               then Move( DragPos);
               ClearEvent( E);
               end
          else if (E.What = evKeyPress)
          then begin
               if ( E.KeyInfo.ScanCode = keyALTF4)
               then begin
                    ClearEvent( E);
                    Close;
                    Exit;
                    end
               else if ( E.KeyInfo.ScanCode = keyF5)
               then begin
                    ClearEvent( E);
                    if ( Parent <> nil)
                    then begin
                         Parent^.GetClientRect( R);
                         MousePos.X := (R.B.X - R.A.X - Size.X + metSHADOWSIZE) div 2;
                         MousePos.Y := (R.B.Y - R.A.Y - Size.Y + metSHADOWSIZE) div 2;
                         if ( MousePos.X < 0)
                         then MousePos.X := 0;
                         if ( MousePos.Y < 0)
                         then MousePos.Y := 0;
                         if (( Origin.X <> MousePos.X) or ( Origin.Y <> MousePos.Y))
                         then Move( MousePos);
                         end;
                    end;
               end;
          end;

     inherited HandleEvent( E);
end;

procedure TCaptionWindow.GetClientRect( var R: TRect);
begin
     R.A.Assign( met3DFRAME, metCAPTIONHEIGHT + met3DFRAME * 2);
     R.B.Assign( Size.X - met3DFRAME - 1 - metSHADOWSIZE, Size.Y - met3DFRAME - 1 - metSHADOWSIZE);
end;

procedure TCaptionWindow.DrawDragFrame;
begin
     TheScreen.HideMouseCursor;
     SetPColor( clrSELECTION);
     Rectangle( DragPos.X, DragPos.Y,
                 DragPos.X + Size.X - 1 - metSHADOWSIZE, DragPos.Y + Size.Y - 1 - metSHADOWSIZE);
     Rectangle( DragPos.X + 1, DragPos.Y + 1,
                 DragPos.X + Size.X - 2 - metSHADOWSIZE, DragPos.Y + Size.Y - 2 - metSHADOWSIZE);
     Rectangle( DragPos.X + 2, DragPos.Y + 2,
                 DragPos.X + Size.X - 2 - metSHADOWSIZE, DragPos.Y + Size.Y - 2 - metSHADOWSIZE);
     TheScreen.ShowMouseCursor;
end;

function TCaptionWindow.ContainsPoint( P: TPoint): Boolean;
begin
     if Inherited ContainsPoint( P)
     then begin
          MakeLocal( P);
          if (( P.X < Size.X - metSHADOWSIZE) and ( P.Y < Size.Y - metSHADOWSIZE))
          then ContainsPoint := True
          else ContainsPoint := False;
          end
     else ContainsPoint := False;
end;

procedure TCaptionWindow.Close;
begin
     Free;
end;

procedure TCaptionWindow.LoseFocus;
begin
     inherited LoseFocus;
     UpdateCommands;
end;

procedure TCaptionWindow.GainFocus;
begin
     inherited GainFocus;
     UpdateCommands;
end;

function TCaptionWindow.GetCaption: string;
begin
     if ( Caption <> nil)
     then GetCaption := Caption^
     else GetCaption := '';
end;

procedure TCaptionWindow.ChildNotify;
begin
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TLabel.Create( AX, AY: Integer; AStr: string);
begin
     inherited Create;
     Caption := AllocateString( AStr);
     Origin.Assign( AX, AY);
end;

destructor TLabel.Destroy;
begin
     if ( Caption <> nil)
     then FreeString( Caption);
     inherited Destroy;
end;

function TLabel.GetCaption: string;
begin
     if ( Caption <> nil)
     then GetCaption := Caption^
     else GetCaption := '';
end;

function TLabel.GetPosX: Integer;
begin
     GetPosX := Origin.X;
end;

function TLabel.GetPosY: Integer;
begin
     GetPosY := Origin.Y;
end;


{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TDialog.Create( ASize: TPoint; ACaption: string);
var R: TRect;
begin
     R.A.Assign( 0, 0);
     R.B := ASize;
     inherited Create( R);
     State := sfVisible or sfEnabled;
     Options := ofFramed or ofSelectable or ofCentered;
     EventMask := $FF;
     Caption := AllocateString( ACaption);
     Labels.Create;
end;

destructor TDialog.Destroy;
begin
     if ( Caption <> nil)
     then FreeString( Caption);
     Labels.Destroy;
     inherited Destroy;
end;

procedure TDialog.GetClientRect( var R: TRect);
begin
     R.A.Assign( met3DFRAME, metCAPTIONHEIGHT + met3DFRAME * 2);
     R.B.Assign( Size.X - met3DFRAME - 1 - metSHADOWSIZE, Size.Y - met3DFRAME - 1 - metSHADOWSIZE);
end;

procedure TDialog.HandleEvent( var E: TEvent);
begin
     if ( E.What = evKeyPress)
     then begin
          case E.KeyInfo.ScanCode
          of keyTAB: begin
                     E.What := evCommand;
                     if (( E.KeyInfo.ShiftStatus and shkShiftDown) <> $00)
                     then E.Command := cmSelectPrev
                     else E.Command := cmSelectNext;
                     PutEvent( E);
                     ClearEvent( E);
                     end;
             keyENTER: begin
                       {Enter}
                       E.What := evCommand;
                       E.Command := cmOk;
                       PutEvent( E);
                       ClearEvent( E);
                       end;
             keyESC: begin
                     {Escape}
                     E.What := evCommand;
                     E.Command := cmCancel;
                     PutEvent( E);
                     ClearEvent( E);
                     end;
             end;
          end
     else if ( E.What = evCommand)
     then begin
          case E.command
          of cmOk: begin
                   if DialogExitQuery( True)
                   then SetState( sfExecuted, False);
                   ClearEvent( E);
                   end;
             cmCancel: begin
                       if DialogExitQuery( False)
                       then SetState( sfExecuted, False);
                       ClearEvent( E);
                       end;
             cmSelectNext: begin
                           if ( Current <> nil)
                           then SelectNext( Current)
                           else if (First <> nil)
                                then SelectNext( First^.Prev);
                           ClearEvent( E);
                           end;
             cmSelectPrev: begin
                           if ( Current <> nil)
                           then SelectPrev( Current);
                           ClearEvent( E);
                           end;
             end;
          end;
     if ( E.What <> evNoThing)
     then inherited HandleEvent( E);
end;

function TDialog.DialogExitQuery( AAccept: Boolean): Boolean;
begin
     if AAccept
     then DialogExitQuery := ValidateData
     else DialogExitQuery := True;
end;

function TDialog.ValidateData: Boolean;
begin
     ValidateData := True;
end;

procedure TDialog.Draw;
var ScanLabel: PLabel;
begin
     BeginDraw;

     SetPFillPattern( clrSHADOW, SolidPattern);
     Bar( Size.X - metSHADOWSIZE, metSHADOWSIZE, Size.X - 1, Size.Y - 1);
     Bar( metSHADOWSIZE, Size.Y - metSHADOWSIZE, Size.X - metSHADOWSIZE - 1, Size.Y - 1);
     Draw3DBar( 0, 0, Size.X - 1 - metSHADOWSIZE, Size.Y - 1 - metSHADOWSIZE, clr3D0, clr3D1, clr3D2, clr3D3);
     SetPFillPattern( clrCAPTION, SolidPattern);
     Bar( met3DFRAME, met3DFRAME, Size.X - met3DFRAME - 1 - metSHADOWSIZE, met3DFRAME + metCAPTIONHEIGHT);

     SetPColor( clrCAPTIONTEXT);
     if ( Caption <> nil)
     then OutTextXY( 8, ( metCAPTIONHEIGHT - metTEXTHEIGHT) div 2 + met3DFRAME, Caption^);

     InitClientViewPort;
     SetPColor( clr3DTEXT);
     ScanLabel := PLabel( Labels.GetFirst);
     while ( ScanLabel <> nil)
     do begin
        OutTextXY( ScanLabel^.GetPosX, ScanLabel^.GetPosY, ScanLabel^.GetCaption);
        ScanLabel := PLabel( Labels.GetNext);
        end;

     EndDraw;
end;

procedure TDialog.AddLabel( AX, AY: Integer; ACaption: string);
begin
     Labels.PushLast( New( PLabel, Create( AX, AY, ACaption)));
end;

procedure TDialog.ChildNotify;
begin
end;


{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TAboutDlg.Create( ACaption: string);
var Sz: TPoint;
    R: TRect;
begin
     Sz.Assign( 500, 250);
     inherited Create( Sz, ACaption);
     GetClientRect( R);
     InsertChild( New( PButton, Create( R.B.X - R.A.X - 100 - metSHADOWSIZE - 10,
                                        R.B.Y - R.A.Y - 30 - metSHADOWSIZE - 10,
                                        100 + metSHADOWSIZE, 30 + metSHADOWSIZE, '&Ok', cmOk, keyO)));
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TMessageDlg.Create( ACaption: string; AMessage: string);
var Sz: TPoint;
    R: TRect;
    W: Integer;
begin
     W := TextWidth( AMessage) + 60;
     if W < 150
     then W := 150;
     Sz.Assign( W, 150);
     inherited Create( Sz, ACaption);
     Message := AllocateString( AMessage);
     GetClientRect( R);
     InsertChild( New( PButton, Create( (R.A.X + R.B.X - 100 - metSHADOWSIZE) div 2,
                  R.B.Y - R.A.Y - 30 - metSHADOWSIZE - 15, 100 + metSHADOWSIZE, 30 + metSHADOWSIZE, '&Ok', cmOk, keyO)));
end;

destructor TMessageDlg.Destroy;
begin
     if ( Message <> nil)
     then FreeString( Message);
     inherited Destroy;
end;

procedure TMessageDlg.Draw;
var R: TRect;
    W: Integer;
begin
     inherited Draw;
     if ( Message <> nil)
     then begin
          BeginDraw;
          GetClientRect( R);
          SetPColor( clr3DTEXT);
          W := TextWidth( Message^);
          OutTextXY( (R.A.X + R.B.X - W) div 2, R.A.Y + 30, Message^);
          EndDraw;
          end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TAskingDlg.Create( ACaption: string; AMessage: string);
var Sz: TPoint;
    R: TRect;
    W: Integer;
begin
     W := TextWidth( AMessage) + 60;
     if W < 150
     then W := 150;
     Sz.Assign( W, 150);
     inherited Create( Sz, ACaption);
     Message := AllocateString( AMessage);
     GetClientRect( R);
     InsertChild( New( PButton, Create( ( R.A.X + R.B.X) div 2 - (100 + metSHADOWSIZE) - 10,
                  R.B.Y - R.A.Y - 30 - metSHADOWSIZE - 15, 100 + metSHADOWSIZE, 30 + metSHADOWSIZE, '&Yes', cmOk, keyY)));
     InsertChild( New( PButton, Create( (R.A.X + R.B.X) div 2 + 5,
                  R.B.Y - R.A.Y - 30 - metSHADOWSIZE - 15, 100 + metSHADOWSIZE, 30 + metSHADOWSIZE, '&No', cmCancel, keyN)));
     Accept := False;
end;

destructor TAskingDlg.Destroy;
begin
     if ( Message <> nil)
     then FreeString( Message);
     inherited Destroy;
end;

procedure TAskingDlg.Draw;
var R: TRect;
    W: Integer;
begin
     inherited Draw;
     if ( Message <> nil)
     then begin
          BeginDraw;
          GetClientRect( R);
          SetPColor( clr3DTEXT);
          W := TextWidth( Message^);
          OutTextXY( (R.A.X + R.B.X - W) div 2, R.A.Y + 30, Message^);
          EndDraw;
          end;
end;

function TAskingDlg.DialogExitQuery( AAccept: Boolean): Boolean;
begin
     inherited DialogExitQuery( AAccept);
     Accept := AAccept;
end;

function TAskingDlg.IsAccepted: Boolean;
begin
     IsAccepted := Accept;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

procedure Message( AWindow: PWindow; ACaption: string; AMessage: string);
var Dlg: PMessageDlg;
begin
     if ( AWindow <> nil)
     then begin
          Dlg := New( PMessageDlg, Create( ACaption, AMessage));
          Dlg^.ExecuteDlg( AWindow);
          Dlg^.Free;
          end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

function MessageYN( AWindow: PWindow; ACaption: string; AMessage: string): Boolean;
var Dlg: PAskingDlg;
begin
     if ( AWindow <> nil)
     then begin
          Dlg := New( PAskingDlg, Create( ACaption, AMessage));
          Dlg^.ExecuteDlg( AWindow);
          MessageYN := Dlg^.IsAccepted;
          Dlg^.Free;
          end
     else MessageYN := False;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

function AddExtentionIfNeeded( AFullName: string; ADefaultName: string; AExtention: string): string;
var Path: array[0..fsPathName] of Char;
    Dir: array[0..fsDirectory] of Char;
    Name: array[0..fsFileName] of Char;
    Ext: array[0..fsExtension] of Char;
    Result: string;
begin
     if (( Length( AExtention) < fsExtension)
        and ( Length( AFullName) < (fsPathName - 4))
        and ( Length( ADefaultName) < fsFileName))
     then begin
          StrPCopy( Path, AFullName);
          FileSplit(Path, Dir, Name, Ext);
          if Name[0] = #0 then StrPCopy( Name, ADefaultName);
          if Ext[0] = #0 then StrPCopy( Ext, '.' + AExtention);
          StrECopy(StrECopy(StrECopy(Path, Dir), Name), Ext);
          AddExtentionIfNeeded := StrPas( Path);
          end
     else AddExtentionIfNeeded := '';
end;

function RetriveFilePath( AFullName: string): string;
var Path: array[0..fsPathName] of Char;
    Dir: array[0..fsDirectory] of Char;
    Name: array[0..fsFileName] of Char;
    Ext: array[0..fsExtension] of Char;
    Result: string;
begin
     if (Length( AFullName) < (fsPathName - 4))
     then begin
          StrPCopy( Path, AFullName);
          FileSplit( Path, Dir, Name, Ext);
          RetriveFilePath := StrPas( Dir);
          end
     else RetriveFilePath := '';
end;

function RetriveFileName( AFullName: string): string;
var Path: array[0..fsPathName] of Char;
    Dir: array[0..fsDirectory] of Char;
    Name: array[0..fsFileName] of Char;
    Ext: array[0..fsExtension] of Char;
    Result: string;
begin
     if (Length( AFullName) < (fsPathName - 4))
     then begin
          StrPCopy( Path, AFullName);
          FileSplit( Path, Dir, Name, Ext);
          StrECopy( StrECopy( Path, Name), Ext);
          RetriveFileName := StrPas( Path);
          end
     else RetriveFileName := '';
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TEdit.Create( AX, AY, AWidth: Integer; AMaxLength: Integer);
var R: TRect;
    Width: Integer;
begin
     if (AWidth > 0)
     then Width := AWidth
     else Width := (AMaxLength + 1) * TextWidth('W') + 16{6};
     R.A.Assign( AX, AY);
     R.B.X := R.A.X + Width;
     R.B.Y := R.A.Y + TextHeight('W') + 16{6};
     inherited Create( R);
     State := sfEnabled or sfVisible;
     Options := ofSelectable;
     EventMask := $FF;
     Str := '';
     Pos := 1;
     MaxLength := AMaxLength;
end;

destructor TEdit.Destroy;
begin
     inherited Destroy;
end;

procedure TEdit.UpdateView( AActivateViewPort: Boolean);
var S1, S2: string;
begin
     if AActivateViewPort
     then BeginDraw;
     SetPFillPattern( clrFIELDBACK, SolidPattern);
     Bar( 2, 2, Size.X - 3, Size.Y - 3);
     S1 := Copy(Str,1,Pos - 1);
     S2 := Copy(Str,Pos,Length(Str));
     SetPColor( clrFIELDTEXT);
     MoveTo( 8{3}, 8{3});
     OutText( S1);
     SetPColor( clrCURSOR);
     OutText('_');
     SetPColor( clrFIELDTEXT);
     OutText( S2);
     if AActivateViewPort
     then EndDraw;
end;

procedure TEdit.Draw;
begin
     BeginDraw;
     Draw3DInFrame( 0, 0, Size.X - 1, Size.Y - 1, clr3D0, clr3D1, clr3D2, clr3D3);
     if GetState( sfFocused)
     then UpdateView( False)
     else begin
          SetPFillPattern( clrFIELDBACKINACTIVE, SolidPattern);
          Bar( 2, 2, Size.X - 3, Size.Y - 3);
          SetPColor( clrFIELDTEXTINACTIVE);
          OutTextXY( 8{3}, 8{3}, Str);
          end;
     EndDraw;
end;

procedure TEdit.LoseFocus;
begin
     inherited LoseFocus;
end;

procedure TEdit.GainFocus;
begin
     inherited GainFocus;
end;

procedure TEdit.HandleEvent( var E: TEvent);
var S1, S2, S3: string;
    VUpdate: Boolean;
begin
     if GetState( sfFocused)
     then begin
          if E.What = evKeyPress
          then begin
               VUpdate := False;
               case E.KeyInfo.ScanCode
               of keyDEL: begin {Del}
                          VUpdate := Del;
                          ClearEvent( E);
                          end;
                  keyEND: begin {End}
                          VUpdate := GoEnd;
                          ClearEvent( E);
                          end;
                  keyHOME: begin {Home}
                           VUpdate := GoHome;
                           ClearEvent( E);
                           end;
                  keyLEFT: begin {Left}
                           VUpdate := GoLeft;
                           ClearEvent( E);
                           end;
                  keyRIGHT: begin {Right}
                            VUpdate := GoRight;
                            ClearEvent( E);
                            end;
                  keyBACKSPACE: begin {Back}
                                VUpdate := BackDel;
                                ClearEvent( E);
                                end;
                  else
                      if ((E.KeyInfo.CharCode >= #32) and (E.KeyInfo.CharCode <= #128))
                      then begin
                           VUpdate := Insert( E.KeyInfo.CharCode);
                           ClearEvent( E);
                           end;
                  end;
               if VUpdate
               then UpdateView( True);
               end;
          end;
     {inherited HandleEvent( E);}
end;

function TEdit.Insert( AChar: Char): Boolean;
var L: Byte;
begin
     L := Length(Str);
     if ((L < MaxLength) and ValidateChar( AChar))
     then begin
          System.Insert( AChar, Str, Pos);
          Pos := Pos + 1;
          Insert := True;
          end
     else Insert := False;
end;

function TEdit.OverWrite( AChar: Char): Boolean;
begin
end;

function TEdit.BackDel: Boolean;
begin
     if (Pos > 1)
     then begin
          System.Delete( Str, Pos - 1, 1);
          Pos := Pos - 1;
          BackDel := True;
          end
     else BackDel := False;
end;

function TEdit.Del: Boolean;
var L: Byte;
begin
     L := Length( Str);
     if (Pos <= L)
     then begin
          System.Delete( Str, Pos, 1);
          if (Pos > L)
          then Pos := L;
          Del := True;
          end
     else Del := False;
end;

function TEdit.GoLeft: Boolean;
begin
     if (Pos > 1)
     then begin
          Pos := Pos - 1;
          GoLeft := True;
          end
     else GoLeft := False;
end;

function TEdit.GoRight: Boolean;
begin
     if (Pos <= Length( Str))
     then begin
          Pos := Pos + 1;
          GoRight := True;
          end
     else GoRight := False;
end;

function TEdit.GoHome: Boolean;
begin
     if ( Pos > 1)
     then begin
          Pos := 1;
          GoHome := True;
          end
     else GoHome := False;
end;

function TEdit.GoEnd: Boolean;
var L: Byte;
begin
     L := Length( Str);
     if ( Pos <= L)
     then begin
          Pos := L + 1;
          GoEnd := True;
          end
     else GoEnd := False;
end;

function TEdit.GetText: string;
begin
     GetText := Str;
end;

procedure TEdit.SetText( AStr: string);
begin
     Str := AStr;
     Pos := Length( Str) + 1;
     UpdateView( True);
end;

function TEdit.ValidateChar( AChar: Char): Boolean;
begin
     ValidateChar := True;
end;

function TEdit.ValidateString: Boolean;
begin
     ValidateString := True;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TIntegerEdit.Create( AX, AY, AWidth: Integer; AMinValue, AMaxValue: Longint);
begin
     inherited Create( AX, AY, AWidth, 15);
     MaxValue := AMaxValue;
     MinValue := AMinValue;
end;

function TIntegerEdit.ValidateChar( AChar: Char): Boolean;
begin
     ValidateChar := AChar in ['0'..'9','-','+'];
end;

function TIntegerEdit.ValidateString: Boolean;
var Code: Integer;
    V: Longint;
begin
     Val( GetText, V, Code);
     if ( Code = 0)
     then ValidateString := ((V >= MinValue) and ( V <= MaxValue))
     else ValidateString := False;
end;

procedure TIntegerEdit.SetValue( AValue: Longint);
var S: string;
begin
     System.Str( AValue, S);
     SetText( S);
end;

function TIntegerEdit.GetValue: Longint;
var V: Longint;
    Code: Integer;
begin
     Val( GetText, V, Code);
     GetValue := V;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TFloatEdit.Create( AX, AY, AWidth: Integer; AMinValue, AMaxValue: Float);
begin
     inherited Create( AX, AY, AWidth, 15);
     MaxValue := AMaxValue;
     MinValue := AMinValue;
end;

function TFloatEdit.ValidateChar( AChar: Char): Boolean;
begin
     ValidateChar := AChar in ['0'..'9','-','+','.','e','E'];
end;

function TFloatEdit.ValidateString: Boolean;
var Code: Integer;
    V: Float;
begin
     Val( GetText, V, Code);
     if ( Code = 0)
     then ValidateString := ((V >= MinValue) and ( V <= MaxValue))
     else ValidateString := False;
end;

procedure TFloatEdit.SetValue( AValue: Float);
var S: string;
begin
     System.Str( AValue:0:2, S);
     SetText( S);
end;

function TFloatEdit.GetValue: Float;
var V: Float;
    Code: Integer;
begin
     Val( GetText, V, Code);
     GetValue := V;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TCheckBox.Create( AX, AY: Integer);
var R: TRect;
begin
     R.A.X := AX;
     R.A.Y := AY;
     R.B.X := AX + mstCHECKBOXSIZE;
     R.B.Y := AY + mstCHECKBOXSIZE;
     inherited Create( R);
     State := sfEnabled or sfVisible;
     Options := ofSelectable;
     EventMask := $FF;
     Value := False;
end;

procedure TCheckBox.SetValue( AValue: Boolean);
begin
     Value := AValue;
     Update;
end;

function TCheckBox.GetValue: Boolean;
begin
     GetValue := Value;
end;

procedure TCheckBox.Draw;
begin
     inherited Draw;
     BeginDraw;
     Draw3DInFrame( 0, 0, Size.X - 1, Size.Y - 1, clr3D0, clr3D1, clr3D2, clr3D3);
     if GetState( sfFocused)
     then begin
          SetPFillPattern( clrFIELDBACK, SolidPattern);
          Bar( 2, 2, Size.X - 3, Size.Y - 3);
          SetPColor( clrFIELDTEXT);
          end
     else begin
          SetPFillPattern( clrFIELDBACKINACTIVE, SolidPattern);
          Bar( 2, 2, Size.X - 3, Size.Y - 3);
          SetPColor( clrFIELDTEXTINACTIVE);
          end;
     if Value
     then begin
          Line( 5, 5, Size.X - 6, Size.Y - 6);
          Line( 5, 4, Size.X - 5, Size.Y - 6);
          Line( 4, 5, Size.X - 6, Size.Y - 5);

          Line( 6, 4, Size.X - 5, Size.Y - 7);
          Line( 4, 6, Size.X - 7, Size.Y - 5);

          Line( Size.X - 6, 5, 5, Size.Y - 6);
          Line( Size.X - 6, 4, 4, Size.Y - 6);
          Line( Size.X - 5, 5, 5, Size.Y - 5);

          Line( Size.X - 7, 4, 4, Size.Y - 7);
          Line( Size.X - 5, 6, 6, Size.Y - 5);
          end;
     EndDraw;
end;

procedure TCheckBox.HandleEvent( var E: TEvent);
begin
     if GetState( sfFocused)
     then begin
          if ( E.What = evMouseDown)
          then begin
               Value := not Value;
               ClearEvent( E);
               Update;
               end
          else if ( E.What = evKeyPress)
          then begin
               if ( E.KeyInfo.ScanCode = keySPACE)
               then begin
                    Value := not Value;
                    ClearEvent( E);
                    Update;
                    end
               end;
          end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TTextListLine.Create( AStr: string);
begin
     inherited Create;
     Str := AllocateString( AStr);
end;

destructor TTextListLine.Destroy;
begin
     if ( Str <> nil)
     then FreeString( Str);
     inherited Destroy;
end;

function TTextListLine.GetString: string;
begin
     if ( Str <> nil)
     then GetString := Str^
     else GetString := '';
end;

procedure TTextListLine.SetString( AStr: string);
begin
     if (Str <> nil)
     then FreeString( Str);
     Str := AllocateString( AStr);
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TTextList.Create( R: TRect);
begin
     inherited Create( R);
     State := sfEnabled or sfVisible;
     Lines.Create;
     CursorPos.Assign( 0, 0);
end;

destructor TTextList.Destroy;
begin
     Lines.Destroy;
     inherited Destroy;
end;

procedure TTextList.Draw;
var ScanLine: PTextListLine;
    YPos: Integer;
begin
     BeginDraw;
     SetPFillPattern( clrFIELDBACKINACTIVE, SolidPattern);
     Bar( 0, 0, Size.X - 1, Size.Y - 1);
     SetPColor( clrFIELDTEXT);
     YPos := Size.Y - 1 - metTEXTHEIGHT;
     ScanLine := PTextListLine( Lines.GetLast);
     while (( ScanLine <> nil) and (YPos >= 0))
     do begin
        OutTextXY( 0, YPos, ScanLine^.GetString);
        YPos := YPos - metTEXTHEIGHT;
        ScanLine := PTextListLine( Lines.GetPrev);
        end;
     EndDraw;
end;

procedure TTextList.WriteLn( AStr: string);
var NewLine: PTextListLine;
    YPos: Integer;
begin
     NewLine := New( PTextListLine, Create( AStr));
     Lines.PushLast( NewLine);
     YPos := Size.Y - 1 - metTEXTHEIGHT;
     if GetState( sfVisible)
     then begin
          BeginDraw;
          ScroolUp( metTEXTHEIGHT);
          SetPFillPattern( clrFIELDBACKINACTIVE, SolidPattern);
          Bar( 0, YPos, Size.X - 1, Size.Y - 1);
          SetPColor( clrFIELDTEXT);
          OutTextXY( 0, YPos, NewLine^.GetString);
          EndDraw;
          end;{}
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TListBoxList.Create( R: TRect; AOwnerListBox: PListBox);
begin
     inherited Create( R);
     State := sfVisible or sfEnabled;
     Options := 0;
     EventMask := $FF;
     Items.Create;
     FirstVisibleItem := nil;
     LastVisibleItem := nil;
     SelectedItem := nil;
     SelectedItemViewNo := -1;
     VisibleItemsCount := Size.Y div metLISTBOXITEMHEIGHT;
     OwnerListBox := AOwnerListBox;
end;

destructor TListBoxList.Destroy;
begin
     Items.Destroy;
     inherited Destroy;
end;

{
     TempItem := Current;
     while ( TempItem <> nil)
     do begin
        NumItems := NumItems + 1;
        if TempItem^.Title <> nil
        then begin
             if Active
             then begin
                  if TempItem^.Enabled
                  then SetPColor( TextColor)
                  else SetPColor( clrINACTIVEMENULISTTEXT);
                  end
             else SetPColor( TextColor);
             OutTextXYEx( 5, 20 + (metMENUITEMHEIGHT - metTEXTHEIGHT) div 2 + I * metMENUITEMHEIGHT - 2, TempItem^.Title^);
             I := I + 1;
             TempItem := TempItem^.Next;
             end;
        end;
}

function TListBoxList.GetViewItemNoByPos( APos: TPoint): Integer;
var No: Integer;
begin
     No := APos.Y div metLISTBOXITEMHEIGHT;
     if ( No < VisibleItemsCount)
     then GetViewItemNoByPos := No
     else GetViewItemNoByPos := VisibleItemsCount - 1;
end;

procedure TListBoxList.DrawSelectionFrame( AViewItemNo: Integer; ASelected: Boolean; AInitViewPort: Boolean);
var YPos: Integer;
begin
     if AInitViewPort
     then BeginDraw;

     if ASelected
     then SetPColor( clrSELECTION)
     else SetPColor( clrFIELDBACK);

     YPos := AViewItemNo * metLISTBOXITEMHEIGHT;
     if YPos < Size.Y
     then begin
          Rectangle( 0, YPos, Size.X - 1, YPos + metLISTBOXITEMHEIGHT - 1);
          Rectangle( 1, YPos + 1, Size.X - 2, YPos + metLISTBOXITEMHEIGHT - 2);
          end;

     if AInitViewPort
     then EndDraw;
end;

procedure TListBoxList.Draw;
var Active: Boolean;
    TextColor: Byte;
    BackColor: Byte;
    R: TRect;
    ScanItem: PListBoxListItem;
    ItemYPos: Integer;
    VisibleItemNo: Integer;
    DisplaySelectionFrame: Boolean;
begin
     BeginDraw;

     if ( Parent <> nil)
     then begin
          if Parent^.GetState( sfFocused)
          then Active := True
          else Active := False;
          end
     else Active := False;

     if Active
     then begin
          TextColor := clrFIELDTEXT;
          BackColor := clrFIELDBACK;
          DisplaySelectionFrame := True;
          end
     else begin
          TextColor := clrFIELDTEXTINACTIVE;
          BackColor := clrFIELDBACKINACTIVE;
          DisplaySelectionFrame := False;
          end;

     SetPFillPattern( BackColor, SolidPattern);
     Bar( 0, 0, Size.X - 1, Size.Y - 1);

     ItemYPos := ( metLISTBOXITEMHEIGHT - metTEXTHEIGHT) div 2;

     if FirstVisibleItem = nil
     then FirstVisibleItem := PListBoxListItem( Items.GetFirst);
     ScanItem := FirstVisibleItem;
     VisibleItemNo := 0;
     SelectedItemViewNo := -1;
     SetPColor( TextColor);
     while (( ScanItem <> nil) and ( VisibleItemNo < VisibleItemsCount))
     do begin
        OutTextXY( 2, ItemYPos, ScanItem^.GetString);
        if (SelectedItem = ScanItem)
        then begin
             SelectedItemViewNo := VisibleItemNo;
             if DisplaySelectionFrame
             then begin
                  DrawSelectionFrame( SelectedItemViewNo, True, False);
                  SetPColor( TextColor);
                  end;
             end;
        LastVisibleItem := ScanItem;
        ScanItem := PListBoxListItem( Items.GetAfter( ScanItem));
        ItemYPos := ItemYPos + metLISTBOXITEMHEIGHT;
        VisibleItemNo := VisibleItemNo + 1;
        end;

     EndDraw;
end;

procedure TListBoxList.AddItem( AItem: PListBoxListItem; AUpdate: Boolean);
begin
     if ( AItem <> nil)
     then begin
          Items.PushLast( AItem);
          if ( FirstVisibleItem = nil)
          then FirstVisibleItem := PListBoxListItem( Items.GetFirst);
          if ( SelectedItem = nil)
          then begin
               SelectedItem := FirstVisibleItem;
               SelectedItemViewNo := -1;
               end;
          if AUpdate
          then Update;
          end;
end;

procedure TListBoxList.ClearItems;
begin
     FirstVisibleItem := nil;
     LastVisibleItem := nil;
     SelectedItem := nil;
     SelectedItemViewNo := -1;
     Items.Clear;
end;

procedure TListBoxList.HandleEvent( var E: TEvent);
var Active: Boolean;
    NewSelectedItem: PListBoxListItem;
    Pos: TPoint;
    MouseItem: Integer;
    I: Integer;
begin
     if E.What = evMouseDown
     then begin
          Pos := E.MouseInfo.Where;
          MakeLocal( Pos);
          MouseItem := GetViewItemNoByPos( Pos);
          if ( MouseItem <> SelectedItemViewNo)
          then begin
               NewSelectedItem := FirstVisibleItem;
               I := MouseItem;
               while (( NewSelectedItem <> nil) and ( I > 0))
               do begin
                  NewSelectedItem := PListBoxListItem( Items.GetAfter( NewSelectedItem));
                  I := I - 1;
                  end;
               if ( NewSelectedItem <> nil)
               then begin
                    SelectedItem := NewSelectedItem;
                    DrawSelectionFrame( SelectedItemViewNo, False, True);
                    SelectedItemViewNo := MouseItem;
                    DrawSelectionFrame( SelectedItemViewNo, True, True);
                    end;
               end;
          SelectItem( SelectedItem);
          end
     else if E.What = evKeyPress
     then begin
          if ( Parent <> nil)
          then begin
               if Parent^.GetState( sfFocused)
               then Active := True
               else Active := False;
               end
          else Active := False;
          if Active
          then begin
               case E.KeyInfo.ScanCode
               of keyUP: begin
                         if ( SelectedItem <> nil)
                         then begin
                              if ( SelectedItemViewNo >= 0)
                              then begin
                                   NewSelectedItem := PListBoxListItem( Items.GetBefore( SelectedItem));
                                   if ( NewSelectedItem <> nil)
                                   then begin
                                        if ( SelectedItem = FirstVisibleItem)
                                        then begin
                                             FirstVisibleItem := NewSelectedItem;
                                             SelectedItem := NewSelectedItem;
                                             UpDate;
                                             end
                                        else begin
                                             SelectedItem := NewSelectedItem;
                                             DrawSelectionFrame( SelectedItemViewNo, False, True);
                                             SelectedItemViewNo := SelectedItemViewNo - 1;
                                             DrawSelectionFrame( SelectedItemViewNo, True, True);
                                             end;
                                        end;
                                   end
                              else begin
                                   FirstVisibleItem := SelectedItem;
                                   Update;
                                   end;
                              end
                         else begin
                              SelectedItem := PListBoxListItem( Items.GetFirst);
                              FirstVisibleItem := SelectedItem;
                              Update;
                              end;
                         ClearEvent( E);
                         end;
                  keyDOWN: begin
                           if ( SelectedItem <> nil)
                           then begin
                                if ( SelectedItemViewNo >= 0)
                                then begin
                                     NewSelectedItem := PListBoxListItem( Items.GetAfter( SelectedItem));
                                     if ( NewSelectedItem <> nil)
                                     then begin
                                          if ( SelectedItem = LastVisibleItem)
                                          then begin
                                               FirstVisibleItem := PListBoxListItem( Items.GetAfter( FirstVisibleItem));
                                               SelectedItem := NewSelectedItem;
                                               UpDate;
                                               end
                                          else begin
                                               SelectedItem := NewSelectedItem;
                                               DrawSelectionFrame( SelectedItemViewNo, False, True);
                                               SelectedItemViewNo := SelectedItemViewNo + 1;
                                               DrawSelectionFrame( SelectedItemViewNo, True, True);
                                               end;
                                          end;
                                     end
                                else begin
                                     FirstVisibleItem := SelectedItem;
                                     Update;
                                     end;
                                end
                           else begin
                                SelectedItem := PListBoxListItem( Items.GetFirst);
                                FirstVisibleItem := SelectedItem;
                                Update;
                                end;
                           ClearEvent( E);
                           end;
                  keySPACE: begin
                            SelectItem( SelectedItem);
                            ClearEvent( E);
                            end;
                  end;
               end;
          end
     else if E.What = evCommand
     then begin
          case E.Command
          of cmScrollUp: begin
                         NewSelectedItem := PListBoxListItem( Items.GetBefore( FirstVisibleItem));
                         if ( NewSelectedItem <> nil)
                         then begin
                              FirstVisibleItem := NewSelectedItem;
                              Update;
                              Delay( 50);
                              end;
                         ClearEvent( E);
                         end;
             cmScrollDown: begin
                           NewSelectedItem := PListBoxListItem( Items.GetAfter( FirstVisibleItem));
                           if ( NewSelectedItem <> nil)
                           then begin
                                FirstVisibleItem := NewSelectedItem;
                                Update;
                                Delay( 50);
                                end;
                           ClearEvent( E);
                           end
             end;
          end;
     if E.What <> evNothing
     then inherited HandleEvent( E);
end;

procedure TListBoxList.SelectItem( AItem: PListBoxListItem);
begin
     if (( OwnerListBox <> nil) and ( AItem <> nil))
     then OwnerListBox^.SelectItem( AItem);
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TListBox.Create( R: TRect);
var R2: TRect;
begin
     inherited Create( R);
     State := sfVisible or sfEnabled;
     Options := ofSelectable {or ofFramed};
     EventMask := $FF;
     R2.A.X := 2;
     R2.A.Y := 2;
     R2.B.X := Size.X - 2 - 26;
     R2.B.Y := Size.Y - 2;
     List := New( PListBoxList, Create( R2, @Self));
     GetClientRect( R2);
     R2.A.X := Size.X - 1 - 25;
     R2.A.Y := 0;
     R2.B.X := Size.X;
     R2.B.Y := Size.Y;
     Scroller := New( PScrollBar, Create( R2, List, True, 10, 100, 0));
     InsertChild( List);
     InsertChild( Scroller);
end;

destructor TListBox.Destroy;
begin
     inherited Destroy;
end;

procedure TListBox.Draw;
var FrameColor: Byte;
    BackColor: Byte;
begin
     BeginDraw;
     Draw3DInFrame( 0, 0, Size.X - 27, Size.Y - 1, clr3D0, clr3D1, clr3D2, clr3D3);
     EndDraw;
end;

procedure TListBox.AddItem( AItem: PListBoxListItem; AUpdate: Boolean);
begin
     List^.AddItem( AItem, AUpdate);
end;

procedure TListBox.ClearItems;
begin
     List^.ClearItems
end;

procedure TListBox.HandleEvent( var E: TEvent);
begin
     inherited HandleEvent( E);
end;

procedure TListBox.SelectItem( AItem: PListBoxListItem);
begin
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TScrollControl.Create( R: TRect; ARange: Integer; AValue: Integer);
begin
     inherited Create( R);
     State := sfEnabled or sfVisible;
     EventMask := $FF;
     Range := ARange;
     SetValue( AValue);
     TuchBttn := 0;
end;

destructor TScrollControl.Destroy;
begin
     inherited Destroy;
end;

procedure TScrollControl.Draw;
var I, X, Y: Integer;
    Active: Boolean;
    S: string;
begin
     if ( Parent <> nil)
     then begin
          if Parent^.GetState( sfFocused)
          then Active := True
          else Active := False;
          end
     else Active := False;
     BeginDraw;

     {Draw3DInBar( 0, 0,
                    Size.X - 1, Size.Y - 1,
                    clr3D0, clr3D1, clr3D2, clr3D3);}
     Draw3DInFrame( 0, 0, Size.X - 1, Size.Y - 1, clr3D0, clr3D1, clr3D2, clr3D3);
     SetPFillPattern( clr3D3, SolidPattern);
     Bar( mstSCROLLBTNWIDTH + 1, 2, Size.X - mstSCROLLBTNWIDTH - 1, Size.Y - 3);
     {Draw3DBar( 2, 2, mstSCROLLBTNWIDTH - 2, Size.Y - 3, clr3D0, clr3D1, clr3D2, clr3D3);}
     Draw3DBar( 2, 2,
                mstSCROLLBTNWIDTH, Size.Y - 3,
                clr3D0, clr3D1, clr3D2, clr3D3);
     Draw3DBar( Size.X - mstSCROLLBTNWIDTH, 2,
                Size.X  - 3, Size.Y - 3,
                clr3D0, clr3D1, clr3D2, clr3D3);
     Draw3DBar( Pos + mstSCROLLBTNWIDTH + 1, 2,
                Pos + mstSCROLLBTNWIDTH * 2 + 1, Size.Y - 3,
                clr3D0, clr3D1, clr3D2, clr3D3);

     SetPColor( clr3DTEXT);

     X :=  mstSCROLLBTNWIDTH div 2 - 1;
     Y := Size.Y div 2 - 1;

     Line( X - 4, Y, X + 5, Y);
     Line( X - 4, Y + 1, X + 5, Y + 1);

     X :=  Size.X - mstSCROLLBTNWIDTH div 2 - 1;

     Line( X - 4, Y, X + 5, Y);
     Line( X - 4, Y + 1, X + 5, Y + 1);
     Line( X, Y - 4, X, Y + 5);
     Line( X + 1, Y - 4, X + 1, Y + 5);


     X := Pos + mstSCROLLBTNWIDTH div 2 + 1;
     Str( GetValue, S);
     OutTextXY( mstSCROLLBTNWIDTH + X - TextWidth(S) div 2, ( Size.Y - metTEXTHEIGHT) div 2, S);
     EndDraw;
end;

procedure TScrollControl.HandleEvent( var E: TEvent);
var MousePos: TPoint;
    NewPos: Integer;
    Value: Integer;
    X: Integer;
    ValueChanged: Boolean;
    procedure DrawFeedBack;
    begin
         X := Pos + ((mstSCROLLBTNWIDTH * 3) div 2) + 1;
         Rectangle( Pos + mstSCROLLBTNWIDTH + 1, 2,
                    Pos + mstSCROLLBTNWIDTH * 2 + 1, Size.Y - 3);
         Rectangle( Pos + mstSCROLLBTNWIDTH + 2, 3,
                    Pos + mstSCROLLBTNWIDTH * 2 + 0, Size.Y - 4);
   end;

    function ProcessIncDecBttns( AXPos: Longint): Boolean;
    begin
         ProcessIncDecBttns := False;
         if ( MousePos.X <= mstSCROLLBTNWIDTH)
         then begin
              Value := GetValue;
              if ( Value > 0)
              then begin
                   SetValue( Value - 1);
                   ValueChanged := True;
                   end;
              ProcessIncDecBttns := True;
              TuchBttn := 1;
              end
         else if ( MousePos.X >= Size.X - mstSCROLLBTNWIDTH)
         then begin
              Value := GetValue;
              if ( Value < Range)
              then begin
                   SetValue( Value + 1);
                   ValueChanged := True;
                   end;
              ProcessIncDecBttns := True;
              TuchBttn := 2;
              end;
    end;
begin
     ValueChanged := False;
     if E.What = evMouseDown
     then begin
          MousePos := E.MouseInfo.Where;
          MakeLocal( MousePos);
          TuchBttn := 0;
          if ProcessIncDecBttns( MousePos.X)
          then BeginDrag
          else if ((MousePos.X >= Pos + mstSCROLLBTNWIDTH) and (MousePos.X <= Pos + (mstSCROLLBTNWIDTH * 2)))
               then begin
                    TuchBttn := 3;
                    TuchPos.X := MousePos.X - Pos - mstSCROLLBTNWIDTH;
                    TuchPos.Y := MousePos.Y;
                    BeginDraw;
                    SetPColor( clrSELECTION);
                    SetWriteMode( XorPut);
                    DrawFeedBack;
                    EndDraw;
                    BeginDrag;
                    end;
          ClearEvent( E);
          end
     else if E.What = evMouseUp
     then begin
          if GetState( sfDrag)
          then begin
               if TuchBttn = 3
               then begin
                    BeginDraw;
                    SetPColor( clrSELECTION);
                    SetWriteMode( XorPut);
                    DrawFeedBack;
                    EndDraw;
                    EndDrag;
                    SetValue( GetValue);
                    ValueChanged := True;
                    end
               else EndDrag;
               end;
          ClearEvent( E);
          end
     else if E.What = evMouseDrag
     then begin
          if GetState( sfDrag)
          then begin
               MousePos := E.MouseInfo.Where;
               MakeLocal( MousePos);
               if TuchBttn = 3
               then begin
                    NewPos := MousePos.X - TuchPos.X - mstSCROLLBTNWIDTH ;
                    if (NewPos < 0)
                    then NewPos := 0
                    else if (NewPos > Size.X - mstSCROLLBTNWIDTH * 3 - 2)
                    then NewPos := Size.X - mstSCROLLBTNWIDTH * 3  - 2;
                    if ( NewPos <> Pos)
                    then begin
                         BeginDraw;
                         SetPColor( clrSELECTION);
                         SetWriteMode( XorPut);
                         DrawFeedBack;
                         Pos := NewPos;
                         DrawFeedBack;
                         EndDraw;
                         end;
                    end;
               end;
          ClearEvent( E);
          end
     else if ( E.What = evMouseRepeat)
     then begin
          if GetState( sfDrag)
          then begin
               if TuchBttn = 1
               then begin
                    Value := GetValue;
                    if ( Value > 0)
                    then SetValue( Value - 1);
                    end
               else if TuchBttn = 2
               then begin
                    Value := GetValue;
                    if ( Value < Range)
                    then SetValue( Value + 1);
                    end
               end;
          ClearEvent( E);
          end;

     if ValueChanged
     then ChildNotify( @Self);

     inherited HandleEvent( E);
end;

function TScrollControl.GetValue: Integer;
begin
     GetValue := Round(Longint(Range) * Longint(Pos) / Longint(Size.X - mstSCROLLBTNWIDTH * 3 - 2));
end;

procedure TScrollControl.SetValue( AValue: Integer);
begin
     if AValue > Range
     then AValue := Range
     else if AValue < 0
     then AValue := 0;

     Pos := Round(Longint(Size.X - mstSCROLLBTNWIDTH * 3 - 2) * Longint(AValue) / Longint( Range));
     Update;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TFilesListBox.Create( ADialog: PFileDlg; R: TRect; AFilesType: TFileType);
begin
     inherited Create( R);
     Dialog := ADialog;
     FilesType := AFilesType;
end;

destructor TFilesListBox.Destroy;
begin
     inherited Destroy;
end;

procedure TFilesListBox.FillWithFiles( AMask: string);
var ListItem: PTextListLine;
    NameLength: Byte;
    Name: string;
    ScanFileInfo: TSearchRec;
    Attr: Word;
begin
     ClearItems;
     Name := AMask + #0;
     Attr := 0;

     FindFirst( PChar(@Name[1]), faAnyFile, ScanFileInfo);
     while DosError = 0
     do begin
        ScanFileInfo.Attr := ScanFileInfo.Attr and not faArchive;
        if ((FilesType = ftDir) and (( ScanFileInfo.Attr and faDirectory) = faDirectory))
           or ((FilesType = ftFile) and (( ScanFileInfo.Attr and faDirectory) = 0))
        then begin
             NameLength := 0;
             while (( ScanFileInfo.Name[NameLength] <> #0) and (NameLength < 12))
             do begin
                Name[NameLength + 1] := ScanFileInfo.Name[NameLength];
                NameLength := NameLength + 1;
                end;
             Name[0] := Char( NameLength);
             AddItem( New( PListBoxListItem, Create( Name)), False);
             end;
        FindNext( ScanFileInfo);
        end;
     Update;
end;

procedure TFilesListBox.HandleEvent( var E: TEvent);
begin
     inherited HandleEvent( E);
end;

procedure TFilesListBox.SelectItem( AItem: PListBoxListItem);
begin
     if (( Dialog <> nil) and ( AItem <> nil))
     then begin
          if FilesType = ftFile
          then Dialog^.SetFile( AItem^.GetString)
          else if FilesType = ftDir
          then Dialog^.SetDir( AItem^.GetString)
          end;
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

constructor TFileDlg.Create( ADefFileName: string; AOpen: Boolean; AExtention: string);
var P: TPoint;
    R: TRect;
begin
     Open := AOpen;
     P.Assign( 500, 430);
     if Open
     then inherited Create( P, 'Open file')
     else inherited Create( P, 'Save file');

     FileName := RetriveFileName( ADefFileName);
     FilePath := RetriveFilePath( ADefFileName);
     FileSelected := False;

     Lock;
     FileNameEdit := New( PEdit, Create( 100, 20, 360, 255));
     InsertChild( FileNameEdit);
     FilterEdit := New( PEdit, Create( 100, 60, 150, 12));
     InsertChild( FilterEdit);

     Extention := AExtention;
     FilterEdit^.SetText('*.' + AExtention);

     R.A.Assign( 20, 100);
     R.B.Assign( 20 + 160, 100 + 280);
     FilesList := New( PFilesListBox, Create( @Self, R, ftFile));
     InsertChild( FilesList);
     R.A.Assign( 20 + 170, 100);
     R.B.Assign( 20 + 325, 100 + 280);
     DirsList := New( PFilesListBox, Create( @Self, R, ftDir));
     InsertChild( DirsList);

     AddLabel( 20, 25 + 3, 'File name');
     AddLabel( 20, 65 + 3, 'Filter');

     if Open
     then InsertChild( New( PButton, Create( 360, 310, 100 + metSHADOWSIZE, 30, '&Open', cmOk, keyO)))
     else InsertChild( New( PButton, Create( 360, 310, 100 + metSHADOWSIZE, 30, '&Save', cmOk, keyS)));
     InsertChild( New( PButton, Create( 360, 350, 100 + metSHADOWSIZE, 30, '&Cancel', cmCancel, keyC)));
     Unlock;
end;

procedure TFileDlg.FillLists;
begin
     FilesList^.FillWithFiles( FilterEdit^.GetText);
     DirsList^.FillWithFiles( '*.*');
end;

procedure TFileDlg.BeforeExecuteDlg;
begin
     GetDir( 0, StartPath);
     StartPath := StartPath + '\';
     if ( FilePath <> '')
     then ChDir( FilePath + '.')
     else FilePath := StartPath;
     FillLists;
     FileNameEdit^.SetText( FileName);
end;

procedure TFileDlg.AfterExecuteDlg;
begin
     ChDir( StartPath + '.');
     FileName := FileNameEdit^.GetText;
end;

function TFileDlg.ValidateData: Boolean;
var F: file;
    FullName: string;
begin
     FileName := FileNameEdit^.GetText;
     FilePath := RetriveFilePath( FileName);
     FileName := RetriveFileName( FileName);
     ChDir( FilePath + '.');
     GetDir( 0, FilePath);
     FilePath := FilePath + '\';
     FullName := FilePath + FileName;
     FullName := AddExtentionIfNeeded( FullName, 'NONAME', Extention);
     FileName := RetriveFileName( FullName);
     FilePath := RetriveFilePath( FullName);
     FileNameEdit^.SetText( FileName);

     if Open
     then begin
          Assign( F, FullName);
          {$I-}
          Reset( F);
          if ( IOResult <> 0)
          then ValidateData := False
          else begin
               { File exists }
               ValidateData := True;
               FileSelected := True;
               Close( F);
               end;
          end
     else begin
          Assign( F, FullName);
          {$I-}
          Reset( F);
          if ( IOResult <> 0)
          then FileSelected := True
          else begin
               { File exists }
               Close( F);
               FileSelected := MessageYN( @Self, 'WARNING', 'Over write the file ~' + FileName + '~?');
               end;
          ValidateData := FileSelected;
          end;
end;

procedure TFileDlg.SetFile( AFileName: string);
begin
     FileName := AFileName;
     FileNameEdit^.SetText( FileName);
end;

procedure TFileDlg.SetDir( ADirName: string);
begin
     FileName := '';
     FileNameEdit^.SetText( FileName);
     ChDir( ADirName);
     GetDir( 0, FilePath);
     FilePath := FilePath + '\';
     FillLists;
end;

function TFileDlg.GetFileNameFP: string;
begin
     GetFileNameFP := FilePath + FileName;
end;

function TFileDlg.GetFileName: string;
begin
     GetFileName := FileName;
end;

function TFileDlg.IsFileSelected: Boolean;
begin
     IsFileSelected := FileSelected;
end;

end.