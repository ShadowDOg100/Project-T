/**
 *	TAttachment_CloseWide
 *
 *	Creation date: 2/2/2012 17:47
 *	Copyright 2012, Kibbie
 */

class TAttachment_MidPump extends TWeaponAttachment;

var ParticleSystem BeamTemplate;
var class<UDKExplosionLight> ImpactLightClass;

var int CurrentPath;

simulated function FirstPersonFireEffects(Weapon PawnWeapon, vector HitLocation)
{
	Super.FirstPersonFireEffects(PawnWeapon, HitLocation);
}

simulated function ThirdPersonFireEffects(vector HitLocation)
{
	Super.ThirdPersonFireEffects(HitLocation);
}

simulated function bool AllowImpactEffects(Actor HitActor, vector HitLocation, vector HitNormal)
{
	return (HitActor != None && TProj_Bullet(HitActor) == None && Super.AllowImpactEffects(HitActor, HitLocation, HitNormal));
}

simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
	local float PathValues[3];
	local int NewPath;
	Super.SetMuzzleFlashparams(PSC);
	if (Instigator.FiringMode == 0)
	{
		NewPath = Rand(3);
		if (NewPath == CurrentPath)
		{
			NewPath++;
		}
		CurrentPath = NewPath % 3;

		PathValues[CurrentPath % 3] = 1.0;
		PSC.SetFloatParameter('Path1',PathValues[0]);
		PSC.SetFloatParameter('Path2',PathValues[1]);
		PSC.SetFloatParameter('Path3',PathValues[2]);
//			CurrentPath++;
	}
	else if (Instigator.FiringMode == 3)
	{
		PSC.SetFloatParameter('Path1',1.0);
		PSC.SetFloatParameter('Path2',1.0);
		PSC.SetFloatParameter('Path3',1.0);
	}
	else
	{
		PSC.SetFloatParameter('Path1',0.0);
		PSC.SetFloatParameter('Path2',0.0);
		PSC.SetFloatParameter('Path3',0.0);
	}

}


defaultproperties
{
	// Weapon SkeletalMesh
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'MyWeapons.SK_WP_MidPump'
	End Object

	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Beam_Impact', Sound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue')
	ImpactEffects(0)=(MaterialType=Water, ParticleTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Beam_Impact_HIT', Sound=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_FireCue')
	BulletWhip=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_WhipCue'

	MuzzleFlashSocket=MuzzleFlashSocket
//	MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Primary
	MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_3P_MF
	MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_3P_MF
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)
	MuzzleFlashDuration=0.33;
	MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'
	BeamTemplate=particlesystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Beam'
	WeaponClass=class'TGame.TWeap_Shotgun_MidPump'
	ImpactLightClass=class'UTShockImpactLight'
}
