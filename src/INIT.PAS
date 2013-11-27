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
{*  FILE: INIT.PAS                                                         *}
{*                                                                         *}
{***************************************************************************}

program Init;

uses Crt, {UCrt,} Generics;

const
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

      STEPPERFREQUENCY          = $0034;

var
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
     Frequency: TWord;
     Delta: TWord;
begin
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

     {PPI4C := $08;
     Port[ DataPPI4C] := PPI4C;}
end.