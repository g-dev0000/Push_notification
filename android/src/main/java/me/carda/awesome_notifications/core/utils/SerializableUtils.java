package me.carda.awesome_notifications.core.utils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.Serializable;
import java.sql.Time;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;


import me.carda.awesome_notifications.core.models.AbstractModel;

public class SerializableUtils {

    public static final String TAG = "SerializableUtils";

    protected final EnumUtils enumUtils;
    protected final StringUtils stringUtils;
    protected final CalendarUtils calendarUtils;
    protected final TimeZoneUtils timeZoneUtils;

    // ************** SINGLETON PATTERN ***********************

    protected SerializableUtils(
            @NonNull EnumUtils enumUtils,
            @NonNull StringUtils stringUtils,
            @NonNull CalendarUtils calendarUtils,
            @NonNull TimeZoneUtils timeZoneUtils
    ){
        this.enumUtils = enumUtils;
        this.stringUtils = stringUtils;
        this.calendarUtils = calendarUtils;
        this.timeZoneUtils = timeZoneUtils;
    }

    protected static SerializableUtils instance;
    public static SerializableUtils getInstance() {
        if (instance == null)
            instance = new SerializableUtils(
                    EnumUtils.getInstance(),
                    StringUtils.getInstance(),
                    CalendarUtils.getInstance(),
                    TimeZoneUtils.getInstance()
            );
        return instance;
    }

    // ***********************   SERIALIZATION METHODS   *********************************

    public <T extends Calendar> Object serializeCalendar(T value) {
        return calendarUtils.calendarToString(value);
    }

    public <T extends TimeZone> Object serializeTimeZone(T value) {
        return timeZoneUtils.timeZoneToString(value);
    }
}
