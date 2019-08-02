object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'KindleGen Launcher'
  ClientHeight = 441
  ClientWidth = 731
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 731
    Height = 51
    Align = alTop
    TabOrder = 0
    object rgCompression: TRadioGroup
      Left = 8
      Top = 0
      Width = 345
      Height = 49
      Caption = 'Compression Mode'
      Columns = 3
      ItemIndex = 2
      Items.Strings = (
        'STORE Only (big)'
        'Standard (FAST)'
        'Huffdic (Small)')
      TabOrder = 0
    end
    object chbVerbose: TCheckBox
      Left = 368
      Top = 3
      Width = 177
      Height = 17
      Caption = 'Verbose Info'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object chb1252: TCheckBox
      Left = 368
      Top = 26
      Width = 177
      Height = 17
      Caption = 'force build Windows-1252 book'
      TabOrder = 2
    end
    object chbJpg2Gif: TCheckBox
      Left = 551
      Top = 3
      Width = 177
      Height = 17
      Caption = 'Convert JPG to GIF'
      TabOrder = 3
    end
    object pbBooks: TProgressBar
      Left = 170
      Top = 2
      Width = 177
      Height = 12
      DoubleBuffered = True
      ParentDoubleBuffered = False
      Smooth = True
      Step = 1
      TabOrder = 5
    end
    object chbNoSource: TCheckBox
      Left = 551
      Top = 26
      Width = 177
      Height = 17
      Caption = 'do NOT append source*'
      TabOrder = 4
    end
  end
  object mmoOutput: TMemo
    Tag = 5
    Left = 0
    Top = 51
    Width = 731
    Height = 390
    Align = alClient
    Ctl3D = True
    DoubleBuffered = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Consolas'
    Font.Style = []
    Lines.Strings = (
      'just drag and drop, and enjoy.'
      '  - drop on the program icon, or'
      '  - drop anywhere in this window'
      ''
      'compression mode'
      '  -c0: no compression (Fast! BIG)'
      
        '  -c1: standard DOC compression (default mode, medium size, medi' +
        'um time)'
      '  -c2: Kindle huffdic compression (Small, SLOW)'
      ''
      '* trick'
      
        '  -dont_append_source: a HIDDEN parameter, creates even smaller ' +
        'mobi files, not following the standard. '
      ''
      ''
      ''
      '')
    ParentCtl3D = False
    ParentDoubleBuffered = False
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
