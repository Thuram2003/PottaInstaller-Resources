; ============================================================================
; Potta Finance - Professional Installer Script
; ============================================================================
; Created with Inno Setup 6.7
; 
; This installer provides a modern, professional installation experience
; with custom branding, comprehensive license agreements, and user-friendly
; component selection for Potta POS, Potta KDS, and the core API engine.
; ============================================================================

#define MyAppName "Potta Finance POS"
#define MyKdsName "Potta KDS"
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
#define MyKdsExeName "PottaKDS.exe"
#define MyAppDescription "Professional Point of Sale & Finance Management System"
#define MyKdsDescription "Kitchen Display System for Kitchen Screens"

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

[CustomMessages]
; ============================================================================
; Custom Multilingual UI Strings
; ============================================================================
english.TypeStandard=Standard POS Station (Recommended)
english.TypeStandardDesc=Installs Potta POS and its background API server for standard store checkout.
english.TypeRestaurant=Restaurant & Cafe Setup (POS + KDS)
english.TypeRestaurantDesc=Installs Potta POS (with API server) and Potta KDS (Kitchen Display System).
english.TypeKdsOnly=Kitchen Display Station Only
english.TypeKdsOnlyDesc=Installs Potta KDS for a dedicated kitchen screen connecting over LAN to the POS.
english.TypeCustom=Custom Installation
english.TypeCustomDesc=Select the exact applications you want to install.

english.CompPos=Potta POS - Point of Sale & Finance Management (Includes API Backend)
english.CompKds=Potta KDS - Kitchen Display System (For kitchen order screens)

english.LaunchPos=Launch Potta Finance POS
english.LaunchKds=Launch Potta KDS (Kitchen Display System)
english.PosDesktopIcon=Create Potta POS desktop shortcut
english.KdsDesktopIcon=Create Potta KDS desktop shortcut

french.TypeStandard=Station POS Standard (Recommandé)
french.TypeStandardDesc=Installe Potta POS et son serveur API pour l'encaissement en magasin.
french.TypeRestaurant=Configuration Restaurant & Café (POS + KDS)
french.TypeRestaurantDesc=Installe Potta POS (avec serveur API) et Potta KDS (Affichage Cuisine).
french.TypeKdsOnly=Station Affichage Cuisine Uniquement
french.TypeKdsOnlyDesc=Installe Potta KDS pour un écran cuisine dédié connecté en réseau au POS.
french.TypeCustom=Installation Personnalisée
french.TypeCustomDesc=Sélectionnez les applications spécifiques à installer.

french.CompPos=Potta POS - Point de Vente & Gestion Financière (Inclut le serveur API)
french.CompKds=Potta KDS - Système d'Affichage Cuisine (Pour écrans de commande)

french.LaunchPos=Lancer Potta Finance POS
french.LaunchKds=Lancer Potta KDS (Affichage Cuisine)
french.PosDesktopIcon=Créer un raccourci de bureau pour Potta POS
french.KdsDesktopIcon=Créer un raccourci de bureau pour Potta KDS

[Types]
; ============================================================================
; Installation Types
; ============================================================================
Name: "standard"; Description: "{cm:TypeStandard}"
Name: "restaurant"; Description: "{cm:TypeRestaurant}"
Name: "kds_only"; Description: "{cm:TypeKdsOnly}"
Name: "custom"; Description: "{cm:TypeCustom}"; Flags: iscustom

[Components]
; ============================================================================
; Selectable Application Components
; ============================================================================
Name: "pos"; Description: "{cm:CompPos}"; Types: standard restaurant custom; Flags: checkablealone
Name: "kds"; Description: "{cm:CompKds}"; Types: restaurant kds_only custom; Flags: checkablealone

[Tasks]
; ============================================================================
; Desktop Shortcuts
; ============================================================================
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; ============================================================================
; Application Files
; ============================================================================

; Main WPF POS Application (Installed if 'pos' component is selected)
Source: "{#SourceDir}\Potta Finance\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion; Components: pos
Source: "{#SourceDir}\Potta Finance\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.pdb,*.xml"; Components: pos

; Core API Server (Backend engine for Potta POS - installed with POS)
; Keep API binaries in a dedicated subfolder to prevent DLL collisions
; with the WPF desktop runtime files (e.g., WindowsBase.dll).
Source: "{#SourceDir}\PottaAPI\{#MyApiExeName}"; DestDir: "{app}\PottaAPI"; Flags: ignoreversion; Components: pos
Source: "{#SourceDir}\PottaAPI\*"; DestDir: "{app}\PottaAPI"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.pdb,*.xml"; Components: pos

; Potta KDS Application (Installed if 'kds' component is selected)
; Kept in a dedicated subfolder to prevent WPF DLL collision with main app
Source: "{#SourceDir}\PottaKDS\{#MyKdsExeName}"; DestDir: "{app}\PottaKDS"; Flags: ignoreversion; Components: kds
Source: "{#SourceDir}\PottaKDS\*"; DestDir: "{app}\PottaKDS"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.pdb,*.xml"; Components: kds

[Icons]
; ============================================================================
; Shortcuts
; ============================================================================

; Potta POS Shortcuts
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Comment: "{#MyAppDescription}"; Components: pos
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; Comment: "{#MyAppDescription}"; Components: pos

; Potta KDS Shortcuts
Name: "{autoprograms}\{#MyKdsName}"; Filename: "{app}\PottaKDS\{#MyKdsExeName}"; Comment: "{#MyKdsDescription}"; Components: kds
Name: "{autodesktop}\{#MyKdsName}"; Filename: "{app}\PottaKDS\{#MyKdsExeName}"; Tasks: desktopicon; Comment: "{#MyKdsDescription}"; Components: kds

[Run]
; ============================================================================
; Post-Installation Actions (Only prompts for components that were installed)
; ============================================================================
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchPos}"; Flags: nowait postinstall skipifsilent; Components: pos
Filename: "{app}\PottaKDS\{#MyKdsExeName}"; Description: "{cm:LaunchKds}"; Flags: nowait postinstall skipifsilent unchecked; Components: kds

[UninstallDelete]
; ============================================================================
; Cleanup on Uninstall
; ============================================================================
Type: filesandordirs; Name: "{app}\logs"
Type: filesandordirs; Name: "{app}\temp"
Type: filesandordirs; Name: "{app}\PottaAPI\logs"
Type: filesandordirs; Name: "{app}\PottaKDS\logs"
Type: files; Name: "{app}\*.log"

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
            'You can choose to install the POS Terminal, the Kitchen Display System (KDS), or both.' + #13#10 + #13#10 +
            'Click Next to continue, or Cancel to exit Setup.',
            'Cet assistant vous guidera dans l''installation de ' + '{#MyAppName}' + ', ' +
            'un systeme professionnel de point de vente et de gestion financiere.' + #13#10 + #13#10 +
            'Vous pouvez choisir d''installer le Terminal POS, le Systeme d''Affichage Cuisine (KDS), ou les deux.' + #13#10 + #13#10 +
            'Cliquez sur Suivant pour continuer, ou sur Annuler pour quitter l''installation.'
          );
      end;
    wpSelectComponents:
      begin
        WizardForm.PageNameLabel.Caption := L('Select Components', 'Selectionner les composants');
        WizardForm.PageDescriptionLabel.Caption :=
          L(
            'Choose the applications you want to install for your store configuration.',
            'Choisissez les applications a installer selon la configuration de votre magasin.'
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
