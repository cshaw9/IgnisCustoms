-- Banishite Commoner
local s,id,o=GetID()
-- c210000073
function s.initial_effect(c)
	--[[
	[HOPT]
	During the Main Phase (Quick Effect): You can banish this card from your hand;
	Fusion Summon 1 “Banishite” Fusion Monster from your Extra Deck,
	by banishing monsters from your hand or field,
	and/or shuffling monsters from your banishment into the Deck/Extra Deck as material.
	]]--
	local params = {
		fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0xce3),
		matfilter=s.e1mfil,
		extrafil=s.e1sfil,
		extraop=s.e1sevt,
		extratg=s.e1stgt
	}

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,(id+0))
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e1:SetCondition(s.e1con)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(Fusion.SummonEffTG(params))
	e1:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	During the End Phase, if this card is currently banished,
	and was banished to successfully activate the previous effect this turn:
	You can add this card to your hand.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,(id+1))
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
function s.e1con(e)
	return Duel.IsMainPhase()
end
function s.e1mfil(c)
	return ((c:IsLocation(LOCATION_HAND) or c:IsOnField()) and c:IsAbleToRemove())
	or (c:IsLocation(LOCATION_REMOVED) and c:IsAbleToDeck())
end
function s.e1sfil(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.e1stgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_HAND+LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,0,tp,1)
end
function s.e1sevt(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
	if rg:GetCount()>0 then
		Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_FUSION+REASON_MATERIAL)
		sg:Sub(rg)
	end
	Fusion.BanishMaterial(e,tc,tp,sg)

	Card.ResetFlagEffect(e:GetHandler(),id)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.e2con(e)
	return e:GetHandler():GetFlagEffect(id)~=0
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then return
		e:GetHandler():IsAbleToHand()
	end

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,LOCATION_REMOVED)
end
function s.e2evt(e)
	local c=e:GetHandler()

	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end