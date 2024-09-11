program Leitor;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, uPrincipal, zcomponent, uConexao, uArquivos, uUtils, uRepository,
  uLeituraRepository, datetimectrls, uTypes
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TdfmPrincipal, dfmPrincipal);
  Application.CreateForm(TdfmConexao, dfmConexao);
  Application.Run;
end.

