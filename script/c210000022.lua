--Polygod Dimension
local s,id,o=GetID()
-- c210000022
function s.initial_effect(c)
	-- [Activation]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- If this card would be sent to the GY, banish it instead.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(s.e2con)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)

	if not s.global_check then
		s.global_check=true

		local e2b=Effect.GlobalEffect()
		e2b:SetType(EFFECT_TYPE_FIELD)
		e2b:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e2b:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		e2b:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
		e2b:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(e2b,0)
	end
	--[[
	[SOPT]
	Once per turn: You can Special Summon 1 “Polygod” monster from your banishment.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	Once per turn, if a “Polygod” monster(s) changes its battle position: You can change the battle position of 1 other monster on the field.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHANGE_POS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1) -- EFFECT_COUNT_CODE_CHAIN
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
function s.e2con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e3fil(c,e,tp)
	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e3con(e,tp)
	local g=Duel.GetMatchingGroup(s.e3fil,tp,LOCATION_REMOVED,0,nil,e,tp)

	return Duel.GetLocationCount(tp,LOCATION_MZONE)>=1
	and g:GetCount()>0
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_REMOVED,0,1,nil,e,tp)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.e3evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e3fil,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e4fil(c)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()

	return c:IsSetCard(0xce1)
	and c:IsType(TYPE_MONSTER)
	and ((pp==0x1 and np==0x4) or (pp==0x4 and np==0x1) or (pp==0x8 and np==0x1))
end
function s.e4psfil(c,e,tp,eg)
	return c:IsFaceup()
	and c:IsCanChangePosition()
	and not eg:IsContains(c)
end
function s.e4con(e,tp,eg)
	return eg:IsExists(s.e4fil,1,nil)
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if chk==0 then return g:GetCount()>1 end

	-- e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)

	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.e4evt(e,tp,eg)
	local g=Duel.GetMatchingGroup(s.e4psfil,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp,eg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local sel = Group.Select(g,tp,1,1,nil)
	Duel.ChangePosition(sel:GetFirst(),POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
end