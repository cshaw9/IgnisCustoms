--Draco, The Polygod Dragon
local s,id,o=GetID()
-- c210000038
function s.initial_effect(c)
	-- 1 “Polygod” Tuner + 1 non-Tuner “Polygod” monster
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xce1),1,1,Synchro.NonTunerEx(Card.IsSetCard,0xce1),1,1)
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
	-- When this card is Synchro Summoned: Inflict damage to your opponent equal to the number of monsters in your banishment x 100.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	-- If this card is destroyed by battle, while in Defense Position: Inflict 2000 damage to your opponent.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
function s.e1con(e)
	return e:GetHandler():GetDestination()==LOCATION_GRAVE
end
function s.e2fil(c)
	return c:IsFaceup()
	and c:IsType(TYPE_MONSTER)
end
function s.e2con(e,tp)
	local g=Duel.GetMatchingGroup(s.e2fil,tp,LOCATION_REMOVED,0,nil,e,tp)

	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
	and g:GetCount()>=1
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	local g=Duel.GetMatchingGroup(s.e2fil,tp,LOCATION_REMOVED,0,nil,e,tp)
	local dmg=g:GetCount()*100

	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg)
end
function s.e2evt(e,tp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)

	local g=Duel.GetMatchingGroup(s.e2fil,tp,LOCATION_REMOVED,0,nil,e,tp)
	local dmg=g:GetCount()*100

	Duel.Damage(p,dmg,REASON_EFFECT)
end
function s.e3con(e,tp)
	local c=e:GetHandler()

	return c:IsReason(REASON_BATTLE)
	and c:IsPreviousControler(tp)
	and (c:GetBattlePosition()==POS_FACEUP_DEFENSE or c:GetBattlePosition()==POS_FACEDOWN_DEFENSE)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(2000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
function s.e3evt(e)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end