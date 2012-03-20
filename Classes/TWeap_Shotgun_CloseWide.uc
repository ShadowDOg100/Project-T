/**
 *	TWeap_Shotgun_CloseWide
 *
 *	Creation date: 15/11/2011 19:31
 *	Copyright 2011, Shadow, Kibbie
 */
class TWeap_Shotgun_CloseWide extends TWeap_Shotgun;

defaultproperties
{
    // Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'MyWeapons.SK_WP_CloseWide'
		AnimSets(0)=AnimSet'WP_ShockRifle.Anim.K_WP_ShockRifle_1P_Base'
		Animations=MeshSequenceA
		Rotation=(Yaw=-16384)
		FOV=60.0
	End Object

	AttachmentClass=class'TGame.TAttachment_CloseWide'

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'MyWeapons.SK_WP_CloseWide'
	End Object

	InstantHitMomentum(0)=+60000.0

	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Projectile
	WeaponProjectiles(0)=class'TProj_Bullet'

	InstantHitDamage(0)=45

	InstantHitDamageTypes(0)=class'UTDmgType_ShockPrimary'
	InstantHitDamageTypes(1)=None

	WeaponFireSnd[0]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_FireCue'
	WeaponFireSnd[1]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireCue'
	WeaponEquipSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_RaiseCue'
	WeaponPutDownSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_LowerCue'
	PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Shock_Cue'

	MaxDesireability=0.65
	bInstantHit=false
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=1

	Spread(0)=+0.15
	Spread(1)=+0.15
	
	FireInterval(0)=+1.2
	FireInterval(1)=+1.2

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
	
	WeaponSubClass = 3;
}
