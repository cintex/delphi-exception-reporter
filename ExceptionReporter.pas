unit ExceptionReporter;
// по материалам http://www.rsdn.ru/article/Delphi/DelphiJCL.xml
interface

uses SysUtils, Windows, Classes, JclDebug, JclHookExcept, dialogs, IdSMTP, IdMessage;

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

procedure SendLastException(E: Exception);

implementation

uses uConfirmDialog;

function GetModuleName: string;
var
  fName: string;
  nsize: cardinal;
begin
  nsize := 128;
  SetLength(fName, nsize);
  SetLength(fName,
    GetModuleFileName(
    hinstance,
    pchar(fName),
    nsize));
  Result := ExtractFileName(fName);
end;

function GetEmailSubject(E: Exception): String;
begin
  Result := GetModuleName;
  if Assigned(E) then
    Result := Result + ', ' + E.ClassName;
end;

procedure Send(const Subject, Text: String);
var
  SMTP: TIdSMTP;
  IdMessage1: TIdMessage;
begin
  SMTP := TIdSMTP.Create(nil);
  IdMessage1 := TIdMessage.Create(nil);
  try
    try
    SMTP.Host := SMTP_HOST;
    SMTP.Port := SMTP_PORT; //
    SMTP.AuthenticationType := atLogin;
    SMTP.Username := SMTP_USERNAME;
    SMTP.Password := SMTP_PASSWORD;
    IdMessage1.Recipients.EMailAddresses:= TO_ADDRESS;
    IdMessage1.From.Text := FROM_ADDRESS;
    IdMessage1.Subject := Subject;
    IdMessage1.Body.Text := Text;
    SMTP.Connect;
    SMTP.Send(IdMessage1);
    SMTP.Disconnect;
    except
    end;
  finally
    FreeAndNil(smtp);
    FreeAndNil(IdMessage1);
  end;
end;

procedure SendLastException(E: Exception);
var
  Strings: TStrings;
begin
  Strings := TStringList.Create;
  try
    Strings.BeginUpdate;
    if Assigned(E) then
    begin
      Strings.Add(E.ClassName);
      Strings.Add(E.Message);
      Strings.Add('at');
    end;
    JclLastExceptStackListToStrings(Strings, false, True, True);
    Strings.EndUpdate;
    if SendConfirm(Strings.Text) then
      Send(GetEmailSubject(E), Strings.Text);
  finally
    FreeAndNil(Strings);
  end;
end;

procedure AnyExceptionNotify(
  ExceptObj: TObject; ExceptAddr: Pointer; OSException: Boolean);
begin
  SendLastException(nil);
end;

{ TExceptionHandler }

procedure TExceptionHandler.DoException(Sender: TObject; E: Exception);
begin
  SendLastException(E);
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
