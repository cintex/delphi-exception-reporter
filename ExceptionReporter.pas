unit ExceptionReporter;
// по материалам http://www.rsdn.ru/article/Delphi/DelphiJCL.xml
interface

uses SysUtils, Classes, JclDebug, JclHookExcept, dialogs;

Type
  THandleExceptions = (heAll, heNotHandled);

const
  HandleException = heNotHandled;

type
  TExceptionHandler = class
  public
    procedure OnException(Sender: TObject; E: Exception);
  end;

var
  Strings: TStrings = nil;
  ExceptionHandler: TExceptionHandler;

implementation

uses ComObj;

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
