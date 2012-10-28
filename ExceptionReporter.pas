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
    procedure OnException(Sender: TObject; E: Exception);
  end;

var
  Strings: TStrings = nil;
  ExceptionHandler: TExceptionHandler;

implementation

procedure Send();
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
    //SMTP.
    IdMessage1.Recipients.EMailAddresses:= TO_ADDRESS;
    IdMessage1.From.Text := FROM_ADDRESS;
    IdMessage1.Subject := 'Exception Report';
    IdMessage1.Body.Text := 'hello';
    SMTP.Connect;
    SMTP.Send(IdMessage1);
    SMTP.Disconnect; 
  finally
    FreeAndNil(smtp);
    FreeAndNil(IdMessage1);
  end;
end;

procedure AnyExceptionNotify(
  ExceptObj: TObject; ExceptAddr: Pointer; OSException: Boolean);
begin
  if Assigned(Strings) then
  begin
    Strings.BeginUpdate;
    JclLastExceptStackListToStrings(Strings, false, True, True);
    Strings.EndUpdate;
    SHowMessage(Strings.Text);
  end;
end;

{ TExceptionHandler }

procedure TExceptionHandler.OnException(Sender: TObject; E: Exception);
begin
  if Assigned(Strings) then
  begin
    Strings.BeginUpdate;
    JclLastExceptStackListToStrings(Strings, true, true); 
    Strings.EndUpdate;
    SHowMessage(Strings.Text);
  end;
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
