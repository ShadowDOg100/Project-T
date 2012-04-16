class TPlayerController extends UDKPlayerController;

var UTUIDataStore_StringAliasBindingsMap BoundEventsStringDataStore;

var bool bCurrentCamAnimAffectsFOV;
var bool bCurrentCamAnimIsDamageShake;
var ForceFeedbackWaveform CameraShakeShortWaveForm, CameraShakeLongWaveForm;

//    Zooming variables
/** How fast (degrees/sec) should a zoom occur */
var float FOVLinearZoomRate;
/** If TRUE, FOV interpolation for zooming is nonlineear, using FInterpTo.  If FALSE, use linear interp. */
var bool bNonlinearZoomInterpolation;
/** Interp speed (as used in FInterpTo) for nonlinear FOV interpolation. */
var float FOVNonlinearZoomInterpSpeed;

var float ZoomRotationModifier;

var bool bCurrentCamAnimEffectsFOV;

simulated function StartZoom(float NewDesiredFOV, float NewZoomRate)
{
	FOVLinearZoomRate = NewZoomRate;
	DesiredFOV = NewDesiredFOV;
	
	bNonlinearZoomInterpolation = false;
	FOVNonlinearZoomInterpSpeed = 0.0;
}

simulated function StartZoomNonlinear(float NewDesiredFOV, float NewZoomRate)
{
	FOVLinearZoomRate = NewZoomRate;
	DesiredFOV = NewDesiredFOV;
	
	bNonlinearZoomInterpolation = true;
	FOVNonlinearZoomInterpSpeed = 0.0;
}

simulated function StopZoom()
{
	DesiredFOV = FOVAngle;
	FOVLinearZoomRate = 0.0;
}

simulated function EndZoom()
{
	DesiredFOV = default.DefaultFOV;
	FOVAngle = default.DefaultFOV;
	FOVLinearZoomRate = 0.0;
	FOVNonlinearZoomInterpSpeed = 0.0;
}

simulated function EndZoomNonlinear(float ZoomInterpSpeed)
{
	DesiredFOV = default.DefaultFOV;
	FOVNonlinearZoomInterpSpeed = ZoomInterpSpeed;
	bNonlinearZoomInterpolation = true;
	FOVLinearZoomRate = 0.0;
}

reliable simulated client function ClientEndZoom()
{
	EndZoom();
}

function OnUpdatePropertyFOVAngle()
{
	bCurrentCamAnimEffectsFOV = true;
	FOVAngle = DesiredFOV + (FOVAngle - 90.0);
}

event float GetFOVAngle()
{
	return FOVAngle;
}

exec function SwitchWeapon(byte T)
{
	ClientMessage("PlayerController Switch Weapon");
	if (TPawn(Pawn) != None)
		TPawn(Pawn).SwitchWeapon(t);
}

exec function SwitchHud()
{
	ClientSetHud(class'TGFxHUDWrapper');
}

exec function Crouch()
{
	if (TPawn(Pawn) != None)
		TPawn(Pawn).setHeight(25.0);
	ClientMessage("Crouch");
}

exec function UnCrouch()
{
	if (TPawn(Pawn) != None)
		TPawn(Pawn).setHeight(38.0);
	ClientMessage("UnCrouch");
}

event InitInputSystem()
{
	local LocalPlayer LP;

	LP = LocalPlayer(Player);

	Super.InitInputSystem();
	// we do this here so that we only bother to create it for local players
	CameraAnimPlayer = new(self) class'CameraAnimInst';
	// reset the post processing when we get a new PC
	LP.RemoveAllPostProcessingChains();
	LP.InsertPostProcessingChain(LP.Outer.GetWorldPostProcessChain(), INDEX_NONE, true);
}


simulated function bool TriggerInteracted()
{
	return super.TriggerInteracted();
}

function PlayCameraAnim( CameraAnim AnimToPlay, optional float Scale=1.f, optional float Rate=1.f,
			optional float BlendInTime, optional float BlendOutTime, optional bool bLoop, optional bool bIsDamageShake )
{
	local Camera MatineeAnimatedCam;

	bCurrentCamAnimAffectsFOV = false;

	// if we have a real camera, e.g we're watching through a matinee camera,
	// send the CameraAnim to be played there
	MatineeAnimatedCam = PlayerCamera;
	if (MatineeAnimatedCam != None)
	{
		MatineeAnimatedCam.PlayCameraAnim(AnimToPlay, Rate, Scale, BlendInTime, BlendOutTime, bLoop, FALSE);
	}
	else if (CameraAnimPlayer != None)
	{
		// play through normal UT camera
		CamOverridePostProcess = class'CameraActor'.default.CamOverridePostProcess;
		CameraAnimPlayer.Play(AnimToPlay, self, Rate, Scale, BlendInTime, BlendOutTime, bLoop, false);
	}

	// Play controller vibration - don't do this if damage, as that has its own handling
	if( !bIsDamageShake && !bLoop && WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( AnimToPlay.AnimLength <= 1 )
		{
			ClientPlayForceFeedbackWaveform(CameraShakeShortWaveForm);
		}
		else
		{
			ClientPlayForceFeedbackWaveform(CameraShakeLongWaveForm);
		}
	}

	bCurrentCamAnimIsDamageShake = bIsDamageShake;
}

simulated exec function RaiseWeapon()
{
    if((TPawn(Pawn) == none) || Pawn.Weapon == none) return;

    TWeapon(TPawn(Pawn).Weapon).RaiseWeapon();
}

simulated exec function LowerWeapon()
{
    if((TPawn(Pawn) == none) || Pawn.Weapon == none) return;

    TWeapon(TPawn(Pawn).Weapon).LowerWeapon();
}

function AdjustFOV(float DeltaTime)
{
	local float DeltaFOV;
	if( FOVAngle != DesiredFOV && (!bCurrentCamAnimEffectsFOV || CameraAnimPlayer.bFinished))
	{
		if(bNonlinearZoomInterpolation)
		{
			FOVAngle = FInterpTo(FOVAngle, DesiredFOV, DeltaTime, FOVNonlinearZoomInterpSpeed);
		}
		else
		{	
			if(FOVLinearZoomRate > 0.0)
			{
				DeltaFOV = FOVLinearZoomRate * DeltaTime;
				if(FOVAngle > DesiredFOV)
				{
					FOVAngle = FMax(DesiredFOV, (FOVAngle - DeltaFOV));
				}
				else
				{
					FOVAngle = FMin(DesiredFOV, (FOVAngle + DeltaFOV));
				}
			}
			else
			{
				FOVAngle = DesiredFOV;
			}
		}
	}
}

defaultproperties
{
	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveform7
		Samples(0)=(LeftAmplitude=60,RightAmplitude=50,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=0.200)
	End Object
	CameraShakeShortWaveForm=ForceFeedbackWaveform7
	DesiredFOV=90.000000
	DefaultFOV=90.000000
	FOVAngle=90.000
}
