unit uUFRepository;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, uRepository, uTypes;

type

  { TUFRepository }

  TUFRepository = class(TRepository)

  public
    function InsertIfNotImported(pUF: TUF): Integer;

  end;

implementation

{ TUFRepository }

function TUFRepository.InsertIfNotImported(pUF: TUF): Integer;
begin
  with Query do
  begin
    Close;
    SQL.Clear;
    SQL.Add(' SELECT UF.ID_UF, UF.UF  FROM UF WHERE UF.UF = '''+pUF.Sigla+'''  ');
    Open;

    if IsEmpty then
    begin
      Close;
      SQL.Clear;
      SQL.Add(' INSERT INTO uf(uf) VALUES ('''+pUF.Sigla+''') ');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add(' SELECT UF.ID_UF, UF.UF  FROM UF WHERE UF.UF = '''+pUF.Sigla+'''  ');
      Open;
    end;

    if not IsEmpty then
      result := fieldByName('ID_UF').AsInteger;
  end;
end;

end.

