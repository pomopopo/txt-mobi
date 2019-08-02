unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.ToolWin;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    mmoOutput: TMemo;
    rgCompression: TRadioGroup;
    chbVerbose: TCheckBox;
    chb1252: TCheckBox;
    chbJpg2Gif: TCheckBox;
    pbBooks: TProgressBar;
    chbNoSource: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    procedure DropFiles(var Msg: TMessage); message WM_DROPFILES;
    function GetBuildParam(): string;
    procedure DoConvert(const AFileName: string);
//    procedure OutText(Sender: TObject; st: string);
    procedure CaptureConsoleOutput(const ACommand, AParameters: String; AMemo: TMemo);
    procedure ReadConfig();
    procedure WriteConfig();
  end;

var
  Form1: TForm1;
  IsDebut: Boolean = True;

implementation

{$R *.dfm}
uses
  WinAPi.ShellApi, IniFiles;

procedure TForm1.CaptureConsoleOutput(const ACommand, AParameters: String;
  AMemo: TMemo);
const
  CReadBuffer = 4095;
var
  saSecurity: TSecurityAttributes;
  hRead: THandle;
  hWrite: THandle;
  suiStartup: TStartupInfo;
  piProcess: TProcessInformation;
  pBuffer: array [0 .. CReadBuffer] of AnsiChar;
  dRead: DWord;
  dRunning: DWord;
  CreateOk: Boolean;
begin
  saSecurity.nLength := SizeOf(TSecurityAttributes);
  saSecurity.bInheritHandle := True;
  saSecurity.lpSecurityDescriptor := nil;

  if CreatePipe(hRead, hWrite, @saSecurity, 0) then
  begin
    FillChar(suiStartup, SizeOf(TStartupInfo), #0);
    suiStartup.cb := SizeOf(TStartupInfo);
    suiStartup.hStdInput := hRead;
    suiStartup.hStdOutput := hWrite;
    suiStartup.hStdError := hWrite;
    suiStartup.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    suiStartup.wShowWindow := SW_HIDE;

    CreateOK := CreateProcess(nil, PChar(ACommand + ' ' + AParameters), @saSecurity,
      @saSecurity, True, NORMAL_PRIORITY_CLASS, nil, nil, suiStartup, piProcess);

    // must CLOSE right after createprocess!!!
    // otherwise ReadFile will never stop.
    CloseHandle(hWrite);

    if CreateOK then
    begin
      repeat
        dRunning := WaitForSingleObject(piProcess.hProcess, 100);
        Application.ProcessMessages();
        repeat
          dRead := 0;
          ReadFile(hRead, pBuffer[0], CReadBuffer, dRead, nil);
          pBuffer[dRead] := #0;

//          OemToAnsi(pBuffer, pBuffer);        // may got wired result on utf8
//          AMemo.Lines.Add(String(pBuffer));

          AMemo.Lines.Add(Utf8ToAnsi(pBuffer)); // UTF8 convertion supports CJK
        until (dRead < CReadBuffer);
      until (dRunning <> WAIT_TIMEOUT);
      CloseHandle(piProcess.hProcess);
      CloseHandle(piProcess.hThread);
    end;

    CloseHandle(hRead);
//    CloseHandle(hWrite);
  end;
end;

procedure TForm1.DoConvert(const AFileName: string);
var
  fn: string;
begin
  fn := '"'+ AFileName + '"' + GetBuildParam();

  mmoOutput.Lines.Add('');
  mmoOutput.Lines.Add('JOB: '+ fn);

  CaptureConsoleOutput('kindlegen\kindlegen.exe', fn, mmoOutput);

  mmoOutput.Lines.Add('Fin');
  mmoOutput.Lines.Add('');
  mmoOutput.Lines.Add('');
end;

procedure TForm1.DropFiles(var Msg: TMessage);
var
  buffer: array[0..MAX_PATH-1] of Char;
  count: integer; // count of files
  I: Integer;
begin
  inherited;
  buffer[0] := #0;
  count := DragQueryFile(Msg.WParam, $FFFFFFFF, buffer, sizeof(buffer)); //第一个文件

  pbBooks.Min := 0;
  pbBooks.Max := count;
  pbBooks.Position := 0;

  for I := 0 to count - 1 do
  begin
    if DragQueryFile(Msg.WParam, i, buffer, sizeof(buffer)) = 0 then exit;

    DoConvert(buffer);
    pbBooks.Position := i+1;
  end;

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WriteConfig();
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  I: Integer;
begin

  pbBooks.Min := 0;
  pbBooks.Max := ParamCount();

  // accept DropFiles event
  DragAcceptFiles(handle, true);

  ReadConfig();

  if not FileExists('kindlegen\kindlegen.exe') then
  begin
    mmoOutput.Lines.Add('Error: kindlegen\kindlegen.exe not found.');
    mmoOutput.Lines.Add('');
  end;

end;

procedure TForm1.FormPaint(Sender: TObject);
var
  i: integer;
begin
  //处理命令行参数。
  //不知道放哪里才不影响显示界面
  if IsDebut then
  begin
    IsDebut := False; // avoid re-enter ... maybe needed.

    for I := 1 to ParamCount() do
    begin
      DoConvert(ParamStr(i));
      pbBooks.Position := i;
    end;
  end;
end;

function TForm1.GetBuildParam: string;
begin

  case rgCompression.ItemIndex of
    0: Result := ' -c0';
    1: Result := ' -c1';
    2: Result := ' -c2';
  end;

  if chbVerbose.Checked  then Result := Result + ' -verbose';
  if chb1252.Checked     then Result := Result + ' -western';
  if chbJpg2Gif.Checked  then Result := Result + ' -gif';
  if chbNoSource.Checked then Result := Result + ' -dont_append_source';

//  Result := Result + ' -locale en';   // 咋显示都有道理的吧？

end;

procedure TForm1.ReadConfig;
var
  fn: string;
  ini: TIniFile;
begin
// get saved status
  fn := ChangeFileExt(Application.ExeName,'.cfg');
  ini := TIniFile.Create(fn);

  rgCompression.ItemIndex := ini.ReadInteger('cfg','compression',2);
  chbVerbose.Checked      := ini.ReadBool('cfg','verbose',True);
  chb1252.Checked         := ini.ReadBool('cfg','western1252',False);
  chbJpg2Gif.Checked      := ini.ReadBool('cfg', 'Jpg2Gif', False);
  chbNoSource.Checked     := ini.ReadBool('cfg', 'NoSource', False);

  ini.Destroy;
end;

procedure TForm1.WriteConfig;
var
  fn: string;
  ini: TIniFile;
begin
// save status
  fn := ChangeFileExt(Application.ExeName,'.cfg');
  ini := TIniFile.Create(fn);

  ini.WriteInteger('cfg', 'compression', rgCompression.ItemIndex);
  ini.WriteBool('cfg', 'verbose', chbVerbose.Checked);
  ini.WriteBool('cfg', 'western1252', chb1252.Checked);
  ini.WriteBool('cfg', 'Jpg2Gif', chbJpg2Gif.Checked);
  ini.WriteBool('cfg', 'NoSource', chbNoSource.Checked);

  ini.Destroy;
end;

end.
