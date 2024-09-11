unit uTypes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TUF = record
    ID_UF: Integer;
    Sigla: String;
  end;

  TEstacaoMeteorologica = record
    ID_ESTACAO: Integer;
    UF: TUF;
    Nome: String;
    Codigo: String;
    Latitude: Double;
    Longitude: Double;
    Altitude: Double;
    DataFundacao: TDateTime;
  end;

  TLeitura = record
    ID_LEITURA: Integer;
    ESTACAO: TEstacaoMeteorologica;
    DATA: TDateTime;
    HORA: String;
    PRECIPITACAO_TOTAL: Double;
    PRESS_ATM_ESTACAO: Double;
    PRESS_ATM_MAX: Double;
    PRESS_ATM_MIN: Double;
    RADIACAO_GLOBAL: Double;
    TEMP_AR: Double;
    TEMP_PONTO_ORVALHO: Double;
    TEMP_MAX: Double;
    TEMP_MIN: Double;
    TEMP_ORVALHO_MAX: Double;
    TEMP_ORVALHO_MIN: Double;
    UMIDADE_REL_MAX: Double;
    UMIDADE_REL_MIN: Double;
    UMIDADE_RELATIVA_AR: Double;
    VENTO_DIRECAO_HORARIA: Double;
    VENTO_RAJADA_MAX: Double;
    VENTO_VELOCIDADE_HORARIA: Double;
  end;

implementation

end.

