unit uSystemInfo;

interface
uses
  Windows;

function GetWinVer: String;

implementation

uses SysUtils;

function PlatformToStr(platform: Integer): String;
begin
  case platform of
    0: Result := 'WIN32s';
    1: Result := 'WIN32_WINDOWS';
    2: Result := 'WIN32_NT';
    else Result := IntToStr(platform);
  end;
end;

function Is64BitOS: String;
// true - OS x64
// false - OS x32
type
  TIsWow64Process = function(Handle: THandle; var IsWow64: BOOL) : BOOL; stdcall;
var
  hKernel32: Integer;
  IsWow64Process: TIsWow64Process;
  IsWow64: BOOL;
begin
  Result := '';
  hKernel32 := LoadLibrary('kernel32.dll');
  if (hKernel32 <> 0) then
  @IsWow64Process := GetProcAddress(hkernel32, 'IsWow64Process');
  if Assigned(IsWow64Process) then
  begin
    IsWow64 := False;
    if (IsWow64Process(GetCurrentProcess, IsWow64)) then
    begin
      if IsWow64 then
        Result := 'x64'
      else
        Result := 'x86';  
    end
  end;
  FreeLibrary(hKernel32);
end;

function GetWinVer: String;
var
  OSVersionInfo: TOSVersionInfo;
begin
  Result := '';
  OSVersionInfo.dwOSVersionInfoSize := sizeof(TOSVersionInfo);
  if GetVersionEx(OSVersionInfo) then
  case OSVersionInfo.DwMajorVersion of
    3:
      Result := 'Windows NT 3';
    4:
      case OSVersionInfo.DwMinorVersion of
        0:
          if OSVersionInfo.dwPlatformId = VER_PLATFORM_WIN32_NT then
            Result := 'Windows NT 4'
          else
            Result := 'Windows 95';
        10:
          Result := 'Windows 98';
        90:
          Result := 'Windows ME';
      end;
    5:
      case OSVersionInfo.DwMinorVersion of
        0:
          Result := 'Windows 2000';
        1:
          Result := 'Windows XP';
        2:
          Result := 'Windows 2003';
      end;
    6:
      case OSVersionInfo.DwMinorVersion of
        0:
          Result := 'Windows Vista';
        1:
          Result := 'Windows 7';
        2:
          Result := 'Windows 8';
      end;
  end;
  Result := Result + ' ' + Is64BitOS + ' (' + IntToStr(OSVersionInfo.dwMajorVersion) + '.'
    + IntToStr(OSVersionInfo.dwMinorVersion) + '.'
    + IntToStr(OSVersionInfo.dwBuildNumber)
    + ', platform ' + PlatformToStr(OSVersionInfo.dwPlatformId) + ', ' 
    + OSVersionInfo.szCSDVersion + ')';
end;

initialization

end.
