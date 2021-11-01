program MineSweeper;
uses GraphABC,ABCObjects,ABCButtons;
const size = 30;//size of each cell
      dsize = 2;//distance between each cell
      LUpCorner = 15;//indent from top left corner
      N = 30;
      M = 16;//field NxM
      AmountOfMines = 99;//qty of mines

type Cell=record
       mine:boolean;//is there a mine?
       flag:boolean;//is there a flag?
       MinesAround:integer;//how many mines are around?
       open:boolean;//is the cell opened?
     end;

var ButtonNewGame,ButtonHint:ButtonAbc;
    Field:array[0..100,0..100] of Cell;//mechanical component of the playing field
    Squares:array[0..100,0..100] of SquareABC;//graphical component of the playing field
    MA:integer;//qty of MinesAround
    Opened:integer;//qty of opened cells
    firstclick:boolean;

procedure CreateField;
begin    
for var x:=1 to N do
  for var y:=1 to M do begin
    Squares[x,y]:=new SquareABC(LUpCorner+(x-1)*(size+dsize),LUpCorner+(y-1)*(size+dsize),size,clLightGray);
    Squares[x,y].BorderColor:=clGray;
    Squares[x,y].BorderWidth:=2;
    Squares[x,y].TextScale:=0.9;
    Squares[x,y].FontStyle:=fsBold;
  end;    
end;

procedure EndOfGame(text:string);//output of the result of the end of the game
begin
  if text='You win!' then
    SetFontColor(clGreen)
  else
    SetFontColor(clRed);
  SetBrushColor(clWhite);
  SetFontSize(25); 
  TextOut(1000,200,text);
end;


procedure NewGame;
begin
firstclick:=true;
//cleaning field
SetBrushColor(clWhite);
FillRectangle(1000,200,1200,238);
for var i:=1 to N do
  for var j:=1 to M do begin
    Field[i,j].mine:=false;
    Field[i,j].open:=false;
    Field[i,j].flag:=false;
    Field[i,j].MinesAround:=0;
    Squares[i,j].BorderColor:=clGray;
    Squares[i,j].Text:='';
    Squares[i,j].Color:=clLightGray;
  end;

Opened:=0;
end;

procedure GenerationOfMines(fx,fy:integer);
var x,y:integer;
begin
randomize;
//placing mines
for var i:=1 to AmountOfMines do begin
  x:=random(N)+1;
  y:=random(M)+1;
  while (Field[x,y].mine)or((x=fx-1)and(y=fy-1))or((x=fx)and(y=fy-1))or((x=fx+1)and(y=fy-1))or((x=fx-1)and(y=fy))or((x=fx)and(y=fy))or((x=fx+1)and(y=fy))or((x=fx-1)and(y=fy+1))or((x=fx)and(y=fy+1))or((x=fx+1)and(y=fy+1)) do
  begin
    x:=random(1,N);
    y:=random(1,M);
  end;
  Field[x,y].mine:=true;
end;

//counting the number of mines around each cell
for var i:=1 to N do
  for var j:=1 to M do
  begin
    MA:=0;
    if not Field[i,j].mine then
    begin
      for var di:=-1 to 1 do
        for var dj:=-1 to 1 do
          if not((di=0)and(dj=0)) then
            if Field[i+di,j+dj].mine then inc(MA);
    end;
  Field[i,j].MinesAround:=MA;
  end;
end;

procedure OpenZero(x,y:integer);//opening neighboring cells with no mines around
begin
if (Field[x,y].MinesAround=0)and(not Field[x,y].mine) then
begin
  if (not Field[x,y].open) then
  begin
    Field[x,y].open:=True;
    inc(Opened);
  end;
  Squares[x,y].Color:=clDarkGray;
  for var dx:=-1 to 1 do
    for var dy:=-1 to 1 do
      if not((x=0)and(y=0)) then
        if Field[x+dx,y+dy].MinesAround>0 then
        begin
          Squares[x+dx,y+dy].Color:=clLightGray;
          Squares[x+dx,y+dy].Text:=IntToStr(Field[x+dx,y+dy].MinesAround);
          if not Field[x+dx,y+dy].open then
          begin
            Field[x+dx,y+dy].open:=True;
            inc(Opened);
          end;
        end
        else
          if (Field[x+dx,y+dy].MinesAround=0)and(not Field[x+dx,y+dy].open) then
            if (x+dx>0)and(x+dx<=N)and(y+dy>0)and(y+dy<=M) then
              OpenZero(x+dx,y+dy);
end;
end;

procedure Hint;//a hint that briefly shows a mine next to already open cells     (Field[x-1,y-1].open)or(Field[x-1,y].open)or(Field[x-1,y+1].open)or(Field[x,y-1].open)or(Field[x,y+1].open)or(Field[x+1,y-1].open)or(Field[x+1,y].open)or(Field[x+1,y+1].open)
label metka;
var x,y:integer;
begin
x:=0;y:=0;
randomize;
for var i:=1 to N do
  for var j:=1 to M do
    if (Field[i,j].MinesAround>0)and(Field[i,j].open)and(((Field[i-1,j].mine)and(not Field[i-1,j].flag))or((Field[i+1,j].mine)and(not Field[i+1,j].flag))or((Field[i,j-1].mine)and(not Field[i,j-1].flag))or((Field[i,j+1].mine)and(not Field[i,j+1].flag))) then
begin
repeat
  begin
    x:=random(1,N);
    y:=random(1,M);
  end;
until ((Field[x,y].mine)and(not Field[x,y].flag))and(((Field[x-1,y].open)and(not Field[x-1,y].flag))or((Field[x+1,y].open)and(not Field[x+1,y].flag))or((Field[x,y-1].open)and(not Field[x,y-1].flag))or((Field[x,y+1].open)and(not Field[x,y+1].flag)));
if (x<>0)and(y<>0) then
begin
  Squares[x,y].Color:=clYellow;
  sleep(500);
  Squares[x,y].Color:=clSilver;
end;
goto metka
end;
metka:
end;

procedure OpenField;//opening the whole field in case of losing
begin
for var x:=1 to N do
  for var y:=1 to M do
    begin
      Field[x,y].open:=True;
      if (Field[x,y].mine)and(not Field[x,y].flag) then
      begin
        Squares[x,y].Text:='M';
        Squares[x,y].Color:=clCrimson;
      end;
      OpenZero(x,y);
      if Field[x,y].MinesAround>0 then
      begin
        Squares[x,y].Color:=clLightGray;
        Squares[x,y].Text:=IntToStr(Field[x,y].MinesAround);
      end;
    end;
end;

procedure MouseDown(x, y, mb: integer);
var fx,fy:integer;
begin
 if ObjectUnderPoint(x,y)=nil then //if clicked not on object then do not react
  exit;
  
  //calculating the coordinates on the board for the cell on which we clicked with the mouse
  fx:=((x-LUpCorner)div(size+dsize))+1;
  
  fy:=((y-LUpCorner)div(size+dsize))+1;
  
  if mb = 1 then begin
    if firstclick then
    begin
      GenerationOfMines(fx,fy);
      OpenZero(fx,fy);
      firstclick:=false;
    end
    else
    begin 
    //if click on the mine
    if not Field[fx,fy].flag then begin
      if Field[fx,fy].mine then begin
        Squares[fx,fy].Text:='M';
        Squares[fx,fy].Color:=clCrimson;
        OpenField;
        EndOfGame('You lose!');
      end
      else begin
        //if click on the empty cell
        if (Field[fx,fy].MinesAround=0) then begin
          Squares[fx,fy].Color:=clDarkGray;
          if Field[fx,fy].flag then Squares[fx,fy].Text:='';
          //calling the procedure for expanding empty cells
          OpenZero(fx,fy);
        end
        else 
          if Field[fx,fy].MinesAround>0 then begin
            Squares[fx,fy].Color:=clLightGray;
            Squares[fx,fy].Text:=IntToStr(Field[fx,fy].MinesAround);
          end;
      if (not Field[fx,fy].open) then
      begin
        inc(Opened);
        Field[fx,fy].open:=True;
      end;
    end;
    if (Opened=N*M-AmountOfMines) then
    begin
      EndOfGame('You win!');
      OpenField;
    end;
  end;
  end;
  end;
  //putting and putting away the flag
  if mb=2 then begin
    if Field[fx,fy].flag then begin //putting away the flag
      Field[fx,fy].flag:=False;
      Squares[fx,fy].Text:='';
      Squares[fx,fy].Color:=clLightGray;
    end
    else begin //putting the flag
      Field[fx,fy].flag:=true;
      Squares[fx,fy].Text:='F';
      Squares[fx,fy].Color:=clLightBlue;
    end;
  end;
Field[fx,fy].open:=true;
end;
 
 
procedure MouseMove(x,y,mb:integer);
begin
  if ObjectUnderPoint(x,y)=nil then //if clicked not on object then do not react
    exit;
  var fx:=((x-LUpCorner)div(size+dsize))+1; //calculating the coordinates on the board for the cell we clicked on
  var fy:=((y-LUpCorner)div(size+dsize))+1;
  for var i:=1 to N do
    for var j:=1 to M do begin
      if not Field[i,j].open then
        Squares[i,j].Color:=clLightGray;
      end; 
  if not Field[fx,fy].open then
    Squares[fx,fy].Color:=clSilver;//showing the cell over which the mouse is
end;

BEGIN
  SetSmoothingOff; //disabling smoothing
  Window.Title:='Minesweeper';
  SetWindowWidth(1150);
  SetWindowHeight(545);
  Window.IsFixedSize:=True;
   
  CreateField;
  ButtonNewGame:=ButtonAbc.Create(1025,35,100,'New Game',clSkyBlue);
  ButtonNewGame.OnClick:=NewGame;
  ButtonHint:=ButtonAbc.Create(1025,80,100,'Hint',clYellow);
  ButtonHint.Onclick:=Hint;
  NewGame;
  
  OnMouseDown:=MouseDown;
  OnMouseMove:=MouseMove;
END.