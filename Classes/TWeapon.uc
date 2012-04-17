class TWeapon extends UDKWeapon
	dependson(TPlayerController)
	config(Weapon)
	abstract;

// -------------------------------------- INVENTORY
/** inventory slot */
var int InventorySlot;
/** weapon sub class */
var int WeaponSubClass;
	
// -------------------------------------- AMMUNITION
/** magazine ammunition */
var(Ammo) int MagAmmo;
/** Max magazine ammunition */
var(Ammo) int MaxMagAmmo;
/** Max ammo storage */
var(Ammo) int MaxAmmoCount;
/** shot cost */
var(Ammo) array<int> ShotCost;
	
// -------------------------------------- SOCKETS
/** firearm socket */
var(Sockets) name WeaponSocket;

// -------------------------------------- FIREARM
/** firearm class */
var(Firearm) class<TFirearm> FirearmClass;
/** firearm */
var(Firearm) TFirearm Firearm;
	
// -------------------------------------- ANIMATIONS
/** arm idle animations */
var(Animations) array<name> ArmIdleAnims;
/** arm equip animation */
var(Animations) name ArmEquipAnim;
/** arm fire animation */
var(Animations) name ArmFireAnim;
/** arm reload animation */
var(Animations) name ArmReloadAnim;

// -------------------------------------- ANIMATION RATES
/** arm idle anim rate */
var float ArmIdleAnimRate;
/** arm equip anim rate */
var float ArmEquipAnimRate;
/** arm fire anim rate */
var float ArmFireAnimRate;
/** arm reload anim rate */
var float ArmReloadAnimRate;

/** arms mesh vieww offset */
var() vector ArmViewOffset;

/** replication */
replication
{
	if(bNetOwner)
		MagAmmo;
}

/** get get weapon sub class */
simulated function int GetWeaponSubClass()
{
	return WeaponSubClass;
}

/** get inventory slot */
simulated function int GetInventorySlot()
{
	return InventorySlot;
}

/** get ammo count */
simulated function int GetAmmoCount()
{
	return AmmoCount;
}

/* get magazine ammo count */
simulated function int GetClipCount()
{
	return MagAmmo;
}

/* set ammo */
simulated function setAmmo(int ammo)
{
	AmmoCount = ammo;
}

/* set clip */
simulated function setClip(int clip)
{
	MagAmmo = clip;
}

/** add/remove magazine ammunition */
simulated function int AddMagAmmo(int Amount)
{
	MagAmmo = Clamp(MagAmmo + Amount, 0, MaxMagAmmo);
	if(MagAmmo < 0) MagAmmo = 0;
	
	return MagAmmo;
}

/** add/remove ammunition storage */
simulated function int AddStorageAmmo(int Amount)
{
	AmmoCount = Clamp(AmmoCount + Amount, 0 , MaxAmmoCount);
	if(AmmoCount < 0) AmmoCount = 0;
	
	return AmmoCount;
}

/** weapon has magazine ammunition */
simulated function bool HasMagazineAmmo()
{
	return (MagAmmo > 0);
}

/** weapon has storage ammunition */
simulated function bool HasStorageAmmo()
{
	return (AmmoCount > 0);
}

/** ammunition storage is maxed out */
simulated function bool AmmoMaxed()
{
	return (AmmoCount >= MaxAmmoCount);
}

/** magazin is maxed out */
simulated function bool IsMagFull()
{
	return (MagAmmo >= MaxMagAmmo);
}

/** overloaded: has any amunition */
//@notes: called by GetWeaponRating and Active.BeginState
simulated function bool HasAnyAmmo()
{
	return (AmmoCount > 0 || MagAmmo > 0);
}

/** overloaded: has ammo */
//@notes: called by ShouldRefire and Active.BeginState
simulated function bool HasAmmo(byte FireModeNum, optional int Amount)
{
	if(Amount == 0) return (MagAmmo >= ShotCost[FireModeNum]);
	
	return (MagAmmo == Amount);
}

/** overloaded: should refire */
simulated function bool ShouldRefire()
{
	// if out of magaine ammo
	if(!HasAmmo(CurrentFireMode)) return false;
	
	// force stop fire for single shots at a time
	StopFire(CurrentFireMode);
	return false;
}

/** reload weapon */
simulated function ReloadWeapon()
{
	// weapon is inactive or already reloading so return
	if(IsInState('Inactive') || IsInState('WeaponReloading'))
	{
		return;
	}
	
	// if we are client replicate to the server
	if(Role < ROLE_Authority)
	{
		ServerReloadWeapon();
	}
	
	// if we can reload
	if(CanReload())
	{
		// begin reloading
		GotoState('WeaponReloading');
	}
}

/** client to server: reload weapon */
reliable server function ServerReloadWeapon()
{
	ReloadWeapon();
}

/** can the weapon reload */
simulated function bool CanReload()
{
	// check if we have storage ammo and our mag isn't already full
	if(HasStorageAmmo() && !IsMagFull())
	{
		// can add further checks such as jumping or sprinting
		return true;
	}
	
	return false;
}

/** play weapon animation */
simulated function float PlayWeaponAnim(name AnimName, float Rate, optional bool bLooping, optional SkeletalMeshComponent SkelMesh, optional float StartTime)
{
	local AnimNodeSequence AnimNode;
	
	// get anim node sequence
	if(SkelMesh != none)
	{
		AnimNode = AnimNodeSequence(SkelMesh.Animations);
	}
	else
	{
		AnimNode = GetWeaponAnimNodeSeq();
	}
	
	// no sequence so return
	if(AnimNode == none) return 0.01;
	
	// set anim
	if(AnimNode.AnimSeq != none || AnimNode.AnimSeq.SequenceName != AnimName)
	{
		AnimNode.SetAnim(AnimName);
	}
	
	// no anim so return
	if(AnimNode.AnimSeq == none) return 0.01;
	
	// play anim
	AnimNode.PlayAnim(bLooping, Rate, StartTime);
	
	// return anim length
	return AnimNode.GetAnimPlaybackLength();
}

/** play weapon animation by duration */
simulated function PlayWeaponByDuration(name AnimName, float Duration, optional bool bLooping, optional SkeletalMeshComponent SkelMesh, optional float StartTime)
{
	local float Rate;
	
	// use mesh if none passed in
	if((SkelMesh == none) && Mesh != none)
	{
		SkelMesh = SkeletalMeshComponent(Mesh);
	}
	
	// if no mesh or anim then return
	if(SkelMesh == none || AnimName == '') return;
	
	// get anim rate by duration
	Rate = SkelMesh.GetAnimRateByDuration(AnimName, Duration);
	
	// play anim by duration
	PlayWeaponAnim(AnimName, Rate, blooping, SkelMesh, StartTime);
}

/** currently playing an animation */
simulated function bool IsPlayingAnim(name AnimName, optional bool bIsLooping, optional SkeletalMeshComponent SkelMesh)
{
	local AnimNodeSequence AnimNode;
	
	// get anim node sequence
	if(SkelMesh != none)
	{
		AnimNode = AnimNodeSequence(SkelMesh.Animations);
	}
	else
	{
		AnimNode = GetWeaponAnimNodeSeq();
	}
	
	// no sequence so return
	if(AnimNode == none) return false;
	
	// not playing, or anim nname doesn't match, or is looping but the animation isn't looping
	if(!AnimNode.bPlaying || AnimNode.AnimSeq.SequenceName != AnimName || bIsLooping && !AnimNode.bLooping)
	{
		return false;
	}
	
	return true;
}

/** currently playing any animation */
simulated function bool IsPlayingAnims(optional SkeletalMeshComponent SkelMesh, optional bool bLooping)
{
	local AnimNodeSequence AnimNode;
	
	// get anim node sequence
	if(SkelMesh != none)
	{
		AnimNode = AnimNodeSequence(SkelMesh.Animations);
	}
	else
	{
		AnimNode = GetWeaponAnimNodeSeq();
	}
	
	// no sequence so return
	if(AnimNode == none) return false;
	
	// not playing, or anim nname doesn't match, or is looping but the animation isn't looping
	if(bLooping && AnimNode.bLooping)
	{
		return false;
	}
	
	return AnimNode.bPlaying;
}

/** get animation length */
simulated function float GetAnimLength(name AnimName, optional SkeletalMeshComponent SkelMesh)
{
	local AnimNodeSequence AnimNode;
	
	// get anim node sequence
	if(SkelMesh != none)
	{
		AnimNode = AnimNodeSequence(SkelMesh.Animations);
	}
	else
	{
		AnimNode = GetWeaponAnimNodeSeq();
	}
	
	// no sequence so return
	if(AnimNode == none) return 0.01;
	
	AnimNode.SetAnim(AnimName);
	return AnimNode.GetAnimPlaybackLength();
}

/** get animations time remaining */
simulated function float GetAnimTimeLeft(optional SkeletalMeshComponent SkelMesh)
{
	local AnimNodeSequence AnimNode;
	
	// get anim node sequence
	if(SkelMesh != none)
	{
		AnimNode = AnimNodeSequence(SkelMesh.Animations);
	}
	else
	{
		AnimNode = GetWeaponAnimNodeSeq();
	}
	
	// no sequence so return
	if(AnimNode == none) return 0.01;
	
	return AnimNode.GetTimeLeft();
}

/** overloaded: align the arm mesh player view */
simulated event SetPosition(UDKPawn Holder)
{
	local vector ViewOffset, DrawOffset;
	local rotator NewRotation;
	
	// if we're not in first person just return
	if(!Holder.IsFirstPerson()) return;
	
	// set view offset based on our arm view offset
	ViewOffset = ArmViewOffset;
	
	// calculate location and rotation
	DrawOffset.Z = TPawn(Holder).GetEyeHeight();
	DrawOffset = DrawOffset + (ViewOffset >> Holder.Controller.Rotation);
	DrawOffset = Holder.Location + DrawOffset;
	
	if(Holder.Controller == none)
	{
		NewRotation = Holder.GetBaseAimRotation();
	}
	else
	{
		NewRotation = Holder.Controller.Rotation;
	}
	
	// set location/rotation/base
	SetLocation(DrawOffset);
	SetRotation(NewRotation);
	SetBase(Holder);
}

/** overloaded: attach mesh */
simulated function AttachWeaponTo(SkeletalMeshComponent SkelMesh, optional name SocketName)
{
	super.AttachWeaponTo(SkelMesh, SocketName);
	
	if((Mesh != none) && !Mesh.bAttached)
	{
		AttachComponent(Mesh);
		AttachFirearm();
		SetHidden(false);
	}
}

/** attach firearm to arms */
simulated function AttachFirearm()
{
	local TPawn P;
	
	if(Instigator != none)
	{
		P = TPawn(Instigator);
		
		if(FirearmClass != none)
		{
			Firearm = Spawn(FirearmClass);
			
			if(Firearm != none)
			{
				Firearm.AttachTo(self, P);
				Firearm.ChangeVisibility(false);
			}
		}
	}
}

/** overloaded: detach arms */
simulated function DetachWeapon()
{
	super.DetachWeapon();
	
	if((Mesh != none) && Mesh.bAttached)
	{
		DetachFirearm();
		DetachComponent(Mesh);
	}
	
	SetBase(none);
	SetHidden(true);
}

/** detach firearm to arms */
simulated function DetachFirearm()
{
	if(Firearm != none)
	{
		Firearm.DetachFrom();
	}
}

/** time weapon equiping */
simulated function TimeWeaponEquipping()
{
	local float EquipAnimTime;
	
	// attach weapon
	if(Instigator !=none)
	{
		// attach arm mesh
		AttachWeaponTo(Instigator.Mesh);
		
		// play arm equip animation
		if(ArmEquipAnim != '')
		{
			// play animation and return anim length for equip timer
			EquipAnimTime = PlayWeaponAnim(ArmEquipAnim, ArmEquipAnimRate, false);
			SetTimer(EquipAnimTime, false, 'WeaponEquipped');
		}
	}
}

/** timed weapon reloading */
simulated function TimeWeaponReload()
{
	local float ReloadAnimTime;
	
	// make sure this timer isn't already active
	if(!IsTimerActive('Reload'))
	{
		// play reload animation and get the animation length
		ReloadAnimTime = PlayWeaponAnim(ArmReloadAnim, ArmReloadAnimRate, false);
		// play reload animation on the weapon mesh as well
		PlayWeaponAnim(ArmReloadAnim, ArmReloadAnimRate, false, Firearm.Mesh);
		// set the timer based on the anim length and actually reload
		SetTimer(ReloadAnimTime, false, 'Reload');
	}
}

/** is weapon reloading */
simulated function bool IsReloading()
{
	return false;
}

/** reload */
simulated function Reload()
{
	if(CanReload())
	{
		if(IsTimerActive('Reload'))
		{
			ClearTimer('Reload');
		}
	}
}

/** overloaded: play fire effects */
simulated function PlayFireEffects(byte FireModeNum, optional vector HitLocation)
{
	if(ArmFireAnim != '')
	{
		PlayWeaponAnim(ArmFireAnim, ArmFireAnimRate, false);
		PlayWeaponAnim(ArmFireAnim, ArmFireAnimRate, false, Firearm.mesh);
	}
}

/** state: active */
simulated state Active
{
	/** begin state */
	simulated function beginState(name PrevState)
	{
		// playing any animations
		if(IsPlayingAnims())
		{
			// already playing an animation so get the time left and set the timer
			SetTimer(GetAnimTimeLeft(), false, 'PlayIdleAnimation');
		}
		else
		{
			// not playing an anim so play the idle anim
			PlayIdleAnimation();
		}
		
		super.BeginState(PrevState);
	}
	
	/** end state */
	simulated function EndState(name NextState)
	{
		if(IsTimerActive('PlayIdleAnimation'))
		{
			ClearTimer('PlayIdleAnimation');
		}
		
		super.EndState(NextState);
	}
	
	/** play idle animation */
	simulated function PlayIdleAnimation()
	{
		local int i;
		
		if(WorldInfo.NetMode != NM_DedicatedServer && ArmIdleAnims.Length > 0)
		{
			i = Rand(ArmIdleAnims.Length);
			PlayWeaponAnim(ArmIdleAnims[i], ArmIdleAnimRate, true);
		}
	}
}

/** state: weapon reloading */
simulated state WeaponReloading
{
	/** begin state */
	simulated function BeginState(name PrevState)
	{
		// playing anims except looping anims (will be our idle anim)
		if(IsPlayingAnims(, true))
		{
			SetTimer(GetAnimTimeLeft(), false, 'TimeWeaponReload');
		}
		else
		{
			TimeWeaponReload();
		}
	}
	
	/** begin fire */
	simulated function BeginFire(byte FireModeNum)
	{
		// don't allow firing
		return;
	}
	
	/** end state */
	simulated function EndState(name NextState)
	{
		// clear our timers
		ClearTimer('TimeWeaponReload');
		ClearTimer('Reload');
	}
	
	/** is weapon reloading */
	simulated function bool IsReloading()
	{
		return true;
	}
	
	/** reload */
	simulated function Reload()
	{
		local int Ammo;
		
		if(MagAmmo < 1)
		{
			Ammo = Min(MaxMagAmmo, AmmoCount);
			AddMagAmmo(Ammo);
			AddStorageAmmo(-Ammo);
		}
		else
		{
			Ammo = Abs(MaxMagAmmo - MagAmmo);
			Ammo = Min(AmmoCount, Ammo);
			AddMagAmmo(Ammo);
			AddStorageAmmo(-Ammo);
		}
		
		// return to acctive state
		GotoState('Active');
	}
}

defaultproperties
{
	// anim sequence
	begin object class=AnimNodeSequence name=MeshSequenceA
		bCauseActorAnimEnd = true
	end object

	// arms mesh
	begin object class=UDKSkeletalMeshComponent name=ArmsMeshComp
		SkeletalMesh = SkeletalMesh'T.Mesh.Char_Arms'
		AnimSets(0) = AnimSet'T.Anims.Char_Arm_Anims'
		DepthPriorityGroup = SDPG_Foreground
		bOnlyOwnerSee = true
		bOverrideAttachmentOwnerVisibility = true
		CastShadow = false;
		FOV = 60.0f
		Animations = MeshSequenceA
		bPerBoneMotionBlur = true
		bAcceptsStaticDecals = false
		bAcceptsDynamicDecals = false
		bUpdateSkelWhenNotRendered = false
		bComponentUseFixedSkelBounds = true
	end object
	Mesh = ArmsMeshComp
	
	// mesh settings
	ArmViewOffset = (X=43.0)
	
	// -------------------------------------- ANIMATIONS
	ArmIdleAnims(0) = 1p_Idle
	ArmEquipAnim = 1p_Equip
	ArmFireAnim = 1p_Fire
	ArmReloadAnim = 1p_Reload
	
	// -------------------------------------- ANIMATION RATES
	ArmIdleAnimRate = 1.0
	ArmEquipAnimRate = 1.0
	ArmFireAnimRate = 1.0
	ArmReloadAnimRate = 1.0
	
	// -------------------------------------- WEAPON SETTINGS
	bInstantHit = true
	FiringStatesArray(0) = WeaponFiring
	WeaponFireTypes(0) = EWFT_InstantHit
	ShouldFireOnRelease(0) = 0
	FireInterval(0) = 0.1
	Spread(0) = 0.05
	InstantHitDamage(0) = 10.0
	InstantHitMomentum(0) = 1.0
	InstantHitDamageTypes(0) = class'DamageType'
	InventorySlot = 0;
	WeaponSubClass = 0;
	
	// -------------------------------------- SOCKETS
	WeaponSocket = WeaponSocket
	
	// -------------------------------------- AMMUNITION
	MagAmmo = 15
	MaxMagAmmo = 15
	AmmoCount = 15
	MaxAmmoCount = 99
	ShotCost(0) = 1
	ShotCost(1) = 0
}