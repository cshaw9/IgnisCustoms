-- Banishite King
local s,id,o=GetID()
-- c210000066
function s.initial_effect(c)
	--[[
	If this card is Special Summoned by the effect of “Banishite Knight”:
	This card gains 2000 ATK until your 3rd End Phase after this effect was activated.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(s.e1con)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	If a card(s) would be banished, its owner can add that card to their hand instead,
	and if they do, that player applies the following effects to all cards in their possession
	whose original name is the card name of the card added to the hand by this effect for the rest of this turn.
	• They cannot be placed on the field.
	• They cannot be activated, nor can their effects be activated or applied.
	• They cannot be Summoned or Set.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_SEND_REPLACE)--EFFECT_REMOVE_REDIRECT
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.e2tgt)
	e2:SetValue(s.e2val)
	c:RegisterEffect(e2)
end
function s.e1con(e,tp,eg,ep,ev,re)
	return re
	and re:GetHandler():IsCode(210000069)
end
function s.e1evt(e,tp)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetCode(EFFECT_UPDATE_ATTACK)
	e1b:SetValue(2000)
	e1b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
	c:RegisterEffect(e1b)
end
function s.e2fil(c,tp)
	return c:IsLocation(LOCATION_ALL)
	and c:GetDestination()==LOCATION_REMOVED
	and c:IsAbleToHand()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		eg:IsExists(s.e2fil,1,nil,tp)
	end
	
	local c=e:GetHandler()
	if Duel.SelectEffectYesNo(tp,c) then
		local g=eg:Filter(s.e2fil,nil,tp)
		local ct=g:GetCount()
		
		if ct>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			g=g:Select(tp,1,ct,nil)
		end
		
		for tc in g:Iter() do
			local e2b1=Effect.CreateEffect(c)
			e2b1:SetType(EFFECT_TYPE_SINGLE)
			e2b1:SetCode(EFFECT_TO_DECK_REDIRECT)
			e2b1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2b1:SetValue(LOCATION_HAND)
			e2b1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2b1)
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~RESET_TOHAND+RESET_PHASE+PHASE_END,0,1)
		end
		
		local e2b2=Effect.CreateEffect(c)
		e2b2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2b2:SetCode(EVENT_TO_HAND)
		e2b2:SetCountLimit(1)
		e2b2:SetCondition(s.e2bcon)
		e2b2:SetOperation(s.e2bevt)
		e2b2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2b2,tp)

		return true
	else
		return false
	end
end
function s.e2val(e,c)
	return false
end
function s.e2bfil(c)
	return c:GetFlagEffect(id)~=0
end
function s.e2bcon(e,tp,eg)
	return eg:IsExists(s.e2bfil,1,nil)
end
function s.e2bevt(e,tp,eg)
	local g=eg:Filter(s.e2bfil,nil)

	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end