unit uRepository;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset;

type
  { TRepository }
  TRepository = class(TComponent)
  private
    constructor Create();
  protected
    Query: TZQuery;
  public
    constructor Create(pConnection: TZConnection);
    destructor Destroy();
  end;


implementation

{ TRepository }

constructor TRepository.Create;
begin
  Query := TZQuery.Create(self);
end;

constructor TRepository.Create(pConnection: TZConnection);
begin
  Create();
  Query.Connection := pConnection;
end;

destructor TRepository.Destroy;
begin
  Query.Connection := nil;
  Query.Free;
end;

end.

