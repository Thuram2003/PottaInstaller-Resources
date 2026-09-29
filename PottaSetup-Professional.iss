; ============================================================================
; Potta Finance - Professional Installer Script
; ============================================================================
; Version: 1.3.4.5
; Created with Inno Setup 6.7
; 
; This installer provides a modern, professional installation experience
; with custom branding, comprehensive license agreements, and user-friendly
; interface following industry best practices.
; ============================================================================

#define MyAppName "Potta Finance POS"
// MyAppVersion is injected by BUILD-INSTALLER.bat via: /dMyAppVersion=<version>
#ifndef MyAppVersion
#define MyAppVersion "0.0.0.0"
#endif
// SourceDir is injected by BUILD-INSTALLER.bat via: /dSourceDir=<path_to_build_temp>
#ifndef SourceDir
#define SourceDir ""
#endif
#define MyAppPublisher "Instanvi Sarl"
#define MyAppURL "https://www.instanvi.com/"
#define MyAppExeName "Potta Finance.exe"
#define MyApiExeName "PottaAPI.exe"
#define MyAppDescription "Professional Point of Sale & Finance Management System"

[Setup]
; ============================================================================
; Application Information
; ============================================================================
AppId={{8B17E339-57BF-4C25-A66B-8CB5707CC9A3}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
AppCopyright=Copyright (C) 2024-2026 {#MyAppPublisher}
AppComments={#MyAppDescription}
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppDescription}
VersionInfoCopyright=Copyright (C) 2024-2026 {#MyAppPublisher}
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}

; ============================================================================
; Installation Directories - User Local (No Admin Required)
; ============================================================================
DefaultDirName={localappdata}\Programs\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes

; ============================================================================
; License and Documentation
; ============================================================================
LicenseFile=LICENSE.txt
InfoBeforeFile=README.txt

; ============================================================================
; Output Configuration
; ============================================================================
OutputDir=installer-output
OutputBaseFilename=PottaSetup_v{#MyAppVersion}
SetupIconFile=..\Potta Finance\Resources\pottaLogo.ico
UninstallDisplayIcon={app}\{#MyAppExeName}

; ============================================================================
; Compression & Security
; ============================================================================
; Using 'max' instead of 'ultra64' to prevent out-of-memory errors
; when compressing large DLL files like ClosedXML.dll
Compression=lzma2/max
SolidCompression=yes
LZMAUseSeparateProcess=yes
LZMADictionarySize=262144
LZMANumFastBytes=64
InternalCompressLevel=max

; ============================================================================
; Visual Appearance - Modern Professional Theme
; ============================================================================
WizardStyle=modern
WizardImageFile=potta_wizard_large.png
WizardSmallImageFile=potta_wizard_small.png
DisableWelcomePage=no
WindowVisible=no
ShowLanguageDialog=auto

; ============================================================================
; Privileges & Architecture - No Admin Required
; ============================================================================
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible

; ============================================================================
; Uninstall Configuration
; ============================================================================
UninstallDisplayName={#MyAppName}
UninstallFilesDir={app}\uninstall
CreateUninstallRegKey=yes
Uninstallable=yes

; ============================================================================
; Additional Settings
; ============================================================================
AllowNoIcons=yes
AlwaysShowDirOnReadyPage=yes
AlwaysShowGroupOnReadyPage=yes
ShowTasksTreeLines=yes
DisableDirPage=no
DisableReadyPage=no
AppendDefaultDirName=yes
UsePreviousAppDir=yes
DirExistsWarning=auto

[Languages]
; ============================================================================
; Multi-Language Support
; ============================================================================
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
; ============================================================================
; Installation Tasks
; ============================================================================
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[Files]
; ============================================================================
; Application Files
; ============================================================================
; Main WPF Application
Source: "{#SourceDir}\Potta Finance\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\Potta Finance\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.pdb,*.xml"

; API Server
; Keep API binaries in a dedicated subfolder to prevent DLL collisions
; with the WPF desktop runtime files (e.g., WindowsBase.dll).
Source: "{#SourceDir}\PottaAPI\{#MyApiExeName}"; DestDir: "{app}\PottaAPI"; Flags: ignoreversion
Source: "{#SourceDir}\PottaAPI\*"; DestDir: "{app}\PottaAPI"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.pdb,*.xml"

[Icons]
; ============================================================================
; Shortcuts
; ============================================================================
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Comment: "{#MyAppDescription}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; Comment: "{#MyAppDescription}"

[Run]
; ============================================================================
; Post-Installation Actions
; ============================================================================
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall

; ============================================================================
; NOTE: [InstallDelete] section removed intentionally.
;
; The previous version deleted WindowsBase.dll during every install/upgrade,
; which caused a fatal crash:
;   System.IO.FileNotFoundException: Could not load file or assembly
;   'WindowsBase, Version=8.0.0.0'
;
; For self-contained .NET 8 WPF apps, WindowsBase.dll is a REQUIRED runtime
; assembly included in the publish output. It must NEVER be deleted.
;
; If you are upgrading from a very old framework-dependent version that shipped
; a stale WindowsBase v4.0 DLL, the [Files] section above uses `Flags: ignoreversion`
; which means the new file from the publish output always overwrites whatever is
; currently on disk making manual pre-deletion unnecessary.
; ============================================================================

[UninstallDelete]
; ============================================================================
; Cleanup on Uninstall
; ============================================================================
Type: filesandordirs; Name: "{app}\logs"
Type: filesandordirs; Name: "{app}\temp"
Type: files; Name: "{app}\*.log"
; Never delete user data on normal uninstall. User data is stored in:
; {localappdata}\Instanvi\Potta Finance POS\

[Code]
function L(const EnglishText, FrenchText: String): String;
begin
  if ActiveLanguage = 'french' then
    Result := FrenchText
  else
    Result := EnglishText;
end;

procedure InitializeWizard();
begin
  WizardForm.WelcomeLabel1.Font.Size := 12;
  WizardForm.WelcomeLabel1.Font.Style := [fsBold];
  WizardForm.WelcomeLabel2.Font.Size := 9;
  WizardForm.Color := $00F9FAFB;
end;

function InitializeSetup: Boolean;
var
  ResultCode: Integer;
  DotNetInstalled: Boolean;
begin
  Result := True;

  // Self-contained builds do not require .NET runtime on the machine.
  // Framework-dependent builds do. We keep this check non-blocking: if dotnet isn't found,
  // show info but allow installation to continue (the app itself will display errors if needed).
  DotNetInstalled := Exec('dotnet', '--list-runtimes', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

  if (not DotNetInstalled) or (ResultCode <> 0) then
  begin
    if MsgBox(
      L(
        'If this installer is framework-dependent, the .NET 8 Desktop Runtime is required. Would you like to download it now?',
        'Si cet installateur depend du framework, le Runtime .NET 8 Desktop est requis. Voulez-vous le telecharger maintenant ?'
      ),
      mbConfirmation, MB_YESNO) = IDYES then
    begin
      ShellExec('open', 'https://dotnet.microsoft.com/en-us/download/dotnet/8.0', '', '', SW_SHOW, ewNoWait, ResultCode);
    end;
    // Do not hard-block installation; allow self-contained installs to proceed.
    Result := True;
  end;
end;

function InitializeUninstall(): Boolean;
begin
  Result := MsgBox(
                   L(
                     'Are you sure you want to completely remove ' + '{#MyAppName}' + ' and all of its components?',
                     'Voulez-vous vraiment supprimer completement ' + '{#MyAppName}' + ' et tous ses composants ?'
                   ),
                   mbConfirmation, MB_YESNO) = IDYES;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ResultCode: Integer;
  DataDir: String;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    if MsgBox(
              L(
                'Would you like to remove all user data and settings?' + #13#10 + #13#10 +
                'This will delete all databases, configurations, and logs.' + #13#10 +
                'This action cannot be undone.',
                'Voulez-vous supprimer toutes les donnees utilisateur et les parametres ?' + #13#10 + #13#10 +
                'Cela supprimera les bases de donnees, configurations et journaux.' + #13#10 +
                'Cette action est irreversible.'
              ),
              mbConfirmation, MB_YESNO) = IDYES then
    begin
      DataDir := ExpandConstant('{localappdata}\Instanvi\Potta Finance POS');
      DelTree(DataDir, True, True, True);
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  DataDir: String;
  SeedPath: String;
  SeedValue: String;
begin
  if CurStep = ssPostInstall then
  begin
    DataDir := ExpandConstant('{localappdata}\Instanvi\Potta Finance POS');
    ForceDirectories(DataDir);
    SeedPath := DataDir + '\install-language.txt';

    if ActiveLanguage = 'french' then
      SeedValue := 'fr'
    else
      SeedValue := 'en';

    SaveStringToFile(SeedPath, SeedValue, False);
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  case CurPageID of
    wpWelcome:
      begin
        WizardForm.WelcomeLabel1.Caption := L('Welcome to ', 'Bienvenue dans ') + '{#MyAppName}' + ' Setup';
        WizardForm.WelcomeLabel2.Caption :=
          L(
            'This wizard will guide you through the installation of ' + '{#MyAppName}' + ', ' +
            'a professional Point of Sale and Finance Management System.' + #13#10 + #13#10 +
            'It is recommended that you close all other applications before continuing.' + #13#10 + #13#10 +
            'Click Next to continue, or Cancel to exit Setup.',
            'Cet assistant vous guidera dans l''installation de ' + '{#MyAppName}' + ', ' +
            'un systeme professionnel de point de vente et de gestion financiere.' + #13#10 + #13#10 +
            'Il est recommande de fermer les autres applications avant de continuer.' + #13#10 + #13#10 +
            'Cliquez sur Suivant pour continuer, ou sur Annuler pour quitter l''installation.'
          );
      end;
    wpFinished:
      begin
        WizardForm.FinishedLabel.Caption :=
          L(
            '{#MyAppName}' + ' has been successfully installed on your computer.' + #13#10 + #13#10 +
            'Click Finish to complete the installation.',
            '{#MyAppName}' + ' a ete installe avec succes sur votre ordinateur.' + #13#10 + #13#10 +
            'Cliquez sur Terminer pour finaliser l''installation.'
          );
      end;
  end;
end;
