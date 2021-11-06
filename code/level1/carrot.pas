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

unit Carrot;

interface

uses
  Classes, CastleVectors, CastleScene, CastleTransform, CastleUtils, Math,
  CastleCameras, ThirdPersonJumper;

type
  TCarrot = class(TCastleBehavior)
  strict private
    Scene: TCastleScene;
    CarrotSpeed: Single;
    FallSpeed: Single;
    AvatarRotationSpeed: Single;
  public
    Player: TCastleScene;
    Jumper: TThirdPersonJumper;
  public 
    constructor Create(AOwner: TComponent); override;

    { constructor Create(AOwner: TComponent; APlayer: TCastleScene); }
    procedure ParentChanged; override;
    procedure Update(const SecondsPassed: Single; var RemoveMe: TRemoveType); override;
    function ToGravityPlane(const V: TVector3; const GravUp: TVector3): TVector3;
  end;
{ function Create(AOwner: TComponent; APlayer: TCastleScene): TCarrot; }

implementation

constructor TCarrot.Create(AOwner: TComponent);
begin
  inherited;
  CarrotSpeed := 1;
  FallSpeed := 1;
AvatarRotationSpeed := 10;

end;

{
function Create(AOwner: TComponent; APlayer: TCastleScene): TCarrot;
var
  ACarrot: TCarrot;
begin
  ACarrot := TCarrot.Create(AOwner);
  ACarrot.Player := APlayer;
  Result := ACarrot;
end;
}

procedure TCarrot.ParentChanged;
begin
  inherited;
  Scene := Parent as TCastleScene; // TEnemy can only be added as behavior to TCastleScene
{ Scene.PlayAnimation('walk', true); }
end;

procedure TCarrot.Update(const SecondsPassed: Single; var RemoveMe: TRemoveType);
const
  MovingSpeed = 2;
  AngleEpsilon = 0.01;
var
  NewDirection: TVector3;
  Angle: Single;
begin
  inherited;

  NewDirection := Player.Translation - Scene.Translation;
  { Add a little in the y direction, so carrot goes towards pepper's legs,
    and doesn't get stuck at her feet/the floor }
  NewDirection := NewDirection + vector3(0, 0.5, 0);

  { Calculate new carrot direction: }
  NewDirection := ToGravityPlane(NewDirection, Jumper.GetGravityUp);
  NewDirection := Scene.UniqueParent.WorldToLocalDirection(NewDirection);
  Angle := AngleRadBetweenVectors(NewDirection, Scene.Direction);
  if Angle > AngleEpsilon then
  begin
    MinVar(Angle, AvatarRotationSpeed * SecondsPassed);
    Scene.Direction := RotatePointAroundAxisRad(Angle, Scene.Direction,
            -TVector3.CrossProduct(NewDirection, Scene.Direction));
  end;

  { Handle movement: }
  Scene.Move(NewDirection * CarrotSpeed * SecondsPassed, false);

  { Now, move down a little as if gravity is acting on them: }
  Scene.Move(vector3(0,-1,0) * FallSpeed * SecondsPassed, false);


   { Scene.Direction := NewDirection; }

  { Respawn behind player if fallen off the edge of the world }
  if Scene.Translation.y < -20
    then Scene.Translation := Player.Translation - Player.Direction;


{ if Dead then Exit; }

{ // We modify the Z coordinate, responsible for enemy going forward
  Scene.Translation := Scene.Translation +
    Vector3(0, 0, MoveDirection * SecondsPassed * MovingSpeed);

  Scene.Direction := Vector3(0, 0, MoveDirection);

  // Toggle MoveDirection between 1 and -1
  if Scene.Translation.Z > 5 then
    MoveDirection := -1
  else
  if Scene.Translation.Z < -5 then
    MoveDirection := 1; }
end;

function TCarrot.ToGravityPlane(const V: TVector3; const GravUp: TVector3): TVector3;
begin
  Result := V;
  if not VectorsParallel(Result, GravUp) then
    MakeVectorsOrthoOnTheirPlane(Result, GravUp);
end;

end.

