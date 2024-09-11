unit uPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, DBCtrls, DBGrids, ZConnection, ZDataset, uConexao, uArquivos,
  DateTimePicker, uLeituraRepository, uUFRepository, uEstacaoRepository;

type

  { TdfmPrincipal }
  TdfmPrincipal = class(TForm)
    btnAtualizar: TBitBtn;
    btnConexao: TBitBtn;
    Button1: TButton;
    Conn: TZConnection;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    DBGrid1: TDBGrid;
    DBLookupComboBox1: TDBLookupComboBox;
    DBLookupComboBox2: TDBLookupComboBox;
    DBLookupComboBox3: TDBLookupComboBox;
    lblConexao: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    qrAtualizador: TZQuery;
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnConexaoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure Atualizador;

  public

  end;

var
  dfmPrincipal: TdfmPrincipal;

implementation

{$R *.lfm}

{ TdfmPrincipal }

procedure TdfmPrincipal.btnConexaoClick(Sender: TObject);
begin
  try
    dfmConexao := TdfmConexao.Create(self);
    dfmConexao.Conn := Conn;
    dfmConexao.ShowModal;
  finally
    dfmConexao.Conn := nil;
    dfmConexao.Free;
    if Conn.Connected then
    begin
      lblConexao.Visible := true;
      Atualizador;
    end;
  end;
end;

procedure TdfmPrincipal.FormShow(Sender: TObject);
begin
  lblConexao.Visible := false;
  btnConexao.SetFocus;
end;

procedure TdfmPrincipal.btnAtualizarClick(Sender: TObject);
var
  mArquivos: TArquivos;
begin
  //TODO: Baixar apenas os arquivos dos anos que ainda não foram importados E o arquivo do ano atual (pode ter atualizado o mês)
  //existe ainda a possibilidade de verificar se o mês virou, ou seja, temos os dados de agosto e ainda é setembro, logo nao tem mais dados a serem baixados
  //mas em outubro vai ter dados de setembro então baixa o arquivo do ano atual dnv

  if messageDlg('Deseja realmente atualizar os dados?', mtInformation, [mbYes, mbNo],0) <> mrYes then
    Exit;

  mArquivos := TArquivos.Create(Self);
  try
    try
      mArquivos.Atualizar(ExtractFilePath(Application.ExeName),
                          TUFRepository.Create(Conn),
                          TEstacaoRepository.Create(Conn),
                          TLeituraRepository.Create(Conn));
    except
      on e: Exception do
      begin
        messageDlg('Erro ao atualizar!' + E.Message, mtInformation, [mbOk], 0);
        Exit;
      end;
    end;
  finally
    mArquivos.Free;
  end;
end;

procedure TdfmPrincipal.Atualizador();
var
  mSql : String;
begin
  if not Conn.Connected then
    Exit;

  with qrAtualizador do
  begin
    Close;
    SQL.Clear;
    try
      SQL.Add(' SELECT table_name FROM information_schema.tables WHERE Upper(table_name) = ''UF''  ');
      Open;

      if qrAtualizador.isEmpty then
        raise Exception.Create('');
    except
      SQL.Clear;
      SQL.Add(' CREATE TABLE UF ( ID_UF SERIAL PRIMARY KEY, UF CHAR(3) ) ');
      ExecSQL();
    end;

    Close;
    SQL.Clear;
    try
      SQL.Add(' SELECT table_name FROM information_schema.tables WHERE Upper(table_name) = ''ESTACAO_METEOROLOGICA'' ');
      Open;

      if qrAtualizador.isEmpty then
        raise Exception.Create('');
    except
      Close;
      SQL.Clear;
      mSql := 'CREATE TABLE ESTACAO_METEOROLOGICA ( '+
              '  ID_ESTACAO SERIAL PRIMARY KEY,     '+
              '  ID_UF INTEGER,                     '+
              '  NOME CHAR(100),                    '+
              '  CODIGO CHAR(100),                  '+
              '  LATITUDE CHAR(100),                '+
              '  LONGITUDE CHAR(100),               '+
              '  ALTITUDE CHAR(100),                '+
              '  DATA_FUNDACAO DATE,                '+
              '  CONSTRAINT FK_UF_ESTACAO FOREIGN KEY (ID_UF) REFERENCES UF (ID_UF) '+
              ' )';
      SQL.Add(mSql);
      ExecSQL();
    end;

    Close;
    SQL.Clear;
    try
      SQL.Add(' SELECT table_name FROM information_schema.tables WHERE Upper(table_name) = ''LEITURAS''  ');
      Open;

      if qrAtualizador.isEmpty then
        raise Exception.Create('');
    except
      {
      PRECIPITAÇÃO TOTAL, HORÁRIO (mm)                        C - PRECIPITACAO_TOTAL
      PRESSAO ATMOSFERICA AO NIVEL DA ESTACAO, HORARIA (mB)   D - PRESS_ATM_ESTACAO
      PRESSÃO ATMOSFERICA MAX.NA HORA ANT. (AUT) (mB)         E - PRESS_ATM_MAX
      PRESSÃO ATMOSFERICA MIN. NA HORA ANT. (AUT) (mB)        F - PRESS_ATM_MIN
      RADIACAO GLOBAL (Kj/m²)                                 G - RADIACAO_GLOBAL
      TEMPERATURA DO AR - BULBO SECO, HORARIA (°C)            H - TEMP_AR
      TEMPERATURA DO PONTO DE ORVALHO (°C)                    I - TEMP_PONTO_ORVALHO
      TEMPERATURA MÁXIMA NA HORA ANT. (AUT) (°C)              J - TEMP_MAX
      TEMPERATURA MÍNIMA NA HORA ANT. (AUT) (°C)              K - TEMP_MIN
      TEMPERATURA ORVALHO MAX. NA HORA ANT. (AUT) (°C)        L - TEMP_ORVALHO_MAX
      TEMPERATURA ORVALHO MIN. NA HORA ANT. (AUT) (°C)        M - TEMP_ORVALHO_MIN
      UMIDADE REL. MAX. NA HORA ANT. (AUT) (%)                N - UMIDADE_REL_MAX
      UMIDADE REL. MIN. NA HORA ANT. (AUT) (%)                O - UMIDADE_REL_MIN
      UMIDADE RELATIVA DO AR, HORARIA (%)                     P - UMIDADE_RELATIVA_AR
      VENTO, DIREÇÃO HORARIA (gr) (° (gr))                    Q - VENTO_DIRECAO_HORARIA
      VENTO, RAJADA MAXIMA (m/s)                              R - VENTO_RAJADA_MAX
      VENTO, VELOCIDADE HORARIA (m/s)                         S - VENTO_VELOCIDADE_HORARIA
      }

      Close;
      SQL.Clear;
      mSql := 'CREATE TABLE LEITURAS (           '+
              '  ID_LEITURA SERIAL PRIMARY KEY,  '+
              '  ID_ESTACAO INTEGER,             '+
              '  DATA_LEITURA DATE,              '+
              '  HORA CHAR(8),                   '+
              '  PRECIPITACAO_TOTAL REAL,        '+
              '  PRESS_ATM_ESTACAO REAL,         '+
              '  PRESS_ATM_MAX REAL,             '+
              '  PRESS_ATM_MIN REAL,             '+
              '  RADIACAO_GLOBAL REAL,           '+
              '  TEMP_AR REAL,                   '+
              '  TEMP_PONTO_ORVALHO REAL,        '+
              '  TEMP_MAX REAL,                  '+
              '  TEMP_MIN REAL,                  '+
              '  TEMP_ORVALHO_MAX REAL,          '+
              '  TEMP_ORVALHO_MIN REAL,          '+
              '  UMIDADE_REL_MAX REAL,           '+
              '  UMIDADE_REL_MIN REAL,           '+
              '  UMIDADE_RELATIVA_AR REAL,       '+
              '  VENTO_DIRECAO_HORARIA REAL,     '+
              '  VENTO_RAJADA_MAX REAL,          '+
              '  VENTO_VELOCIDADE_HORARIA REAL,  '+
              '  CONSTRAINT FK_LEITURA_ESTACAO FOREIGN KEY (ID_ESTACAO) REFERENCES ESTACAO_METEOROLOGICA (ID_ESTACAO) '+
              ' )';
      SQL.Add(mSql);
      ExecSQL();
    end;
  end;
end;

end.

