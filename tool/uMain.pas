unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Layouts, FMX.ListBox,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Rtti,
  FMX.Grid.Style, Data.Bind.EngExt, FMX.Bind.DBEngExt, FMX.Bind.Grid,
  System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope, FMX.ScrollBox, FMX.Grid, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, FireDAC.DApt,
  FireDAC.Phys.SQLiteVDataSet, FMX.DateTimeCtrls, System.Generics.Collections,
  FMX.Memo, IniFiles;

type
  TfrmLogger = class(TForm)
    edtPath: TEdit;
    btnSelectFolder: TButton;
    SaveDialog1: TSaveDialog;
    ListBox1: TListBox;
    memTableLog: TFDMemTable;
    memTableLogData: TDateField;
    memTableLogTipo: TStringField;
    memTableLogMensagem: TMemoField;
    memTableLogHora: TTimeField;
    gdLogs: TGrid;
    memTableLogID: TIntegerField;
    memTableLogUser: TStringField;
    cbxUsuarios: TComboBox;
    fdConnection: TFDConnection;
    queryAux: TFDQuery;
    FDLocalSQL1: TFDLocalSQL;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    dtFirtsDate: TDateEdit;
    dtLastDate: TDateEdit;
    cbxTypes: TComboBox;
    edtContainsInMessage: TEdit;
    ckIncludeUser: TCheckBox;
    ckIncludeType: TCheckBox;
    ckIncludeDate: TCheckBox;
    ckIncludeMessage: TCheckBox;
    btnSearch: TButton;
    btnUseMessage: TButton;
    queryMain: TFDQuery;
    queryMainID: TIntegerField;
    queryMainTipo: TStringField;
    queryMainUser: TStringField;
    queryMainHora: TTimeField;
    queryMainData: TDateField;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    queryMainMensagem: TMemoField;
    Button1: TButton;
    memLogsText: TMemo;
    Button2: TButton;
    Button3: TButton;
    procedure btnSelectFolderClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure gdLogsCellClick(const Column: TColumn; const Row: Integer);
    procedure ckIncludeUserChange(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure cbxUsuariosChange(Sender: TObject);
    procedure ckIncludeTypeChange(Sender: TObject);
    procedure cbxTypesChange(Sender: TObject);
    procedure ckIncludeDateChange(Sender: TObject);
    procedure dtLastDateChange(Sender: TObject);
    procedure dtFirtsDateChange(Sender: TObject);
    procedure ckIncludeMessageChange(Sender: TObject);
    procedure btnUseMessageClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private

    FFileLogsList: TStringList;
    QueryBuilder: TDictionary<string, String>;
     FSettings : TIniFile;
  const
    _Table: string = 'memTableLog';

    procedure IncludeUser;
    procedure IncludeType;
    procedure IncludeDate;
    procedure IncludeMessage;
    procedure SearchInLogs;
    procedure ShowItensQueryBuilder;
    procedure LoadItensLogs;
    procedure PopulateLogsItens;
    procedure LoadLogs(APath: string = '');
    function NormalizeField(AValue: string): string;
    procedure ListUsers;
    procedure ListDates;
    procedure ListLogTypes;
    procedure ListLogs;
  public

  end;

var
  frmLogger: TfrmLogger;

implementation

{$R *.fmx}

uses System.IOUtils, JaySettings.CORE;

procedure TfrmLogger.btnSearchClick(Sender: TObject);
begin
  // ShowItensQueryBuilder;
  SearchInLogs;
end;

procedure TfrmLogger.btnSelectFolderClick(Sender: TObject);
begin

  if SaveDialog1.Execute then
    edtPath.Text := ExtractFilePath(SaveDialog1.FileName);

    Settings.SetSettings('Path',ExtractFilePath(SaveDialog1.FileName));
end;

procedure TfrmLogger.btnUseMessageClick(Sender: TObject);
begin
  IncludeMessage;
end;

procedure TfrmLogger.Button1Click(Sender: TObject);
begin
  ListLogs;
end;

procedure TfrmLogger.Button2Click(Sender: TObject);
begin
  LoadItensLogs;
  LoadLogs;
  ListLogs;
end;

procedure TfrmLogger.Button3Click(Sender: TObject);
begin
  LoadLogs;
  ListLogs;
end;

procedure TfrmLogger.cbxTypesChange(Sender: TObject);
begin
  IncludeType;
end;

procedure TfrmLogger.cbxUsuariosChange(Sender: TObject);
begin
  IncludeUser;
end;

procedure TfrmLogger.ckIncludeDateChange(Sender: TObject);
begin
  IncludeDate;
end;

procedure TfrmLogger.ckIncludeMessageChange(Sender: TObject);
begin
  IncludeMessage;
end;

procedure TfrmLogger.ckIncludeTypeChange(Sender: TObject);
begin
  IncludeType;
end;

procedure TfrmLogger.ckIncludeUserChange(Sender: TObject);
begin
  IncludeUser;
end;

procedure TfrmLogger.dtFirtsDateChange(Sender: TObject);
begin
  IncludeDate;
end;

procedure TfrmLogger.dtLastDateChange(Sender: TObject);
begin
  IncludeDate;
end;

procedure TfrmLogger.FormCreate(Sender: TObject);
begin
  edtPath.Text := Settings(False).GetSettings('Path');

  FFileLogsList := TStringList.Create;
  QueryBuilder := TDictionary<string, String>.Create();
  memTableLog.Active := True;

  FDLocalSQL1.DataSets.Add(memTableLog);
  FDLocalSQL1.Active := True;
end;

procedure TfrmLogger.FormDestroy(Sender: TObject);
begin
  FFileLogsList.Free;
  QueryBuilder.Free;
end;

procedure TfrmLogger.FormShow(Sender: TObject);
begin
 if edtPath.Text = '' then
 Exit;


  LoadItensLogs;
  LoadLogs;

  ListUsers;
  ListDates;
  ListLogTypes;

  ListLogs;
end;

procedure TfrmLogger.gdLogsCellClick(const Column: TColumn; const Row: Integer);
begin
  memLogsText.Text := queryMainMensagem.AsString;
end;

procedure TfrmLogger.IncludeDate;
var
  _Date, Key: String;
begin
  Key := 'Date';

  _Date := ' Data BETWEEN ' + DateToStr(dtFirtsDate.Date) + ' AND ' +
    DateToStr(dtLastDate.Date);

  if ckIncludeDate.IsChecked then
  begin
    if QueryBuilder.ContainsKey(Key) then
      QueryBuilder[Key] := _Date
    else
      QueryBuilder.Add(Key, _Date);
  end
  else if QueryBuilder.ContainsKey(Key) then
    QueryBuilder.Remove(Key);
end;

procedure TfrmLogger.IncludeMessage;
var
  _Message, Key: String;
begin
  Key := 'Message';

  _Message := ' Mensagem LIKE ' +
    QuotedStr('%' + edtContainsInMessage.Text + '%');

  if ckIncludeMessage.IsChecked then
  begin
    if QueryBuilder.ContainsKey(Key) then
      QueryBuilder[Key] := _Message
    else
      QueryBuilder.Add(Key, _Message);
  end
  else if QueryBuilder.ContainsKey(Key) then
    QueryBuilder.Remove(Key);
end;

procedure TfrmLogger.IncludeType;
var
  _Type, Key: String;
begin
  Key := 'Type';

  _Type := ' Tipo = ' + QuotedStr(cbxTypes.Items[cbxTypes.ItemIndex]);

  if ckIncludeType.IsChecked then
  begin
    if QueryBuilder.ContainsKey(Key) then
      QueryBuilder[Key] := _Type
    else
      QueryBuilder.Add(Key, _Type);
  end
  else if QueryBuilder.ContainsKey(Key) then
    QueryBuilder.Remove(Key);
end;

procedure TfrmLogger.IncludeUser;
var
  _USER, Key: String;
begin
  Key := 'User';

  _USER := ' User = ' + QuotedStr(cbxUsuarios.Items[cbxUsuarios.ItemIndex]);

  if ckIncludeUser.IsChecked then
  begin
    if QueryBuilder.ContainsKey(Key) then
      QueryBuilder[Key] := _USER
    else
      QueryBuilder.Add(Key, _USER);
  end
  else if QueryBuilder.ContainsKey(Key) then
    QueryBuilder.Remove(Key);
end;

procedure TfrmLogger.ListBox1Click(Sender: TObject);

begin

//  memTableLog.

  LoadLogs(ListBox1.Items[ListBox1.ItemIndex]);
  ListLogs;
end;

procedure TfrmLogger.ListDates;
begin
  with queryAux do
  begin
    Close;
    SQL.Clear;
    SQL.Add(Format('SELECT DISTINCT Data FROM %s ORDER BY Data ASC', [_Table]));
    Open;

    First;
    dtFirtsDate.Date := FieldByName('Data').AsDateTime;

    Last;
    dtLastDate.Date := FieldByName('Data').AsDateTime;
  end;
end;

procedure TfrmLogger.ListLogs;
begin
  with queryMain do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT * FROM ' + _Table);
    Open();
  end;
end;

procedure TfrmLogger.ListLogTypes;
begin
  with queryAux do
  begin
    Close;
    SQL.Clear;
    SQL.Add(Format('SELECT DISTINCT Tipo FROM %s ORDER BY Tipo ASC', [_Table]));
    Open();

    First;
    cbxTypes.Clear;
    while not Eof do
    begin

      cbxTypes.Items.Add(FieldByName('Tipo').AsString);
      Next;
    end;

    cbxTypes.ItemIndex := 0;
  end;
end;

procedure TfrmLogger.ListUsers;
begin
  with queryAux do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT DISTINCT User FROM ' + _Table + ' ORDER BY User ASC');
    Open;

    First;
    cbxUsuarios.Items.Clear;

    while not Eof do
    begin
      cbxUsuarios.Items.Add(FieldByName('User').AsString);
      Next;
    end;

    cbxUsuarios.ItemIndex := 0;

  end;
end;

procedure TfrmLogger.LoadItensLogs;
var
  SR: TSearchRec;
begin
  FFileLogsList.Clear;
  if FindFirst(edtPath.Text + '*.*', faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Attr and faDirectory) = 0 then
        FFileLogsList.Add(SR.Name);
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;

  PopulateLogsItens;
end;

procedure TfrmLogger.LoadLogs(APath: string = '');
var
  FileList: TStringDynArray;
  FileName, Line: string;
  LogFile: TStreamReader;
  Parts: TArray<string>;
begin
  if not DirectoryExists(edtPath.Text) then
    Exit;

  memTableLog.EmptyDataSet;

  if APath.IsEmpty then
  begin
    FileList := TDirectory.GetFiles(edtPath.Text, '*.logr');
  end
  else
  begin
    SetLength(FileList,1);
    FileList[0] := edtPath.Text + APath;
  end;

  // Obt�m todos os arquivos de log
  for FileName in FileList do
  begin
    LogFile := TStreamReader.Create(FileName, TEncoding.Default);
    try
      while not LogFile.EndOfStream do
      begin
        Line := LogFile.ReadLine;
        Parts := Line.Split(['|'], TStringSplitOptions.ExcludeEmpty);

        if Length(Parts) = 5 then
        begin
          memTableLog.Append;
          memTableLog.FieldByName('Data').AsDateTime :=
            StrToDate(NormalizeField(Parts[0].Trim));
          memTableLog.FieldByName('Tipo').AsString :=
            NormalizeField(Parts[1].Trim);
          memTableLog.FieldByName('User').AsString := Parts[2].Trim;
          memTableLog.FieldByName('Mensagem').AsString := Parts[3].Trim;
          memTableLog.FieldByName('Hora').AsDateTime :=
            StrToTime(NormalizeField(Parts[4].Trim));
          memTableLog.Post;
        end;

      end;

    finally
      LogFile.Free;
    end;
  end;
end;

function TfrmLogger.NormalizeField(AValue: string): string;
begin
  Result := Copy(AValue, 2, Length(AValue) - 2);
end;

procedure TfrmLogger.PopulateLogsItens;
var
  Value: string;
begin
  ListBox1.Clear;

  for Value in FFileLogsList do
    ListBox1.Items.Add(Value);
end;

procedure TfrmLogger.SearchInLogs;
var
  _Query, _List: TStringList;
  Value: String;
  I: Integer;
begin
  if QueryBuilder.Count = 0 then
    Exit;

  _Query := TStringList.Create;
  _List := TStringList.Create;
  try
    _Query.Add('SELECT * FROM ' + _Table);
    for Value in QueryBuilder.Values do
    begin
      _List.Add(Value);
    end;

    for I := 0 to _List.Count - 1 do
    begin
      if I = 0 then
        _Query.Add('WHERE' + _List[I]);

      if I > 0 then
        _Query.Add('AND' + _List[I]);

    end;

    with queryMain do
    begin
      Close;
      SQL.Clear;
      SQL.AddStrings(_Query);
      Open();
    end;

  finally
    _Query.Free;
    _List.Free;
  end;

end;


procedure TfrmLogger.ShowItensQueryBuilder;
var
  _List: TStringList;
  _Value: String;
begin
  _List := TStringList.Create;
  try
    for _Value in QueryBuilder.Values do
      _List.Add(_Value);

    ShowMessage(_List.Text);
  finally
    _List.Free;
  end;
end;

end.
