-- Banishite Lord
local s,id,o=GetID()
-- c210000071
function s.initial_effect(c)
	-- Any card sent to the GY is banished instead.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0xff,0xff)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTarget(s.e1tgt)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If you control “Banishite Lady”: You can Special Summon this card from your hand.
	]]--
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can add 1 “Banishite” Spell/Trap from your Deck to your hand.
	]]--
	--[[
	[HOPT]
	When a monster on the field activates its effect (Quick Effect):
	You can banish this card you control (until the End Phase); negate that effect.
	]]--
end
function s.e1tgt(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.IsPlayerCanRemove(tp,c)
end