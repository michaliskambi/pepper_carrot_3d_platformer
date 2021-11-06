{
    Copyright 2020-2020 Michalis Kamburelis.
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

{ Level Rivers logic: }
unit GameStateRivers;

interface

uses Classes, CastleWindow,
  CastleUIState, CastleComponentSerialize, CastleUIControls, CastleControls,
  CastleKeysMouse, CastleViewport, CastleScene, CastleVectors, CastleCameras,
  CastleTransform, CastleInputs, CastleThirdPersonNavigation, CastleDebugTransform,
  CastleCreatures, ThirdPersonJumper, Carrot, GameStateMain, GameStateLevelClouds;

type
  { Main "playing game" state, where most of the game logic takes place. }
  TStateRivers = class(TUIState)
  private
    { Components designed using CGE editor, loaded from state-main.castle-user-interface. }
    LabelFps: TCastleLabel;
    LabelCarrot: TCastleLabel;
    LabelGems: TCastleLabel;
    MainViewport: TCastleViewport;
    ThirdPersonNavigation: TThirdPersonJumper;
    SceneAvatar: TCastleScene;
    Carrot: TCastleScene;
    GemHolder: TCastleTransform;
    CheckboxCameraFollows: TCastleCheckbox;
    CheckboxAimAvatar: TCastleCheckbox;
    CheckboxDebugAvatarColliders: TCastleCheckbox;
    CheckboxImmediatelyFixBlockedCamera: TCastleCheckbox;

    LevelNext: TStateLevelClouds;

    DebugAvatar: TDebugTransform;

    procedure ChangeCheckboxCameraFollows(Sender: TObject);
    procedure ChangeCheckboxAimAvatar(Sender: TObject);
    procedure ChangeCheckboxDebugAvatarColliders(Sender: TObject);
    procedure ChangeCheckboxImmediatelyFixBlockedCamera(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Start; override;
    procedure Stop; override;
    procedure Update(const SecondsPassed: Single; var HandleInput: Boolean); override;
    function Press(const Event: TInputPressRelease): Boolean; override;
  end;

var
  StateRivers: TStateRivers;

implementation

uses SysUtils, Math, StrUtils,
  CastleSoundEngine, CastleLog, CastleStringUtils, CastleFilesUtils, CastleUtils;

{ TStateRivers ----------------------------------------------------------------- }

constructor TStateRivers.Create(AOwner: TComponent);
begin
  inherited;
  DesignUrl := 'castle-data:/rivers_and_bridges/gamestaterivers.castle-user-interface';
end;

procedure TStateRivers.Start;
var
  SoldierScene: TCastleScene;
  I: Integer;
  Behavior: TCarrot;
begin
  inherited;

  { Find components, by name, that we need to access from code }
  LabelFps := DesignedComponent('LabelFps') as TCastleLabel;
  LabelCarrot := DesignedComponent('LabelCarrot') as TCastleLabel;
  LabelGems := DesignedComponent('LabelGems') as TCastleLabel;
  MainViewport := DesignedComponent('MainViewport') as TCastleViewport;
  { ThirdPersonNavigation := DesignedComponent('ThirdPersonNavigation') as
  TCastleThirdPersonNavigation; }
  ThirdPersonNavigation := TThirdPersonJumper.Create(MainViewport);
  SceneAvatar := DesignedComponent('SceneAvatar') as TCastleScene;
  CheckboxCameraFollows := DesignedComponent('CheckboxCameraFollows') as TCastleCheckbox;
  CheckboxAimAvatar := DesignedComponent('CheckboxAimAvatar') as TCastleCheckbox;
  CheckboxDebugAvatarColliders := DesignedComponent('CheckboxDebugAvatarColliders') as TCastleCheckbox;
  CheckboxImmediatelyFixBlockedCamera := DesignedComponent('CheckboxImmediatelyFixBlockedCamera') as TCastleCheckbox;
  Carrot := DesignedComponent('carrot') as TCastleScene;
  GemHolder := DesignedComponent('GemHolder') as TCastleTransform;

  Behavior := TCarrot.Create(nil);
  Behavior.Player := SceneAvatar;
  Carrot.AddBehavior(Behavior);

  CheckboxCameraFollows.OnChange := @ChangeCheckboxCameraFollows;
  CheckboxAimAvatar.OnChange := @ChangeCheckboxAimAvatar;
  CheckboxDebugAvatarColliders.OnChange := @ChangeCheckboxDebugAvatarColliders;
  CheckboxImmediatelyFixBlockedCamera.OnChange := @ChangeCheckboxImmediatelyFixBlockedCamera;

  { Make SceneAvatar collide using a sphere.
    Sphere is more useful than default bounding box for avatars and creatures
    that move in the world, look ahead, can climb stairs etc. }
  SceneAvatar.MiddleHeight := 0.9;
  SceneAvatar.CollisionSphereRadius := 0.5;

  { Gravity means that object tries to maintain a constant height
    (SceneAvatar.PreferredHeight) above the ground.
    GrowSpeed means that object raises properly (makes walking up the stairs work).
    FallSpeed means that object falls properly (makes walking down the stairs,
    falling down pit etc. work). }
  SceneAvatar.Gravity := true;
  SceneAvatar.GrowSpeed := 10.0;
  { SceneAvatar.FallSpeed := 1.0; }
  SceneAvatar.FallSpeed := 0;

  { Visualize SceneAvatar bounding box, sphere, middle point, direction etc. }
  DebugAvatar := TDebugTransform.Create(FreeAtStop);
  DebugAvatar.Parent := SceneAvatar;

  { Configure ThirdPersonNavigation, some things that cannot be yet adusted using CGE editor.
    In particular assign some keys that are not assigned by default. }
  ThirdPersonNavigation.Input_LeftStrafe.Assign(keyE);
  ThirdPersonNavigation.Input_RightStrafe.Assign(keyQ);
  ThirdPersonNavigation.Input_CameraCloser.Assign(keyNone, keyNone, '', false, buttonLeft, mwUp);
  ThirdPersonNavigation.Input_CameraFurther.Assign(keyNone, keyNone, '', false, buttonLeft, mwDown);
  ThirdPersonNavigation.CameraFollows := true;
  ThirdPersonNavigation.Input_Jump.Assign(keySpace);
  ThirdPersonNavigation.MouseLook := true; // by default use mouse look
  ThirdPersonNavigation.AimAvatar := aaNone;
  ThirdPersonNavigation.Avatar := SceneAvatar;
  ThirdPersonNavigation.MoveSpeed := 4.0;

  ThirdPersonNavigation.Init;
  Behavior.Jumper := ThirdPersonNavigation;

  MainViewport.Navigation := ThirdPersonNavigation;
end;

procedure TStateRivers.Stop;
begin
  inherited;
end;

procedure TStateRivers.Update(const SecondsPassed: Single; var HandleInput: Boolean);
  var
    A: TCastleTransform;
    Gem: TCastleSphere;
    I: Integer;
    J: Integer;
    GemsToGo: Integer;

  // Test: use this to make AimAvatar only when *holding* right mouse button.
  (*
  procedure UpdateAimAvatar;
  begin
    if buttonRight in Container.MousePressed then
      ThirdPersonNavigation.AimAvatar := aaHorizontal
    else
      ThirdPersonNavigation.AimAvatar := aaNone;

     In this case CheckboxAimAvatar only serves to visualize whether
      the right mouse button is pressed now. 
     CheckboxAimAvatar.Checked := ThirdPersonNavigation.AimAvatar <> aaNone;
  end;
  *)

begin
  inherited;
  { This virtual method is executed every frame.}
  LabelFps.Caption := 'FPS: ' + Container.Fps.ToString;
  LabelCarrot.Caption := 'Carrot pos: ' + Carrot.Translation.ToString;
  // UpdateAimAvatar;

  { Let them go to next level after getting 6 gems }
  J := 0;
  GemsToGo := 6;
  for I := 0 to GemHolder.Count - 1 do
  begin
    { Gem := GetItem[I] as TCastleSphere; }
    Gem := GemHolder.Items[I] as TCastleSphere;
    if Gem.BoundingBox.Collides(SceneAvatar.BoundingBox)
    then Gem.Exists := false;
    if (Gem.Exists = true) then 
      J := J + 1
    else
      GemsToGo := GemsToGo - 1;

  end;
  if GemsToGo <= 0 then
  begin
    LevelNext := TStateLevelClouds.Create(Application);
    TUIState.Current := LevelNext;
    Exit;

  end;
  LabelGems.Caption := 'Num Gems Remaining: ' + GemsToGo.ToString;

  if SceneAvatar.Translation.Y < -30 then
  begin
    StateRivers := TStateRivers.Create(Application);
    TUIState.Current := StateRivers;
    Exit;
  end;

end;

function TStateRivers.Press(const Event: TInputPressRelease): Boolean;

  function AvatarRayCast: TCastleTransform;
  begin
    { SceneAvatar.RayCast tests a ray collision,
      ignoring the collisions with SceneAvatar itself (so we don't detect our own
      geometry as colliding). }
    Result := SceneAvatar.RayCast(SceneAvatar.Middle, SceneAvatar.Direction);
  end;

var
  HitByAvatar: TCastleTransform;
begin
  Result := inherited;
  if Result then Exit; // allow the ancestor to handle keys

  { This virtual method is executed when user presses
    a key, a mouse button, or touches a touch-screen.

    Note that each UI control has also events like OnPress and OnClick.
    These events can be used to handle the "press", if it should do something
    specific when used in that UI control.
    The TStateRivers.Press method should be used to handle keys
    not handled in children controls.
  }


  if Event.IsKey(keyM) then
  begin
    ThirdPersonNavigation.MouseLook := not ThirdPersonNavigation.MouseLook;
    Exit(true);
  end;

  if Event.IsKey(keyF5) then
  begin
    Container.SaveScreenToDefaultFile;
    Exit(true);
  end;

  if Event.IsKey(keyEscape) then
  begin
    StateMain := TStateMain.Create(Application);
    TUIState.Current := StateMain;
    Exit(true);
  end;

  if Event.IsMouseButton(buttonRight) then
  begin
    CheckboxAimAvatar.Checked := not CheckboxAimAvatar.Checked;
    ChangeCheckboxAimAvatar(CheckboxAimAvatar); // update ThirdPersonNavigation.AimAvatar
    Exit(true);
  end;
end;

procedure TStateRivers.ChangeCheckboxCameraFollows(Sender: TObject);
begin
  ThirdPersonNavigation.CameraFollows := CheckboxCameraFollows.Checked;
end;

procedure TStateRivers.ChangeCheckboxAimAvatar(Sender: TObject);
begin
  if CheckboxAimAvatar.Checked then
    ThirdPersonNavigation.AimAvatar := aaHorizontal
  else
    ThirdPersonNavigation.AimAvatar := aaNone;

  { The 3rd option, aaFlying, doesn't make sense for this case,
    when avatar walks on the ground and has Gravity = true. }
end;

procedure TStateRivers.ChangeCheckboxDebugAvatarColliders(Sender: TObject);
begin
  DebugAvatar.Exists := CheckboxDebugAvatarColliders.Checked;
end;

procedure TStateRivers.ChangeCheckboxImmediatelyFixBlockedCamera(Sender: TObject);
begin
  ThirdPersonNavigation.ImmediatelyFixBlockedCamera := CheckboxImmediatelyFixBlockedCamera.Checked;
end;

end.
