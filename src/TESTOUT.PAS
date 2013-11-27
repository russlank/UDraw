uses Graph, Crt{, UCrt};
const Zoom = 1;
var GM, GD: Integer;
    FLastX, FLastY: Double;
    FNewX, FNewY: Double;
    F: Text;
    FDX, FDY: Double;
    X1, X2, Y1, Y2: Integer;
    PosX, PosY: Double;
begin
     GD := Detect;
     Initgraph( GD, GM, '');
     PosX := 0;
     PosY := 0;
     FLastX := 0;
     FLastY := 0;
     Assign( F, 'DEBUG.TXT');
     Reset( F);
     SetColor( 12);
     X1 := 320 + Round(Zoom * FLastX / 1);
     Y1 := 240 + Round(Zoom * FLastY / 5);
     Circle( X1, Y1, 10);
     while not EOF( F)
     do begin
        ReadLn( F, FDX, FDY);
        PosX := PosX + FDX;
        PosY := PosY + FDY;
        FNewX := FLastX + FDX;
        FNewY := FLastY + FDY {+ (50 * 0.995)};
        X1 := 320 + Round(Zoom * FLastX / 1);
        Y1 := 240 + Round(Zoom * FLastY / 5);
        X2 := 320 + Round(Zoom * FNewX / 1);
        Y2 := 240 + Round(Zoom * FNewY / 5);
        Line( X1, Y1, X2, Y2);
        FLastX := FNewX;
        FLastY := FNewY;
        end;
     X1 := 320 + Round(Zoom * FLastX / 1);
     Y1 := 240 + Round(Zoom * FLastY / 5);
     SetColor( 4);
     Circle( X1, Y1, 10);
     Close( F);


     (*
     FLastX := 0;
     FLastY := 0;
     Assign( F, 'OUT.TXT');
     Reset( F);
     SetColor( 9);
     while not EOF( F)
     do begin
        ReadLn( F, FDX, FDY);
        FNewX := FLastX + FDX;
        FNewY := FLastY + FDY {+ (50 * 0.995)};
        X1 := 320 + Round(Zoom * FLastX / 1);
        Y1 := 240 + Round(Zoom * FLastY / 5);
        X2 := 320 + Round(Zoom * FNewX / 1);
        Y2 := 240 + Round(Zoom * FNewY / 5);
        Line( X1, Y1, X2, Y2);
        FLastX := FNewX;
        FLastY := FNewY;
        end;
     Close( F);
     *)



     Readkey;
     CloseGraph;
     WriteLn( 'Final pos = ', PosX:0:3, ', ', PosY:0:3);
     ReadKey;
end.