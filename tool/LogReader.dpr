program LogReader;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {frmLogger};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmLogger, frmLogger);
  Application.Run;
end.
