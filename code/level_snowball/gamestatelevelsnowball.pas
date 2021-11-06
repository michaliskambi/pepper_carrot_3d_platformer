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

unit GameStateLevelSnowball;

interface

uses Classes, CastleWindow,
  CastleUIState, CastleComponentSerialize, CastleUIControls, CastleControls,
  CastleKeysMouse, CastleViewport, CastleScene, CastleVectors, CastleCameras,
  CastleTransform, CastleInputs, CastleThirdPersonNavigation, CastleDebugTransform,
  ThirdPersonSnowball, Snowball, GameStateLevelSnowball2, GameStateMain;

type
  TStateLevelSnowball = class(TUIState)
  private
    { Components designed using CGE editor, loaded from state-main.castle-user-interface. }
    LabelFps: TCastleLabel;
    LabelEnemies: TCastleLabel;
    MainViewport: TCastleViewport;
    ThirdPersonNavigation: TThirdPersonSnowball;
    SceneAvatar: TCastleScene;
    EnemiesHolder: TCastleTransform;
    CheckboxCameraFollows: TCastleCheckbox;
    CheckboxAimAvatar: TCastleCheckbox;
    CheckboxDebugAvatarColliders: TCastleCheckbox;
    CheckboxImmediatelyFixBlockedCamera: TCastleCheckbox;
    FInput_Snowball: TInputShortcut;

    { Enemies behaviors }
    { Enemies: TEnemyList; }
    Snowballs: TCastleTransform;

    DebugAvatar: TDebugTransform;
     { DebugSnowballs: TDebugTransform; }

    LevelNext: TStateLevelSnowball2;

    procedure ChangeCheckboxCameraFollows(Sender: TObject);
    procedure ChangeCheckboxAimAvatar(Sender: TObject);
    procedure ChangeCheckboxDebugAvatarColliders(Sender: TObject);
    procedure ChangeCheckboxImmediatelyFixBlockedCamera(Sender: TObject);
    procedure SpawnSnowball;
  public
    property Input_Snowball: TInputShortcut read FInput_Snowball;
    constructor Create(AOwner: TComponent); override;
    procedure Start; override;
    procedure Stop; override;
    procedure Update(const SecondsPassed: Single; var HandleInput: Boolean); override;
    function Press(const Event: TInputPressRelease): Boolean; override;
  end;

var
  StateLevelSnowball: TStateLevelSnowball;

implementation

uses SysUtils, Math, StrUtils,
  CastleSoundEngine, CastleLog, CastleStringUtils, CastleFilesUtils,
  CastleUtils;

{ TStateLevelSnowball ----------------------------------------------------------------- }

constructor TStateLevelSnowball.Create(AOwner: TComponent);
begin
  inherited;
  DesignUrl := 'castle-data:/level_snowball/gamestatelevelsnowball.castle-user-interface';
  FInput_Snowball  := TInputShortcut.Create(Self);
  Input_Snowball.Assign(keyF);
  Input_Snowball.SetSubComponent(true);
  Input_Snowball.Name := 'Input_Snowball';
end;

procedure TStateLevelSnowball.Start;
var
  SoldierScene: TCastleScene;
{ Enemy: TEnemy; }
  I: Integer;
begin
  inherited;

  { Find components, by name, that we need to access from code }
  LabelFps := DesignedComponent('LabelFps') as TCastleLabel;
  LabelEnemies := DesignedComponent('LabelEnemies') as TCastleLabel;
  MainViewport := DesignedComponent('MainViewport') as TCastleViewport;
  { ThirdPersonNavigation := DesignedComponent('ThirdPersonNavigation') as
  TCastleThirdPersonNavigation; }
  ThirdPersonNavigation := TThirdPersonSnowball.Create(MainViewport);
  SceneAvatar := DesignedComponent('SceneAvatar') as TCastleScene;
  EnemiesHolder := DesignedComponent('EnemiesHolder') as TCastleTransform;
  CheckboxCameraFollows := DesignedComponent('CheckboxCameraFollows') as TCastleCheckbox;
  CheckboxAimAvatar := DesignedComponent('CheckboxAimAvatar') as TCastleCheckbox;
  CheckboxDebugAvatarColliders := DesignedComponent('CheckboxDebugAvatarColliders') as TCastleCheckbox;
  CheckboxImmediatelyFixBlockedCamera := DesignedComponent('CheckboxImmediatelyFixBlockedCamera') as TCastleCheckbox;

  Snowballs := TCastleTransform.Create(Self);
  MainViewport.Items.Add(Snowballs);

  { Create TEnemy instances, add them to Enemies list }
{ Enemies := TEnemyList.Create(true);
  for I := 1 to 4 do
  begin
    SoldierScene := DesignedComponent('SceneSoldier' + IntToStr(I)) as TCastleScene; }
    { Below using nil as Owner of TEnemy, as the Enemies list already "owns"
      instances of this class, i.e. it will free them. }
{ Enemy := TEnemy.Create(nil);
    SoldierScene.AddBehavior(Enemy);
    Enemies.Add(Enemy);
  end; }

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
{ DebugSnowballs := TDebugTransform.Create(FreeAtStop); }
{ DebugSnowballs.Parent := Snowballs; }
{ DebugSnowballs.Exists := true; }

  { Configure ThirdPersonNavigation, some things that cannot be yet adusted using CGE editor.
    In particular assign some keys that are not assigned by default. }
  ThirdPersonNavigation.Input_LeftStrafe.Assign(keyA);
  ThirdPersonNavigation.Input_RightStrafe.Assign(keyD);
  ThirdPersonNavigation.Input_CameraCloser.Assign(keyNone, keyNone, '', false, buttonLeft, mwUp);
  ThirdPersonNavigation.Input_CameraFurther.Assign(keyNone, keyNone, '', false, buttonLeft, mwDown);
  ThirdPersonNavigation.CameraFollows := true;
  ThirdPersonNavigation.Input_Jump.Assign(keyJ);
  ThirdPersonNavigation.MouseLook := true; // by default use mouse look
  ThirdPersonNavigation.AimAvatar := aaHorizontal;
  ThirdPersonNavigation.Avatar := SceneAvatar;
  ThirdPersonNavigation.MoveSpeed := 5.0;

  ThirdPersonNavigation.Init;

  MainViewport.Navigation := ThirdPersonNavigation;
end;

procedure TStateLevelSnowball.Stop;
begin
{ FreeAndNil(Enemies); }
  inherited;
end;

procedure TStateLevelSnowball.Update(const SecondsPassed: Single; var HandleInput: Boolean);
  var
    Enemy: TCastleScene;
    I: Integer;
    J: Integer;
    K: Integer;
    Snow: TCastleScene;

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
  // UpdateAimAvatar;

  J := 0;
  for I := 0 to EnemiesHolder.Count - 1 do
  begin
    { Gem := GetItem[I] as TCastleSphere; }
    Enemy := EnemiesHolder.Items[I] as TCastleScene;
    if (Enemy.Exists = true) then
    begin
      J := J + 1;
      if Snowballs.Count > 0 then
      begin
        for K := 0 to Snowballs.Count -1 do
        begin
          Snow := Snowballs.Items[K] as TCastleScene;
          if Enemy.BoundingBox.Collides(Snow.BoundingBox)
          then 
          begin
            Enemy.Exists := false;
            Snow .Exists := false;
          end;
        end;
      end;
    end;

  end;
  if J = 0 then
  begin
    LevelNext := TStateLevelSnowball2.Create(Application);
    TUIState.Current := LevelNext;
    Exit;

  end;
  LabelEnemies.Caption := 'Num Enemies Remaining: ' + J.ToString;

  if SceneAvatar.Translation.Y < -10 then
  begin
    StateLevelSnowball := TStateLevelSnowball.Create(Application);
    TUIState.Current := StateLevelSnowball;
    Exit;
  end;

end;

function TStateLevelSnowball.Press(const Event: TInputPressRelease): Boolean;

  function AvatarRayCast: TCastleTransform;
  begin
    { SceneAvatar.RayCast tests a ray collision,
      ignoring the collisions with SceneAvatar itself (so we don't detect our own
      geometry as colliding). }
    Result := SceneAvatar.RayCast(SceneAvatar.Middle, SceneAvatar.Direction);
  end;

var
  HitByAvatar: TCastleTransform;
  { HitEnemy: TEnemy; }
begin
  Result := inherited;
  if Result then Exit; // allow the ancestor to handle keys

  { This virtual method is executed when user presses
    a key, a mouse button, or touches a touch-screen.

    Note that each UI control has also events like OnPress and OnClick.
    These events can be used to handle the "press", if it should do something
    specific when used in that UI control.
    The TStateLevelSnowball.Press method should be used to handle keys
    not handled in children controls.
  }

{ if Event.IsMouseButton(buttonLeft) then
  begin
    SoundEngine.Sound(SoundEngine.SoundFromName('shoot_sound')); }

    { We clicked on enemy if
      - HitByAvatar indicates we hit something
      - It has a behavior of TEnemy. }
{ HitByAvatar := AvatarRayCast;
    if (HitByAvatar <> nil) and
       (HitByAvatar.FindBehavior(TEnemy) <> nil) then
    begin
      HitEnemy := HitByAvatar.FindBehavior(TEnemy) as TEnemy;
      HitEnemy.Hurt;
    end; }

{ Exit(true);
  end; }

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

{ if Event.IsMouseButton(buttonRight) then
  begin
    CheckboxAimAvatar.Checked := not CheckboxAimAvatar.Checked;
    ChangeCheckboxAimAvatar(CheckboxAimAvatar); // update ThirdPersonNavigation.AimAvatar
    Exit(true);
  end; }

  if Input_Snowball.IsEvent(Event) or Event.IsMouseButton(buttonLeft) 
     or Event.IsKey(keySpace) then
  begin
    SpawnSnowball;
    Exit(true);
  end;
end;

procedure TStateLevelSnowball.ChangeCheckboxCameraFollows(Sender: TObject);
begin
  ThirdPersonNavigation.CameraFollows := CheckboxCameraFollows.Checked;
end;

procedure TStateLevelSnowball.ChangeCheckboxAimAvatar(Sender: TObject);
begin
  if CheckboxAimAvatar.Checked then
    ThirdPersonNavigation.AimAvatar := aaHorizontal
  else
    ThirdPersonNavigation.AimAvatar := aaNone;

  { The 3rd option, aaFlying, doesn't make sense for this case,
    when avatar walks on the ground and has Gravity = true. }
end;

procedure TStateLevelSnowball.ChangeCheckboxDebugAvatarColliders(Sender: TObject);
begin
  DebugAvatar.Exists := CheckboxDebugAvatarColliders.Checked;
end;

procedure TStateLevelSnowball.ChangeCheckboxImmediatelyFixBlockedCamera(Sender: TObject);
begin
  ThirdPersonNavigation.ImmediatelyFixBlockedCamera := CheckboxImmediatelyFixBlockedCamera.Checked;
end;

procedure TStateLevelSnowball.SpawnSnowball;
var
  Snowball: TSnowball;
begin
  Snowball := TSnowball.Create(MainViewport.Items);
  Snowballs.Add(Snowball);
{
  Snowball := TCastleSphere.Create(nil);
  
  Snowball.Material := pmUnlit;
  Snowball.RenderOptions.WireframeEffect := weSilhouette;
  }
  Snowball.Translation := SceneAvatar.Translation + vector3(0,1.5,0) + SceneAvatar.Direction;
  Snowball.Direction   := SceneAvatar.Direction;
  { MainViewport.Items.Add(Snowball); }

end;

end.
