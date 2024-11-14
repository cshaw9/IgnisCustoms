-- Rainbow Realm Landscapist
local s,id,o=GetID()
-- c210000061
function s.initial_effect(c)
	-- If this card battles a monster, neither can be destroyed by that battle.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.e1tgt)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	During your opponent’s Main Phase, if you control no monsters (Quick Effect): You can discard this card;
	place 1 “Area” Continuous Trap from your Deck or GY face-up on your field, but send it to the GY during the End Phase.
	You cannot Summon/Set monsters until the end of the next turn after this effect is activated.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,(id+0))
	e2:SetCondition(s.e2con)
	e2:SetCost(s.e2cst)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is in your GY:
	You can send 1 “Rainbow Realm” card, or 1 “Area” Continuous Trap, from your hand or face-up field to the GY;
	add this card to your hand.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,(id+0))
	e3:SetCost(s.e3cst)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e1tgt(e,tc)
	local c=e:GetHandler()
	return tc==c or tc==c:GetBattleTarget()
end
function s.e2con(e,tp)
	return Duel.IsMainPhase()
	and Duel.IsTurnPlayer(1-tp)
	and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.e2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsDiscardable()
	end
	
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.e2fil(c)
	return c:IsSetCard(0xce2b)
	and c:IsContinuousTrap()
	and not c:IsForbidden()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.e2fil),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	local e2a1=Effect.CreateEffect(c)
	e2a1:SetType(EFFECT_TYPE_FIELD)
	e2a1:SetCode(EFFECT_CANNOT_SUMMON)
	e2a1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2a1:SetTargetRange(1,0)
	e2a1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e2a1,tp)

	local e2a2=e2a1:Clone()
	e2a2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e2a2,tp)

	local e2a3=e2a1:Clone()
	e2a3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e2a3,tp)

	local e2a4=e2a1:Clone()
	e2a4:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e2a4,tp)

	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.e2fil),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)

			local e2b=Effect.CreateEffect(c)
			e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2b:SetCode(EVENT_PHASE+PHASE_END)
			e2b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e2b:SetCountLimit(1)
			e2b:SetLabel(fid)
			e2b:SetLabelObject(tc)
			e2b:SetCondition(s.e2bcon)
			e2b:SetOperation(s.e2bevt)
			e2b:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2b,tp)
		end
	end
end
function s.e2bcon(e)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(id)==e:GetLabel()
end
function s.e2bevt(e)
	local tc=e:GetLabelObject()
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
function s.e3fil(c)
	return ((c:IsSetCard(0xce2a))
	or (c:IsSetCard(0xce2b) and c:IsContinuousTrap()))
	and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
	and c:IsAbleToGraveAsCost()
end
function s.e3cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.e3fil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsAbleToHand()
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.e3evt(e)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end