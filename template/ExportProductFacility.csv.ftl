<#if products?has_content>
  <#assign firstProduct = products?first/>
  <#if "Y" != skipHeader!>
    <#list firstProduct.keySet() as field>${field}<#if (firstProduct.keySet()?size -1) != field_index>,</#if><#t></#list>
  </#if>
  <#list products as product>
    <#list firstProduct.keySet() as field>${product[field]}<#if (firstProduct.keySet()?size -1) != field_index>,</#if><#t></#list>
  </#list>
</#if>