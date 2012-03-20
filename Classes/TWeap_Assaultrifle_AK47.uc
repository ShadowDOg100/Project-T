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

defaultproperties
{
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'MyWeapons.SK_WP_SigCommando'
		AnimSets(0)=AnimSet'WP_ShockRifle.Anim.K_WP_ShockRifle_1P_Base'
		Animations=MeshSequenceA
		Rotation=(Yaw=-16384)
		FOV=60.0
	End Object

	AttachmentClass=class'TGame.TAttachment_AK47'

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'MyWeapons.SK_WP_SigCommando'
	End Object

	InstantHitMomentum(0)=+60000.0

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_InstantHit
	//WeaponProjectiles(0)=class'TProj_Bullet'

	InstantHitDamage(0)=45
	FireInterval(0)=+0.1
	FireInterval(1)=+0.1
	InstantHitDamageTypes(0)=class'UTDmgType_ShockPrimary'
	InstantHitDamageTypes(1)=None

	WeaponFireSnd[0]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_FireCue'
	WeaponFireSnd[1]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireCue'
	WeaponEquipSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_RaiseCue'
	WeaponPutDownSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_LowerCue'
	PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Shock_Cue'

	MaxDesireability=0.65
	bInstantHit=true
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=1

	ShotCost(0)=1
	ShotCost(1)=1

	FireOffset=(X=20,Y=5)
	PlayerViewOffset=(X=17,Y=10.0,Z=-8.0)

	ClipCount=30
	MaxClipCount=30
	AmmoCount=90
	MaxAmmoCount=90

	FireCameraAnim(1)=CameraAnim'Camera_FX.ShockRifle.C_WP_ShockRifle_Alt_Fire_Shake'

	MuzzleFlashSocket=b_Muzzle
	MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashColor=(R=200,G=120,B=255,A=255)
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'
	CrossHairCoordinates=(U=256,V=0,UL=64,VL=64)
	
	WeaponSubClass = 1;
}
