Program Pzim ;
uses crt;
var
MatrizMapa : array [1..10,1..10] of boolean;
MatrizEspelho : array [1..10,1..10] of string;
aFases : array [1..10] of string;

sSelecao, sBoneco , sSaida, sParede, sVazio, sNeblina, SEED, sFaseAtual{para guardar a seed}, sFase{para o contador} : string;
x, y, B_x, B_y, S_x, S_y, CodigoASCII, Dig, Alt, iLargura, iAltura, iFase, CorTexto, CorFundo : integer;
cOpc : Char;
bDireita: boolean;

function ValorASCII(cCaracter : char) : integer;         //transforma os dígitos em valores numéricos
var
i, ascii  : integer;
begin
  i:= dig;
  ascii := ord(cCaracter);
  case ascii of
  	48..57 :  {números}
  		begin
  			ValorASCII := ascii - 48;
  		end;

  	97..118 :   {letras minúsculas}
  		begin
  			ValorASCII := ascii - 87;
  		end;

  	else
  	ValorASCII := 0;
  	
  end;                         
end;

function ValorBinario(cCaracter : char) : string;     //Coverte os números em binário
var
sDig, sBinario : string;
quo, res, DigitoSeed : integer;
begin
  
  quo:= ValorASCII(cCaracter);
  sBinario:= '';
  
  if (quo = 0) then 
  	begin
  	sBinario := '00000';
  	ValorBinario := sBinario;
  	end
  else
  begin
    while quo > 0 do
    begin
      res := quo mod 2;  //guarda o digito binario
      quo := quo div 2;  //atualiza para a proxima divisão
      
      Str(res, sDig);         //adiciona o dígito à string
      sBinario := sDig + sBinario;
    end;
    while length(sBinario) < 5 do
    sBinario := '0' + sBinario;
    
    ValorBinario := sBinario;
  end;
end;

function transformar0em10(sZero : string) : integer;
var outro, inutil : integer;
begin
  transformar0em10 := 0; // Valor padrão caso a conversão falhe
  if sZero = '0' then
    transformar0em10 := 10
  else
    val(sZero, outro, inutil);
    transformar0em10 := outro;
end;

procedure GerarMatrizBOOLEAN;
var
sBinario : string;
i : integer;
begin
	i := 1;
	for y := 1 to 10 do 
		begin
		sBinario := ValorBinario(SEED[i]);
		for x := 1 to 5 do
			begin
			if sBinario[x] = '1' then
			MatrizMapa[x, y] := true
			else 
			MatrizMapa[x, y] := false;	
			end;
		sBinario := ValorBinario(SEED[i + 1]);
		for x := 6 to 10 do
			begin  
			
			if sBinario[x - 5] = '1' then
			MatrizMapa[x, y] := true
			else 
			MatrizMapa[x, y] := false;	
			end;
		if (i + 2 <= 20) then
		inc(i, 2);
		end;
end; 

procedure DesenharMoldura;
begin
//Bordas
	write (#201); 				{Canto superior direito}
	for x := 1 to 20 do
	begin
		gotoxy (x + 1, 1);    {Borda de cima}
		write (#205); 
		gotoxy (x + 1, 12);   {Borda de baixo}
		write (#205);
	end;
		gotoxy (22, 1);       {Canto superior esquerdo}
		write (#187);
		gotoxy (22, 12);      {Canto inferior direito}
		write (#188);
		gotoxy (1, 12);       {Canto superior esquerdo}
		write (#200);
	for y := 1 to 10 do
	begin
		gotoxy (1, y + 1);    {Borda da esquerda}
		write (#186);
		gotoxy (22, y + 1);   {Borda da direita}
		write (#186);
	end;
end;

procedure DesenharMapa;    
begin   
//Labirinto		 
	for y := 1 to 10 do 
		begin
		for x := 1 to 10 do
			begin
				gotoxy ((x* 2),y);
				if MatrizMapa[x,y] then      //Checa se a coordenada é TRUE
					write (sParede, sParede)
				else 
					write (sVazio);
			end;
		end;   
end;

procedure GerarMatrizEspelho;
var
jafez : boolean;
i, iY : integer;
begin
	if (jafez) then
	begin
		for iY := 1 to 10 do
		begin
			gotoxy (2, iY + 1);
			for i := 1 to 10 do
				write (MatrizEspelho[i,iY]);
		end;
	end
	else
	begin
		for i := 1 to 10 do
			for iY := 1 to 10 do 
				MatrizEspelho[i,iY] := sNeblina;
		jafez := true
	end;
end;
 
procedure MoverPersonagem;
var
Ny, Wx, Sy, Ex : integer;
label
desv_W, desv_A, desv_S, desv_D;

begin
  Ny := B_y - 1;
  Wx := B_x - 1;
  Sy := B_y + 1;
  Ex := B_x + 1;
	
	gotoxy (1,13);
  write ('MOVA O PERSONAGEM (A < W ^ S v D >)');
  cOpc := readkey; 
  gotoxy(B_x*2,B_y);
  write (sBoneco);
  gotoxy(25,2);                                                               
  write ('x ', B_x, ' y ', B_y);
  if cOpc = #0 then       //se for uma seta
  cOpc:= readkey;
  case cOpc of                                         //Recebe comandos de movimento do personagem
  	'w', 'W', #72{seta pra cima} :
    begin
      if (Ny <= 10) and (Ny >= 1) and (MatrizMapa[B_x, Ny] = false) then //Checa se o lugar que o jogador quer ir está vazio
      begin
      	gotoxy(B_x*2,B_y);
    		write(sVazio);
        B_y := Ny;        //Seta as coordenadas do jogador pra N
        gotoxy(1,14);
				writeln ('        ')
      end
      else 
			begin
				gotoxy(1,14);
				writeln ('Parede')
			end;
    end;
    
    'a', 'A', #75{seta pra esquerda} :
    begin
      if (Wx <= 10) and (Wx >= 1) and (MatrizMapa[Wx, B_y] = false) then //Checa se o lugar que o jogador quer ir está vazio
      begin
      	gotoxy(B_x*2,B_y);
    		write(sVazio);
        B_x := Wx;         //Seta as coordenadas do jogador pra N
        gotoxy(1,14);
				writeln ('        ')
      end
      else 
			begin
				gotoxy(1,14);
				writeln ('Parede')
			end;
    end;
    
    's', 'S', #80{seta pra baixo}:
    begin
      if (Sy <= 10) and (Sy >= 1) and (MatrizMapa[B_x, Sy] = false) then //Checa se o lugar que o jogador quer ir está vazio
      begin
      gotoxy(B_x*2,B_y);
    	write(sVazio);
        B_y := Sy;        //Seta as coordenadas do jogador pra N
        gotoxy(1,14);
				writeln ('        ')
      end
      else 
			begin
				gotoxy(1,14);
				writeln ('Parede')
			end;
    end;
    
    'd', 'D', #77 {seta para direita} :
    begin
      if (Ex <= 10) and (Ex >= 1) and (MatrizMapa[Ex, B_y] = false) then //Checa se o lugar que o jogador quer ir está vazio
      begin
      gotoxy(B_x*2,B_y);
    	write(sVazio);
        B_x := Ex;        //Seta as coordenadas do jogador pra N
        gotoxy(1,14);
				writeln ('        ')
      end
      else 
			begin
				gotoxy(1,14);
				writeln ('Parede')
			end;
    end;
  end;
  gotoxy (B_x*2, B_y);
  write (sBoneco);
end;

procedure SelecaoDePersonagem;
begin
  writeln ('Selecione o seu personagem:');         //Escolhe um caracter para representar o jogador
  readln (sBoneco);
  sBoneco := sBoneco[1];  
end;

Begin
	SEED := '2ho63iea06dk359o62go1102';  
	sParede := #219;
	sVazio := '  ';
	sNeblina:= #178;
	B_x := transformar0em10(SEED[21]);
	B_y := transformar0em10(SEED[22]);
	S_x := transformar0em10(SEED[23]);
	S_y := transformar0em10(SEED[24]);
	
	SelecaoDePersonagem;
	clrscr;
	{DesenharMoldura;   }
	GerarMatrizBOOLEAN;

	DesenharMapa;	
	gotoxy(B_x*2,B_y);
	write(sBoneco);
	repeat 
	MoverPersonagem;
	until (B_x = S_x) and (B_y = S_y);
	readkey;
End.