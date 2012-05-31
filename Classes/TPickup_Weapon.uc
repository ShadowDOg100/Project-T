class TPickup_Weapon extends TPickup
        abstract;

// Player touches pickup actor
event Touch (Actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
        local TPlayerController PC;
        super.Touch(Other, OtherComp, HitLocation, HitNormal);

        PC = TPlayerController(Pawn(Other).Controller);

        if (PC != none)
        {
                WorldInfo.Game.BroadCast(Player,"Weapon item touched");
                WeapSlot = GetWeapSlot();
                WeapSubClass = GetWeapSubClass();
                PC.setTouched(self);
        }
}

event UnTouch(Actor Other)
{
       local TPlayerController PC;
       super.UnTouch(Other);

        PC = TPlayerController(Pawn(Other).Controller);

        if (PC != none)
        {
            PC.setTouched(none);
        }
}


// Player picks up weapon
simulated function PickupWeap()
{
        local Inventory Inv;

        if (bShowHUD)
        {
                // PlaySound()
                Player.GetWeaponList(WeaponList,true);
                if(WeaponList[WeapSlot] != None)
	        {
		      if(WeaponList[WeapSlot].GetWeaponSubClass() == WeapSubClass)
		      {
			     WeaponList[WeapSlot].AddStorageAmmo(getAmmo() + getClip());
			     return;
		      }
		      else
		      {
		      	     //swap weapon
		      }
	       }
	       else
	       {
                        Inv = spawn(weapClass);
                        if (Inv != none && Player != none)
                        {
                             WorldInfo.Game.BroadCast(Player,"Weapon Picked Up");
			     Player.GiveWeapon(Inv);
			     Player.GetWeaponList(WeaponList, true);
			     WeaponList[WeapSlot].SetAmmo(ammo);
			     WeaponList[WeapSlot].SetClip(getClip());
		        }
	       }
	       
	       btouch = false;
	       Destroy();
	}
}

defaultproperties
{
        bShowHUD = true
}