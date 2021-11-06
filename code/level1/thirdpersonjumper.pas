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



unit ThirdPersonJumper;

interface

uses SysUtils, Classes,
CastleComponentSerialize, CastleKeysMouse, CastleInputs,
CastleThirdPersonNavigation, CastleClassUtils, CastleTransform,
CastleLog, CastleVectors, CastleScene, Math, CastleUtils;

type
  TThirdPersonJumper = class(TCastleThirdPersonNavigation)
  private
    FInput_Jump: TInputShortcut;
    FInput_GoLeft: TInputShortcut;
    FInput_GoRight: TInputShortcut;
    FInput_GoBack: TInputShortcut;

    FJumpMaxHeight: Single;
    FIsJumping: boolean;
    FJumpHeight: Single;
    FJumpTime: Single;
    FJumpHorizontalSpeedMultiply: Single;
    FJumpSpeed: Single;

    FFallSpeed: Single;
    
    function Jump: boolean;

  public
    const
      DefaultJumpMaxHeight = 5.0;
      DefaultJumpHorizontalSpeedMultiply = 2.0;
      DefaultJumpTime = 1.0;
  public
    property JumpMaxHeight: Single
      read FJumpMaxHeight write FJumpMaxHeight default DefaultJumpMaxHeight;
    property IsJumping: boolean read FIsJumping;
    property JumpHorizontalSpeedMultiply: Single
      read FJumpHorizontalSpeedMultiply write FJumpHorizontalSpeedMultiply
      default DefaultJumpHorizontalSpeedMultiply;
    property JumpTime: Single read FJumpTime write FJumpTime
      default DefaultJumpTime;
    property Input_Jump: TInputShortcut read FInput_Jump;
    property Input_GoLeft: TInputShortcut read FInput_GoLeft;
    property Input_GoRight: TInputShortcut read FInput_GoRight;
    property Input_GoBack: TInputShortcut read FInput_GoBack;
    constructor Create(AOwner: TComponent); override;
    procedure Update(const SecondsPassed: Single; var HandleInput: Boolean); override;
    function ToGravityPlane(const V: TVector3; const GravUp: TVector3): TVector3;
    function MaxJumpDistance: Single;
    function Press(const Event: TInputPressRelease): boolean; override;
    function GetGravityUp: TVector3;
  end;


implementation

constructor TThirdPersonJumper.Create(AOwner: TComponent);
begin
  inherited;

  FIsJumping := false;
  FJumpMaxHeight := DefaultJumpMaxHeight;
  FJumpHorizontalSpeedMultiply := DefaultJumpHorizontalSpeedMultiply;
  FJumpTime := DefaultJumpTime;
  FJumpSpeed := 12.25;
  FInput_Jump    := TInputShortcut.Create(Self);
  Input_Jump.Assign(keySpace);
  Input_Jump.SetSubComponent(true);
  Input_Jump.Name := 'Input_Jump';
  FInput_GoLeft  := TInputShortcut.Create(Self);
  Input_GoLeft.Assign(keyA);
  Input_GoLeft.SetSubComponent(true);
  Input_GoLeft.Name := 'Input_GoLeft';
  FInput_GoRight := TInputShortcut.Create(Self);
  Input_GoRight.Assign(keyD);
  Input_GoRight.SetSubComponent(true);
  Input_GoRight.Name := 'Input_GoRight';
  FInput_GoBack := TInputShortcut.Create(Self);
  Input_GoBack.Assign(keyS);
  Input_GoBack.SetSubComponent(true);
  Input_GoBack.Name := 'Input_GoBack';

{ Un-assign old keys }
  Input_LeftRotate.Assign(keyR);
  Input_RightRotate.Assign(keyT);
  Input_Backward.Assign(keyY);

  AvatarRotationSpeed := 40;
  MinDistanceToAvatarTarget := 1.0;

  FFallSpeed := 0;
end;

function TThirdPersonJumper.ToGravityPlane(const V: TVector3; const GravUp: TVector3): TVector3;
begin
  Result := V;
  if not VectorsParallel(Result, GravUp) then
    MakeVectorsOrthoOnTheirPlane(Result, GravUp);
end;

procedure TThirdPersonJumper.Update(const SecondsPassed: Single; var HandleInput: Boolean);
  const
    AngleEpsilon = 0.01;
    IncreaseFallSpeed = -0.3;
  var
    B: TCastleTransform;
    V: TVector3;
    TargetDir: Tvector3;
    Angle: Single;
    Moving: Boolean;

  function TryJump: boolean;
  const
    MaxFallSpeed = -8.5;
  var
    ThisJumpHeight: Single;
    ThisFallHeight: Single;
  begin
    Result := IsJumping;

    FFallSpeed := FFallSpeed + IncreaseFallSpeed;
    if FFallSpeed < MaxFallSpeed then FFallSpeed := MaxFallSpeed;

    if Result then
    begin
      FIsJumping := false;
      FFallSpeed := FJumpSpeed;
      { jump. This means:
        1. update FJumpHeight and move Position
        2. or set FIsJumping to false when jump ends }
{       ThisJumpHeight := MaxJumpDistance * SecondsPassed / FJumpTime; }
{ FJumpHeight := FJumpHeight + ThisJumpHeight; }
      { WriteLnLog(FloatToStr(ThisFallHeight)); }
{if FJumpHeight > MaxJumpDistance then
          FIsJumping := false else
        begin }
        { Move(Self.Up * ThisJumpHeight, false, false); }
        { do jumping }
        { Move(Camera.GravityUp * ThisJumpHeight, false, false); }
          { B.Move(Vector3(0, FJumpSpeed, 0), false, true); }
{ B.Move(Self.Up * ThisJumpHeight, false, true); }
          { WriteLnLog('I''m jumping!!!'); }
{ end }

    end; {else} { fall }
    ThisFallHeight := (FFallSpeed * SecondsPassed / FJumpTime) * 0.66;
    if (FFallSpeed < 0) 
       and (not B.MoveAllowed(B.Translation, B.Translation + Vector3(0, ThisFallHeight, 0),
            false))
      then FFallSpeed := 0
    else
      B.Move(Vector3(0, ThisFallHeight, 0), false, true);
  end;
begin
  inherited;

  B := Avatar;

{ B.Up := vector3(0,1,0); }

  TargetDir := B.Direction;
  if Input_Forward.isPressed(Container) then
  begin
    TargetDir := Camera.Direction;
    Moving := true;

  end;
  if Input_GoBack.isPressed(Container) then
  begin
    TargetDir := -Camera.Direction;
    Moving := true;
  end;
  if Input_GoLeft.isPressed(Container) then
  begin
    TargetDir := -TVector3.CrossProduct(Camera.Direction, Camera.Up);
    Moving := true;

  end;
  if Input_GoRight.isPressed(Container) then
  begin
    TargetDir := TVector3.CrossProduct(Camera.Direction, Camera.Up);
    Moving := true;

  end;

  TargetDir := ToGravityPlane(TargetDir, Camera.GravityUp);
  TargetDir := B.UniqueParent.WorldToLocalDirection(TargetDir);
  Angle := AngleRadBetweenVectors(TargetDir, B.Direction);
  if Angle > AngleEpsilon then
  begin
    MinVar(Angle, AvatarRotationSpeed * SecondsPassed);
    B.Direction := RotatePointAroundAxisRad(Angle, B.Direction, -TVector3.CrossProduct(TargetDir, B.Direction));
  end;

  { Now, we're (almost) looking in the right direction: 
    If we've pushed right, left, or back, then move in targetDir - Forward has
        already been handled!! }
  if (Input_GoRight.isPressed(Container) or
     Input_GoLeft.isPressed(Container) or
     Input_GoBack.isPressed(Container)) 
     and not Input_Forward.isPressed(Container)
    then B.Move(TargetDir * MoveSpeed * SecondsPassed, false);

  {
  if Moving then
    Avatar.AutoAnimation := AnimationWalk
  else
    if not (Avatar.AutoAnimation = AnimationIdle)
      then Avatar.AutoAnimation := AnimationIdle;
  }

  if TryJump then ;
end;

function TThirdPersonJumper.Jump: boolean;
begin
  Result := false;

  if IsJumping {or Falling or (not Gravity) } then Exit;

  { Merely checking for Falling is not enough, because Falling
    may be triggered with some latency. E.g. consider user that holds
    Input_Jump key down: whenever jump will end (in GravityUpdate),
    Input_Jump.IsKey = true will cause another jump to be immediately
    (before Falling will be set to true) initiated.
    This is of course bad, because user holding Input_Jump key down
    would be able to jump to any height. The only good thing to do
    is to check whether player really has some ground beneath his feet
    to be able to jump. }

  { update IsAbove, AboveHeight }
  { Height(Camera.Position, FIsAbove, FAboveHeight, FAboveGround); }

  { if AboveHeight > RealPreferredHeight + RealPreferredHeightMargin then
    Exit; }

  FIsJumping := true;
  FJumpHeight := 0.0;
  Result := true;
end;

function TThirdPersonJumper.MaxJumpDistance: Single;
begin
  Result := JumpMaxHeight;
end;

function TThirdPersonJumper.Press(const Event: TInputPressRelease): boolean;
begin
  inherited;

  if Input_Jump.IsEvent(Event) then
  begin
    { WriteLnLog('Jumping!'); }
    Result := Jump and ExclusiveEvents;
  end else
    Result := false;
end;

function TThirdPersonJumper.GetGravityUp: TVector3;
begin

  Result := Camera.GravityUp;
end;

end.








