unit uLeituraRepository;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, uRepository, uTypes;

type
  { TLeituraRepository }
  TLeituraRepository = class(TRepository)
  private

  protected

  public
    function fExistemLeiturasPorAno(pAno: String): Boolean;
    function InsertIfNotImported(mLeitura: TLeitura): Integer;
  end;

implementation

{ TLeituraRepository }

function TLeituraRepository.fExistemLeiturasPorAno(pAno: String): Boolean;
begin
  result := false;
  try
    with Query do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT COUNT(L.ID_LEITURA) AS QTD   ');
      SQL.Add('  FROM LEITURAS L                   ');
      SQL.Add(' WHERE L.DATA >= ''01/01/'+pAno+''' ');
      SQL.Add('   AND L.DATA <= ''31/12/'+pAno+''' ');
      Open;
    end;

    result := Query.FieldByName('QTD').AsInteger > 0;
  except
    result := false;
  end;
end;

function TLeituraRepository.InsertIfNotImported(mLeitura: TLeitura): Integer;
begin
  with Query do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT L.ID_LEITURA                   ');
    SQL.Add('  FROM LEITURAS L                     ');
    SQL.Add(' WHERE L.ID_ESTACAO = :ID_ESTACAO     ');
    SQL.Add('   AND L.DATA_LEITURA = :DATA_LEITURA ');
    SQL.Add('   AND L.HORA = :HORA                 ');
    params.ParamByName('ID_ESTACAO').AsInteger := mLeitura.ESTACAO.ID_ESTACAO;
    params.ParamByName('DATA_LEITURA').AsString := DateToStr(mLeitura.DATA);
    params.ParamByName('HORA').AsString := mLeitura.HORA;
    Open;

    if IsEmpty then
    begin
      Close;
      SQL.Clear;
      SQL.Add('INSERT INTO leituras(id_estacao, data_leitura, hora, precipitacao_total,                      ');
      SQL.Add('                     press_atm_estacao, press_atm_max, press_atm_min, radiacao_global,        ');
      SQL.Add('                     temp_ar, temp_ponto_orvalho, temp_max, temp_min, temp_orvalho_max,       ');
      SQL.Add('                     temp_orvalho_min, umidade_rel_max, umidade_rel_min, umidade_relativa_ar, ');
      SQL.Add('                     vento_direcao_horaria, vento_rajada_max, vento_velocidade_horaria)       ');
      SQL.Add('  VALUES (:id_estacao, :data_leitura, :hora, :precipitacao_total,                             ');
      SQL.Add('          :press_atm_estacao, :press_atm_max, :press_atm_min, :radiacao_global,               ');
      SQL.Add('          :temp_ar, :temp_ponto_orvalho, :temp_max, :temp_min, :temp_orvalho_max,             ');
      SQL.Add('          :temp_orvalho_min, :umidade_rel_max, :umidade_rel_min, :umidade_relativa_ar,        ');
      SQL.Add('          :vento_direcao_horaria, :vento_rajada_max, :vento_velocidade_horaria)               ');

      params.ParamByName('id_estacao')              .AsInteger  := mLeitura.ESTACAO.ID_ESTACAO;
      params.ParamByName('data_leitura')            .AsDateTime := mLeitura.DATA;
      params.ParamByName('hora')                    .AsString   := mLeitura.HORA;
      params.ParamByName('precipitacao_total')      .AsFloat    := mLeitura.PRECIPITACAO_TOTAL;
      params.ParamByName('press_atm_estacao')       .AsFloat    := mLeitura.PRESS_ATM_ESTACAO;
      params.ParamByName('press_atm_max')           .AsFloat    := mLeitura.PRESS_ATM_MAX;
      params.ParamByName('press_atm_min')           .AsFloat    := mLeitura.PRESS_ATM_MIN;
      params.ParamByName('radiacao_global')         .AsFloat    := mLeitura.RADIACAO_GLOBAL;
      params.ParamByName('temp_ar')                 .AsFloat    := mLeitura.TEMP_AR;
      params.ParamByName('temp_ponto_orvalho')      .AsFloat    := mLeitura.TEMP_PONTO_ORVALHO;
      params.ParamByName('temp_max')                .AsFloat    := mLeitura.TEMP_MAX;
      params.ParamByName('temp_min')                .AsFloat    := mLeitura.TEMP_MIN;
      params.ParamByName('temp_orvalho_max')        .AsFloat    := mLeitura.TEMP_ORVALHO_MAX;
      params.ParamByName('temp_orvalho_min')        .AsFloat    := mLeitura.TEMP_ORVALHO_MIN;
      params.ParamByName('umidade_rel_max')         .AsFloat    := mLeitura.UMIDADE_REL_MAX;
      params.ParamByName('umidade_rel_min')         .AsFloat    := mLeitura.UMIDADE_REL_MIN;
      params.ParamByName('umidade_relativa_ar')     .AsFloat    := mLeitura.UMIDADE_RELATIVA_AR;
      params.ParamByName('vento_direcao_horaria')   .AsFloat    := mLeitura.VENTO_DIRECAO_HORARIA;
      params.ParamByName('vento_rajada_max')        .AsFloat    := mLeitura.VENTO_RAJADA_MAX;
      params.ParamByName('vento_velocidade_horaria').AsFloat    := mLeitura.VENTO_VELOCIDADE_HORARIA;
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('SELECT L.ID_LEITURA                   ');
      SQL.Add('  FROM LEITURAS L                     ');
      SQL.Add(' WHERE L.ID_ESTACAO = :ID_ESTACAO     ');
      SQL.Add('   AND L.DATA_LEITURA = :DATA_LEITURA ');
      SQL.Add('   AND L.HORA = :HORA                 ');
      params.ParamByName('ID_ESTACAO').AsInteger := mLeitura.ESTACAO.ID_ESTACAO;
      params.ParamByName('DATA_LEITURA').AsString := DateToStr(mLeitura.DATA);
      params.ParamByName('HORA').AsString := mLeitura.HORA;
      Open;
    end;

    if not IsEmpty then
      result := fieldByName('ID_LEITURA').AsInteger;
  end;
end;

end.

