class TWeapon extends UDKWeapon
	dependson(TPlayerController)
	config(Weapon)
	abstract;

// -------------------------------------- MUZZLE FLASH
/** muzzle flash class */
var class<TMuzzleFlash> MuzzleFlashClass;
/** muzzle flash */
var TMuzzleFlash MuzzleFlash;
	
// -------------------------------------- RECOIL
/** recoil */
var(Recoil) float Recoil;
/** max recoil */
var(Recoil) float MaxRecoil;
/** aiming recoil */
var(Recoil) float AimRecoil;
/** recoil offset to use */
var rotator RecoilOffset;
/** recoil interp speed */
var(Recoil) float RecoilInterpSpeed;
/** recoil decline offset to use */
var rotator RecoilDecline;
/** decline percentage */
var(Recoil) float RecoilDeclinePct;
/** recoil decline speed */
var(Recoil) float RecoilDeclineSpeed;
/** total recoil caches */
var rotator TotalRecoil;
	
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
/** arm to arm animatoin */
var(Animations) name ArmAimAnim;
/** arm aim idl animation */
var(Animations) name ArmAimIdleAnim;
/** arm aim fire animation */
var(Animations) name ArmAimFireAnim;

// -------------------------------------- ANIMATION RATES
/** arm idle anim rate */
var float ArmIdleAnimRate;
/** arm equip anim rate */
var float ArmEquipAnimRate;
/** arm fire anim rate */
var float ArmFireAnimRate;
/** arm reload anim rate */
var float ArmReloadAnimRate;
/** arm to aim anim rate */
var float ArmAimAnimRate;
/** arm aim idle anim rate */
var float ArmAimIdleAnimRate;
/** ar aim fire anim rate */
var float ArmAimFireAnimRate;

// -------------------------------------- IRONSIGHT
/** is aiming */
var bool bIsAiming;
/** aiming FOV */
var() float AimingFOV;
/** aiming delay */
var bool bAimingDelay;

/** arms mesh vieww offset */
var() vector ArmViewOffset;
/** arms view offset during ironsight */
var() vector IronsightViewOffset;
/** aiming mesh FOV */
var() float AimingMeshFOV;
/** default mesh FOV */
var() float DefaultMeshFOV;
/** private: current mesh FOV */
var float CurrentMeshFOV;
/** private: mesh desired FOV */
var float DesiredMeshFOV;

/** replication */
replication
{
	if(bNetOwner)
		MagAmmo;
}

/** process view rotation; called by pawn */
/** process view rotation; called by Pawn */
simulated function ProcessViewRotation(float DeltaTime, out rotator out_ViewRotation, out rotator out_DeltaRot)
{
	local rotator DeltaRecoil;
	local float DeltaPitch, DeltaYaw;
	
	// perform recoil
	if(RecoilOffset != rot(0,0,0))
	{
		// interp recoil based on recoil offset
		DeltaRecoil.Pitch = RecoilOffset.Pitch - FInterpTo(RecoilOffset.Pitch, 0, DeltaTime, RecoilInterpSpeed);
		DeltaRecoil.Yaw = RecoilOffset.Yaw - FInterpTo(RecoilOffset.Yaw, 0, DeltaTime, RecoilInterpSpeed);
		
		// cache total recoil
		TotalRecoil.Pitch += DeltaRecoil.Pitch;
		
		// recoil is greater than our max recoil
		if(TotalRecoil.Pitch > MaxRecoil)
		{
			// still performing recoil
			if(DeltaRecoil.Pitch > 0)
			{
				// reduce offset as normal
				RecoilOffset -= DeltaRecoil;
				// reduce recoil but don't stop
				out_DeltaRot.Pitch += 1;
				out_DeltaRot.Yaw += DeltaRecoil.Yaw;
			}
		}
		// normal recoil
		else
		{
			RecoilDecline += DeltaRecoil;
			RecoilOffset -= DeltaRecoil;
			out_DeltaRot += DeltaRecoil;
		}
	
		// finished recoil
		if(DeltaRecoil == rot(0,0,0)) RecoilOffset = rot(0,0,0);	
	}
	else
	{
		// recoil recovery
		if(RecoilDecline != rot(0,0,0))
		{
			// revert total recoil cache
			TotalRecoil = rot(0,0,0);
			
			// interp recoil recovery based on recoil decline
			DeltaPitch = RecoilDecline.Pitch - FInterpTo(RecoilDecline.Pitch, 0, DeltaTime, RecoilDeclineSpeed);
			DeltaYaw = RecoilDecline.Yaw - FInterpTo(RecoilDecline.Yaw, 0, DeltaTime, RecoilDeclineSpeed);
			
			out_DeltaRot.Pitch -= DeltaPitch * RecoilDeclinePct;
			out_DeltaRot.Yaw -= DeltaYaw * RecoilDeclinePct;

			RecoilDecline.Pitch -= DeltaPitch;
			RecoilDecline.Yaw -= DeltaYaw;
			
			// turn of recoil recovery if low enough
			if(Abs(DeltaPitch) < 1.0)
			{
				RecoilDecline = rot(0,0,0);
			}
		}
	}
	
	// adjust mesh field of view
	AdjustMeshFOV(DeltaTime);
}

/** overloaded: fire ammunition; called by WeaponFireing state */
simulated function FireAmmunition()
{
	super.FireAmmunition();
	
	// recoil
	SetWeaponRecoil(GetWeaponRecoil());
}

/** set recoil offset */
simulated function SetWeaponRecoil(int PitchRecoil)
{
	local int YawRecoil;
	YawRecoil = (0.5 - FRand()) * PitchRecoil;
	RecoilOffset.Pitch += PitchRecoil;
	RecoilOffset.Yaw += YawRecoil;
}

/** get weapon recoil */
simulated function int GetWeaponRecoil()
{
	if(bIsAiming)
	{
		return AimRecoil;
	}
	else
	{
		return Recoil;
	}
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
	// if out of magazine ammo
	if(!HasAmmo(CurrentFireMode)) return false;
	
	// force stop fire single shots at a time
	StopFire(CurrentFireMode);
	return false;
}

/** overloaded: consume ammo */
function ConsumeAmmo( byte FireModeNum )
{
	AddMagAmmo(-ShotCost[FireModeNum]);
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
	
	// clear idle anim timer if active
	if(IsTimerActive('PlayIdleAnimation'))
	{
		ClearTimer('PlayIdleAnimation');
	}
	
	// if we can reload
	if(CanReload())
	{
		// clear weapon raising if active
		if(IsTimerActive('TimerWeaponRaising')) ClearTimer('TimerWeaponRaising');
		
		// clear weapon lowering if active
		if(IsTimerActive('TimeWeaponLowering')) ClearTimer('TimeWeaponLowering');
		
		// playing fire anim so wait until the animation has finished
		// exit and come back to this function so below logic is performed at the right time
		if(IsPlayingAnim(ArmFireAnim))
		{
			SetTimer(GetAnimTimeLeft() + 0.01, false, 'ReloadWeapon');
			return;
		}
		
		// currently aiming so lower weapon before reloading
		if(bIsAiming)
		{
			TimeWeaponLowering();
		}
		
		// playing aim animatino so wait until the animation has finished
		if(IsPlayingAnim(ArmAimAnim))
		{
			SetTimer(GetANimTimeLeft() + 0.01, false, 'TimeReload');
		}
		else
		{
			// safe to continue
			TimeReload();
		}
	}
}

/** timer: delayed time reloading */
simulated function TimeReload()
{
	GotoState('WeaponReloading');
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

/** ironsight aiming: raise weapon*/
simulated function RaiseWeapon()
{
	// if inactice then just exit
	if(IsInState('Inactive'))
	{
		return;
	}
	
	// if reloading at all then delay aiming and exit
	if(IsInState('WeaponReloading') || IsTimerActive('ReloadWeapon') || IsTimerActive('TimeReload'))
	{
		bAimingDelay = true;
		return;
	}
	
	// clear idle if active
	if(IsTimerActive('PlayIdleAnimation')) ClearTimer('PlayIdleAnimation');
	
	// clear raising if active
	if(IsTimerActive('TimeWeaponRaising')) ClearTimer('TimeWeaponRaising');
	
	// clear lowering if active
	if(IsTimerActive('TimeWeaponRaising')) ClearTimer('TimeWeaponLowering');
	
	// enable aiming delay, used in various checks
	bAimingDelay = true;
	
	// playing aim fire so just play idle after animation is finished
	if(IsPlayingAnim(ArmAimFireAnim))
	{
		SetTimer(GetAnimTimeLeft() + 0.01, false, 'PlayIdleAnimation');
	}
	// playing normal fire so continue after the animation is finished
	else if(IsPlayingAnim(ArmFireAnim))
	{
		SetTimer(GetAnimTimeLeft() + 0.01, false, 'TimeWeaponRaising');
	}
	// safe to just continue
	else
	{
		TimeWeaponRaising();
	}
}

/** ironsight aiming: lower weapon */
simulated function LowerWeapon()
{
	// if inactive then just exit
	if(IsInState('Inactive'))
	{
		return;
	}
	
	// if reloading at all then delay aiming and exit
	if(IsInState('WeaponReloading') || IsTimerActive('ReloadWeapon') || IsTimerActive('TimeReload'))
	{
		bAimingDelay = false;
		return;
	}
	
	// clear idle if active
	if(IsTimerActive('PlayIdleAnimation')) ClearTimer('PlayIdleAnimation');
	
	// clear raising if active
	if(IsTimerActive('TimeWeaponRaising')) ClearTimer('TimeWeaponRaising');
	
	// clear lowering if active
	if(IsTimerActive('TimeWeaponRaising')) ClearTimer('TimeWeaponLowering');
	
	// disable aiming delay, used in various checks
	bAimingDelay = false;
	
	// playing aim fire so continue after the animaion is finished
	if(IsPlayingAnim(ArmAimFireAnim))
	{
		SetTimer(GetAnimTimeLeft() + 0.01, false, 'TimeWeaponLowering');
	}
	// playing normal fire so continue after the animation is finished
	else if(IsPlayingAnim(ArmFireAnim))
	{
		SetTimer(GetAnimTimeLeft() + 0.01, false, 'PlayIdleAnimation');
	}
	// safe to just continue
	else
	{
		TimeWeaponLowering();
	}
}

/** time weapon raising; called by RaiseWeapon */
simulated function TimeWeaponRaising()
{
	local float AimTime;
	local float TimeDiff;
	
	// if playing aim animation, grab the difference and apply to start offset
	if(IsPlayingAnim(ArmAimAnim))
	{
		// start difference to apply
		TimeDiff = GetAnimTimeLeft();
		AimTime = PlayWeaponAnim(ArmAimAnim, ArmAimAnimRate, false, , TimeDiff);
	}
	// playing aim fire so grab the time remaining
	else if(IsPlayingAnim(ArmAimFireAnim))
	{
		AimTime = GetAnimTimeLeft() + 0.01;
	}
	// safe to normally play the animation
	else
	{
		AimTime = PlayWeaponAnim(ArmAimANim, ArmAimAnimRate, false);
	}
	
	// enable aiming
	bIsAiming = true;
	// set idle animation to aim idle animation
	ArmIdleAnims[0] = ArmAimIdleAnim;
	// set fire animation to aim fire animation
	ArmFireAnim = ArmAimFireAnim;
	// set view offset to ironsight view offset
	ArmViewOffset = IronsightViewOffset;
	// set camera field of view to aiming field of view
	SetFOV(AimingFOV);
	// set mesh field of view to aiming field of view
	SetMeshFOV(AimingMeshFOV);
	// play idle animation after aim animation finishes
	SetTimer(AimTime, false, 'PlayIdleAniation');
}

/** time weapon lowering; called by LowerWeapon */
simulated function TimeWeaponLowering()
{
	local float AimTime;
	local float TimeDiff;
	
	// if playng aim animation, grab the difference and apply to start offset
	if(IsPlayingAnim(ArmAimAnim))
	{
		// start difference to appu
		TimeDiff = GetAnimTImeLeft();
		AimTime = PlayWeaponAnim(ArmAimAnim, -ArmAimAnimRate, false, , TimeDiff);
	}
	// safe to normally play the animation
	else
	{
		AimTime = PlayWeaponAnim(ArmAimAnim, -ArmAimAnimRate, false);
	}
	
	// disable aiming
	bIsAiming = false;
	// reset arm idle animation
	ArmIdleAnims[0] = default.ArmIdleAnims[0];
	// reset arm fire animation
	ArmFireAnim = default.ArmFireAnim;
	// reset arm view offset
	ArmViewOffset = default.ArmViewOffset;
	// reset camera field of view
	SetFOV();
	// reset mesh field of view
	SetMeshFOV(DefaultMeshFOV);
	// play idle animation after aim animation finishes
	SetTimer(Abs(AimTime), false, 'PlayIdleAnimation');
}

/** set camera field of view */
simulated function SetFOV(optional float NewFOV)
{
	local TPlayerController PC;
	
	if((Instigator != none) && Instigator.Controller != none)
	{
		PC = TPlayerController(Instigator.Controller);
		if(NewFOV > 0.0)
		{
			PC.StartZoomNonlinear(NewFOV, 10.0f);
		}
		else
		{
			PC.EndZoomNonlinear(10.0f);
		}
	}
}

/** set mesh field of view */
simulated function SetMeshFOV(float NewFOV, optional bool bForceFOV)
{
	if((Mesh != none) && Mesh.bAttached)
	{
		DesiredMeshFOV = NewFOV;
	}
}

/** adjust mesh field of view; called by Tick */
simulated function AdjustMeshFOV(float DeltaTime)
{
	if((Mesh != none) && Mesh.bAttached)
	{
		if(CurrentMeshFOV != DesiredMeshFOV)
		{
			CurrentMeshFOV != FInterpTo(CurrentMeshFOV, DesiredMeshFOV, DeltaTime, 10.0f);
			UDKSkeletalMeshComponent(Mesh).SetFOV(CurrentMeshFOV);
			
			if((Firearm != none) && Firearm.Mesh != none)
			{
				UDKSkeletalMeshComponent(Firearm.Mesh).SetFOV(CurrentMeshFOV);
			}
		}
	}
}

/** overloaded: tick */
simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	
	// adjust mesh field of view
	AdjustMeshFOV(DeltaTime);
}

/** overloaded: play fire effects */
simulated function PlayFireEffects(byte FireModeNum, optional vector HitLocation)
{
	if(ArmFireAnim != '')
	{
		PlayWeaponAnim(ArmFireAnim, ArmFireAnimRate, false);
		
		// fire anim was changed to aim fire so play normal fire anim for the firearm
		if(ArmFireAnim == ArmAimFireAnim)
		{
			PlayWeaponAnim(default.ArmFireAnim, ArmFireAnimRate, false, Firearm.Mesh);
		}
		else
		{
			PlayWeaponAnim(ArmFireAnim, ArmFireAnimRate, false, Firearm.mesh);
		}
	}
}

/** state: active */
simulated state Active
{
	/** begin state */
	simulated function BeginState(name PrevState)
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
		// clear idle anim timer is still active
		if(IsTimerActive('PlayIdleAnimation'))
		{
			ClearTimer('PlayIdleAnimation');
		}
	
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
		
		// aiming delay, so begin raising
		if(bAimingDelay)
		{
			bAimingDelay = false;
			TimeWeaponRaising();
		}
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
	IronsightViewOffset = (X=40.0)
	DefaultMeshFOV = 60.0f
	CurrentMeshFOV = 60.0f
	DesiredMeshFOV = 60.0f
	AimingMeshFOV = 30.0f
	
	// -------------------------------------- RECOIL
	Recoil = 250.0;
	MaxRecoil = 1000.0
	AimRecoil = 170.0
	RecoilInterpSpeed = 10.0
	RecoilDeclinePct = 1.0
	RecoilDeclineSpeed = 10.0
	
	// -------------------------------------- ANIMATIONS
	ArmIdleAnims(0) = 1p_Idle
	ArmEquipAnim = 1p_Equip
	ArmFireAnim = 1p_Fire
	ArmReloadAnim = 1p_Reload
	ArmAimAnim = 1p_ToAim
	ArmAimIdleAnim = 1p_AimIdle
	ArmAimFireAnim = 1p_AimFire
	
	// -------------------------------------- ANIMATION RATES
	ArmIdleAnimRate = 1.0
	ArmEquipAnimRate = 1.0
	ArmFireAnimRate = 1.0
	ArmReloadAnimRate = 1.0
	ArmAimAnimRate = 1.0
	ArmAimIdleAnimRate = 1.0
	ArmAimFireAnimRate = 1.0
	
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
	
	// -------------------------------------- IRONSIGHT
	AimingFOV = 60.0f
	
	// -------------------------------------- SOCKETS
	WeaponSocket = WeaponSocket
	
	// -------------------------------------- AMMUNITION
	MagAmmo = 15
	MaxMagAmmo = 15
	AmmoCount = 15
	MaxAmmoCount = 15
	ShotCost(0) = 1
	ShotCost(1) = 0
}