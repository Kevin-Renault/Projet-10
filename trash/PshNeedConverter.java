package com.openclassrooms.yourwayapi.converter;

import com.openclassrooms.yourwayapi.entity.YourWayUserEntity;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import java.util.Locale;

@Converter(autoApply = true)
public class PshNeedConverter implements AttributeConverter<YourWayUserEntity.PshNeed, String> {

    @Override
    public String convertToDatabaseColumn(YourWayUserEntity.PshNeed attribute) {
        return attribute == null ? null : attribute.name().toLowerCase(Locale.ROOT);
    }

    @Override
    public YourWayUserEntity.PshNeed convertToEntityAttribute(String dbData) {
        if (dbData == null) {
            return null;
        }
        try {
            return YourWayUserEntity.PshNeed.valueOf(dbData.toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
