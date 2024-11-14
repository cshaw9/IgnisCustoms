-- Banishite Foot Soldier
local s,id,o=GetID()
-- c210000070
function s.initial_effect(c)
	--[[
	This card can attack directly, but when it does so using this effect,
	the battle damage inflicted to your opponent is equal to the number of cards in the banishments x 100.
	]]--
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1a)

	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1b:SetCondition(s.e1con)
	e1b:SetValue(s.e1val)
	c:RegisterEffect(e1b)
	-- When this card is destroyed by battle: banish this card.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(s.e2con)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1con(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()

	return Duel.GetAttackTarget()==nil
	and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2
	and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function s.e1val(e,dp)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()

	if dp==1-tp then
		return Duel.GetFieldGroupCount(tp,LOCATION_REMOVED,LOCATION_REMOVED)*100
	else
		return -1
	end
end
function s.e2con(e)
	return not c:IsLocation(LOCATION_REMOVED)
	and c:IsAbleToRemove()
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
end