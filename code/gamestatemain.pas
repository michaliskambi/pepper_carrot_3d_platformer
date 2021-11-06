{
    Copyright 2021 ultidonki

    This file is part of "Pepper and the Potion of Jumping".

    "Pepper and the Potion of Jumping" is free software;
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
}

{ Main state: Just the Main Menu. }
unit GameStateMain;

interface

uses Classes, CastleWindow,
  CastleUIState, CastleComponentSerialize, CastleUIControls, CastleControls,
  CastleKeysMouse, CastleOnScreenMenu, CastleLog;

type
  TStateMain = class(TUIState)
  private
    { Components designed using CGE editor, loaded from gamestatemain.castle-user-interface. }
    LabelFps: TCastleLabel;
    SomethingEmpty: TCastleUserInterface;
    DebugLabel: TCastleLabel;
    OnScreenMenu: TCastleOnScreenMenu;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Start; override;
    procedure Update(const SecondsPassed: Single; var HandleInput: Boolean); override;
    function Press(const Event: TInputPressRelease): Boolean; override;
    procedure GotoLevelList(Sender: TObject);
    procedure StartGame(Sender: TObject);
    procedure Quit(Sender: TObject);
  end;

var
  StateMain: TStateMain;

implementation

uses SysUtils, GameStateLevelList;

{ TStateMain ----------------------------------------------------------------- }

constructor TStateMain.Create(AOwner: TComponent);
begin
  inherited;
  DesignUrl := 'castle-data:/gamestatemain.castle-user-interface';
end;

procedure TStateMain.GotoLevelList(Sender: TObject);
begin
  WriteLnLog('hello!');
  TUIState.Current := StateLevelList;
end;

procedure TStateMain.StartGame(Sender: TObject);
begin
  WriteLnLog('hello!');
  StateLevelList.StartGrassLevel(Sender);
end;

procedure TStateMain.Quit(Sender: TObject);
begin
  WriteLnLog('hello!');
  Application.Quit;
end;

procedure TStateMain.Start;
var 
  NotifyEvent: TNotifyEvent;
begin
  inherited;

  { Find components, by name, that we need to access from code }
  LabelFps := DesignedComponent('LabelFps') as TCastleLabel;
  SomethingEmpty := DesignedComponent('SomethingEmpty') as TCastleUserInterface;
  DebugLabel := DesignedComponent('DebugLabel') as TCastleLabel;

  DebugLabel.Exists := false;

  OnScreenMenu := TCastleOnScreenMenu.Create(Self);
  SomethingEmpty.InsertFront(OnScreenMenu);

  NotifyEvent := @StartGame;
  OnScreenMenu.Add('Start Game', NotifyEvent);

  NotifyEvent := @GotoLevelList;
  OnScreenMenu.Add('Select Level', NotifyEvent);
{ OnScreenMenu.Add('3', NotifyEvent);
  OnScreenMenu.Add('Woweee button 4', NotifyEvent); }

  NotifyEvent := @Quit;
  OnScreenMenu.Add('Quit', NotifyEvent);

end;

procedure TStateMain.Update(const SecondsPassed: Single; var HandleInput: Boolean);
begin
  inherited;
  { This virtual method is executed every frame.}
  LabelFps.Caption := 'FPS: ' + Container.Fps.ToString;
end;

function TStateMain.Press(const Event: TInputPressRelease): Boolean;
begin
  Result := inherited;
  if Result then Exit; // allow the ancestor to handle keys

  { This virtual method is executed when user presses
    a key, a mouse button, or touches a touch-screen.

    Note that each UI control has also events like OnPress and OnClick.
    These events can be used to handle the "press", if it should do something
    specific when used in that UI control.
    The TStateMain.Press method should be used to handle keys
    not handled in children controls.
  }

  // Use this to handle keys:
  {
  if Event.IsKey(keyXxx) then
  begin
    // DoSomething;
    Exit(true); // key was handled
  end;
  }

  if Event.IsKey(keyEscape) then Application.Terminate;

end;

end.
