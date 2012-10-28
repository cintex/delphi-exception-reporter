unit ExceptionReporter;
// по материалам http://www.rsdn.ru/article/Delphi/DelphiJCL.xml
interface

uses SysUtils, Classes, JclDebug, JclHookExcept, dialogs, IdSMTP, IdMessage;

Type
  THandleExceptions = (heAll, heNotHandled);

const
  HandleException = heNotHandled;
  SendOnEmail = True;
  {$I email.options.inc}
type
  TExceptionHandler = class
  public
    procedure DoException(Sender: TObject; E: Exception);
  end;

var
  ExceptionHandler: TExceptionHandler;

implementation

uses uConfirmDialog;

procedure Send(const Text: String);
var
  SMTP: TIdSMTP;
  IdMessage1: TIdMessage;
begin
  SMTP := TIdSMTP.Create(nil);
  IdMessage1 := TIdMessage.Create(nil);
  try
    SMTP.Host := SMTP_HOST;
    SMTP.Port := SMTP_PORT; //
    SMTP.AuthenticationType := atLogin;
    SMTP.Username := SMTP_USERNAME;
    SMTP.Password := SMTP_PASSWORD;
    IdMessage1.Recipients.EMailAddresses:= TO_ADDRESS;
    IdMessage1.From.Text := FROM_ADDRESS;
    IdMessage1.Subject := 'Exception Report';
    IdMessage1.Body.Text := Text;
    SMTP.Connect;
    SMTP.Send(IdMessage1);
    SMTP.Disconnect; 
  finally
    FreeAndNil(smtp);
    FreeAndNil(IdMessage1);
  end;
end;

procedure OnException;
var
  Strings: TStrings;
begin
  Strings := TStringList.Create;
  try
    Strings.BeginUpdate;
    JclLastExceptStackListToStrings(Strings, false, True, True);
    Strings.EndUpdate;
    if SendConfirm(Strings.Text) then
      Send(Strings.Text);
  finally
    FreeAndNil(Strings);
  end;
end;

procedure AnyExceptionNotify(
  ExceptObj: TObject; ExceptAddr: Pointer; OSException: Boolean);
begin
  OnException;
end;

{ TExceptionHandler }

procedure TExceptionHandler.DoException(Sender: TObject; E: Exception);
begin
  OnException;
end;

initialization

JclStartExceptionTracking;

case HandleException of
  heAll:
  begin
    Include(JclStackTrackingOptions, stRawMode);
    JclAddExceptNotifier(AnyExceptionNotify);
  end;
  heNotHandled: begin
    ExceptionHandler := TExceptionHandler.Create;
  end;
end;

end.
