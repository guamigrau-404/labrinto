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
  begin
    val(sZero, outro, inutil);
    transformar0em10 := outro;
  end;
end;

function Parede(iX, iY: integer): string;
var 
  iSoma : integer;
  bDiagSupEsq, bDiagInfEsq, bDiagSupDir, bDiagInfDir : boolean;
begin
  iSoma := 0;

  // Vizinhos Ortogonais Diretos (Soma clássica)
  if (iX < 10) and MatrizMapa[iX+1, iY] then inc(iSoma, 1); // Direita
  if (iX > 1)  and MatrizMapa[iX-1, iY] then inc(iSoma, 2); // Esquerda
  if (iY < 10) and MatrizMapa[iX, iY+1] then inc(iSoma, 4); // Baixo
  if (iY > 1)  and MatrizMapa[iX, iY-1] then inc(iSoma, 8); // Cima

  // Mapeamento das Diagonais Internas
  bDiagSupEsq := (iX > 1)  and (iY > 1)  and MatrizMapa[iX-1, iY-1];
  bDiagInfEsq := (iX > 1)  and (iY < 10) and MatrizMapa[iX-1, iY+1];
  bDiagSupDir := (iX < 10) and (iY > 1)  and MatrizMapa[iX+1, iY-1];
  bDiagInfDir := (iX < 10) and (iY < 10) and MatrizMapa[iX+1, iY+1];

  case iSoma of
    // --- PILAR / BLOCO ISOLADO OU CONECTADO À MOLDURA ---
    0: 
    begin
      if (iY = 1) or (iY = 10) then
        Parede := #186 + ' '    { ¦  Haste vertical descendo do teto / subindo do chão }
      else if (iX = 1) or (iX = 10) then
        Parede := #205 + #205   { -- Haste horizontal conectando nas laterais }
      else
        Parede := '[]';         { Blocos isolados no meio do mapa continuam [] }
    end;

    // --- PONTAS HORIZONTAIS ---
    2: 
    begin
      if bDiagSupDir and bDiagInfDir then Parede := #205 + #185
      else if bDiagSupDir then Parede := #205 + #188
      else if bDiagInfDir then Parede := #205 + #187
      else Parede := #205 + '=';
    end;

    1: 
    begin
      if bDiagSupEsq and bDiagInfEsq then Parede := #204 + #205
      else if bDiagSupEsq then Parede := #200 + #205
      else if bDiagInfEsq then Parede := #201 + #205
      else Parede := '=' + #205;
    end;

    // --- PONTAS VERTICAIS ---
    8:
    begin
      if bDiagSupEsq then Parede := #202 + #205
      else if bDiagInfEsq then Parede := #188 + ' '
      else if bDiagInfDir then Parede := #187 + ' '
      else Parede := #186 + ' ';
    end;

    4:
    begin
      if bDiagSupEsq then Parede := #200 + #205
      else if bDiagSupDir then Parede := #201 + #205
      else if bDiagInfEsq then Parede := #203 + #205
      else Parede := #186 + ' ';
    end;

    // --- CANTOS ---
    5:  Parede := #201 + #205; { +- }
    6:  Parede := #187 + ' ';  { +  }
    9:  if bDiagInfEsq then Parede := #202 + #205 else Parede := #200 + #205; { +- ou -- }
    10: if bDiagInfDir then Parede := #202 + #205 else Parede := #188 + ' ';  { +  ou -- }

    // --- PAREDES RETAS E ENTROUNCAMENTOS ---
    3:  Parede := #205 + #205; { -- }
    12: Parede := #186 + ' ';  { ¦  }
    7:  Parede := #203 + #205; { -- }
    11: Parede := #202 + #205; { -- }
    13: Parede := #204 + #205; { ¦- }
    14: Parede := #185 + ' ';  { ¦  }
    15: Parede := #206 + #205; { +- }

    else Parede := #205 + #205;
  end;
end;

procedure IrPara(iX, iY: integer);
begin
  // Como a moldura ocupa a linha 1 e coluna 1,
  // somamos +1 nas coordenadas virtuais do jogo.
  gotoxy((iX - 1) * 2 + 2, iY + 1);
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
var
  iX, iY : integer;
begin
  // 1. Cantos principais da moldura
  gotoxy(1, 1);    write(#201); { + }
  gotoxy(22, 1);   write(#187); { + }
  gotoxy(1, 12);   write(#200); { + }
  gotoxy(22, 12);  write(#188); { + }

  // 2. Teto e Chão Dinâmicos
  for iX := 1 to 10 do
  begin
    // Teto (Linha 1 da tela)
    gotoxy((iX - 1) * 2 + 2, 1);
    if MatrizMapa[iX, 1] then
      write(#203, #205)   { -- Encaixe perfeito! }
    else
      write(#205, #205);  { -- Moldura contínua }

    // Chão (Linha 12 da tela)
    gotoxy((iX - 1) * 2 + 2, 12);
    if MatrizMapa[iX, 10] then
      write(#202, #205)   { -- Encaixe perfeito! }
    else
      write(#205, #205);  { -- Moldura contínua }
  end;

  // 3. Paredes Laterais
  for iY := 1 to 10 do
  begin
    // Parede Esquerda (Coluna 1 da tela)
    gotoxy(1, iY + 1);
    if MatrizMapa[1, iY] then
      write(#204)  { ¦ }
    else
      write(#186); { ¦ }

    // Parede Direita (Coluna 22 da tela)
    gotoxy(22, iY + 1);
    if MatrizMapa[10, iY] then
      write(#185)  { ¦ }
    else
      write(#186); { ¦ }
  end;
end;

procedure DesenharMapa;    
begin   
//Labirinto		 
	for y := 1 to 10 do 
		begin
		for x := 1 to 10 do
			begin
				IrPara(x,y);
				if MatrizMapa[x,y] then      //Checa se a coordenada é TRUE
					write (Parede(x,y))
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
	iModX, iModY : integer;
begin	
	{gotoxy (1,13);
  write ('MOVA O PERSONAGEM (A < W ^ S v D >)');  } 
  {gotoxy(B_x*2,B_y);
  write (sBoneco); }
  {gotoxy(25,2);   
  write ('x ', B_x, ' y ', B_y);}
  
	iModX := 0;
	iModY := 0;
	  
	cOpc := readkey;
  if cOpc = #0 then       //se for uma seta
  cOpc:= readkey;
  case cOpc of                                         //Recebe comandos de movimento do personagem
  	'w', 'W', #72{seta pra cima} :
    begin
      iModX := 0;
      iModY := -1;
    end;
    
    'a', 'A', #75{seta pra esquerda} :
    begin
    	iModX := -1;
      iModY := 0;  
    end;
    
    's', 'S', #80{seta pra baixo}:
    begin
      iModX := 0;
      iModY := 1;
    end;
    
    'd', 'D', #77 {seta para direita} :
    begin
      iModX := 1;
      iModY := 0;
    end;
  end;  
  
  if (B_x + iModX <= 10) and (B_x + iModX >= 1) and (B_y + iModY <= 10) and (B_y + iModY >= 1) and (MatrizMapa[B_x + iModX, B_y + iModY] = false) then //Checa se o lugar que o jogador quer ir está vazio
      begin
      	IrPara(B_x,B_y);
    		write(sVazio);
    		B_x := B_x + iModX;
        B_y := B_y + iModY;
        {gotoxy(1,14);
				writeln ('        ')   }
      end
      else 
			begin
				IrPara(1,14);
				writeln ('Parede')
			end;	
				
  IrPara(B_x, B_y);
  write (sBoneco);
end;

procedure SelecaoDePersonagem;
begin
  writeln ('Selecione o seu personagem:');         //Escolhe um caracter para representar o jogador
  readln (sBoneco);
  sBoneco := sBoneco[1];  
end;
//////////////////////////////////////////////////////////////////////////////////////////////////////////
Begin
	SEED := '2ho63iea06dk359o62go1102';  
	{sParede := #219;}
	sVazio := '  ';
	sNeblina:= #178;
	B_x := transformar0em10(SEED[21]);
	B_y := transformar0em10(SEED[22]);
	S_x := transformar0em10(SEED[23]);
	S_y := transformar0em10(SEED[24]);
	
	SelecaoDePersonagem;
	clrscr;
	   
	GerarMatrizBOOLEAN;

	DesenharMapa;	
	DesenharMoldura;
	IrPara(B_x,B_y);
	write(sBoneco);
	repeat 
	MoverPersonagem;
	until (B_x = S_x) and (B_y = S_y);
	readkey;
End.