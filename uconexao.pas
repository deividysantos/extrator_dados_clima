unit uConexao;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls,
  ZConnection;

type

  { TdfmConexao }

  TdfmConexao = class(TForm)
    btnSalvar: TBitBtn;
    btnCancelar: TBitBtn;
    edtDatabase: TEdit;
    edtUser: TEdit;
    edtPassword: TEdit;
    edtPort: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public
    Conn : TZConnection;
  end;

var
  dfmConexao: TdfmConexao;

implementation

{$R *.lfm}

{ TdfmConexao }

procedure TdfmConexao.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TdfmConexao.btnSalvarClick(Sender: TObject);
begin
  try
    strToInt(edtPort.Text);
  except
    messageDlg('O campo ''Port'' deverá ser um valor inteiro!', mtInformation, [mbOk], 0);
    Exit;
  end;

  try
    Conn.Disconnect;
    Conn.Database  := edtDatabase.Text;
    Conn.User      := edtUser.Text;
    Conn.Password  := edtPassword.Text;
    Conn.Port      := strToInt(edtPort.Text);
    Conn.Connect;
  except
    on E : Exception do
    begin
      messageDlg('Houve um erro ao conectar ao banco de dados!' + #10+#13 + E.Message, mtInformation, [mbOk], 0);
      Exit;
    end;
  end;

  Close;
end;

procedure TdfmConexao.FormShow(Sender: TObject);
begin
  edtDatabase.Text := Conn.Database;
  edtUser.Text     := Conn.User;
  edtPassword.Text := Conn.Password;
  edtPort.Text     := IntToStr(Conn.Port);
end;

end.

