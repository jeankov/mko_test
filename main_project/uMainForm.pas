unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,

  uDllParam, Vcl.ExtCtrls, uCommonType, Vcl.Mask, Vcl.ComCtrls, Vcl.Menus;

type
  TDllRec = record
  private
    FName: string;
    FHandle: HModule;
  end;
  TDllRecArray = array of TDllRec;

  TfrmMainForm = class(TForm)
    pLeft: TPanel;
    bLoadDll: TBitBtn;
    leDllName: TLabeledEdit;
    Panel1: TPanel;
    lbTaskTypes: TListBox;
    Panel2: TPanel;
    lbTasks: TListBox;
    pmTasks: TPopupMenu;
    miStopTask: TMenuItem;
    procedure bLoadDllClick(Sender: TObject);
    procedure lbTaskTypesDblClick(Sender: TObject);
    procedure lbTasksDblClick(Sender: TObject);
    procedure lbTasksDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure miStopTaskClick(Sender: TObject);
    procedure pmTasksPopup(Sender: TObject);
  private
    { Private declarations }
    FDlls: TDllRecArray;
    procedure TaskResultProc(var Msg: TMessage); message WM_TASK_RESULT;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TListObj = class
  private
    FDllHandle: HModule;
    FSysName: string;
    FCaption: string;
    FParams: TDLLParamArray;
  public
    constructor Create(aDllHandle: HModule; aSysName, aCaption: string; aParams: TDLLParamArray);
  end;

  TTaskState = (tsPerformed, tsBreak, tsError, tsDone);
  TTaskThreadObj = class
  private
    FCaption: string;
    FDllHandle: HModule;
    FThreadHandle: THandle;
    FDLLParamsResult: TDLLParamArray;
    FState: TTaskState;
    FErrorText: string;
  public
    constructor Create(aThreadHandle: THandle; aDllHandle: HModule; aCaption: string);
  end;


var
  frmMainForm: TfrmMainForm;

implementation

uses
   uBaseFunction, uParamsForm;

{$R *.dfm}

constructor TfrmMainForm.Create(AOwner: TComponent);
begin
  inherited;
  FDlls := nil;
end;

destructor TfrmMainForm.Destroy;
var
  I: integer;
  vListObj: TListObj;
  vTaskThreadObj: TTaskThreadObj;
begin
  for I := lbTaskTypes.Items.Count - 1 downto 0 do
  begin
    vListObj := TListObj(lbTaskTypes.Items.Objects[I]);
    lbTaskTypes.Items.Delete(I);
    FreeAndNil(vListObj);
  end;

  for I := lbTasks.Items.Count - 1 downto 0 do
  begin
    vTaskThreadObj := TTaskThreadObj(lbTasks.Items.Objects[I]);
    lbTasks.Items.Delete(I);
    if vTaskThreadObj.FState = tsPerformed then
      try
        TerminateThread(vTaskThreadObj.FThreadHandle, 0);
      except

      end;
    FreeAndNil(vTaskThreadObj);
  end;

  for I := High(FDlls) downto 0 do
    try
      FreeLibrary(FDlls[I].FHandle);
    Except
    end;
  FDlls := nil;
  inherited;
end;

procedure TfrmMainForm.TaskResultProc(var Msg: TMessage);
var
  vDLLParamsPtr: PDLLParamArray;
  vInd, I: integer;
  vThreadHandle: THandle;
begin
  vDLLParamsPtr := PDLLParamArray(Msg.LParam);
  vInd := vDLLParamsPtr^.IndexOf('thread_handle');
  if vInd > -1 then
  begin
    vThreadHandle := THandle(vDLLParamsPtr^[vInd].Value);

    for I := 0 to lbTasks.Items.Count - 1 do
      if TTaskThreadObj(lbTasks.Items.Objects[I]).FThreadHandle = vThreadHandle then
      begin
        vDLLParamsPtr^.CopyTo(TTaskThreadObj(lbTasks.Items.Objects[I]).FDLLParamsResult);
        vInd := TTaskThreadObj(lbTasks.Items.Objects[I]).FDLLParamsResult.IndexOf('error_text');
        if vInd > -1 then
        begin
          TTaskThreadObj(lbTasks.Items.Objects[I]).FState := tsError;
          TTaskThreadObj(lbTasks.Items.Objects[I]).FErrorText :=
            TTaskThreadObj(lbTasks.Items.Objects[I]).FDLLParamsResult[vInd].Value;
        end
        else
          TTaskThreadObj(lbTasks.Items.Objects[I]).FState := tsDone;

        lbTasks.Repaint;
        Break;
      end;
  end;
end;

procedure TfrmMainForm.bLoadDllClick(Sender: TObject);
var
  vTaskTypes: TTaskTypeArray;
  vTaskType: TTaskType;
  I: integer;
  vListObj: TListObj;
  vDllHandle: HModule;
  vFound: Boolean;
begin
  if not String(leDllName.Text).IsEmpty then
  begin
    vDllHandle := LoadDll(leDllName.Text);
    vFound := False;
    for I := 0 to High(FDlls) do
      if FDlls[I].FHandle = vDllHandle then
      begin
        vFound := True;
        Break;
      end;
    if not vFound then
    begin
      SetLength(FDlls, LENGTH(FDlls) + 1);
      FDlls[High(FDlls)].FName := leDllName.Text;
      FDlls[High(FDlls)].FHandle := vDllHandle;

      vTaskTypes := GetTaskTypes(vDllHandle);
      for vTaskType in vTaskTypes do
      begin
        vListObj := TListObj.Create(vDllHandle, vTaskType.SysName, vTaskType.Caption, vTaskType.Params);
        lbTaskTypes.Items.AddObject(
          ChangeFileExt(leDllName.Text, '.dll') + ': ' + vTaskType.Caption, vListObj);
      end;
    end;
  end;
end;

procedure TfrmMainForm.lbTasksDblClick(Sender: TObject);
var
  vDllHandle: THandle;
  vObj: TTaskThreadObj;
  vInd: Integer;
begin
  if lbTasks.ItemIndex > -1 then
  begin
    vObj := TTaskThreadObj(lbTasks.Items.Objects[lbTasks.ItemIndex]);
    if not vObj.FErrorText.IsEmpty then
      ShowMessage('При выполнении задачи произошла ошибка: ' + vObj.FErrorText)
    else
    begin
      vInd := vObj.FDLLParamsResult.IndexOf('dll_handle');
      if vInd > -1 then
      begin
        vDllHandle := THandle(vObj.FDLLParamsResult[vInd].Value);
        RunTask(vDllHandle, Addr(vObj.FDLLParamsResult));
      end;
    end;
  end;
end;

procedure TfrmMainForm.lbTasksDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
var
  vObj: TTaskThreadObj;
begin
  lbTasks.Canvas.Brush.Color := clWhite;
  lbTasks.Canvas.Font.Color := clBlack;
  vObj := TTaskThreadObj(lbTasks.Items.Objects[Index]);
  case vObj.FState of
    tsDone: lbTasks.Canvas.Brush.Color := clGreen;
    tsBreak: lbTasks.Canvas.Brush.Color := clBlue;
    tsError: lbTasks.Canvas.Brush.Color := clRed;
  end;
  lbTasks.Canvas.FillRect(Rect);
  lbTasks.Canvas.TextOut(Rect.Left + 5, Rect.Top, lbTasks.Items[Index]);
end;

procedure TfrmMainForm.lbTaskTypesDblClick(Sender: TObject);
var
  vDLLParams: TDLLParamArray;
  vListObj: TListObj;
  vTaskHandle: THandle;
  vObj: TTaskThreadObj;
  vParamText: string;
begin
  if lbTaskTypes.ItemIndex > -1 then
  begin
    vListObj := TListObj(lbTaskTypes.Items.Objects[lbTaskTypes.ItemIndex]);

    vListObj.FParams.CopyTo(vDLLParams);
    if SetTaskParam(vDLLParams, vParamText) then
    begin
      vDLLParams.AddDLLParam('task_type', vListObj.FSysName);
      vDLLParams.AddDLLParam('form_handle', Self.Handle);
      vDLLParams.AddDLLParam('dll_handle', vListObj.FDllHandle);

      vTaskHandle := RunTask(vListObj.FDllHandle, Addr(vDLLParams));
      if vTaskHandle > 0 then
      begin
        vObj := TTaskThreadObj.Create(vTaskHandle, vListObj.FDllHandle, vListObj.FCaption);
        lbTasks.Items.AddObject((lbTasks.Items.Count + 1).ToString + ': ' +
          vListObj.FCaption + vParamText, vObj);
      end;
    end;
  end;
end;

procedure TfrmMainForm.miStopTaskClick(Sender: TObject);
var
  vObj: TTaskThreadObj;
begin
  if lbTasks.ItemIndex > -1 then
  begin
    vObj := TTaskThreadObj(lbTasks.Items.Objects[lbTasks.ItemIndex]);
    if vObj.FState = tsPerformed then
    begin
      vObj.FState := tsBreak;
      TerminateThread(vObj.FThreadHandle, 0);
    end;
  end;
end;

procedure TfrmMainForm.pmTasksPopup(Sender: TObject);
var
  vObj: TTaskThreadObj;
begin
  if lbTasks.ItemIndex > -1 then
  begin
    vObj := TTaskThreadObj(lbTasks.Items.Objects[lbTasks.ItemIndex]);
    miStopTask.Visible := vObj.FState = tsPerformed;
  end;
end;

{ TListObj }

constructor TListObj.Create;
begin
  inherited Create;
  FDllHandle := aDllHandle;
  FSysName := aSysName;
  FCaption := aCaption;
  aParams.CopyTo(FParams);
end;

{ TTaskThreadObj }

constructor TTaskThreadObj.Create(aThreadHandle: THandle; aDllHandle: HModule; aCaption: string);
begin
  FThreadHandle := aThreadHandle;
  FDllHandle := aDllHandle;
  FCaption := aCaption;
  FDLLParamsResult := nil;
  FState := tsPerformed;
  FErrorText := EmptyStr;
end;

end.
