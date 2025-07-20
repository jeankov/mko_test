unit uFindFiles;

interface

uses
  System.Classes, System.SyncObjs, Types, uTaskBaseThread, uCommonType, uDllParam;

type
  TFindFilesThread = class(TTaskThread)
  protected
    procedure TaskExecute; override;
  private
    FPatch: String;
    FMasks: TStringDynArray;
    FFoundFiles: TStringDynArray;
    procedure FindFiles;
  end;

  function FindFiles(const aPatch: String; const aMasks: string;
    aDllHandle, aFormHandle: THandle): NativeUInt;

implementation

uses
  System.SysUtils, RegularExpressions;

function FindFiles(const aPatch: String; const aMasks: string;
  aDllHandle, aFormHandle: THandle): NativeUInt;
var
  vThread: TFindFilesThread;
begin
  vThread := TFindFilesThread.Create(aDllHandle, aFormHandle);
  vThread.FPatch := IncludeTrailingPathDelimiter(aPatch);
  vThread.FMasks := aMasks.Split([';']);
  vThread.FFoundFiles := nil;
  Result := vThread.Handle;
  vThread.Start;
end;

{ TFindFilesThread }

procedure TFindFilesThread.TaskExecute;
begin
  inherited;
  FindFiles;
  FResultDLLParams.AddDLLParam('found_files', FFoundFiles);
  FResultDLLParams.AddDLLParam('task_type', 'show_found_files');
end;

procedure TFindFilesThread.FindFiles;
var
  vSearchRec: TSearchRec;
  vResCode: Integer;
  I: integer;
begin
  for I := 0 to High(FMasks) do
  begin
    if Terminated then
      Exit;
    vResCode := FindFirst(FPatch + FMasks[I], faAnyFile, vSearchRec);
    try
      while vResCode = 0 do
      begin
        if Terminated then
          Exit;
        if (vSearchRec.Name <> '.') and (vSearchRec.Name <> '..') and
           ((vSearchRec.Attr and faDirectory) <> faDirectory) then
          FFoundFiles := FFoundFiles + [FPatch + vSearchRec.Name];
        vResCode := System.SysUtils.FindNext(vSearchRec);
      end;
    finally
      System.SysUtils.FindClose(vSearchRec);
    end;
  end;
end;

end.
