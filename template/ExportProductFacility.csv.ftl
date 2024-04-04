<#if products?has_content>
  <#assign firstProduct = products?first/>
  <#if "Y" != skipHeader!>
    <#list firstProduct.keySet() as field>"${field}",</#list>
  </#if>
  <#list products as product>
    <#list firstProduct.keySet() as field>"${product[field]}",</#list>
  </#list>
</#if>