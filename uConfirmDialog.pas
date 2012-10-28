unit uConfirmDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfConfirmDialog = class(TForm)
    mDataToSend: TMemo;
    btSendToDeveloper: TButton;
    btDontSend: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;


function SendConfirm(const Text: String): Boolean;

implementation

{$R *.dfm}

function SendConfirm(const Text: String): Boolean;
var
  f: TfConfirmDialog;
begin
  f := TfConfirmDialog.Create(nil);
  try
    f.mDataToSend.Text := Text;
    f.ShowModal;
    Result := f.ModalResult = mrOk;
  finally
    FreeAndNil(f);
  end;
end;

end.
