class DMBigGun : DMWeapon replaces BFG9000 {
    // Fires a ripping wave of bright green plasma, dealing horrific amounts of damage. However, it eats your ammo AND health.
    default {
        Weapon.SlotNumber 7;
        Weapon.AmmoType "Cell";
        Weapon.AmmoUse 50;
        Weapon.AmmoGive 50;

        Inventory.PickupMessage "Biggest Fraggin' Gun!";
    }
    
    action void BFGTracer(double ang, bool decay = false) {
        Name beam = "DMBigBeam";
        if (decay) {
            beam = "DMDecayBeam";
        }

        A_FireProjectile(beam,ang,false);
        A_FireProjectile(beam,-ang,false);
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
                A_FireProjectile("DMBigBeam");
                for (int i = 0; i < 10; i++) {
                    BFGTracer(i * 2.5);
                    BFGTracer(i * 2.5,true);
                }
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

class DMTestBFG : DMWeapon {
    States {
        Ready:
            BFGG A 1 A_WeaponReady();
            Loop;
        Fire:
            BFGG B 1 A_FireProjectile("DMBigBeam");
        Hold:
            BFGG B 1;
            BFGG B 1 A_Refire();
            BFGG B 1;
            Goto Ready;
    }
}

class DMBigBeam : Actor { 
    double tracerad;
    Property Area : tracerad;
    Array<Actor> hits;
    Array<Actor> processed;
    Default {
        PROJECTILE;
        +FLOORHUGGER;
        +THRUACTORS;
        RenderStyle "Add";
        // Damage (100);
        Radius 2;
        DMBigBeam.Area 32;
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
            if (dist > invoker.tracerad) {continue;}
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

    void SpawnFX(double spd = 32) {
        double spread = tracerad + frandom(-2,2);
        A_SpawnItemEX("DMBeamFX",0,-spread,ceilingz - 8,0,0,-spd,0,SXF_TRANSFERPOINTERS);
        A_SpawnItemEX("DMBeamFX",0,spread,ceilingz - 8,0,0,-spd,0,SXF_TRANSFERPOINTERS);
        A_SpawnItemEX("DMBeamFX",0,-spread,0,0,0,spd,0,SXF_TRANSFERPOINTERS);
        A_SpawnItemEX("DMBeamFX",0,spread,0,0,0,spd,0,SXF_TRANSFERPOINTERS);
    }

    states {
        Spawn:
            BFS1 A 0;
            BFS1 AABB 1 Bright {
                FindHits();
                SpawnFX();
            }
            BFS1 A 0 DamageHits();
            Loop;
        
        Death:
            BFE1 ABCDEF 6 Bright;
            Stop;
    }
}

class DMDecayBeam : DMBigBeam {

    states {
        Spawn:
            BFS1 A 0;
            BFS1 AABB 1 Bright {
                FindHits();
                Vector3 ovel = invoker.vel;
                double spd = max(0,ovel.length()-0.5);
                if (spd == 0) {
                    return ResolveState("Death");
                }
                invoker.vel = ovel.unit() * spd;
                return ResolveState(null);
            }
            BFS1 A 0 DamageHits();
            BFS1 A 0 SpawnFX(8);
            Loop;
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