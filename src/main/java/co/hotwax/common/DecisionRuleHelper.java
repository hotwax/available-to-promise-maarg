package co.hotwax.common;
import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTCreator;
import com.auth0.jwt.algorithms.Algorithm;
import org.moqui.entity.EntityCondition;
import org.moqui.entity.EntityValue;
import org.moqui.impl.context.ExecutionContextFactoryImpl;
import org.moqui.impl.entity.EntityConditionFactoryImpl;
import org.moqui.util.SystemBinding;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.cache.Cache;
import java.time.Instant;
import java.time.ZonedDateTime;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.Map;
import java.util.List;


public class DecisionRuleHelper {
    protected static final Logger logger = LoggerFactory.getLogger(DecisionRuleHelper.class);

    public static String makeDroolsCondition(EntityValue ev) {
        StringBuilder condition = new StringBuilder();
        Object value = ev.get("fieldValue");
        Object field = ev.get("fieldName");
        boolean multiValued = false;
        if ("Y".equals(ev.get("multiValued"))) {
            multiValued = true;
        }
        EntityCondition.ComparisonOperator operator = EntityConditionFactoryImpl.getComparisonOperator(ev.getString("operator"));

        switch (operator) {
            case EQUALS:
                if (multiValued) {
                    condition.append(field).append(" contains \"").append(value).append("\"");
                } else {
                    condition.append(field).append(" == \"").append(value).append("\"");
                }
                break;
            case NOT_EQUAL:
                if (multiValued) {
                    condition.append(field).append(" not contains \"").append(value).append("\"");
                } else {
                    condition.append(field).append(" != \"").append(value).append("\"");
                }
                break;
            case GREATER_THAN:
                condition.append(field).append(" > ").append(value);
                break;
            case GREATER_THAN_EQUAL_TO:
                condition.append(field).append(" >= ").append(value);
                break;
            case LESS_THAN:
                condition.append(field).append(" < ").append(value);
                break;
            case LESS_THAN_EQUAL_TO:
                condition.append(field).append(" <= ").append(value);
                break;
            case IN:
                List<String> fieldValuesIn = (List<String>) valueToCollection(value);
                if (multiValued) {
                    condition.append("(");
                    boolean isFirstValue = true;
                    for (String fieldValue : fieldValuesIn) {
                        if (!isFirstValue) {
                            condition.append(" || ");
                        }
                        condition.append(field).append(" contains \"").append(fieldValue).append("\"");
                        isFirstValue = false;
                    }
                    condition.append(")");
                } else {
                    boolean isFirstValue = true;
                    condition.append(field).append(" in (");
                    for (String fieldValue : fieldValuesIn) {
                        if (!isFirstValue) {
                            condition.append(", ");
                        }
                        condition.append("\""+ fieldValue + "\"");
                        isFirstValue = false;
                    }
                    condition.append(")");
                }
                break;
            case NOT_IN:
                List<String> fieldValuesNotIn = (List<String>) valueToCollection(value);
                if (multiValued) {
                    condition.append("(");
                    boolean isFirstValue = true;
                    for (String fieldValue : fieldValuesNotIn) {
                        if (!isFirstValue) {
                            condition.append(" && ");
                        }
                        condition.append(field).append(" not contains \"").append(fieldValue).append("\"");
                        isFirstValue = false;
                    }
                    condition.append(")");
                } else {
                    condition.append(field).append(" notin (");
                    boolean isFirstValue = true;
                    for (String fieldValue : fieldValuesNotIn) {
                        if (!isFirstValue) {
                            condition.append(", ");
                        }
                        condition.append("\""+ fieldValue + "\"");
                        isFirstValue = false;
                    }
                    condition.append(")");
                }
                break;
        }
        return condition.toString();
    }

    public static Object valueToCollection(Object value) {
        if (value instanceof CharSequence) {
            String valueStr = value.toString();
            // note: used to do this, now always put in List: if (valueStr.contains(","))
            value = Arrays.asList(valueStr.split(","));
        }
        // TODO: any other useful types to convert?
        return value;
    }
    @Deprecated
    public static String getOmsJwtToken(ExecutionContextFactoryImpl ecfi) {
        //TODO: For now just hardcode the SystemMessageRemote, need to find a better way to do this
        EntityValue tokenSysMessage = ecfi.entityFacade.find("moqui.service.message.SystemMessageRemote")
                .condition("systemMessageRemoteId", "HC_OMS_CONFIG").useCache(true).disableAuthz().one();
        if (tokenSysMessage != null) {
            return tokenSysMessage.getString("remotePublicKey");
        }
        return null;
    }
    @Deprecated
    public static String getOmsInstanceUrl(ExecutionContextFactoryImpl ecfi) {
        //TODO: For now just hardcode the SystemMessageRemote, need to find a better way to do this
        EntityValue omsInstance = ecfi.entityFacade.find("moqui.service.message.SystemMessageRemote")
                .condition("systemMessageRemoteId", "HC_OMS_CONFIG").useCache(true).disableAuthz().one();
        if (omsInstance != null) {
            return omsInstance.getString("sendUrl");
        } else {
            EntityValue omsInstanceProperty = ecfi.entityFacade.find("org.apache.ofbiz.common.property.SystemProperty")
                    .condition("systemResourceId", "url").condition("systemPropertyId" , "content.url.prefix.secure").useCache(true).disableAuthz().one();
            if (omsInstanceProperty != null) {
                return omsInstanceProperty.getString("systemPropertyValue");
            }
        }
        return null;
    }
}
