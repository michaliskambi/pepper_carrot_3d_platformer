{
    Copyright 2020-2022 Michalis Kamburelis.
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


unit ThirdPersonSnowball;

interface

uses SysUtils, Classes,
CastleComponentSerialize, CastleKeysMouse, CastleInputs,
CastleThirdPersonNavigation, CastleClassUtils, CastleTransform,
CastleLog, CastleVectors;

type
  TThirdPersonSnowball = class(TCastleThirdPersonNavigation)
  private
    FInput_Jump: TInputShortcut;

    FJumpMaxHeight: Single;
    FIsJumping: boolean;
    FJumpHeight: Single;
    FJumpTime: Single;
    FJumpHorizontalSpeedMultiply: Single;
    FJumpSpeed: Single;
    
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
    constructor Create(AOwner: TComponent); override;
    procedure Update(const SecondsPassed: Single; var HandleInput: Boolean); override;
    function MaxJumpDistance: Single;
    function Press(const Event: TInputPressRelease): boolean; override;
  end;


implementation

constructor TThirdPersonSnowball.Create(AOwner: TComponent);
begin
  inherited;

  FIsJumping := false;
  FJumpMaxHeight := DefaultJumpMaxHeight;
  FJumpHorizontalSpeedMultiply := DefaultJumpHorizontalSpeedMultiply;
  FJumpTime := DefaultJumpTime;
  FJumpSpeed := 0.25;
  FInput_Jump  := TInputShortcut.Create(Self);
  Input_Jump.Assign(keySpace);
  Input_Jump.SetSubComponent(true);
  Input_Jump.Name := 'Input_Jump';
end;

procedure TThirdPersonSnowball.Update(const SecondsPassed: Single; var HandleInput: Boolean);
  var
    B: TCastleTransform;

  function TryJump: boolean;
  var
    ThisJumpHeight: Single;
    ThisFallHeight: Single;
  begin
    Result := IsJumping;

    ThisFallHeight := -(MaxJumpDistance * SecondsPassed / FJumpTime) * 0.66;
    if Result then
    begin
      { jump. This means:
        1. update FJumpHeight and move Position
        2. or set FIsJumping to false when jump ends }
      ThisJumpHeight := MaxJumpDistance * SecondsPassed / FJumpTime;
      FJumpHeight := FJumpHeight + ThisJumpHeight;
      { WriteLnLog(FloatToStr(ThisFallHeight)); }
      if FJumpHeight > MaxJumpDistance then
          FIsJumping := false else
        begin
        { Move(Self.Up * ThisJumpHeight, false, false); }
        { do jumping }
        { Move(Camera.GravityUp * ThisJumpHeight, false, false); }
          { B.Move(Vector3(0, FJumpSpeed, 0), false, true); }
          B.Move(Self.Camera.Up * ThisJumpHeight, false, true);
          { WriteLnLog('I''m jumping!!!'); }
       end

    end else { fall }
    begin
      { ThisFallHeight := MaxJumpDistance * SecondsPassed / FJumpTime; }
      B.Move(Vector3(0, ThisFallHeight, 0), false, true);
    end
  end;
begin
  inherited;

  B := Avatar;

  if TryJump then ;
end;

function TThirdPersonSnowball.Jump: boolean;
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

function TThirdPersonSnowball.MaxJumpDistance: Single;
begin
  Result := JumpMaxHeight;
end;


function TThirdPersonSnowball.Press(const Event: TInputPressRelease): boolean;
begin
  inherited;

  if Input_Jump.IsEvent(Event) then
  begin
    { WriteLnLog('Jumping!'); }
    Result := Jump and ExclusiveEvents;
  end else
    Result := false;

end;


end.








