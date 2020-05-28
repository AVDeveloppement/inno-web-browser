Unit MainUnit;

Interface

Uses
  Classes, Windows, Variants, OleCtrls, SHDocVw;

Const
  EVENT_BEFORE_NAVIGATE   = 1;
  EVENT_FRAME_COMPLETE    = 2;
  EVENT_DOCUMENT_COMPLETE = 3;

Type
  TWebBrowserEventProc = Procedure(EventCode: Integer; URL: PWideChar) Of Object;

  TInnoWebBrowser = Class
  Private
    FWebBrowser: TWebBrowser;
    FEventCallback: TWebBrowserEventProc;
    Procedure OnBeforeNavigate2(ASender: TObject; Const pDisp: IDispatch;
      Const URL: OleVariant; Const Flags: OleVariant; Const TargetFrameName: OleVariant;
      Const PostData: OleVariant; Const Headers: OleVariant; Var Cancel: WordBool);
    Procedure OnDocumentComplete(ASender: TObject; Const pDisp: IDispatch; Const URL: OleVariant);
  Public
    Constructor Create(ParentWnd: HWND; Left, Top, Width, Height: Integer;
      CallbackProc: TWebBrowserEventProc);
    Destructor Destroy; Override;
    Procedure Show(Visible: Boolean);
    Procedure Navigate(URL: PWideChar);
    Function GetOleObject: Variant;
  End;

Procedure WebBrowserCreate(ParentWnd: HWND; Left, Top, Width, Height: Integer;
  CallbackProc: TWebBrowserEventProc); Stdcall;
Procedure WebBrowserDestroy; Stdcall;
Procedure WebBrowserShow(Visible: Boolean); Stdcall;
Procedure WebBrowserNavigate(URL: PWideChar); Stdcall;
Function WebBrowserGetOleObject: Variant; Stdcall;

Implementation

Var
  InnoWebBrowser: TInnoWebBrowser;

Procedure WebBrowserCreate(ParentWnd: HWND; Left, Top, Width, Height: Integer;
  CallbackProc: TWebBrowserEventProc);
Begin
  WebBrowserDestroy;
  InnoWebBrowser := TInnoWebBrowser.Create(ParentWnd, Left, Top, Width, Height, CallbackProc);
End;

Procedure WebBrowserDestroy;
Begin
  InnoWebBrowser.Free;
  InnoWebBrowser := Nil;
End;

Procedure WebBrowserShow(Visible: Boolean);
Begin
  If Assigned(InnoWebBrowser) Then
    InnoWebBrowser.Show(Visible);
End;

Procedure WebBrowserNavigate(URL: PWideChar);
Begin
  If Assigned(InnoWebBrowser) Then
    InnoWebBrowser.Navigate(URL);
End;

Function WebBrowserGetOleObject: Variant;
Begin
  Result   := NULL;
  If Assigned(InnoWebBrowser) Then
    Result := InnoWebBrowser.GetOleObject;
End;

{ TInnoWebBrowser }

Constructor TInnoWebBrowser.Create(ParentWnd: HWND; Left, Top, Width, Height: Integer;
  CallbackProc: TWebBrowserEventProc);
Begin
  FWebBrowser                    := TWebBrowser.Create(Nil);
  FWebBrowser.ParentWindow       := ParentWnd;
  FWebBrowser.Left               := Left;
  FWebBrowser.Top                := Top;
  FWebBrowser.Width              := Width;
  FWebBrowser.Height             := Height;
  FWebBrowser.OnBeforeNavigate2  := OnBeforeNavigate2;
  FWebBrowser.OnDocumentComplete := OnDocumentComplete;

  FEventCallback                 := CallbackProc;
End;

Destructor TInnoWebBrowser.Destroy;
Begin
  FWebBrowser.Free;
  Inherited;
End;

Procedure TInnoWebBrowser.Navigate(URL: PWideChar);
Begin
  FWebBrowser.Navigate(URL);
End;

Function TInnoWebBrowser.GetOleObject: Variant;
Begin
  Result := FWebBrowser.OleObject;
End;

Procedure TInnoWebBrowser.OnBeforeNavigate2(ASender: TObject; Const pDisp: IDispatch;
  Const URL: OleVariant; Const Flags: OleVariant; Const TargetFrameName: OleVariant;
  Const PostData: OleVariant; Const Headers: OleVariant; Var Cancel: WordBool);
Var
  URLString: WideString;
Begin
  If Assigned(FEventCallback) Then
  Begin
    URLString := URL;
    FEventCallback(EVENT_BEFORE_NAVIGATE, PWideChar(URLString));
  End;
End;

Procedure TInnoWebBrowser.OnDocumentComplete(ASender: TObject; Const pDisp: IDispatch;
  Const URL: OleVariant);
Var
  URLString: WideString;
Begin
  If Assigned(FEventCallback) Then
  Begin
    URLString := URL;
    If pDisp <> TWebBrowser(ASender).ControlInterface Then
      FEventCallback(EVENT_FRAME_COMPLETE, PWideChar(URLString))
    Else
      FEventCallback(EVENT_DOCUMENT_COMPLETE, PWideChar(URLString));
  End;
End;

Procedure TInnoWebBrowser.Show(Visible: Boolean);
Begin
  If Visible Then
    FWebBrowser.Show
  Else
    FWebBrowser.Hide;
End;

End.
