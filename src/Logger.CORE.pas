unit Logger.CORE;

interface

uses

  System.SysUtils, Logger.Types;

type

  TLogger = class
  private
    FLogFile: TextFile;

  const
    _LogAttr = 'MacOrcLog - '; // Log Name

    function LogName: String;
    procedure SettingUPLogger;
    function DefType(aType: TLogLevel): string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(aLogMessage: String; aType: TLogLevel = Info;
      AUser: string = '');

  end;

implementation

uses
  Vcl.Forms;

{ TLogger }

procedure TLogger.Add(aLogMessage: String; aType: TLogLevel; AUser: string);
var
  LUser: String;
begin
  LUser := AUser;

{$IFDEF D2BRIDGE}
  if LUser.IsEmpty then
    LUser := MACSession.NomeUsuario + ' - ' + IntToStr(MACSession.CodEmpresa);
{$ENDIF}
{$IFDEF TEST}
  if LUser.IsEmpty then
    LUser := ' TEST';
{$ENDIF}
  Append(FLogFile);
  try
    Writeln(FLogFile, Format('| [%s] | %s | %s | - %s | [%s] |',
      [DateToStr(Now), DefType(aType), LUser, aLogMessage, TimeToStr(Now)]));
  finally
    CloseFile(FLogFile);
  end;
end;

constructor TLogger.Create;
begin
  SettingUPLogger;
end;

function TLogger.DefType(aType: TLogLevel): string;
begin
  case aType of
    Info:
      Result := '[Info]';
    Warning:
      Result := '[Warning]';
    Error:
      Result := '[Error]';
  else
    Result := '[Unknown]';
  end;
end;

destructor TLogger.Destroy;
begin
  inherited;
end;

function TLogger.LogName: String;
begin
  Result := _LogAttr + FormatDateTime('ddmmyyyy', Now) + '.log';
end;

procedure TLogger.SettingUPLogger;
var
  FDir, FFile: string;
begin
  FDir := ExtractFilePath(Application.ExeName) + 'MacLogs\';

  FFile := FDir + LogName;

  if not DirectoryExists(FDir) then
  begin
    CreateDir(FDir);
  end;

  AssignFile(FLogFile, FFile);
  if not FileExists(FFile) then
    Rewrite(FLogFile)
  else
    Append(FLogFile);

  CloseFile(FLogFile);
end;

end.
