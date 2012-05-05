class TMuzzleFlashClass extends Object;

/** firearm muzzle flash socket */
var() name MuzzleFlashSocket;

/** muzzl flash duration */
var() float MuzzleDuration;

/** muzzle flash light class */
var(Light) class<TMuzzleLight> MuzzleLightClass;

/** muzzle flash light */
var TMuzzleLight MuzzleFlashLight;

/** muzzle flash particle component */
var(Particle) UDKParticleSystemComponent MuzzleFlashEmitter;

/** muzzle flash particle */
var ParticleSystem MuzzleFlashParticle;

/** attach muzzle flash to the weapon */
simulated function AttachTo(TFirearm Weap)
{
	local UDKSkeletalMeshComponent SkelMesh;
	
	// skeletal mesh
	if((Weap != none) && Weap.Mesh != none)
	{
		SkelMesh = UDKSkeletalMeshComponent(Weap.Mesh);
	}	
	
	// if no mesh then exit
	if(SkelMesh == none) return;
	
	// muzzle flash particle
	if((MuzzleFlashParticle != none) && MuzzleFlashEmitter == none)
	{
		// create muzzle flash component
		MuzzleFlashEmitter = new(self) class'UDKParticleSystemComponent';
		// no auto activation
		MuzzleFlashEmitter.bAutoActivate = false;
		// set depth group
		MuzzleFlashEmitter.SetDepthPriorityGroup(SDPG_Foreground);
		// set field of view
		MuzzleFlashEmitter.SetFOV(SkelMesh.FOV);
		// set component template
		MuzzleFlashEmitter.SetTemplate(MuzzleFlashParticle);
		// attach component to firearm socket
		SkelMesh.AttachComponentToSocket(MuzzleFlashEmitter, MuzzleFlashSocket);
	}
	
	// muzzle flash light
	if((MuzzleLightClass != none) && MuzzleFlashLight == non)
	{
		// create muzzle light
		MuzzleFlashLight = new(self) MuzzleLightClass;
		// attach component to firearm socket
		SkelMesh.AttachComponentToSocket(MuzzleFlashLight, MuzzleFlashSocket);
	}
}

/** detach muzzle flash from the weapon */
simulated function DetachFrom(TFirearm Weap)
{
	local UDKSkeletalMeshComponent SkelMesh;
	
	// skeletal mesh
	if((Weap != none) && Weap.Mesh != none)
	{
		SkelMesh = UDKSkeletalMeshComponent(Weap.Mesh);
	}
	
	// if no mesh then exit
	if(SkelMesh == none) return;
	
	// detach component
	if((Weap != none) && Weap.Mesh != none)
	{
		// detach muzzle flash particle
		if(MuzzleFlashEmitter != none)
		{
			Weap.Mesh.DetachComponent(MuzzleFlashEmitter);
		}
		
		// detach muzzle flash light
		if(MuzzleFlashLight != none)
		{
			Weap.Mesh.DetachComponent(MuzzleFlashLight);
		}
	}
	
	// destroy component
	MuzzleFlashEmitter = none;
}

/** activate muzzle flash */
simulated function Activate()
{
	// activate particle
	if(MuzzleFlashEmitter != none)
	{
		MuzzleFlashEmitter.ActivateSystem();
	}	
	
	// activate light
	if(MuzzleFlashLight != none)
	{
		MuzzleFlashLight.ActivateSystem();
	}
}

/** deactive muzzle flash */
simulated function Deactivate()
{
	// deactive particle
	if(MuzzleFlashEmitter != none)
	{
		MuzzleFlashEmitter.DeactivateSystem();
	}
}	

defaultproperties
{
	MuzzleFlashSocket = MuzzleFlashSocket
	MuzzleDuration = 2.0f
}