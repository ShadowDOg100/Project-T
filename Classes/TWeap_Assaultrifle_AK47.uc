/**
 *	TWeap_Assaultrifle_AK47
 *
 *	Creation date: 15/11/2011 19:29
 *	Copyright 2011, Shadow
 */
class TWeap_Assaultrifle_AK47 extends TWeap_Assaultrifle;

// AI properties (for shock combos)
var TProj_Bullet ComboTarget;
var bool bRegisterTarget;
var bool bWaitForCombo;
var vector ComboStart;

var bool bWasACombo;
var int CurrentPath;

/**
* Overriden to use GetPhysicalFireStartLoc() instead of Instigator.GetWeaponStartTraceLocation()
* @returns position of trace start for instantfire()
*/
simulated function vector InstantFireStartTrace()
{
	return GetPhysicalFireStartLoc();
}

simulated function StartFire(byte FireModeNum)
{
	if ( bWaitForCombo )
	{
		if ( (ComboTarget == None) || ComboTarget.bDeleteMe )
			bWaitForCombo = false;
		else
			return;
	}
	super.StartFire(FireModeNum);
}

function DoCombo()
{
	if ( bWaitForCombo )
	{
		bWaitForCombo = false;
		if ( (Instigator != None) && (Instigator.Weapon == self) )
		{
			StartFire(0);
		}
	}
}

function ClearCombo()
{
	ComboTarget = None;
	bWaitForCombo = false;
}

simulated state WeaponFiring
{
	/**
	 * Called when the weapon is done firing, handles what to do next.
	 */
	simulated event RefireCheckTimer()
	{
		if ( bWaitForCombo)
		{
			if ( (ComboTarget == None) || ComboTarget.bDeleteMe )
				bWaitForCombo = false;
			else
			{
				StopFire(CurrentFireMode);
				GotoState('Active');
				return;
			}
		}

		super.RefireCheckTimer();
	}
}

simulated function ImpactInfo CalcWeaponFire(vector StartTrace, vector EndTrace, optional out array<ImpactInfo> ImpactList, optional vector Extent)
{
	local ImpactInfo II;
	II = super.CalcWeaponFire(StartTrace, EndTrace, ImpactList, Extent);
	bWasACombo = (II.HitActor != None && UTProj_ShockBall(II.HitActor) != none );
	return ii;
}

function SetFlashLocation( vector HitLocation )
{
	local byte NewFireMode;
	if( Instigator != None )
	{
		if (bWasACombo)
		{
			NewFireMode = 3;
		}
		else
		{
			NewFireMode = CurrentFireMode;
		}
		Instigator.SetFlashLocation( Self, NewFireMode , HitLocation );
	}
}

simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	if (FireModeNum>1)
	{
		global.PlayFireEffects(0,HitLocation);
	}
	else
	{
		super.PlayFireEffects(FireModeNum, HitLocation);
	}
}

defaultproperties
{
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'MyWeapons.ak47_Box02_001'
		AnimSets(0)=AnimSet'WP_ShockRifle.Anim.K_WP_ShockRifle_1P_Base'
		Animations=MeshSequenceA
		Rotation=(Yaw=-16384)
		FOV=60.0
	End Object

	AttachmentClass=class'TGame.TAttachment_AK47'

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'MyWeapons.ak47_Box02_001'
	End Object

	InstantHitMomentum(0)=+60000.0

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_InstantHit
	//WeaponProjectiles(0)=class'TProj_Bullet'

	InstantHitDamage(0)=45
	FireInterval(0)=+0.1
	FireInterval(1)=+0.1
	InstantHitDamageTypes(0)=class'UTDmgType_LinkBeam'

	WeaponFireSnd[0]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_FireCue'
	WeaponFireSnd[1]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireCue'
	WeaponEquipSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_RaiseCue'
	WeaponPutDownSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_LowerCue'
	PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Shock_Cue'

	MaxDesireability=0.65
	bInstantHit=false
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=1

	ShotCost(0)=1
	ShotCost(1)=1

	FireOffset=(X=20,Y=5)
	PlayerViewOffset=(X=17,Y=10.0,Z=-8.0)

	ClipCount=900
	MaxClipCount=900
	AmmoCount=900
	MaxAmmoCount=900

	FireCameraAnim(1)=CameraAnim'Camera_FX.ShockRifle.C_WP_ShockRifle_Alt_Fire_Shake'

        MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'WP_ShockRifle.Particles.P_ShockRifle_3P_MF'
	MuzzleFlashAltPSCTemplate=ParticleSystem'WP_ShockRifle.Particles.P_ShockRifle_3P_MF'
	MuzzleFlashLightClass=class'TGame.TShockMuzzleFlashLight'
	MuzzleFlashDuration=0.10
	CrossHairCoordinates=(U=256,V=0,UL=64,VL=64)
	LockerRotation=(Pitch=32768,Roll=16384)

	WeaponSubClass = 1

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformShooting1
		Samples(0)=(LeftAmplitude=90,RightAmplitude=40,LeftFunction=WF_Constant,RightFunction=WF_LinearDecreasing,Duration=0.1200)
	End Object
	WeaponFireWaveForm=ForceFeedbackWaveformShooting1
}