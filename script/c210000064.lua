-- Banishite Dragon
local s,id,o=GetID()
-- c210000064
function s.initial_effect(c)
	-- Cannot be Normal Summoned/Set.
	c:EnableReviveLimit()
	-- Must first be Special Summoned (from your hand) by shuffling 5 “Banishite” monsters from your banishment into the Deck/Extra Deck.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.e1con)
	e1:SetOperation(s.e1evt)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- When Summoned this way: Banish all Defense Position monsters on the field.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)

	e1:SetLabelObject(e2)
	-- Cannot be destroyed by card effects.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- Neither player can Set monsters, nor Special Summon monsters in Defense Position.
	local e4a=Effect.CreateEffect(c)
	e4a:SetType(EFFECT_TYPE_FIELD)
	e4a:SetCode(EFFECT_CANNOT_MSET)
	e4a:SetRange(LOCATION_MZONE)
	e4a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4a:SetTargetRange(1,1)
	c:RegisterEffect(e4a)

	local e4b=Effect.CreateEffect(c)
	e4b:SetType(EFFECT_TYPE_FIELD)
	e4b:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e4b:SetRange(LOCATION_MZONE)
	e4b:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4b:SetTargetRange(1,1)
	e4b:SetValue(POS_ATTACK)
	c:RegisterEffect(e4b)
	--[[
	[HOPT]
	During your Main Phase 2: You can activate 1 of these effects.
	• This card loses 1000 ATK, and if it does, banish 1 card on the field.
	• This card gains 1000 ATK, and if it does, it cannot attack directly during your next Battle Phase.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,0})
	e5:SetCondition(s.e5con)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
end
function s.e1fil(c)
	return c:IsSetCard(0xce3)
	and c:IsMonster()
	and c:IsFaceup()
	and c:IsAbleToDeckAsCost()
end
function s.e1con(e,c)
	if c==nil then return true end
	local tp=c:GetControler()

	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_REMOVED,0,5,nil)
end
function s.e1evt(e,tp)
	local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_REMOVED,0,nil)
	if g:GetCount()>=5 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sel=Group.Select(g,tp,5,5,nil)
		Duel.SendtoDeck(sel,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
function s.e2con(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.e2fil(c)
	return c:IsDefensePos()
	and c:IsAbleToRemove()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	local g=Duel.GetMatchingGroup(s.e2fil,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,g:GetCount())
end
function s.e2evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.GetMatchingGroup(s.e2fil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)

	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.e5con(e)
	return Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=e:GetHandler():GetAttack()>=1000 and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)>0
	local b2=true

	if chk==0 then
		return b1 or b2
	end

	local sel=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(sel)
end
function s.e5evt(e,tp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==1 then
		if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsImmuneToEffect(e) then
			local e5a=Effect.CreateEffect(c)
			e5a:SetType(EFFECT_TYPE_SINGLE)
			e5a:SetCode(EFFECT_UPDATE_ATTACK)
			e5a:SetValue(-1000)
			e5a:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e5a)

			if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
				local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
				if g:GetCount()>0 then
					Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
				end
			end
		end
	else
		if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsImmuneToEffect(e) then
			local e5b1=Effect.CreateEffect(c)
			e5b1:SetType(EFFECT_TYPE_SINGLE)
			e5b1:SetCode(EFFECT_UPDATE_ATTACK)
			e5b1:SetValue(1000)
			e5b1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e5b1)

			if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
				local e5b2=Effect.CreateEffect(c)
				e5b2:SetType(EFFECT_TYPE_SINGLE)
				e5b2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e5b2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e5b2:SetReset(RESET_EVENT+RESETS_STANDARD) --+RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN
				c:RegisterEffect(e5b2)
			end
		end
	end
end