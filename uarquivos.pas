unit uArquivos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, uUtils, uLeituraRepository, DateUtils, csvdocument,
  uTypes, uEstacaoRepository, uUFRepository;

type

  { TArquivos }
  TArquivos = class(TComponent)
    private
      AnoAtual : Boolean;
      DiretorioOrigem : String;
      DiretorioDestino : String;
      ApplicationPath: String;
      LeituraRepository: TLeituraRepository;
      EstacaoRepository : TEstacaoRepository;
      UFRepository: TUFRepository;
      procedure pApagarDadosExistentes(pApplicationPath: String);
      procedure pBaixarDados();
      procedure pExtrairArquivos(Dir: string);
      procedure pImportarDados(pDiretorio: String);
      procedure pLerArquivo(pNomeArquivo: String);

    public
      function Atualizar(pApplicationPath: String;
                         pUFRepository: TUFRepository;
                         pEstacaoRepository : TEstacaoRepository;
                         pLeituraRepository: TLeituraRepository) : Boolean;
  end;


implementation

{ TArquivos }

procedure TArquivos.pApagarDadosExistentes(pApplicationPath: String);
begin
  if DirectoryExists(ApplicationPath+'/'+DiretorioDestino) then
  begin
    DeleteDirectory(ApplicationPath+'/'+DiretorioDestino);
  end;
  CreateDir(ApplicationPath+'/'+DiretorioDestino);


  //if DirectoryExists(ApplicationPath+'/'+DiretorioOrigem) then
  //begin
  //  DeleteDirectory(ApplicationPath+'/'+DiretorioOrigem);
  //end;
  //CreateDir(ApplicationPath+'/'+DiretorioOrigem);
end;

procedure TArquivos.pBaixarDados();
var
  mAnoAtual, mAno : integer;
begin
  //mAnoAtual := (YearOf(now()));
  mAnoAtual := 2005;
  for mAno := 2000 to mAnoAtual do
  begin
    if not LeituraRepository.fExistemLeiturasPorAno(intToStr(mAno)) then
    begin
      Download(self, 'https://portal.inmet.gov.br/uploads/dadoshistoricos/'+intToStr(mAno)+'.zip', 'dadoszip\'+intToStr(mAno)+'.zip', ApplicationPath);
    end;
  end;
end;

procedure TArquivos.pExtrairArquivos(Dir: string);
var
  SearchRec: TSearchRec;
  FilePath: string;
begin
  // Adiciona uma barra invertida no final se o diretório não tiver
  if Dir[Length(Dir)] <> '\' then
    FilePath := Dir + '\'
  else
    FilePath := Dir;

  // Inicializa a pesquisa pelo primeiro arquivo no diretório
  if FindFirst(FilePath + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        // Verifica se é um arquivo (e não um diretório ou outro tipo de entrada)
        if ((SearchRec.Attr and faDirectory) = 0) and ( Copy(SearchRec.Name, Length(SearchRec.Name)-3) <> 'tmp' ) then
        begin
          UnZip(FilePath + SearchRec.Name, ApplicationPath+'/'+DiretorioDestino);
        end;

      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec); // Fecha a pesquisa
    end;
  end;
end;

procedure TArquivos.pImportarDados(pDiretorio: String);
var
  SearchRec: TSearchRec;
  FilePath: string;
begin
  // Adiciona uma barra invertida no final se o diretório não tiver
  if pDiretorio[Length(pDiretorio)] <> '\' then
    FilePath := pDiretorio + '\'
  else
    FilePath := pDiretorio;

  // Inicializa a pesquisa pelo primeiro arquivo no diretório
  if FindFirst(FilePath + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        // Verifica se é um arquivo (e não um diretório ou outro tipo de entrada)
        if (SearchRec.Attr and faDirectory) = 0 then
        begin
          pLerArquivo(pDiretorio+'\'+SearchRec.Name);
        end;

        // Verifica se é um diretório
        if (SearchRec.Attr and faDirectory) = faDirectory then
        begin
          // Ignora os diretórios '.' e '..'
          if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
          begin
            pImportarDados(pDiretorio+'\'+SearchRec.Name);
          end;
        end;

      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec); // Fecha a pesquisa
    end;
  end;
end;

procedure TArquivos.pLerArquivo(pNomeArquivo : String);
var
  CSV : TCSVDocument;
  mUF : TUF;
  mEstacao : TEstacaoMeteorologica;
  mLeitura : TLeitura;
  i : integer;

  mData : String;
  Year, Month, Day: Word;
begin
  CSV := TCSVDocument.Create;
  try
    CSV.Delimiter := ';';
    CSV.LoadFromFile(pNomeArquivo);

    mUF.Sigla := CSV.Cells[1, 1];
    mUF.ID_UF := UFRepository.InsertIfNotImported(mUF);

    mEstacao.Nome := CSV.Cells[1, 2];
    mEstacao.Codigo := CSV.Cells[1, 3];
    mEstacao.Latitude := StrToFloatDef(CSV.Cells[1, 4], 0);
    mEstacao.Longitude := StrToFloatDef(CSV.Cells[1, 5], 0);
    mEstacao.Altitude := StrToFloatDef(CSV.Cells[1, 6], 0);
    mEstacao.UF := mUF;

    mData := CSV.Cells[1, 7];
    Year := strToInt(Copy(mData, 0, 4));
    Month := strToInt(Copy(mData, 6, 2));
    Day := strToInt(Copy(mData, 9, 2));

    mEstacao.DataFundacao := EncodeDate(Year, Month, Day);
    mEstacao.ID_ESTACAO := EstacaoRepository.InsertIfNotImported(mEstacao);

    mLeitura.ESTACAO := mEstacao;
    for i := 9 to CSV.RowCount - 1 do
    begin
      mData := CSV.Cells[0, i];
      Year := strToInt(Copy(mData, 0, 4));
      Month := strToInt(Copy(mData, 6, 2));
      Day := strToInt(Copy(mData, 9, 2));

      mLeitura.DATA                     := EncodeDate(Year, Month, Day);
      mLeitura.HORA                     := CSV.Cells[1, i];;
      mLeitura.PRECIPITACAO_TOTAL       := StrToFloatDef(CSV.Cells[2, i], 0);
      mLeitura.PRESS_ATM_ESTACAO        := StrToFloatDef(CSV.Cells[3, i], 0);
      mLeitura.PRESS_ATM_MAX            := StrToFloatDef(CSV.Cells[4, i], 0);
      mLeitura.PRESS_ATM_MIN            := StrToFloatDef(CSV.Cells[5, i], 0);
      mLeitura.RADIACAO_GLOBAL          := StrToFloatDef(CSV.Cells[6, i], 0);
      mLeitura.TEMP_AR                  := StrToFloatDef(CSV.Cells[7, i], 0);
      mLeitura.TEMP_PONTO_ORVALHO       := StrToFloatDef(CSV.Cells[8, i], 0);
      mLeitura.TEMP_MAX                 := StrToFloatDef(CSV.Cells[9, i], 0);
      mLeitura.TEMP_MIN                 := StrToFloatDef(CSV.Cells[10, i], 0);
      mLeitura.TEMP_ORVALHO_MAX         := StrToFloatDef(CSV.Cells[11, i], 0);
      mLeitura.TEMP_ORVALHO_MIN         := StrToFloatDef(CSV.Cells[12, i], 0);
      mLeitura.UMIDADE_REL_MAX          := StrToFloatDef(CSV.Cells[13, i], 0);
      mLeitura.UMIDADE_REL_MIN          := StrToFloatDef(CSV.Cells[14, i], 0);
      mLeitura.UMIDADE_RELATIVA_AR      := StrToFloatDef(CSV.Cells[15, i], 0);
      mLeitura.VENTO_DIRECAO_HORARIA    := StrToFloatDef(CSV.Cells[16, i], 0);
      mLeitura.VENTO_RAJADA_MAX         := StrToFloatDef(CSV.Cells[17, i], 0);
      mLeitura.VENTO_VELOCIDADE_HORARIA := StrToFloatDef(CSV.Cells[18, i], 0);
      mLeitura.ID_LEITURA := LeituraRepository.InsertIfNotImported(mLeitura);
    end;
  finally
    CSV.Free;
  end;
end;

function TArquivos.Atualizar(pApplicationPath: String;
                             pUFRepository: TUFRepository;
                             pEstacaoRepository : TEstacaoRepository;
                             pLeituraRepository: TLeituraRepository): Boolean;
begin
  LeituraRepository := pLeituraRepository;
  EstacaoRepository := pEstacaoRepository;
  UFRepository      := pUFRepository;

  DiretorioOrigem := 'dadoszip';
  DiretorioDestino := 'dados';
  ApplicationPath := pApplicationPath;

  pApagarDadosExistentes(pApplicationPath);
  //pBaixarDados();
  pExtrairArquivos(pApplicationPath+'/'+DiretorioOrigem);
  pImportarDados(pApplicationPath+DiretorioDestino);
end;

end.

