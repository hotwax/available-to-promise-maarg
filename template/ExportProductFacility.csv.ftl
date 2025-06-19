<#if products?has_content>
  <#assign firstProduct = products?first/>
  <#if "Y" != skipHeader!>
    <#list firstProduct.keySet() as field>${field}<#if field_has_next>,</#if><#t></#list>
  </#if>
  <#list products as product>
    <#list firstProduct.keySet() as field>${product[field]}<#if field_has_next>,</#if><#t></#list>
  </#list>
</#if>