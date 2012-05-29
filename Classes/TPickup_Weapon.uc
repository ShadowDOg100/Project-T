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
                WorldInfo.Game.BroadCast(Player,"Item touched");
                
                switch(item)
                {
                        case "":
                                return;
                        break;

                        case "WP":
                                // PlaySound()
                                Player.GetWeaponList(WeaponList,true);
                                if(WeaponList[WeapSlot] != None)
		                {
			             if(WeaponList[WeapSlot].GetWeaponSubClass() == WeapSubClass)
			             {
				            WeaponList[WeapSlot].AddStorageAmmo(getAmmo() + getClip());
				            break;
			             }
			             else
			             {
				            //swap weapon
			             }
		                }
		                else
		                {
                                        if (Weapon != none)
                                        {
				            Player.CreateInventory(weapClass);
				            Player.GetWeaponList(WeaponList, true);
				            WeaponList[WeapSlot].SetAmmo(getAmmo());
				            WeaponList[WeapSlot].SetClip(getClip());
				        }
		                }

                        break;
                }
                
                bTouch = false;
                Destroy();
        }
}

// Player untouches pickup actor
event UnTouch(Actor Other)
{
        WorldInfo.Game.BroadCast(Player,"Item untouched");
        bTouch = false;
        Player = none;
        Weapon = none;
        WeapSlot = 0;
        WeapSubClass = 0;
}

defaultproperties
{
        bShowHUD = true;
        item = "WP"
}