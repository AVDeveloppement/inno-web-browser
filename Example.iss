[Setup]
AppName=Web Browser Project
AppVersion=1.0
DefaultDirName={pf}\Web Browser Project

[Files]
Source:"WebBrowser.dll"; Flags: dontcopy

[Code]
const
  EVENT_BEFORE_NAVIGATE = 1;
  EVENT_FRAME_COMPLETE = 2;
  EVENT_DOCUMENT_COMPLETE = 3;

var
  CustomPage: TWizardPage;

type
  TWebBrowserEventProc = procedure(EventCode: Integer; URL: WideString);

procedure WebBrowserCreate(ParentWnd: HWND; Left, Top, Width, Height: Integer; 
  CallbackProc: TWebBrowserEventProc);
  external 'WebBrowserCreate@files:webbrowser.dll stdcall';
procedure WebBrowserDestroy;
  external 'WebBrowserDestroy@files:webbrowser.dll stdcall';
procedure WebBrowserShow(Visible: Boolean);
  external 'WebBrowserShow@files:webbrowser.dll stdcall';
procedure WebBrowserNavigate(URL: WideString);
  external 'WebBrowserNavigate@files:webbrowser.dll stdcall';
function WebBrowserGetOleObject: Variant;
  external 'WebBrowserGetOleObject@files:webbrowser.dll stdcall';

procedure OnWebBrowserEvent(EventCode: Integer; URL: WideString); 
begin
  if EventCode = EVENT_DOCUMENT_COMPLETE then
    MsgBox('Navigation completed. ' + URL, mbInformation, MB_OK);
end;

procedure InitializeWizard;
begin
  CustomPage := CreateCustomPage(wpWelcome, 'Web Browser Page', 
    'This page contains web browser');
  WebBrowserCreate(WizardForm.InnerPage.Handle, 0, WizardForm.Bevel1.Top, 
    WizardForm.InnerPage.ClientWidth, WizardForm.InnerPage.ClientHeight - WizardForm.Bevel1.Top,
    @OnWebBrowserEvent);
  WebBrowserNavigate('https://www.google.com');
end;

procedure DeinitializeSetup;
begin
  WebBrowserDestroy;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  WebBrowserShow(CurPageID = CustomPage.ID);
end;


