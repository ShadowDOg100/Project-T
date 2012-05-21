class TPickup extends Actor;

// Light Environment
var() const editconst DynamicLightEnvironmentComponent LightEnvironment;

// Replenish Ammo, Health, Armor
var int value;
var int restore;

// Player
var PlayerController PC;

// Weapon
var class<TWeapon> touchWeap;
var int WeapSlot;
var int WeapSubClass;

// Touch
var bool bTouch;

// Tell what item
var string item;

// Ammunition
var() int ammo;
var int clipAmmo;

/** Weapons **/
// get weapon inventory slot
function int getWeapSlot()
{
	return 0;
}

// get weapon subclass
function int getWeapSubClass()
{
	return 0;
}

// get weapon ammo
function int getAmmo()
{
	return 0;
}

// get weapon clip
function int getClip()
{
	return 0;
}

/** Pawn **/
// get pawn health
function int GetHealth(Pawn P)
{
        return TPawn(P).getHealth();
}

// set pawn health
function SetHealth(Pawn P, int value)
{
        if (value <= 100)
                TPawn(P).setHealth(value);
        else
                TPawn(P).setHealth(100);
}

// get pawn armor
function int GetArmor(Pawn P)
{
        return TPawn(P).getArmor();
}

// set pawn armor
function SetArmor(Pawn P, int value)
{
        if (value <= 100)
                TPawn(P).setArmor(value);
        else
        {
                TPawn(P).setArmor(100);
        }
}

// Touch
function SetTouch(bool touch, optional class<TWeapon> weap, optional TPickup Pickup, optional string str)
{
        bTouch = touch;
        PickupActor = Pickup;
        item = str;

        switch(item)
        {
                case "HP":
                        (TGFxHudWrapper(PC.myHUD)).ToggleItemPickup();
                break;
                
                case "AP":
                        (TGFxHudWrapper(PC.myHUD)).ToggleItemPickup();
                break;

                case "WP":
                        touchWeap = weap;
                        (TGFxHudWrapper(PC.myHUD)).ToggleWeaponPickup();
                break;
        }
}

// Pickup Weapon or Item
exec function PickUp()
{
        local int value;

	local Inventory Inv;
	local TPawn TP;
	local int num1, num2;
	local array<TWeapon> WeaponList;
	TP = TPawn(PC.Pawn);
	PC.ClientMessage("PickUp");
	if(bTouch)
	{
                switch(item)
                {
                        case "HP":
                                value = PickupActor.GetHealth(PC.Pawn) + 50;
                                PickupActor.SetHealth(PC.Pawn,value);
                                PickupActor.Destroy();
                                (TGFxHudWrapper(PC.myHUD)).ToggleItemPickup();
                                bTouch = false;
                        break;
                        
                        case "AP":
                                value = PickupActor.GetArmor(PC.Pawn) + 100;
                                PickupActor.SetArmor(PC.Pawn,value);
                                PickupActor.Destroy();
                                (TGFxHudWrapper(PC.myHUD)).ToggleItemPickup();
                                bTouch = false;
                        break;
                        
                        case "WP":
                                num1 = PickupActor.GetWeapSlot();
		                num2 = PickupActor.GetWeapSubClass();
		                TP.GetWeaponList(WeaponList,true);
		                if(WeaponList[num1] != None)
		                {
			             if(WeaponList[num1].GetWeaponSubClass() == num2)
			             {
				            WeaponList[num1].AddStorageAmmo(PickupActor.getAmmo() + PickupActor.getClip());
				            PickupActor.Destroy();
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
			             PlayerOwner.ClientMessage("PickUp");
			             Inv = spawn(touchWeap);
			             if ( Inv != None )
			             {
				            PlayerOwner.ClientMessage("PickUp");
				            TP.CreateInventory( touchWeap );
				            TP.GetWeaponList(WeaponList, true);
				            WeaponList[num1].SetAmmo(PickupActor.getAmmo());
				            WeaponList[num1].SetClip(PickupActor.getClip());
				            PickupActor.Destroy();
				            (TGFxHudWrapper(PC.myHUD)).ToggleWeaponPickup();
				            bTouch = false;
			             }
		                }
                        break;
                }
	}
}

defaultproperties
{
}