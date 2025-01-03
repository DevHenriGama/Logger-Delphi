unit Logger.Log;

interface

uses
  Logger.CORE, Logger.Interfaces, Logger.Types;

type

  TLog = class(TInterfacedObject, ILog)
  private
    FLogger: TLogger;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: ILog;
    procedure Add(aLogMessage: String; aType: TLogLevel = Info;
      AUser: string = '');
  end;

function Log: ILog;

implementation

uses
  System.SysUtils;

{ TLog }

function Log: ILog;
begin
  Result := TLog.Create;
end;

procedure TLog.Add(aLogMessage: String; aType: TLogLevel; AUser: string);
begin
  FLogger.Add(aLogMessage, aType, AUser);
end;

constructor TLog.Create;
begin
  FLogger := TLogger.Create;
end;

destructor TLog.Destroy;
begin
  inherited;
  FLogger.Free;
end;

class function TLog.New: ILog;
begin
  Result := Self.Create;
end;

end.
