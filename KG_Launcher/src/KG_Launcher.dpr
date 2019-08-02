program KG_Launcher;



uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Aqua Light Slate');
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
