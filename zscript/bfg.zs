class DMBigGun : DMWeapon replaces BFG9000 {
    // Fires a ripping wave of bright green plasma, dealing horrific amounts of damage. However, it eats your ammo AND health.
    default {
        Weapon.SlotNumber 7;
        Weapon.AmmoType "Cell";
        Weapon.AmmoUse 50;
        Weapon.AmmoGive 50;

        Inventory.PickupMessage "Biggest Fraggin' Gun!";
    }
    

    States {
        Ready:
            BFGG A 1 A_WeaponReady;
            Loop;
        
        Fire:
            BFGG AAAAAAAAAA 2 A_WeaponOffset(Random(-3,3),32,WOF_INTERPOLATE);
            BFGG B 0 A_DamageSelf(ceil(health*0.1));
            BFGG B 0 A_Pain();
            BFGG BBBBB 2 {
                A_GunFlash();
                A_WeaponOffset(Random(-6,6),32,WOF_INTERPOLATE);
            }
            BFGG B 10 {
                A_StartSound("weapons/bfgx",CHAN_WEAPON);
                A_FireProjectile("DMBigBeam",-45,false);
                A_FireProjectile("DMBigBeam",-40,false);
                A_FireProjectile("DMBigBeam",-35,false);
                A_FireProjectile("DMBigBeam",-30,false);
                A_FireProjectile("DMBigBeam",-25,false);
                A_FireProjectile("DMBigBeam",-20,false);
                A_FireProjectile("DMBigBeam",-15,false);
                A_FireProjectile("DMBigBeam",-10,false);
                A_FireProjectile("DMBigBeam",-5,false);
                A_FireProjectile("DMBigBeam",0);
                A_FireProjectile("DMBigBeam",45,false);
                A_FireProjectile("DMBigBeam",40,false);
                A_FireProjectile("DMBigBeam",35,false);
                A_FireProjectile("DMBigBeam",30,false);
                A_FireProjectile("DMBigBeam",25,false);
                A_FireProjectile("DMBigBeam",20,false);
                A_FireProjectile("DMBigBeam",15,false);
                A_FireProjectile("DMBigBeam",10,false);
                A_FireProjectile("DMBigBeam",5,false);
            }
            BFGG B 10 A_StartSound("weapons/bfgf");
            BFGG AAAAAAAAAA 2 A_WeaponOffset(Random(-3,3),32,WOF_INTERPOLATE);
            Goto Ready;
        
        Flash:
            BFGF A 6 Bright A_Light1();
            BFGF B 5 Bright A_Light1();
            BFGF A 4 Bright A_Light2();
            BFGF B 3 Bright A_Light2();
            Stop;
        
        Spawn:
            BFUG A -1;
            Stop;
    }
}

class DMBigBeam : Actor { 
    Array<Actor> hits;
    Array<Actor> processed;
    Default {
        PROJECTILE;
        +FLOORHUGGER;
        +THRUACTORS;
        RenderStyle "Add";
        // Damage (100);
        Speed 30;
    }

    action void FindHits() {
        ThinkerIterator it = ThinkerIterator.Create("Actor");
        Actor mo;
        while (mo = Actor(it.next())) {
            if (mo is "DMBigBeam" || mo is "DMBeamFX") {continue;}
            if (!mo.bSHOOTABLE) {continue;}
            if (mo == target) {continue;}
            double dist = invoker.Vec2To(mo).length()-mo.radius;
            if (dist > 64) {continue;}
            if (invoker.processed.size() > 0 && invoker.processed.Find(mo) != invoker.processed.size()) {continue;}
            if (invoker.hits.size() > 0 && invoker.hits.Find(mo) != invoker.hits.size()) {continue;}

            invoker.hits.push(mo);
        }
    }

    action void DamageHits() {
        for (int i = 0; i < invoker.hits.size(); i++) {
            Actor mo = invoker.hits[i];
            mo.DamageMobj(self,target,80,"BFG");
            invoker.processed.push(mo);
            invoker.hits.delete(i);
        }
    }

    action void DoBFGTrace() {
        invoker.FindHits();
        invoker.DamageHits();
    }

    states {
        Spawn:
            BFS1 A 0;
            BFS1 AABB 1 Bright {
                FindHits();
                A_SpawnItemEX("DMBeamFX",0,frandom(-8,8),ceilingz - 8,1,0,-32,0,SXF_TRANSFERPOINTERS);
                A_SpawnItemEX("DMBeamFX",0,frandom(-8,8),0,1,0,32,0,SXF_TRANSFERPOINTERS);
                // A_SpawnItemEX("DMBeamFX",16,0,8,0,0,8);
                // A_SpawnItemEX("DMBeamFX",0,32,8,0,0,16);
                // A_SpawnItemEX("DMBeamFX",0,0,8,0,0,24);
                // A_SpawnItemEX("DMBeamFX",0,-32,8,0,0,16);
                // A_SpawnItemEX("DMBeamFX",-16,0,8,0,0,32);
            }
            BFS1 A 0 DamageHits();
            Loop;
        
        Death:
            BFE1 ABCDEF 6 Bright;
            Stop;
    }
}


class DMBeamFX : Actor {
    Default {
        +NOINTERACTION;
        Radius 32;
        Height 4;
        Speed 32;
        RenderStyle "Add";
    }

    states {
        Spawn:
            APLS AB 4;
        Death:
            APBX ABCDE 5 Bright;
            Stop;
    }
}