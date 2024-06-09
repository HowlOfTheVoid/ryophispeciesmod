require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

BladedSomersault = WeaponAbility:new()

function BladedSomersault:init()
    self:reset()

    self.cooldownTimer = self.cooldownTime
end

function BladedSomersault:update(dt, fireMode, shiftHeld)
    WeaponAbility.update(self, dt, fireMode, shiftHeld)

    self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

    if self.weapon.currentAbility == nil
        and self.cooldownTimer == 0
        and self.fireMode == "alt"
        and not status.statPositive("activeMovementAbilities")
        and status.overConsumeResource("energy", self.energyUsage) then

        self:setState(self.windup)
    end
end

function BladedSomersault:windup()
    self.weapon:setStance(self.stances.windup)
    self.weapon:updateAim()

    status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})

    animator.setGlobalTag("directives", "?flipx")

    util.wait(self.stances.windup.duration, function()
        return status.resourceLocked("energy")
    end)

    self:setState(self.slash1)
end

function BladedSomersault:slash1()
    self.weapon:setStance(self.stances.slash1)
    self.weapon:updateAim()

    animator.setAnimationState("risingSwoosh", "slash1")
    animator.playSound("upswing")

    util.wait(self.stances.slash1.duration, function()
        if math.abs(world.gravity(mcontroller.position())) > 0 then
        if util.toDirection(1) ~= mcontroller.facingDirection() then
            mcontroller.setVelocity({-self.dashSpeed / 2, self.dashSpeed / 3})
        else
            mcontroller.setVelocity({self.dashSpeed / 2, self.dashSpeed / 3})
            end
        end

        local damageArea = partDamageArea("risingSwoosh")
        self.weapon:setDamage(self.damageConfig, damageArea)
    end)

    self.cooldownTimer = self.cooldownTime
    self:setState(self.slash2)
end

function BladedSomersault:slash2()
    self.weapon:setStance(self.stances.slash2)
    self.weapon:updateAim()

    animator.setAnimationState("risingSwoosh", "slash2")
    animator.playSound("upswing")

    util.wait(self.stances.slash2.duration, function()
        local damageArea = partDamageArea("risingSwoosh")
        self.weapon:setDamage(self.damageConfig, damageArea)
    end)

    self.cooldownTimer = self.cooldownTime
    self:setState(self.slash3)
end

function BladedSomersault:slash3()
    self.weapon:setStance(self.stances.slash3)
    self.weapon:updateAim()

    animator.setAnimationState("risingSwoosh", "slash3")
    animator.playSound("upswing")

    util.wait(self.stances.slash3.duration, function()
        local damageArea = partDamageArea("risingSwoosh")
        self.weapon:setDamage(self.damageConfig, damageArea)
    end)

    self.cooldownTimer = self.cooldownTime
    self:setState(self.drift)
end

function BladedSomersault:drift()
    self.weapon:setStance(self.stances.drift)
    self.weapon:updateAim()

    util.wait(self.stances.drift.duration, function()
    end)
end

function BladedSomersault:reset()
    animator.setGlobalTag("directives", "")
    status.clearPersistentEffects("weaponMovementAbility")
end

function BladedSomersault:uninit()
    self:reset()
end
