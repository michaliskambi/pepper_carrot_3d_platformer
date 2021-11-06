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

{ Win State! A nice screen that says "You Win!" and then they can go back to the
    main menu. }
unit GameStateWin;

interface

uses Classes,
  CastleWindow, CastleUIState, CastleComponentSerialize, CastleUIControls, 
  CastleControls, CastleKeysMouse, CastleOnScreenMenu, CastleLog, GameStateMain;

type
  TStateWin = class(TUIState)

  public
    constructor Create(AOwner: TComponent); override;
    procedure Start; override;
    procedure Update(const SecondsPassed: Single; var HandleInput: Boolean); override;
    function Press(const Event: TInputPressRelease): Boolean; override;
    procedure GoToMainMenu(Sender: TObject);
  end;

var
  StateWin: TStateWin;

implementation

uses SysUtils;

{ TStateWin ----------------------------------------------------------------- }

constructor TStateWin.Create(AOwner: TComponent);
begin
  inherited;
  DesignUrl := 'castle-data:/win_state/gamestatewin.castle-user-interface';

end;

procedure TStateWin.GoToMainMenu(Sender: TObject);
begin
  WriteLnLog('Back to main menu!');
  StateMain := TStateMain.Create(Application);
  TUIState.Current := StateMain;
end;

procedure TStateWin.Start;
var 
  Button: TCastleButton;
begin
  inherited;

  Button := DesignedComponent('Button1') as TCastleButton;
  Button.OnClick := @GoToMainMenu;

end;

procedure TStateWin.Update(const SecondsPassed: Single; var HandleInput: Boolean);
begin
  inherited;
end;

function TStateWin.Press(const Event: TInputPressRelease): Boolean;
begin
  Result := inherited;
  if Result then Exit; // allow the ancestor to handle keys

  { Also let them push the Escape key to go back to the main menu: }
  if Event.IsKey(keyEscape) then
  begin
    StateMain := TStateMain.Create(Application);
    TUIState.Current := StateMain;
    Exit(true);
  end;

end;

end.
