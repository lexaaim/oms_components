unit uOMScxDBExtLookupComboBox;

interface

uses Classes, cxDBExtLookupComboBox, Windows;

type
  TOMScxDBExtLookupComboBox = class(TcxDBExtLookupComboBox)
  private
    procedure PropertiesChangeHandler(Sender: TObject);
    procedure DropDownDisableHandler(Sender: TObject);
    procedure MouseWheelHandler(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
          MousePos: TPoint; var Handled: Boolean);

  protected
    procedure Loaded; override;
    procedure SetEnabled(Value : Boolean); override;

  public
    constructor Create(AOwner: TComponent); override;

  end;

implementation

uses uOMSStyle, Graphics, cxDropDownEdit;

constructor TOMScxDBExtLookupComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Style.Color := clOMSEditableHighlight;
  Properties.OnPropertiesChanged := PropertiesChangeHandler;
end;

procedure TOMScxDBExtLookupComboBox.Loaded;
begin
  inherited;

  Properties.DropDownListStyle := lsEditFixedList;

  if Properties.DropDownRows < 20
    then Properties.DropDownRows := 20;
  if Properties.DropDownWidth < 600
    then Properties.DropDownWidth := 600;

  OnMouseWheel := MouseWheelHandler;
end;

procedure TOMScxDBExtLookupComboBox.MouseWheelHandler(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

procedure TOMScxDBExtLookupComboBox.DropDownDisableHandler(Sender: TObject);
begin
  (Sender as TcxCustomDropDownEdit).DroppedDown := False;
end;

procedure TOMScxDBExtLookupComboBox.SetEnabled(Value: Boolean);
begin
  inherited SetEnabled(True);

  Properties.ReadOnly := not Value;   // call PropertiesChanged
end;

procedure TOMScxDBExtLookupComboBox.PropertiesChangeHandler(Sender: TObject);
begin
  if Properties.ReadOnly
    then begin
      Style.Color := clWindow;
      Properties.OnPopup := DropDownDisableHandler;
    end
    else begin
      Style.Color := clOMSEditableHighlight;
      Properties.OnPopup := Nil;
    end;
end;

end.