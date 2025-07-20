unit uParamsForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uDllParam, Vcl.Grids, Vcl.ValEdit,
  Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TformParams = class(TForm)
    vleParams: TValueListEditor;
    pButtons: TPanel;
    bContinue: TButton;
    bCancel: TButton;
  private
    { Private declarations }
    class function ReplaceSysMacros(const aValue: String): String;
  public
    { Public declarations }
  end;

  function SetTaskParam(var aDLLParams: TDLLParamArray; out aParamText: String): boolean;

implementation

{$R *.dfm}

uses
  uCommonType, System.UITypes, System.StrUtils;

function SetTaskParam(var aDLLParams: TDLLParamArray; out aParamText: String): boolean;
var
  vForm: TformParams;
  vInd: Integer;
begin
  Result := Length(aDLLParams) = 0;
  if Result then
    Exit;
  aParamText := EmptyStr;
  vForm := TformParams.Create(Application);
  try
    for vInd := 0 to High(aDLLParams) do
      vForm.vleParams.Strings.AddObject(
        aDLLParams[vInd].Caption + vForm.vleParams.Strings.NameValueSeparator +
        TformParams.ReplaceSysMacros(aDLLParams[vInd].DefValue),
        TObject(vInd));

    if vForm.ShowModal = mrContinue then
    begin
      for vInd := 0 to High(aDLLParams) do
      begin
        aDLLParams[vInd].Value := vForm.vleParams.Values[aDLLParams[vInd].Caption];
        aParamText := IfThen(vInd = 0, '', aParamText + '; ') +
          aDLLParams[vInd].Caption + '=' + aDLLParams[vInd].Value;
      end;
      aParamText := '[' + aParamText + ']';
      Result := True;
    end;
  finally
    vForm.Free;
  end;
end;

{ TformParams }

class function TformParams.ReplaceSysMacros(const aValue: String): String;
begin
  Result := StringReplace(aValue, C_PARAM_MACRO_PATH,
    ExtractFilePath(Application.ExeName), []);
end;

end.
