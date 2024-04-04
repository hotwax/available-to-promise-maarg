<#assign decisionRules = ec.entity.find("co.hotwax.common.DecisionRule").condition("ruleGroupId", ruleGroupId).condition("statusId", "ATP_RULE_ACTIVE").orderBy("sequenceNum asc").list()!>
<#if decisionRules?has_content>

  <#-- Set the package and imports -->
  package co.hotwax.product;
  dialect "mvel"
  import org.moqui.util.ContextStack;
  import java.math.BigDecimal;
  import java.util.HashMap;
  global org.moqui.context.ExecutionContext ec;
  global java.util.Map productFacilityDetail;

  <#assign ruleCount = decisionRules?size>
  <#list decisionRules as decisionRule>
    <#assign ruleActions = ec.entity.find("co.hotwax.common.RuleAction").condition("ruleId", decisionRule.ruleId).orderBy("sequenceNum asc").list()!>
    <#assign ruleConditions = ec.entity.find("co.hotwax.common.RuleCondition").condition("ruleId", decisionRule.ruleId).condition("conditionTypeEnumId", "ENTCT_ATP_FILTER").orderBy("sequenceNum asc").list()!>
    <#assign facilityConditions = ec.entity.find("co.hotwax.common.RuleCondition").condition("ruleId", decisionRule.ruleId).condition("conditionTypeEnumId", "ENTCT_ATP_FACILITIES").list()!>
    <#assign facilityIds = []/>
    <#if facilityConditions?has_content>
      <#assign facilityCondition = facilityConditions?first/>
      <#assign facilityIds = Static["co.hotwax.common.DecisionRuleHelper"].valueToCollection(facilityCondition.fieldValue)/>
    </#if>
    <#if !facilityIds?has_content>
      <#assign facilityGroupConditions = ec.entity.find("co.hotwax.common.RuleCondition").condition("ruleId", decisionRule.ruleId).condition("conditionTypeEnumId", "ENTCT_ATP_FAC_GROUPS").list()!>
        <#if facilityGroupConditions?has_content>
          <#assign facilityGroupCondition = facilityGroupConditions?first/>
          <#assign facilityGroupIds = Static["co.hotwax.common.DecisionRuleHelper"].valueToCollection(facilityGroupCondition.fieldValue)>
          <#assign facilityGroupMembers = ec.entity.find("org.apache.ofbiz.product.facility.FacilityGroupMember").condition("facilityGroupId", "in", facilityGroupIds).list()!>
          <#list facilityGroupMembers as facilityGroupMember>
            <#assign facilityIds = facilityIds + [facilityGroupMember.facilityId]>
          </#list>
        </#if>
    </#if>
    <#if facilityIds?has_content>
      rule "${decisionRule.ruleId}"
      salience ${ruleCount}
      when
       $product : Map(<#list ruleConditions as ruleCondition><#if ruleCondition_index gt 0>,</#if> ${Static["co.hotwax.common.DecisionRuleHelper"].makeDroolsCondition(ruleCondition)!}</#list>)
      then
        <#list ruleActions as ruleAction>
          <#list facilityIds as facilityId>
            $actionValues = new HashMap();
            $actionValues.put("${ruleAction.fieldName}", ${ruleAction.fieldValue})
            $actionValues.put("facility_id", "${facilityId}")
            $actionValues.put("product_id", $product.get("productId"))
            productFacilityDetail.put("${facilityId}-" + $product.get("productId"), $actionValues);
          </#list>
        </#list>
      end
    </#if>
    <#assign ruleCount = ruleCount - 1>
  </#list>
</#if>