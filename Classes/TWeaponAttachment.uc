class TWeaponAttachment extends Actor
	dependson(TPawn);

// ---------------------- IMPACT EFFECTS
/** impact effects */
var array<MaterialImpactEffect> ImpactEffects;
/** default impact effect */
var MaterialImpactEffect DefaultImpactEffect;

/** attach third person weapon mesh to pawn */
simulated function AttachTo(TPawn P)
{

}

/** detach third person weapon mesh from pawn mesh */
simulated function DetachFrom(SkeletalMeshComponent SkelComp)
{

}

/** change third person weapon mesh visibility */
simulated function ChangeVisibility(bool bIsVisible)
{

}

/** play impact effects */
simulated function PlayImpactEffects(vector HitLocation)
{
	local vector NewHitLoc, HitNorm;
	local Actor HitActor;
	local TraceHitInfo HitInfo;
	local MaterialImpactEffect ImpactEffect;
	local int DecalMaterialsLength;
	local MaterialInterface MI;
	local MaterialInstanceTimeVarying MITV_Decal;
	local TPawn P;
	
	// cache pawn
	P = TPawn(Owner);

	if(P != none)
	{
		// calculate normal
		HitNorm = Normal(Owner.Location - HitLocation);

		// trace
		HitActor = Trace(NewHitLoc, HitNorm, (HitLocation - (HitNorm * 32)), HitLocation + (HitNorm * 32), true, , HitInfo, TRACEFLAG_Bullet);

		// get impact effect
		ImpactEffect = GetImpactEffect(HitInfo.PhysMaterial);

		// hit an actor and not a pawn
		if((HitActor != none) && Pawn(HitActor) == none)
		{
			// play impact effect sound
			if(ImpactEffect.Sound != none)
			{
				PlaySound(ImpactEffect.Sound, true, , , HitLocation);
			}

			// if not dropped detail
			if(!WorldInfo.bDropDetail)
			{
				// cache length
				DecalMaterialsLength = ImpactEffect.DecalMaterials.Length;

				// has decal materials
				if(DecalMaterialsLength > 0)
				{
					// material from random decal materials
					MI = ImpactEffect.DecalMaterials[Rand(DecalMaterialsLength)];

					if(MI != none)
					{
						// terrain decal
						if(MaterialInstanceTimeVarying(MI) != none)
						{
							if(Terrain(HitActor) == none)
							{
								MITV_Decal = new(self) class'MaterialInstanceTimeVarying';
								MITV_Decal.SetParent(MI);
								WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal, HitLocation, rotator(-HitNorm), ImpactEffect.DecalWidth, ImpactEffect.DecalHeight, 10.0, false, , HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex);
								MITV_Decal.SetScalarStartTime(ImpactEffect.DecalDissolveParamName, ImpactEffect.DurationOfDecal);
							}
						}
						else
						{
							// spawn decal
							WorldInfo.MyDecalManager.SpawnDecal(MI, HitLocation, rotator(-HitNorm), ImpactEffect.DecalWidth, ImpactEffect.DecalHeight, 10.0, false, , HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex);
						}
					}
				}

				// play particle effect if available
				if(ImpactEffect.ParticleTemplate != none)
				{
					WorldInfo.MyEmitterPool.SpawnEmitter(ImpactEffect.ParticleTemplate, HitLocation, rotator(HitNorm), HitActor);
				}
			}
		}
		else
		{
			// hit nothing or a pawn
		}
	}
}

/** get impact effect based on material */
simulated function MaterialImpactEffect GetImpactEffect(PhysicalMaterial HitMaterial)
{
	local int i;
	local TPhysicalMaterialProperty PhysicalProperty;
	
	// get physical material
	if(HitMaterial != none)
	{
		PhysicalProperty = TPhysicalMaterialProperty(HitMaterial.GetPhysicalMaterialProperty(class'TPhysicalMaterialProperty'));
	}
	
	// physical material has a material type
	if((PhysicalProperty != none) && PhysicalProperty.MaterialType != 'None')
	{
		// find material type in our impact effects array
		i = ImpactEffects.Find('MaterialType', PhysicalProperty.MaterialType);
		
		// found impact based on material type
		if(i != -1)
		{
			// return impact effect based on material type
			return ImpactEffects[i];
		}
		
		// none was found so return default
		return DefaultImpactEffect;
	}
	
	// all failed so return default
	return DefaultImpactEffect;
}

defaultproperties
{
	DefaultImpactEffect=(DecalMaterials=(MaterialInstanceConstant'Tutorial_Decal.Materials.Bullet_Decal2_INST', MaterialInstanceConstant'Tutorial_Decal.Materials.Bullet_Decal3_INST', MaterialInstanceConstant'Tutorial_Decal.Materials.Bullet_Decal4_INST', MaterialInstanceConstant'Tutorial_Decal.Materials.Bullet_Decal5_INST', MaterialInstanceConstant'Tutorial_Decal.Materials.Bullet_Decal6_INST'),ParticleTemplate=ParticleSystem'Tutorial_ImpactParticle.Particles.Pistol_ImpactParticle',DurationOfDecal=4.000000,DecalDissolveParamName="DissolveAmount",DecalWidth=8.000000,DecalHeight=8.000000)
}
