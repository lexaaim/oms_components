unit uOMSADOQuery;

interface

uses Classes, Data.Win.ADODB, Data.DB;

type
  TOMSADOQuery = class(TADOQuery)
  private
    FBookmark: TBookmark;

    procedure DeleteErrorHandler(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure EditErrorHandler(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure PostErrorHandler(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
  protected
  public
    constructor Create(AOwner: TComponent); override;

    function isEdited : Boolean;
    procedure SafePost( const isReopen: Boolean = True );
    procedure SafeCancel;
    function SafeOpen : Boolean;
    procedure CloseWithBookmark;
    procedure OpenWithBookmark;    
    procedure SafeResync;
  end;

implementation

uses uOMSDialogs, uLogging, Forms, SysUtils;

constructor TOMSADOQuery.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  OnEditError := EditErrorHandler;
  OnDeleteError := DeleteErrorHandler;
  OnPostError := PostErrorHandler;  
end;

function TOMSADOQuery.isEdited : Boolean;
begin
  Result := Active AND (not Eof) AND (State in [ dsInsert, dsEdit ]);
end;

procedure TOMSADOQuery.SafePost( const isReopen: Boolean );
begin
  if isEdited then Post;
end;

procedure TOMSADOQuery.SafeCancel;
begin
  if isEdited then Cancel;
end;

procedure TOMSADOQuery.CloseWithBookmark;
begin
  DisableControls;
  
  FBookmark := Nil;
  if Active AND (not Eof) 
    then FBookmark := GetBookmark;
    
  if Active then Close;
end;

function TOMSADOQuery.SafeOpen : Boolean;
begin
  try
    if (not Active) then Open;

    while ( State = dsOpening ) do 
      Application.ProcessMessages;

    Result := True;      
  except
    on E: Exception do begin
      Result := False;
      
      ShowError('������ �������� �������. ' + E.ToString );
      logQueryError( Name, SQL.Text, 'OpenError', E.ToString );
    end;
  end;
end;

procedure TOMSADOQuery.OpenWithBookmark;
begin
  try
    if SafeOpen AND ( FBookmark <> Nil ) AND BookmarkValid( FBookmark )
      then GotoBookmark( FBookmark );
  finally
    EnableControls;
  end;
end;

procedure TOMSADOQuery.SafeResync;
begin
  SafePost;
  CloseWithBookmark;
  OpenWithBookmark;   
end;

procedure TOMSADOQuery.DeleteErrorHandler(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
var
  strError : String;
begin
  Action := daAbort;

  strError := '������ �������� ������. ';
  if Pos( 'denied',  E.ToString ) > 0
    then strError := strError + '��������� ������� ��� ������'
    else strError := strError + E.ToString;

  ShowError( strError );
  logQueryError( Name, SQL.Text, 'DeleteError', E.ToString );
end;

procedure TOMSADOQuery.EditErrorHandler(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
var
  strError : String;
begin
  Action := daAbort;

  strError := '������ �������������� ������. ';
  strError := strError + E.ToString;

  logQueryError( Name, SQL.Text, 'EditError', E.ToString );
  ShowError( strError );
end;

procedure TOMSADOQuery.PostErrorHandler(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
var
  strError : String;
begin
  Action := daAbort;

  strError := '������ ������� �������. ';
  if ( Pos( 'allow nulls',  E.ToString ) > 0 )
    then strError := strError + '��������� �� ��� ������������ ����.'
  else if ( Pos( 'unique',  E.ToString ) > 0 )
    then strError := strError + '������ � ������ ������� ��� ����������.'
  else if ( Pos( 'denied',  E.ToString ) > 0 )
    then strError := strError + '��������� ���� ������ ���������.'
    else strError := strError + E.ToString;

  logQueryError( Name, SQL.Text, 'PostError', E.ToString );
  ShowError(strError);
end;

end.