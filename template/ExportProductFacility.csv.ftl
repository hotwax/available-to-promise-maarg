<#if products?has_content>
  <#assign firstProduct = products?first/>
  <#assign csvField = "">
  <#list firstProduct.keySet() as fieldName>
    <#if fieldName != "product-id" && fieldName != "facility-id">
      <#assign csvField = fieldName>
      <#break>
    </#if>
  </#list>
  <#if "allow-brokering" == csvField>
    <#assign entityField = "allowBrokering" />
  <#elseif "allow-pickup" == csvField>
    <#assign entityField = "allowPickup" />
  <#else>
    <#assign entityField = "minimumStock" />
  </#if>
  <#if "Y" != skipHeader!>
    <#list firstProduct.keySet() as field>"${field}",</#list>
  </#if>
  <#list products as product>
    <#assign productFacility = ec.entity.find("org.apache.ofbiz.product.facility.ProductFacility").condition("productId", product['product-id']).condition("facilityId", product['facility-id']).selectField("allowBrokering, allowPickup, minimumStock").one()!>
    <#if !productFacility?has_content || productFacility[entityField]?string != product[csvField]?string>
      <#list firstProduct.keySet() as field>${product[field]}<#if field_has_next>,</#if><#t></#list>
    </#if>
  </#list>
</#if>
