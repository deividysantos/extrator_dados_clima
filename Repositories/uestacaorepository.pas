unit uEstacaoRepository;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, uRepository, uTypes;

type

  { TEstacaoRepository }

  TEstacaoRepository = class(TRepository)
  public
    function InsertIfNotImported(mEstacao: TEstacaoMeteorologica): Integer;
  end;

implementation


{ TEstacaoRepository }

function TEstacaoRepository.InsertIfNotImported(mEstacao: TEstacaoMeteorologica): Integer;
begin
  with Query do
  begin
    Close;
    SQL.Clear;
    SQL.Add(' SELECT EM.ID_ESTACAO                 ');
    SQL.Add('  FROM ESTACAO_METEOROLOGICA EM       ');
    SQL.Add(' WHERE EM.NOME = '''+mEstacao.Nome+'''');
    Open;

    if IsEmpty then
    begin
      Close;
      SQL.Clear;
      SQL.Add(' INSERT INTO estacao_meteorologica(      ');
      SQL.Add('	id_uf, nome, codigo, latitude, longitude, altitude, data_fundacao) ');
      SQL.Add('	VALUES (:id_uf, :nome, :codigo, :latitude, :longitude, :altitude, :data_fundacao) ');
      params.ParamByName('id_uf')        .AsInteger  := mEstacao.UF.ID_UF;
      params.ParamByName('nome')         .AsString   := mEstacao.Nome;
      params.ParamByName('codigo')       .AsString   := mEstacao.Codigo;
      params.ParamByName('latitude')     .AsFloat    := mEstacao.Latitude;
      params.ParamByName('longitude')    .AsFloat    := mEstacao.Longitude;
      params.ParamByName('altitude')     .AsFloat    := mEstacao.Altitude;
      params.ParamByName('data_fundacao').AsDateTime := mEstacao.DataFundacao;
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add(' SELECT EM.ID_ESTACAO                 ');
      SQL.Add('  FROM ESTACAO_METEOROLOGICA EM       ');
      SQL.Add(' WHERE EM.NOME = '''+mEstacao.Nome+'''');
      Open;
    end;

    if not IsEmpty then
      result := fieldByName('ID_ESTACAO').AsInteger;
  end;
end;

end.

