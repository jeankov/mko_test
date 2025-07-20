object formParams: TformParams
  Left = 0
  Top = 0
  Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1079#1072#1076#1072#1095#1080
  ClientHeight = 338
  ClientWidth = 467
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 15
  object vleParams: TValueListEditor
    Left = 0
    Top = 0
    Width = 467
    Height = 297
    Align = alClient
    TabOrder = 0
    TitleCaptions.Strings = (
      #1055#1072#1088#1072#1084#1077#1090#1088
      #1047#1085#1072#1095#1077#1085#1080#1077
      '')
    ColWidths = (
      150
      311)
  end
  object pButtons: TPanel
    Left = 0
    Top = 297
    Width = 467
    Height = 41
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      467
      41)
    object bContinue: TButton
      Left = 288
      Top = 6
      Width = 91
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1086#1076#1086#1083#1078#1080#1090#1100
      ModalResult = 11
      TabOrder = 0
    end
    object bCancel: TButton
      Left = 385
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 1
    end
  end
end
