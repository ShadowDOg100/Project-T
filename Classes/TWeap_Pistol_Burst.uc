/**
 *	TWeap_Pistol_Burst
 *
 *	Creation date: 15/11/2011 19:30
 *	Copyright 2011, Shadow
 */
class TWeap_Pistol_Burst extends TWeap_Pistol;



defaultproperties
{
    // Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'MyWeapons.SK_WP_Generic'
		Animations=MeshSequenceA
		Rotation=(Yaw=-16384)
		FOV=60.0
	End Object

	AttachmentClass=class'TGame.TAttachment_Generic'

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'MyWeapons.SK_WP_Generic'
	End Object

	InstantHitMomentum(0)=+60000.0

	WeaponFireTypes(0)=EWFT_InstantHit
	
	InstantHitDamage(0)=45
	FireInterval(0)=+0.3
	
	InstantHitDamageTypes(0)=class'UTDmgType_ShockPrimary'

	MaxDesireability=0.65
	ShouldFireOnRelease(0)=0

	ShotCost(0)=1

	FireOffset=(X=20,Y=5)
	PlayerViewOffset=(X=17,Y=10.0,Z=-8.0)

	ClipCount=18
	MaxClipCount=18
	AmmoCount=72
	MaxAmmoCount=72

	MuzzleFlashSocket=b_Muzzle
	MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashColor=(R=200,G=120,B=255,A=255)
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'
	CrossHairCoordinates=(U=256,V=0,UL=64,VL=64)
	
	WeaponSubClass = 1;
    

}
