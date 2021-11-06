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
unit Snowball;

interface

uses SysUtils, Classes, Generics.Collections, CastleShapes, CastleScene, CastleTransform;


type
  TSnowball = class(TCastleScene)
  private
    Ball: TCastleSphere;
    MoveSpeed: Single;

  public

    constructor Create(AOwner: TComponent); override;
    procedure Update(const SecondsPassed: Single; var RemoveMe: TRemoveType); override;
  end;
  TSnowballList = specialize TObjectList<TSnowball>;

implementation

constructor TSnowball.Create(AOwner: TComponent);
begin
  inherited;
  MoveSpeed := 6;
  Ball := TCastleSphere.Create(Self);
  
  { Snowball.Translation := SceneAvatar.Translation; }
  { Snowball.Translation := Translation; }
  Ball.Material := pmUnlit;
  Ball.Radius := 0.2;
  Ball.RenderOptions.WireframeEffect := weSilhouette;
  Add(Ball);
  { MainViewport.Items.Add(Ball); }


end;

procedure TSnowball.Update(const SecondsPassed: Single; var RemoveMe: TRemoveType);
begin
  inherited;
  Translation := Translation + (Direction * SecondsPassed * MoveSpeed);

  if (Translation.x > 200.0) or (Translation.z > 200.0)
  or (Translation.x < -200.0) or (Translation.z < -200.0)
  then
    RemoveMe := rtRemoveAndFree;

end;

end.

