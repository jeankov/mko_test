object frmMainForm: TfrmMainForm
  Left = 0
  Top = 0
  Caption = #1058#1077#1089#1090#1086#1074#1086#1077
  ClientHeight = 450
  ClientWidth = 949
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  TextHeight = 15
  object pLeft: TPanel
    Left = 0
    Top = 0
    Width = 153
    Height = 450
    Align = alLeft
    TabOrder = 0
    object bLoadDll: TBitBtn
      Left = 8
      Top = 53
      Width = 137
      Height = 25
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' dll'
      TabOrder = 0
      OnClick = bLoadDllClick
    end
    object leDllName: TLabeledEdit
      Left = 8
      Top = 24
      Width = 137
      Height = 23
      EditLabel.Width = 116
      EditLabel.Height = 15
      EditLabel.Caption = #1048#1084#1103' '#1079#1072#1075#1088#1091#1078#1072#1077#1084#1086#1081' dll'
      TabOrder = 1
      Text = 'mko_first'
    end
  end
  object Panel1: TPanel
    Left = 153
    Top = 0
    Width = 796
    Height = 450
    Align = alClient
    TabOrder = 1
    object lbTaskTypes: TListBox
      Left = 1
      Top = 1
      Width = 794
      Height = 136
      Align = alTop
      ItemHeight = 15
      TabOrder = 0
      OnDblClick = lbTaskTypesDblClick
    end
    object Panel2: TPanel
      Left = 1
      Top = 137
      Width = 794
      Height = 312
      Align = alClient
      TabOrder = 1
      object lbTasks: TListBox
        Left = 1
        Top = 1
        Width = 792
        Height = 310
        Style = lbOwnerDrawFixed
        Align = alClient
        ItemHeight = 15
        PopupMenu = pmTasks
        TabOrder = 0
        OnDblClick = lbTasksDblClick
        OnDrawItem = lbTasksDrawItem
      end
    end
  end
  object pmTasks: TPopupMenu
    OnPopup = pmTasksPopup
    Left = 582
    Top = 205
    object miStopTask: TMenuItem
      Caption = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100
      OnClick = miStopTaskClick
    end
  end
end
