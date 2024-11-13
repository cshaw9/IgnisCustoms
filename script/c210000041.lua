--Vela, The Polygod Ark
local s,id,o=GetID()
-- c210000041
function s.initial_effect(c)
	-- 1 Tuner + 1+ non-Tuner Machine monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsRace,RACE_MACHINE),1,99)
	c:EnableReviveLimit()
	-- If this card would be sent to the GY, banish it instead.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(s.e1con)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)

	if not s.global_check then
		s.global_check=true

		local e1b=Effect.GlobalEffect()
		e1b:SetType(EFFECT_TYPE_FIELD)
		e1b:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e1b:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		e1b:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
		e1b:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(e1b,0)
	end
	-- Non-Machine “Polygod” monsters you control cannot be destroyed by battle.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.e2tgt)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is Synchro Summoned:
	You can Special Summon 1 Level 4 “Polygod” Machine monster from your hand, Deck, or banishment in face-up Defense Position.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,(id+0))
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[HOPT]
	If this Synchro Summoned card in its owner’s control leaves the field because of an opponent’s card:
	You can target 1 Beast “Polygod” monster in your banishment;
	shuffle that target into the Deck, and if you do, Special Summon this card.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,(id+1))
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
function s.e1con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e2tgt(e,c)
	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and not c:IsRace(RACE_MACHINE)
end
function s.e3fil(c,e,tp)
	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and c:IsRace(RACE_MACHINE)
	and c:GetLevel()==4
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.e3con(e,tp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
	and Duel.IsExistingMatchingCard(s.e3fil,0,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED)
end
function s.e3evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e3fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.e4con(e,tp)
	local c=e:GetHandler()

	return c:IsSummonType(SUMMON_TYPE_SYNCHRO)
	and c:IsPreviousLocation(LOCATION_MZONE)
	and c:IsPreviousControler(tp)
	and c:GetReasonPlayer()==1-tp
end
function s.e4fil(c)
	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and c:IsRace(RACE_BEAST)
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.IsExistingTarget(s.e2fil,tp,LOCATION_REMOVED,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SelectTarget(tp,s.e4fil,tp,LOCATION_REMOVED,0,1,1,nil)

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.e4evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end

	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end