-- Banishite Blockade
local s,id,o=GetID()
-- c210000076
function s.initial_effect(c)
	-- [Activation]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--[[
	If your opponent controls more monsters than you do,
	your opponent cannot activate Spell/Trap Cards, or monster effects.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.e2con)
	e2:SetValue(s.e2lim)
	c:RegisterEffect(e2)
	--[[
	[SOPT]
	Once per turn, during your Standby Phase, you must banish the top card of your Deck (this is not optional),
	or this card is destroyed.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.e3con)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	-- You can only control 1 “Banishite Blockade”.
	c:SetUniqueOnField(1,0,id)
end
function s.e2con(e,tp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
function s.e2lim(e,re,tp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) and (re:IsTrapEffect() or re:IsSpellEffect()))
	or re:IsActiveType(TYPE_MONSTER)
end
function s.e3con(e,tp)
	return Duel.GetTurnPlayer()==tp
end
function s.e3evt(e,tp)
	local g=Duel.GetDecktopGroup(tp,1)
	if g:GetCount()==1 and g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEUP)==1 then
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	else
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end