--Polygod Mirror Force
local s,id,o=GetID()
-- c210000031
function s.initial_effect(c)
	--[[
	When your face-up Defense Position monster whose DEF is lower than its ATK,
	or your Attack Position monster whose ATK is lower than its DEF, is targeted for an attack:
	Banish all Attack Position monsters your opponent controls.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
function s.e1fil(c)
	return c:IsAttackPos()
	and c:IsAbleToRemove()
end
function s.e1con(e,tp)
	local d=Duel.GetAttackTarget()

	return d
	and d:IsFaceup()
	and d:IsType(TYPE_MONSTER)
	and d:IsControler(tp)
	and ((d:IsDefensePos() and d:GetDefense()<d:GetAttack())
		or (d:IsAttackPos() and d:GetAttack()<d:GetDefense()))
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1fil,tp,0,LOCATION_MZONE,1,nil)
	end
	
	local g=Duel.GetMatchingGroup(s.e1fil,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
function s.e1evt(e,tp)
	local g=Duel.GetMatchingGroup(s.e1fil,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end