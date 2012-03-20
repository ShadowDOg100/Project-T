class TPlayerController extends UDKPlayerController;

var UTUIDataStore_StringAliasBindingsMap BoundEventsStringDataStore;

var bool bCurrentCamAnimAffectsFOV;
var bool bCurrentCamAnimIsDamageShake;
var ForceFeedbackWaveform CameraShakeShortWaveForm, CameraShakeLongWaveForm;

//    Zooming variables
/** How fast (degrees/sec) should a zoom occur */
var float FOVLinearZoomRate;
/** If TRUE, FOV interpolation for zooming is nonlineear, using FInterpTo.  If FALSE, use linear interp. */
var transient bool bNonlinearZoomInterpolation;
/** Interp speed (as used in FInterpTo) for nonlinear FOV interpolation. */
var transient float FOVNonlinearZoomInterpSpeed;



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

function AdjustFOV(float DeltaTime)
{
        if( FOVAngle != DesiredFOV)
        {
                ClientMessage("Zooming in " $ FOVAngle $ " : " $ DesiredFOV);
                if(FOVAngle > DesiredFOV)
                        FOVAngle = FOVAngle - FMax(7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
                else
                        FOVAngle = FOVAngle - FMin(-7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
                if(Abs(FOVAngle - DesiredFOV) <= 10)
                        FOVAngle = DesiredFOV;
                PlayerCamera.SetFov(FOVAngle);
                ClientMessage("Zoomed in " $ FOVAngle $ " : " $ DesiredFOV);
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