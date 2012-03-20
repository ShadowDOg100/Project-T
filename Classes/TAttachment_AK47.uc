class TAttachment_AK47 extends TWeaponAttachment;

var ParticleSystem BeamTemplate;
var class<UDKExplosionLight> ImpactLightClass;

var int CurrentPath;

simulated function FirstPersonFireEffects(Weapon PawnWeapon, vector HitLocation)
{
        global.FirstPersonFireEffects(PawnWeapon, HitLocation);
}

simulated function ThirdPersonFireEffects(vector HitLocation)
{
	global.ThirdPersonFireEffects(HitLocation);
}

simulated function bool AllowImpactEffects(Actor HitActor, vector HitLocation, vector HitNormal)
{
	return (HitActor != None && global.AllowImpactEffects(HitActor, HitLocation, HitNormal));
}

simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
	local float PathValues[3];
	local int NewPath;
	super.SetMuzzleFlashparams(PSC);
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
		SkeletalMesh=SkeletalMesh'MyWeapons.ak47_Box02_001'
	End Object

        DefaultImpactEffect=(ParticleTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact', Sound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue')
	ImpactEffects(0)=(MaterialType=Water, ParticleTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact', Sound=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_FireCue')
	BulletWhip=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_WhipCue'

        MaxImpactEffectDistance=4000.0

	MuzzleFlashLightClass=class'TGame.TShockMuzzleFlashLight'
	WeaponClass=class'TGame.TWeap_Assaultrifle_AK47'
	
	ImpactLightClass=class'TShockImpactLight'
}