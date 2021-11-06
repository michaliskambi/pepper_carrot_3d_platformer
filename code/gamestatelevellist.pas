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

{ List of Levels, where player can choose which level to start playing next. }

unit GameStateLevelList;

interface

uses Classes,
  CastleWindow, CastleUIState, CastleComponentSerialize, CastleUIControls, 
  CastleControls, CastleKeysMouse, CastleOnScreenMenu, CastleLog, 
  GameStateLevel1, GameStateRivers, GameStateLevelCave, GameStateMain,
  GameStateLevelKomona, GameStateLevelClouds, GameStateLevelSwim,
  GameStateLevelSnowball, GameStateLevelSnowball2, GameStateLevelSnowball3,
  GameStateLevelSnowman, GamestateLevelCastle, GameStateLevelDragonBoss;

type
  { LevelList state, where player can choose a level to play next. }
  TStateLevelList = class(TUIState)
  //private

  public
    constructor Create(AOwner: TComponent); override;
    procedure Start; override;
    procedure Update(const SecondsPassed: Single; var HandleInput: Boolean); override;
    function Press(const Event: TInputPressRelease): Boolean; override;
    procedure StartGrassLevel(Sender: TObject);
    procedure StartRiversLevel(Sender: TObject);
    procedure StartCaveLevel(Sender: TObject);
    procedure StartKomonaLevel(Sender: TObject);
    procedure StartCloudLevel(Sender: TObject);
    procedure StartSwimLevel(Sender: TObject);
    procedure StartSnowballLevel(Sender: TObject);
    procedure StartSnowballLevel2(Sender: TObject);
    procedure StartSnowballLevel3(Sender: TObject);
    procedure StartSnowmanLevel(Sender: TObject);
    procedure StartCastleLevel(Sender: TObject);
    procedure StartDragonBossLevel(Sender: TObject);
    procedure GoBack(Sender: TObject);
  end;

var
  StateLevelList: TStateLevelList;

implementation

uses SysUtils;

{ TStateLevelList ----------------------------------------------------------------- }

constructor TStateLevelList.Create(AOwner: TComponent);
begin
  inherited;
  WriteLnLog('Im createed!!');
  DesignUrl := 'castle-data:/gamestatelevellist.castle-user-interface';

end;

procedure TStateLevelList.StartGrassLevel(Sender: TObject);
begin
  WriteLnLog('hello!');
  StateLevel1 := TStateLevel1.Create(Application);
  TUIState.Current := StateLevel1;
end;

procedure TStateLevelList.StartRiversLevel(Sender: TObject);
begin
  WriteLnLog('river level!');
  StateRivers := TStateRivers.Create(Application);
  TUIState.Current := StateRivers;
end;

procedure TStateLevelList.StartCaveLevel(Sender: TObject);
begin
  WriteLnLog('river level!');
  StateLevelCave := TStateLevelCave.Create(Application);
  TUIState.Current := StateLevelCave;
end;

procedure TStateLevelList.StartKomonaLevel(Sender: TObject);
begin
  WriteLnLog('river level!');
  StateLevelKomona := TStateLevelKomona.Create(Application);
  TUIState.Current := StateLevelKomona;
end;

procedure TStateLevelList.StartCloudLevel(Sender: TObject);
begin
  WriteLnLog('river level!');
  StateLevelClouds := TStateLevelClouds.Create(Application);
  TUIState.Current := StateLevelClouds;
end;

procedure TStateLevelList.StartSwimLevel(Sender: TObject);
begin
  WriteLnLog('river level!');
  StateLevelSwim := TStateLevelSwim.Create(Application);
  TUIState.Current := StateLevelSwim;
end;

procedure TStateLevelList.StartSnowballLevel(Sender: TObject);
begin
  WriteLnLog('snowball1 level!');
  StateLevelSnowball := TStateLevelSnowball.Create(Application);
  TUIState.Current := StateLevelSnowball;
end;

procedure TStateLevelList.StartSnowballLevel2(Sender: TObject);
begin
  WriteLnLog('snowball2 level!');
  StateLevelSnowball2 := TStateLevelSnowball2.Create(Application);
  TUIState.Current := StateLevelSnowball2;
end;

procedure TStateLevelList.StartSnowballLevel3(Sender: TObject);
begin
  WriteLnLog('snowball3 level!');
  StateLevelSnowball3 := TStateLevelSnowball3.Create(Application);
  TUIState.Current := StateLevelSnowball3;
end;

procedure TStateLevelList.StartSnowmanLevel(Sender: TObject);
begin
  WriteLnLog('snowman level!');
  StateLevelSnowman := TStateLevelSnowman.Create(Application);
  TUIState.Current := StateLevelSnowman;
end;

procedure TStateLevelList.StartCastleLevel(Sender: TObject);
begin
  WriteLnLog('Castle level!');
  StateLevelCastle := TStateLevelCastle.Create(Application);
  TUIState.Current := StateLevelCastle;
end;

procedure TStateLevelList.StartDragonBossLevel(Sender: TObject);
begin
  WriteLnLog('Dragon Boss level!');
  StateLevelDragonBoss := TStateLevelDragonBoss.Create(Application);
  TUIState.Current := StateLevelDragonBoss;
end;

procedure TStateLevelList.GoBack(Sender: TObject);
begin
  WriteLnLog('river level!');
  StateMain := TStateMain.Create(Application);
  TUIState.Current := StateMain;
end;

procedure TStateLevelList.Start;
var 
  Button: TCastleButton;
begin
  inherited;
  WriteLnLog('Im started!!');

  { Find components, by name, that we need to access from code }
  Button := DesignedComponent('Level1') as TCastleButton;
  Button.OnClick := @StartGrassLevel;

  Button := DesignedComponent('LevelRivers') as TCastleButton;
  Button.OnClick := @StartRiversLevel;

  Button := DesignedComponent('LevelCave') as TCastleButton;
  Button.OnClick := @StartCaveLevel;

  Button := DesignedComponent('LevelClouds') as TCastleButton;
  Button.OnClick := @StartCloudLevel;

  Button := DesignedComponent('LevelKomona') as TCastleButton;
  Button.OnClick := @StartKomonaLevel;

  Button := DesignedComponent('LevelSwim') as TCastleButton;
  Button.OnClick := @StartSwimLevel;

  Button := DesignedComponent('LevelSnowball') as TCastleButton;
  Button.OnClick := @StartSnowballLevel;

  Button := DesignedComponent('LevelSnowball2') as TCastleButton;
  Button.OnClick := @StartSnowballLevel2;

  Button := DesignedComponent('LevelSnowball3') as TCastleButton;
  Button.OnClick := @StartSnowballLevel3;

  Button := DesignedComponent('LevelSnowman') as TCastleButton;
  Button.OnClick := @StartSnowmanLevel;

  Button := DesignedComponent('LevelCastle') as TCastleButton;
  Button.OnClick := @StartCastleLevel;

  Button := DesignedComponent('LevelDragonBoss') as TCastleButton;
  Button.OnClick := @StartDragonBossLevel;

  Button := DesignedComponent('Back') as TCastleButton;
  Button.OnClick := @GoBack;

end;

procedure TStateLevelList.Update(const SecondsPassed: Single; var HandleInput: Boolean);
begin
  inherited;
  { This virtual method is executed every frame.}
end;

function TStateLevelList.Press(const Event: TInputPressRelease): Boolean;
begin
  Result := inherited;
  if Result then Exit; // allow the ancestor to handle keys

  { This virtual method is executed when user presses
    a key, a mouse button, or touches a touch-screen.

    Note that each UI control has also events like OnPress and OnClick.
    These events can be used to handle the "press", if it should do something
    specific when used in that UI control.
    The TStateLevelList.Press method should be used to handle keys
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

  if Event.IsKey(keyEscape) then 
  begin
    StateMain := TStateMain.Create(Application);
    TUIState.Current := StateMain;
  end;

end;

end.
