unit uListForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uDllParam, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TformList = class(TForm)
    lbFiles: TListBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure ShowListForm(const aCaption, aListParamName: string; aDLLParamsPtr: PDLLParamArray);

implementation

{$R *.dfm}

uses
  Types;

procedure ShowListForm;
var
  vForm: TformList;
  vFoundFiles: TStringDynArray;
  vInd, I: Integer;
begin
  vInd := aDLLParamsPtr^.IndexOf(aListParamName);
  if vInd > -1 then
    vFoundFiles := TStringDynArray(aDLLParamsPtr^[vInd].Value)
  else
    vFoundFiles := nil;

  vForm := TformList.Create(Application);
  try
    vForm.Caption := StringReplace(aCaption, '{cnt}', Length(vFoundFiles).ToString, []);
    for I := 0 to High(vFoundFiles) do
      vForm.lbFiles.Items.Add(vFoundFiles[I]);
    vForm.ShowModal;
  finally
    vForm.Free;
  end;
end;

end.
