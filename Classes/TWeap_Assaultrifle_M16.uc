/**
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 */
class TWeap_Assaultrifle_M16 extends TWeap_Assaultrifle;

// AI properties (for shock combos)
var TProj_Bullet ComboTarget;
var bool bRegisterTarget;
var bool bWaitForCombo;
var vector ComboStart;

var bool bWasACombo;
var int CurrentPath;
//-----------------------------------------------------------------
// AI InterFface
function float GetAIRating()
{
	local UTBot B;

	B = UTBot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) || Pawn(B.Focus) == None )
		return AIRating;

	if ( bWaitForCombo )
		return 1.5;
	if ( !B.ProficientWithWeapon() )
		return AIRating;
	if ( B.Stopped() )
	{
		if ( !B.LineOfSightTo(B.Enemy) && (VSize(B.Enemy.Location - Instigator.Location) < 5000) )
			return (AIRating + 0.5);
		return (AIRating + 0.3);
	}
	else if ( VSize(B.Enemy.Location - Instigator.Location) > 1600 )
		return (AIRating + 0.1);
	else if ( B.Enemy.Location.Z > B.Location.Z + 200 )
		return (AIRating + 0.15);

	return AIRating;
}


/**
* Overriden to use GetPhysicalFireStartLoc() instead of Instigator.GetWeaponStartTraceLocation()
* @returns position of trace start for instantfire()
*/
simulated function vector InstantFireStartTrace()
{
	return GetPhysicalFireStartLoc();
}

function SetComboTarget(TProj_Bullet S)
{
	if ( !bRegisterTarget || (UTBot(Instigator.Controller) == None) || (Instigator.Controller.Enemy == None) )
		return;

	bRegisterTarget = false;
	bWaitForCombo = true;
	ComboStart = Instigator.Location;
	ComboTarget = S;
	ComboTarget.Monitor(UTBot(Instigator.Controller).Enemy);
}

function float RangedAttackTime()
{
	local UTBot B;

	B = UTBot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if ( B.CanComboMoving() )
		return 0;

	return FMin(2,0.3 + VSize(B.Enemy.Location - Instigator.Location)/class'TProj_Bullet'.default.Speed);
}

function float SuggestAttackStyle()
{
	return -0.4;
}

simulated function StartFire(byte FireModeNum)
{
	if ( bWaitForCombo && (UTBot(Instigator.Controller) != None) )
	{
		if ( (ComboTarget == None) || ComboTarget.bDeleteMe )
			bWaitForCombo = false;
		else
			return;
	}
	Super.StartFire(FireModeNum);
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

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	local float EnemyDist;
	local UTBot B;

	bWaitForCombo = false;
	B = UTBot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if (B.IsShootingObjective())
		return 0;

	if ( !B.LineOfSightTo(B.Enemy) )
	{
		if ( (ComboTarget != None) && !ComboTarget.bDeleteMe && B.CanCombo() )
		{
			bWaitForCombo = true;
			return 0;
		}
		ComboTarget = None;
		if ( B.CanCombo() && B.ProficientWithWeapon() )
		{
			bRegisterTarget = true;
			return 1;
		}
		return 0;
	}

	EnemyDist = VSize(B.Enemy.Location - Instigator.Location);

	if ( (EnemyDist > 4*class'TProj_Bullet'.default.Speed) || (EnemyDist < 150) )
	{
		ComboTarget = None;
		return 0;
	}

	if ( (ComboTarget != None) && !ComboTarget.bDeleteMe && B.CanCombo() )
	{
		bWaitForCombo = true;
		return 0;
	}

	ComboTarget = None;

	if ( (EnemyDist > 2500) && (FRand() < 0.5) )
		return 0;

	if ( B.CanCombo() && B.ProficientWithWeapon() )
	{
		bRegisterTarget = true;
		return 1;
	}

	// consider using altfire to block incoming enemy fire
	if (EnemyDist < 1000.0 && B.Enemy.Weapon != None && B.Enemy.Weapon.Class != Class && B.ProficientWithWeapon())
	{
		return (FRand() < 0.3) ? 0 : 1;
	}
	else
	{
		return (FRand() < 0.7) ? 0 : 1;
	}
}

// for bot combos
simulated function Projectile ProjectileFire()
{
	local Projectile p;

	p = Super.ProjectileFire();
	if (TProj_Bullet(p) != None)
	{
		SetComboTarget(TProj_Bullet(P));
	}
	return p;
}

simulated function rotator GetAdjustedAim( vector StartFireLoc )
{
	local rotator ComboAim;

	// if ready to combo, aim at shockball
	if (UTBot(Instigator.Controller) != None && CurrentFireMode == 0 && ComboTarget != None && !ComboTarget.bDeleteMe)
	{
		// use bot yaw aim, so bots with lower skill/low rotation rate may miss
		ComboAim = rotator(ComboTarget.Location - StartFireLoc);
		ComboAim.Yaw = Instigator.Rotation.Yaw;
		return ComboAim;
	}

	return Super.GetAdjustedAim(StartFireLoc);
}

simulated state WeaponFiring
{
	/**
	 * Called when the weapon is done firing, handles what to do next.
	 */
	simulated event RefireCheckTimer()
	{
		if ( bWaitForCombo && (UTBot(Instigator.Controller) != None) )
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

		Super.RefireCheckTimer();
	}
}

simulated function ImpactInfo CalcWeaponFire(vector StartTrace, vector EndTrace, optional out array<ImpactInfo> ImpactList, optional vector Extent)
{
	local ImpactInfo II;
	II = Super.CalcWeaponFire(StartTrace, EndTrace, ImpactList, Extent);
	bWasACombo = (II.HitActor != None && TProj_Bullet(II.HitActor) != none );
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


simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
	local float PathValues[3];
	local int NewPath;
	Super.SetMuzzleFlashparams(PSC);
	if (CurrentFireMode == 0)
	{
		if ( !bWasACombo )
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
		}
		else
		{
			PSC.SetFloatParameter('Path1',1.0);
			PSC.SetFloatParameter('Path2',1.0);
			PSC.SetFloatParameter('Path3',1.0);
		}
	}
	else
	{
		PSC.SetFloatParameter('Path1',0.0);
		PSC.SetFloatParameter('Path2',0.0);
		PSC.SetFloatParameter('Path3',0.0);
	}

}

simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	if (FireModeNum>1)
	{
		Super.PlayFireEffects(0,HitLocation);
	}
	else
	{
		Super.PlayFireEffects(FireModeNum, HitLocation);
	}
}

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

	AttachmentClass=class'TGame.TAttachment_M16'

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'MyWeapons.SK_WP_SigCommando'
	End Object

	InstantHitMomentum(0)=+60000.0

	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Projectile
	WeaponProjectiles(0)=class'TProj_Bullet'

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
	bInstantHit=false
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
