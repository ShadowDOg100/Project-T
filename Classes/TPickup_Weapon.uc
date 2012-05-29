class TPickup_Weapon extends TPickup
        abstract;

// Player touches pickup actor
event Touch (Actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
        local PlayerController PC;

        PC = PlayerController(Pawn(Other).Controller);

        if (PC != none)
        {
                bTouch = true;
                Player = TPawn(Other);
                Weapon = TWeapon(Player.Weapon);
                WeapSlot = getWeapSlot();
                WeapSubClass = getWeapSubClass();
                WorldInfo.Game.BroadCast(Player,"Weapon item touched");
        }
        
        /*
                        case "WP":
                                num1 = GetWeapSlot();
		                num2 = GetWeapSubClass();
		                TP.GetWeaponList(WeaponList,true);
		                if(WeaponList[num1] != None)
		                {
			             if(WeaponList[num1].GetWeaponSubClass() == num2)
			             {
				            WeaponList[num1].AddStorageAmmo(getAmmo() + getClip());
				            Destroy();
				            (TGFxHudWrapper(PC.myHUD)).ToggleWeaponPickup();
				            bTouch = false;
			             }
			             else
			             {
				            //swap weapon
			             }
		                }
		                else
		                {
			             PC.ClientMessage("PickUp");
			             Inv = spawn(touchWeap);
			             if ( Inv != None )
			             {
				            PC.ClientMessage("PickUp");
				            TP.CreateInventory( touchWeap );
				            TP.GetWeaponList(WeaponList, true);
				            WeaponList[num1].SetAmmo(getAmmo());
				            WeaponList[num1].SetClip(getClip());
				            Destroy();
				            (TGFxHudWrapper(PC.myHUD)).ToggleWeaponPickup();
				            bTouch = false;
			             }
		                }
        */
}

defaultproperties
{
        bShowHUD = true
        item = ""
}