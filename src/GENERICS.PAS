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
{*  FILE: GENERICS.PAS                                                     *}
{*                                                                         *}
{***************************************************************************}

unit Generics;

interface

uses Strings;

const
     ITEMLINKSGROUPSIZE = 1024;
     MEMSTREAMBLOCKSIZE = 128;

type
    PWord = ^TWord;
    TWord = record
        case Integer
        of 0:(Word: Word);
           1:(Lo: Byte; Hi: Byte);
        end;

    PString = ^string;

    PPGeneric = ^PGeneric;
    PGeneric = ^TGeneric;
    TGeneric = object
    public
        constructor Create;
        destructor Destroy; virtual;
        procedure Free; virtual;
        function Clone: PGeneric; virtual;
        end;

    PError = ^TError;
    TError = object( TGeneric)
        end;

    PMessageError = ^TMessageError;
    TMessageError = object( TError)
    private
        Message: PString;
    public
        constructor Create( AMessage: string);
        destructor Destroy; virtual;
        function GetMessage: string;
        end;

    PErrGeneric = ^TErrGeneric;
    TErrGeneric = object( TGeneric)
    private
        Owner: PErrGeneric;
    public
        constructor Create( AOwner: PErrGeneric);
        function AddError( AError: PError): Boolean; virtual;
        function AnyError: Boolean; virtual;
        function GetErrorsCount: Word; virtual;
        function GetError( AErrorIndex: Word): PError; virtual;
        end;

    PItemLink = ^TItemLink;
    TItemLink = record
        Item : PGeneric;
        Next : PItemLink;
        Prev : PItemLink;
        end;

    PItemLinksGroup = ^TItemLinksGroup;
    TItemLinksGroup = record
        Next: PItemLinksGroup;
        Links: array[1..ITEMLINKSGROUPSIZE] of TItemLink;
        end;

    PCollection = ^TCollection;
    TCollection = object( TGeneric)
    private
        First, Last, Current: PItemLink;
    public
        constructor Create;
        destructor Destroy; virtual;
        procedure Clear;
        procedure WhenFreeCollectionItem( AItem: PGeneric); virtual;
        function GetItemsCount: Word;
        procedure PushLast( AItem: PGeneric);
        function PopLast: PGeneric;
        procedure PushFirst( AItem: PGeneric);
        function PopFirst: PGeneric;
        function RemoveFromCollection( AItem: PGeneric): Boolean;
        function GetFirst: PGeneric;
        function GetLast: PGeneric;
        function GetNext: PGeneric;
        function GetPrev: PGeneric;
        function GetByIndex( AIndex: Integer): PGeneric;
        function GetAfter( AItem: PGeneric): PGeneric;
        function GetBefore( AItem: PGeneric): PGeneric;
        function InsertAfter( AItem, NewItem: PGeneric): Boolean;
        function InsertBefore( AItem, NewItem: PGeneric): Boolean;
        function PushCollectionFirst( ACollection: PCollection): Boolean;
        function PushCollectionLast( ACollection: PCollection): Boolean;
        function PushCollectionFirstReversed( ACollection: PCollection): Boolean;
        function PushCollectionLastReversed( ACollection: PCollection): Boolean;
        function IsMember( AItem: PGeneric): Boolean;
        function IsSameAs( ACollection: PCollection): Boolean;
        function IsComprise( ACollection: PCollection): Boolean;
        procedure MergeWith( ACollection: PCollection); virtual;
        procedure AddIntersection( ACollection1, ACollection2: PCollection);
        end;

    PContainerCollection = ^TContainerCollection;
    TContainerCollection = object( TCollection)
    public
        procedure WhenFreeCollectionItem( AItem: PGeneric); virtual;
        procedure MergeWith( ACollection: PCollection); virtual;
        procedure AddIntersection( ACollection1, ACollection2: PCollection);
        end;

    PTopErrGeneric = ^TTopErrGeneric;
    TTopErrGeneric = object( TErrGeneric)
    private
        Errors: PContainerCollection;
    public
        constructor Create;
        destructor Destroy; virtual;
        function AddError( AError: PError): Boolean; virtual;
        function AnyError: Boolean; virtual;
        function GetErrorsCount: Word; virtual;
        function GetError( AErrorIndex: Word): PError; virtual;
        end;

    PStream = ^TStream;
    TStream = object( TGeneric)
    private
        ErrorMessage: PString;
        ErrorCode: Integer;
    public
        constructor Create;
        destructor Destroy; virtual;
        procedure SetPos( APos: Longint); virtual;
        function GetPos: Longint; virtual;
        function GetSize: Longint; virtual;
        function Read( var ABuf; ASize: Word): Word; virtual;
        function Write( var ABuf; ASize: Word): Word; virtual;
        procedure WriteStr( AString: string); virtual;
        procedure NewLine; virtual;
        procedure WriteInt( AValue: Longint); virtual;
        procedure WriteIntF( AValue: Longint; AWidth: Integer); virtual;
        procedure Error( AErrorCode: Integer; AErrorMessage: string); virtual;
        function GetErrorCode: Integer; virtual;
        function GetErrorMessage: string; virtual;
        procedure ClearError; virtual;
        procedure SaveData( AStream: PStream);
        procedure LoadData( AStream: PStream);
        end;

    PMemStreamDataBlock = ^TMemStreamDataBlock;
    TMemStreamDataBlock = record
        No: Longint;
        Next: PMemStreamDataBlock;
        Data: array[0..MEMSTREAMBLOCKSIZE - 1] of Byte;
        end;

    PMemStream = ^TMemStream;
    TMemStream = object( TStream)
        FirstBlock: PMemStreamDataBlock;
        LastBlock: PMemStreamDataBlock;
        Size: Longint;
        CurrentBlock: PMemStreamDataBlock;
        CurrentOffset: Word;
        constructor Create;
        destructor Destroy; virtual;
        procedure SetPos( APos: Longint); virtual;
        function GetPos: Longint; virtual;
        function GetSize: Longint; virtual;
        function Read( var ABuf; ASize: Word): Word; virtual;
        function Write( var ABuf; ASize: Word): Word; virtual;
        procedure DebugDump;
        end;

    TFileStreamMode = (fstCreate, fstOpenRead, fstOpenWrite, fstOpen);

    PFileStream = ^TFileStream;
    TFileStream = object( TStream)
    private
         Opened: Boolean;
         Mode: TFileStreamMode;
         F: File;
    public
        constructor Create( AFileName: string; AMode: TFileStreamMode);
        destructor Destroy; virtual;
        function Read( var ABuf; ASize: Word): Word; virtual;
        function Write( var ABuf; ASize: Word): Word; virtual;
        procedure SetPos( APos: Longint); virtual;
        function GetPos: Longint; virtual;
        function GetSize: Longint; virtual;
        end;

    function AllocateString( AString: string): PString;
    procedure FreeString( AString: PString);
    function AllocateItemLink: PItemLink;
    procedure FreeItemlink( ALink: PItemLink);
    procedure GenericsInit;
    procedure GenericsDone;

implementation

{******************************************************************}
{*                                                                *}
{******************************************************************}

function AllocateString( AString: string): PString;
var NewString: PString;
begin
     if ( Length( AString) > 0)
     then begin
          GetMem( NewString, Length( AString) + 1);
          NewString^ := AString;
          AllocateString := NewString;
          end
     else AllocateString := nil;
end;

procedure FreeString( AString: PString);
begin
     if ( AString <> nil)
     then FreeMem( AString, Length( AString^) + 1);
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TGeneric.Create;
begin
end;

destructor TGeneric.Destroy;
begin
end;

procedure TGeneric.Free;
var TempGeneric : PGeneric;
begin
     TempGeneric := @Self;
     Dispose( TempGeneric, Destroy);
end;

function TGeneric.Clone: PGeneric;
begin
     Clone := nil;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TMessageError.Create( AMessage: string);
begin
     inherited Create;
     Message := AllocateString( AMessage);
end;

destructor TMessageError.Destroy;
begin
     FreeString( Message);
     inherited Destroy;
end;

function TMessageError.GetMessage: string;
begin
     if ( Message <> nil)
     then GetMessage := Message^
     else GetMessage := '';
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TErrGeneric.Create( AOwner: PErrGeneric);
begin
     inherited Create;
     Owner := AOwner;
end;

function TErrGeneric.AddError( AError: PError): Boolean;
begin
     if ( Owner <> nil)
     then AddError := Owner^.AddError( AError)
     else begin
          AError^.Free;
          AddError := False;
          end;
end;

function TErrGeneric.AnyError: Boolean;
begin
     if ( Owner <> nil)
     then begin
          AnyError := Owner^.AnyError;
          end
     else AnyError := False;
end;


function TErrGeneric.GetErrorsCount: Word;
begin
     if ( Owner <> nil)
     then GetErrorsCount := Owner^.GetErrorsCount
     else GetErrorsCount := 0;
end;

function TErrGeneric.GetError( AErrorIndex: Word): PError;
begin
     if ( Owner <> nil)
     then GetError := Owner^.GetError( AErrorIndex)
     else GetError := nil;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TCollection.Create;
begin
     inherited Create;
     First := nil;
     Last := nil;
     Current := nil;
end;

destructor TCollection.Destroy;
begin
     Clear;
     inherited Destroy;
end;

procedure TCollection.Clear;
begin
     Current := First;
     while ( Current <> nil)
     do begin
        WhenFreeCollectionItem( Current^.Item);
        First := Current^.Next;
        FreeItemlink( Current);
        Current := First;
        end;
     Current := nil;
     First := nil;
     Last := nil;
end;

procedure TCollection.WhenFreeCollectionItem( AItem: PGeneric);
begin
end;

function TCollection.GetItemsCount: Word;
var C: Word;
    TempItem: PItemLink;
begin
     TempItem := First;
     C := 0;
     while ( TempItem <> nil)
     do begin
        C := C + 1;
        TempItem := TempItem^.Next;
        end;
     GetItemsCount := C;
end;

procedure TCollection.PushLast( AItem: PGeneric);
var NewItem: PItemLink;
begin
     if ( AItem <> nil)
     then begin
          NewItem := AllocateItemLink;
          NewItem^.Next := nil;
          NewItem^.Prev := Last;
          NewItem^.Item := AItem;
          Current := NewItem;
          if ( First <> nil)
          then Last^.Next := NewItem
          else First := NewItem;
          Last := NewItem;
          end;
end;

function TCollection.PopLast: PGeneric;
var TempItem: PItemLink;
begin
     if ( First <> nil)
     then begin
          TempItem := Last;
          Last := Last^.Prev;
          Current := Last;
          if ( Last = nil)
          then First := nil
          else Last^.Next := nil;
          PopLast := TempItem^.Item;
          FreeItemlink( TempItem);
          end
     else PopLast := nil;
end;

procedure TCollection.PushFirst( AItem: PGeneric);
var NewItem: PItemLink;
begin
     if ( AItem <> nil)
     then begin
          NewItem := AllocateItemLink;
          NewItem^.Next := First;
          NewItem^.Prev := nil;
          NewItem^.Item := AItem;
          Current := NewItem;
          if ( First <> nil)
          then begin
               First^.Prev := NewItem;
               First := NewItem;
               end
          else begin
               First := NewItem;
               Last := NewItem;
               end;
          end;
end;

function TCollection.PopFirst: PGeneric;
var TempItem: PItemLink;
begin
     if ( First <> nil)
     then begin
          TempItem := First;
          First := First^.Next;
          Current := First;
          if ( First = nil)
          then Last := nil
          else First^.Prev := nil;
          PopFirst := TempItem^.Item;
          FreeItemlink( TempItem);
          end
     else PopFirst := nil;
end;

function TCollection.RemoveFromCollection( AItem: PGeneric): Boolean;
var TempItem: PItemLink;
begin
     TempItem := First;
     while ( TempItem <> nil)
     do if ( TempItem^.Item <> AItem)
        then TempItem := TempItem^.Next
        else begin
             if ( TempItem^.Next <> nil)
             then TempItem^.Next^.Prev := TempItem^.Prev
             else Last := TempItem^.Prev;
             if ( TempItem^.Prev <> nil)
             then TempItem^.Prev^.Next := TempItem^.Next
             else First := TempItem^.Next;
             Current := First;
             FreeItemlink( TempItem);
             RemoveFromCollection := True;
             Exit;
             end;
     RemoveFromCollection := False;
end;

function TCollection.GetFirst: PGeneric;
begin
     if ( First <> nil)
     then begin
          Current := First;
          GetFirst := Current^.Item;
          end
     else begin
          Current := nil;
          GetFirst := nil;
          end;
end;

function TCollection.GetLast: PGeneric;
begin
     if ( Last <> nil)
     then begin
          Current := Last;
          GetLast := Current^.Item;
          end
     else begin
          Current := nil;
          GetLast := nil;
          end;
end;

function TCollection.GetNext: PGeneric;
begin
     if (( Current <> nil) and ( Current <> Last))
     then begin
          Current := Current^.Next;
          GetNext := Current^.Item;
          end
     else begin
          Current := nil;
          GetNext := nil;
          end;
end;

function TCollection.GetPrev: PGeneric;
begin
     if (( Current <> nil) and ( Current <> First))
     then begin
          Current := Current^.Prev;
          GetPrev := Current^.Item;
          end
     else begin
          Current := nil;
          GetPrev := nil;
          end;
end;

function TCollection.GetByIndex( AIndex: Integer): PGeneric;
var C: Word;
    TempItem: PItemLink;
begin
     TempItem := First;
     C := 1;
     while (( TempItem <> nil) and (C <= AIndex))
     do if (C <> AIndex)
        then begin
             C := C + 1;
             TempItem := TempItem^.Next;
             end
        else begin
             Current := TempItem;
             GetByIndex := TempItem^.Item;
             exit;
             end;
     GetByIndex := nil;
end;

function TCollection.GetAfter( AItem: PGeneric): PGeneric;
var TempCurrent: PItemLink;
begin
     TempCurrent := First;
     while ( TempCurrent <> nil)
     do begin
        if ( TempCurrent^.Item = AItem)
        then if ( TempCurrent^.Next <> nil)
             then begin
                  Current := TempCurrent^.Next;
                  GetAfter := TempCurrent^.Next^.Item;
                  exit;
                  end;
        TempCurrent := TempCurrent^.Next;
        end;
     GetAfter := nil;
end;

function TCollection.GetBefore( AItem: PGeneric): PGeneric;
var TempCurrent: PItemLink;
begin
     TempCurrent := First;
     while ( TempCurrent <> nil)
     do begin
        if ( TempCurrent^.Item = AItem)
        then begin
             if ( TempCurrent^.Prev <> nil)
             then begin
                  Current := TempCurrent^.Prev;
                  GetBefore := TempCurrent^.Prev^.Item;
                  exit;
                  end
             else begin
                  GetBefore := nil;
                  exit;
                  end;
             end;
        TempCurrent := TempCurrent^.Next;
        end;
     GetBefore := nil;
end;

function TCollection.InsertAfter( AItem, NewItem: PGeneric): Boolean;
var TempCurrent: PItemLink;
    NewLink: PItemLink;
begin
     if (( AItem <> nil) and ( NewItem <> nil))
     then begin
          TempCurrent := First;
          while ( TempCurrent <> nil)
          do if ( TempCurrent^.Item = AItem)
             then begin
                  NewLink := AllocateItemLink;
                  NewLink^.Item := NewItem;
                  NewLink^.Prev := TempCurrent;
                  if ( TempCurrent^.Next <> nil)
                  then begin
                       TempCurrent^.Next^.Prev := NewLink;
                       NewLink^.Next := TempCurrent^.Next;
                       end
                  else begin
                       Last := NewLink;
                       NewLink^.Next := nil;
                       end;
                  TempCurrent^.Next := NewLink;
                  Current := NewLink;
                  InsertAfter := True;
                  Exit;
                  end
             else TempCurrent := TempCurrent^.Next;
          end;
          InsertAfter := False;
end;

function TCollection.InsertBefore( AItem, NewItem: PGeneric): Boolean;
var TempCurrent: PItemLink;
    NewLink: PItemLink;
begin
     if (( AItem <> nil) and ( NewItem <> nil))
     then begin
          TempCurrent := First;
          while ( TempCurrent <> nil)
          do if ( TempCurrent^.Item = AItem)
             then begin
                  NewLink := AllocateItemLink;
                  NewLink^.Item := NewItem;
                  NewLink^.Next := TempCurrent;
                  if ( TempCurrent^.Prev <> nil)
                  then begin
                       TempCurrent^.Prev^.Next := NewLink;
                       NewLink^.Prev := TempCurrent^.Prev;
                       end
                  else begin
                       First := NewLink;
                       NewLink^.Prev := nil;
                       end;
                  TempCurrent^.Prev := NewLink;
                  Current := NewLink;
                  InsertBefore := True;
                  Exit;
                  end
             else TempCurrent := TempCurrent^.Next;
          end;
          InsertBefore := False;
end;

function TCollection.PushCollectionFirst( ACollection: PCollection): Boolean;
var ScanItem: PGeneric;
begin
     if (ACollection <> nil)
     then begin
          ScanItem := ACollection^.GetLast;
          while (ScanItem <> nil)
          do begin
             PushFirst(ScanItem);
             ScanItem := ACollection^.GetPrev;
             end;
          end;
end;

function TCollection.PushCollectionLast( ACollection: PCollection): Boolean;
var ScanItem: PGeneric;
begin
     if (ACollection <> nil)
     then begin
          ScanItem := ACollection^.GetFirst;
          while (ScanItem <> nil)
          do begin
             PushLast(ScanItem);
             ScanItem := ACollection^.GetNext;
             end;
          end;
end;

function TCollection.PushCollectionFirstReversed( ACollection: PCollection): Boolean;
var ScanItem: PGeneric;
begin
     if (ACollection <> nil)
     then begin
          ScanItem := ACollection^.GetFirst;
          while (ScanItem <> nil)
          do begin
             PushFirst(ScanItem);
             ScanItem := ACollection^.GetNext;
             end;
          end;
end;

function TCollection.PushCollectionLastReversed( ACollection: PCollection): Boolean;
var ScanItem: PGeneric;
begin
     if (ACollection <> nil)
     then begin
          ScanItem := ACollection^.GetLast;
          while (ScanItem <> nil)
          do begin
             PushLast(ScanItem);
             ScanItem := ACollection^.GetPrev;
             end;
          end;
end;

function TCollection.IsMember( AItem: PGeneric): Boolean;
var ScanLink: PItemLink;
begin
     if (AItem <> nil)
     then begin
          IsMember := False;
          ScanLink := First;
          while (ScanLink <> nil)
          do begin
             if ScanLink^.Item = AItem
             then begin
                  IsMember := True;
                  Break;
                  end
             else ScanLink := ScanLink^.Next;
             end;
          end
     else IsMember := False;
end;

function TCollection.IsSameAs( ACollection: PCollection): Boolean;
var ScanLink1: PItemLink;
    ScanLink2: PItemLink;
    Found: Boolean;
begin
     IsSameAs := False;
     if (ACollection <> nil)
     then begin
          if (GetItemsCount = ACollection^.GetItemsCount)
          then begin
               Found := True;
               ScanLink1 := ACollection^.First;
               while (ScanLink1 <> nil)
               do begin
                  Found := False;
                  ScanLink2 := First;
                  while (ScanLink2 <> nil)
                  do begin
                     if (ScanLink1^.Item = ScanLink2^.Item)
                     then begin
                          Found := True;
                          ScanLink2 := nil
                          end
                     else ScanLink2 := ScanLink2^.Next;
                     end;
                  if Found
                  then ScanLink1 := ScanLink1^.Next
                  else ScanLink1 := nil;
                  end;
               IsSameAs := Found;
               end;
          end;
end;

function TCollection.IsComprise( ACollection: PCollection): Boolean;
var ScanLink1: PItemLink;
    ScanLink2: PItemLink;
    Found: Boolean;
begin
     IsComprise := False;
     if (ACollection <> nil)
     then begin
          Found := True;
          ScanLink1 := ACollection^.First;
          while (ScanLink1 <> nil)
          do begin
             Found := False;
             ScanLink2 := First;
             while (ScanLink2 <> nil)
             do begin
                if (ScanLink1^.Item = ScanLink2^.Item)
                then begin
                     Found := True;
                     ScanLink2 := nil
                     end
                else ScanLink2 := ScanLink2^.Next;
                end;
             if Found
             then ScanLink1 := ScanLink1^.Next
             else ScanLink1 := nil;
             end;
          IsComprise := Found;
          end;
end;

procedure TCollection.MergeWith( ACollection: PCollection);
var ScanLink1: PItemLink;
    ScanLink2: PItemLink;
    NewLink: PItemLink;
    Found: Boolean;
begin
     if (ACollection <> nil)
     then begin
          ScanLink1 := ACollection^.First;
          while (ScanLink1 <> nil)
          do begin
             Found := False;
             ScanLink2 := First;
             while (ScanLink2 <> nil)
             do begin
                if (ScanLink1^.Item = ScanLink2^.Item)
                then begin
                     Found := True;
                     ScanLink2 := nil
                     end
                else ScanLink2 := ScanLink2^.Next;
                end;
             if not Found
             then begin
                  NewLink := AllocateItemLink;
                  NewLink^.Item := ScanLink1^.Item;
                  NewLink^.Next := nil;
                  NewLink^.Prev := Last;
                  if ( First <> nil)
                  then Last^.Next := NewLink
                  else First := NewLink;
                  Last := NewLink;
                  end;
             ScanLink1 := ScanLink1^.Next;
             end;
          end;

end;

procedure TCollection.AddIntersection( ACollection1, ACollection2: PCollection);
var ScanLink1: PItemLink;
    ScanLink2: PItemLink;
    NewLink: PItemLink;
begin
     if ((ACollection1 <> nil) and (ACollection2 <> nil))
     then begin
          ScanLink1 := ACollection1^.First;
          while (ScanLink1 <> nil)
          do begin
             ScanLink2 := ACollection2^.First;
             while (ScanLink2 <> nil)
             do if (ScanLink1^.Item  = ScanLink2^.Item)
                then begin
                     NewLink := AllocateItemLink;
                     NewLink^.Item := ScanLink1^.Item;
                     NewLink^.Next := nil;
                     NewLink^.Prev := Last;
                     if ( First <> nil)
                     then Last^.Next := NewLink
                     else First := NewLink;
                     Last := NewLink;
                     Break;
                     end
                else ScanLink2 := ScanLink2^.Next;
             ScanLink1 := ScanLink1^.Next;
             end;
          end;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

procedure TContainerCollection.MergeWith( ACollection: PCollection);
begin
end;

procedure TContainerCollection.AddIntersection( ACollection1, ACollection2: PCollection);
begin
end;

procedure TContainerCollection.WhenFreeCollectionItem( AItem: PGeneric);
begin
     if ( AItem <> nil)
     then AItem^.Free;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TTopErrGeneric.Create;
begin
     inherited Create( nil);
     Errors := New( PContainerCollection, Create);
end;

destructor TTopErrGeneric.Destroy;
begin
     Errors^.Free;
     inherited Destroy;
end;

function TTopErrGeneric.AddError( AError: PError): Boolean;
begin
     Errors^.PushLast( AError);
     AddError := true;
end;

function TTopErrGeneric.AnyError: Boolean;
begin
     AnyError := ( Errors^.GetItemsCount > 0);
end;

function TTopErrGeneric.GetErrorsCount: Word;
begin
     GetErrorsCount := Errors^.GetItemsCount;
end;

function TTopErrGeneric.GetError( AErrorIndex: Word): PError;
begin
     GetError := PError( Errors^.GetByIndex( AErrorIndex));
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TStream.Create;
begin
     inherited Create;
     ErrorCode := 0;
     ErrorMessage := nil;
end;

destructor TStream.Destroy;
begin
     ClearError;
     inherited Destroy;
end;

procedure TStream.SetPos( APos: Longint);
begin
end;

function TStream.GetPos: Longint;
begin
     GetPos := 0;
end;

function TStream.GetSize: Longint;
begin
     GetSize := 0;
end;

function TStream.Read( var ABuf; ASize: Word): Word;
begin
     Read := 0;
end;

function TStream.Write( var ABuf; ASize: Word): Word;
begin
     Write := 0;
end;

procedure TStream.WriteStr( AString: string);
begin
     if (AString <> '')
     then Write( AString[1], Length( AString));
end;

procedure TStream.NewLine;
const NewLineChars: string = #13#10;
begin
     Write( NewLineChars[1], 2);
end;

procedure TStream.WriteInt( AValue: Longint);
var TempStr: string;
begin
     Str( AValue, TempStr);
     Write( TempStr[1], Length( TempStr));
end;

procedure TStream.WriteIntF( AValue: Longint; AWidth: Integer);
var TempStr: string;
begin
     Str( AValue: AWidth, TempStr);
     Write( TempStr[1], Length( TempStr));
end;


procedure TStream.Error( AErrorCode: Integer; AErrorMessage: string);
begin
     FreeString( ErrorMessage);
     ErrorCode := AErrorCode;
     ErrorMessage := AllocateString( AErrorMessage);
end;

function TStream.GetErrorCode: Integer;
begin
     GetErrorCode := ErrorCode;
end;

function TStream.GetErrorMessage: string;
begin
     if (ErrorMessage <> nil)
     then GetErrorMessage := ErrorMessage^
     else GetErrorMessage := '';
end;

procedure TStream.ClearError;
begin
     ErrorCode := 0;
     FreeString( ErrorMessage);
end;

procedure TStream.SaveData( AStream: PStream);
var Buffer: array[1..1024] of Byte;
    ReadenSize: Word;
    Size: Longint;
begin
     if ( AStream <> nil)
     then begin
          Size := GetSize;
          AStream^.Write( Size, SizeOf( Size));
          SetPos( 0);
          ReadenSize := Read( Buffer, SizeOf( Buffer));
          while ( ReadenSize > 0)
          do begin
             AStream^.Write( Buffer, ReadenSize);
             ReadenSize := Read( Buffer, SizeOf( Buffer));
             end;
          end;
end;

procedure TStream.LoadData( AStream: PStream);
var Buffer: array[1..1024] of Byte;
    ReadenSize: Word;
    SizeToRead: Word;
    Size: Longint;
begin
     if ( AStream <> nil)
     then begin
          ReadenSize := AStream^.Read( Size, SizeOf( Size));
          if ( ReadenSize = SizeOf( Size))
          then begin
               while ( Size > 0)
               do begin
                  if ( SizeOf( Buffer) <= Size)
                  then SizeToRead := SizeOf( Buffer)
                  else SizeToRead := Size;
                  ReadenSize := AStream^.Read( Buffer, SizeToRead);
                  Write( Buffer, ReadenSize);
                  if ReadenSize = SizeToRead
                  then Size := Size - SizeToRead
                  else Size := 0;
                  end;
               end;
          end;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TMemStream.Create;
begin
     inherited Create;
     FirstBlock := nil;
     LastBlock := nil;
     Size := 0;
     CurrentBlock := nil;
     CurrentOffset := 0;
end;

destructor TMemStream.Destroy;
var TempBlock: PMemStreamDataBlock;
begin
     while ( FirstBlock <> nil)
     do begin
        TempBlock := FirstBlock;
        FirstBlock := FirstBlock^.Next;
        Dispose( TempBlock);
        end;

     inherited Destroy;
end;

procedure TMemStream.SetPos( APos: Longint);
var CurrentBlockNo: Longint;
begin
     if ( APos >= Size)
     then begin
          CurrentOffset := Size mod MEMSTREAMBLOCKSIZE;
          if CurrentOffset <> 0
          then CurrentBlock := LastBlock
          else CurrentBlock := nil;
          end
     else begin
          CurrentBlock := FirstBlock;
          CurrentBlockNo := APos div MEMSTREAMBLOCKSIZE;
          while (( CurrentBlockNo > 0) and ( CurrentBlock <> nil))
          do begin
             CurrentBlock := CurrentBlock^.Next;
             CurrentBlockNo := CurrentBlockNo - 1;
             end;
          if ( CurrentBlock <> nil)
          then CurrentOffset := APos mod MEMSTREAMBLOCKSIZE
          else begin
               CurrentBlock := FirstBlock;
               Size := 0;
               CurrentBlockNo := 0;
               while ( CurrentBlock <> nil)
               do begin
                  CurrentBlock^.No := CurrentBlockNo;
                  CurrentBlockNo := CurrentBlockNo + 1;
                  Size := Size + MEMSTREAMBLOCKSIZE;
                  CurrentBlock := CurrentBlock^.Next;
                  end;
               CurrentOffset := Size mod MEMSTREAMBLOCKSIZE;
               if CurrentOffset <> 0
               then CurrentBlock := LastBlock
               else CurrentBlock := nil;
               end;
          end;

end;

function TMemStream.GetPos: Longint;
begin
     if ( CurrentBlock <> nil)
     then GetPos := CurrentBlock^.No * MEMSTREAMBLOCKSIZE + CurrentOffset
     else GetPos := Size;
end;

function TMemStream.GetSize: Longint;
begin
     GetSize := Size;
end;

function TMemStream.Read( var ABuf; ASize: Word): Word;
var Destanation: PChar;
    RemainSize: Word;
    CurrentPos: Longint;
    SubblockSize: Word;
    ReadenSize: Word;
begin
     ReadenSize := 0;
     RemainSize := ASize;
     Destanation := @ABuf;
     CurrentPos := GetPos;

     if (( CurrentPos + Longint(RemainSize)) >= Size)
     then RemainSize := Size - CurrentPos;

     while (( RemainSize > 0) and ( CurrentBlock <> nil))
     do begin
        SubblockSize := MEMSTREAMBLOCKSIZE - CurrentOffset;
        if ( RemainSize < SubblockSize)
        then begin
             SubblockSize := RemainSize;
             RemainSize := 0;
             end
        else RemainSize := RemainSize - SubblockSize;
        Move( CurrentBlock^.Data[CurrentOffset], Destanation^, SubblockSize);
        ReadenSize := ReadenSize + SubblockSize;
        Destanation := Destanation + SubblockSize;
        CurrentOffset := CurrentOffset + SubblockSize;
        if ( CurrentOffset >= MEMSTREAMBLOCKSIZE)
        then begin
             CurrentOffset := 0;
             CurrentBlock := CurrentBlock^.Next;
             end;
        end;
     Read := ReadenSize;
end;

function TMemStream.Write( var ABuf; ASize: Word): Word;
var Source: PChar;
    RemainSize: Word;
    SubblockSize: Word;
    WrittenSize: Word;
begin
     WrittenSize := 0;
     RemainSize := ASize;
     Source := @ABuf;

     while ( RemainSize > 0)
     do begin
        if ( Currentblock = nil)
        then begin
             New( CurrentBlock);
             CurrentBlock^.Next := nil;
             {FillChar( CurrentBlock^.Data, MEMSTREAMBLOCKSIZE, #0);}
             if ( LastBlock <> nil)
             then begin
                  LastBlock^.Next := CurrentBlock;
                  CurrentBlock^.No := LastBlock^.No + 1;
                  end
             else begin
                  CurrentBlock^.No := 0;
                  FirstBlock := CurrentBlock;
                  end;
             LastBlock := CurrentBlock;
             CurrentOffset := 0;
             SubblockSize := MEMSTREAMBLOCKSIZE;
             end
        else SubblockSize := MEMSTREAMBLOCKSIZE - CurrentOffset;
        if ( RemainSize < SubblockSize)
        then begin
             SubblockSize := RemainSize;
             RemainSize := 0;
             end
        else RemainSize := RemainSize - SubblockSize;
        Move( Source^, CurrentBlock^.Data[CurrentOffset], SubblockSize);
        WrittenSize := WrittenSize + SubblockSize;
        Source := Source + SubblockSize;
        CurrentOffset := CurrentOffset + SubblockSize;
        if ( CurrentOffset >= MEMSTREAMBLOCKSIZE)
        then begin
             CurrentBlock := CurrentBlock^.Next;
             CurrentOffset := 0;
             end;
        end;
     if ( LastBlock <> nil)
     then Size := LastBlock^.No * MEMSTREAMBLOCKSIZE + CurrentOffset
     else Size := 0;
     Write := WrittenSize;
end;

procedure TMemStream.DebugDump;
var ScanBlock: PMemStreamDataBlock;
    I: Word;
begin
     ScanBlock := FirstBlock;
     while ( ScanBlock <> nil)
     do begin
        System.Write('Block [', ScanBlock^.No, ']');
        if ( ScanBlock <> CurrentBlock)
        then begin
             WriteLn;
             for I := 0 to MEMSTREAMBLOCKSIZE - 1
             do begin
                System.Write( ScanBlock^.Data[I], ' ');
                end;
             end
        else begin
             System.WriteLn(' CURRENT');
             for I := 0 to MEMSTREAMBLOCKSIZE - 1
             do begin
                if (I <> CurrentOffset)
                then System.Write( ScanBlock^.Data[I], ' ')
                else System.Write( '(', ScanBlock^.Data[I], ') ');
                end;
             end;
        System.WriteLn;
        ScanBlock := ScanBlock^.Next;
        end;
     System.WriteLn;
     System.WriteLn('Size = ', GetSize);
     System.WriteLn('Pos = ', GetPos);
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TFileStream.Create( AFileName: string; AMode: TFileStreamMode);
begin
     inherited Create;
     Opened := False;
     Mode := AMode;
     {$I-}
     Assign( F, AFileName);
     case Mode
     of fstCreate: begin
                  Rewrite(F, 1);
                  if (IOResult = 0)
                  then Opened := True
                  else Error( 1, 'I/O ERROR: Couldn''t create the file ~' + AFileName + '~.');
                  end;
        fstOpenRead: begin
                    Reset(F, 1);
                    if (IOResult = 0)
                    then Opened := True
                    else Error( 1, 'I/O ERROR: Couldn''t open the file ~' + AFileName + '~.');
                    end;
        fstOpenWrite: begin
                     Reset(F, 1);
                     if (IOResult = 0)
                     then Opened := True
                     else Error( 1, 'I/O ERROR: Couldn''t open the file ~' + AFileName + '~.');
                     end;
        fstOpen: begin
                Reset(F, 1);
                if (IOResult = 0)
                then Opened := True
                else Error( 1, 'I/O ERROR: Couldn''t open the file ~' + AFileName + '~.');
                end;
        end;
end;

destructor TFileStream.Destroy;
begin
     if Opened
     then Close(F);
     inherited Destroy;
end;

function TFileStream.Read( var ABuf; ASize: Word): Word;
var Readen: Word;
begin
     Readen := 0;
     if Opened
     then begin
          if (Mode <> fstOpenWrite)
          then begin
               if (ErrorCode = 0)
               then begin
                    BlockRead( F, ABuf, ASize, Readen);
                    if (IOResult <> 0)
                    then Error( 1, 'I/O ERROR: Couldn''t read from the file.');
                    end
               end
          else Error( 1, 'I/O ERROR: Bad file operation.');
          end;
     Read := Readen;
end;

function TFileStream.Write( var ABuf; ASize: Word): Word;
var Written: Word;
begin
     Written := 0;
     if Opened
     then begin
          if (Mode <> fstOpenRead)
          then begin
               if (ErrorCode = 0)
               then begin
                    BlockWrite( F, ABuf, ASize, Written);
                    if (IOResult <> 0)
                    then Error( 1, 'I/O ERROR: Couldn''t write to the file.');
                    end
               end
          else Error( 1, 'I/O ERROR: Bad file operation.');
          end;
     Write := Written;
end;

procedure TFileStream.SetPos( APos: Longint);
begin
     if (Opened and (ErrorCode = 0))
     then begin
          Seek( F, APos);
          if (IOResult <> 0)
          then Error( 1, 'I/O ERROR: Couldn''t access within file.');
          end;
end;

function TFileStream.GetPos: Longint;
begin
     if (Opened and (ErrorCode = 0))
     then GetPos := FilePos( F)
     else GetPos := 0;
end;

function TFileStream.GetSize: Longint;
begin
     if (Opened and (ErrorCode = 0))
     then GetSize := FileSize( F)
     else GetSize := 0;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

var Links: PItemLinksGroup;
    FirstFreeLink: PItemLink;

function AllocateItemLink: PItemLink;
var NewGroup: PItemLinksGroup;
    I: Integer;
begin
     if ( FirstFreeLink <> nil)
     then begin
          AllocateItemLink := FirstFreeLink;
          FirstFreeLink := FirstFreeLink^.Next;
          end
     else begin
          New( NewGroup);
          NewGroup^.Next := Links;
          Links := NewGroup;
          for I := 1 to ITEMLINKSGROUPSIZE - 1
          do begin
             NewGroup^.Links[I].Next := FirstFreeLink;
             FirstFreeLink := @NewGroup^.Links[I];
             end;
          AllocateItemLink := @NewGroup^.Links[ITEMLINKSGROUPSIZE];
          end;
end;

procedure FreeItemlink( ALink: PItemLink);
begin
     if (ALink <> nil)
     then begin
          ALink^.Next := FirstFreeLink;
          FirstFreeLink := ALink;
          end;
end;

procedure GenericsInit;
begin
     Links := nil;
     FirstFreeLink := nil;
end;

procedure GenericsDone;
var TempGroup: PItemLinksGroup;
begin
     while ( Links <> nil)
     do begin
        TempGroup := Links;
        Links := TempGroup^.Next;
        Dispose( TempGroup);
        end;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

begin
     GenericsInit;
end.
