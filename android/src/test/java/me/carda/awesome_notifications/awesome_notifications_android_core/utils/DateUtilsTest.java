package me.carda.awesome_notifications.awesome_notifications_android_core.utils;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

import me.carda.awesome_notifications.awesome_notifications_android_core.exceptions.AwesomeNotificationException;

import static org.junit.Assert.*;

public class DateUtilsTest {

    String localTimezone, utcTimezone, stringMillennialBug, stringMillennialBugLagged;
    Date dateMillennialBug, dateMillennialBugLagged;

    @Before
    public void setUp() throws Exception {

        localTimezone = "GMT+08:00";
        utcTimezone = DateUtils.utcTimeZone.toString();
        stringMillennialBug = "2000-01-01 00:00:00";
        stringMillennialBugLagged = "2000-01-01 08:00:00";

        dateMillennialBug =
                Date.from(Instant.parse("2000-01-01T00:00:00.000Z"));

        DateTimeFormatter formatter =
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss zzz", Locale.ENGLISH);

        dateMillennialBugLagged =
                Date.from(
                    formatter.parse("2000-01-01 00:00:00 +08:00", Instant::from));
    }

    @After
    public void tearDown() throws Exception {
    }

    @Test
    public void cleanTimeZoneIdentifier(){
        assertEquals("Simple time zone must be extracted from complex time zone identifier",
                "America/Sao_Paulo",
                DateUtils.cleanTimeZoneIdentifier("sun.util.calendar.ZoneInfo[id=\"America/Sao_Paulo\",offset=-10800000,dstSavings=0,useDaylight=false,transitions=93,lastRule=null]"));

        assertEquals("Simple time zone must be extracted from complex time zone identifier",
                "GMT",
                DateUtils.cleanTimeZoneIdentifier("sun.util.calendar.ZoneInfo[id=\"GMT\",offset=0,dstSavings=0,useDaylight=false,transitions=0,lastRule=null]"));

        assertEquals("Simple time zone must be extracted from complex time zone identifier",
                "UTC",
                DateUtils.cleanTimeZoneIdentifier("sun.util.calendar.ZoneInfo[id=\"UTC\",offset=0,dstSavings=0,useDaylight=false,transitions=0,lastRule=null]"));

        assertEquals("Simple time zone must be preserved","America/Sao_Paulo", DateUtils.cleanTimeZoneIdentifier("America/Sao_Paulo"));
        assertEquals("Simple time zone must be preserved","GMT", DateUtils.cleanTimeZoneIdentifier("GMT"));
        assertEquals("Simple time zone must be preserved","UTC", DateUtils.cleanTimeZoneIdentifier("UTC"));
        assertEquals("Simple time zone must be preserved","GMT+08:00", DateUtils.cleanTimeZoneIdentifier("GMT+08:00"));
    }

    @Test
    public void stringToDate() throws AwesomeNotificationException {

        Date date1 = DateUtils.stringToDate(
                stringMillennialBug,
                utcTimezone);
        assertEquals("The parsed string must return the expected date object",
                dateMillennialBug, date1);

        Date date2 = DateUtils.stringToDate(
                stringMillennialBug,
                localTimezone);
        assertEquals("The parsed string must respect the timezone",
                dateMillennialBugLagged, date2);
    }

    @Test
    public void dateToString() {
        try {
            assertEquals("Date was not correctly converted into a string",
                    stringMillennialBug,
                    DateUtils.dateToString(dateMillennialBug, utcTimezone));

            assertEquals("Date does not respect time zone",
                    stringMillennialBugLagged,
                    DateUtils.dateToString(dateMillennialBug, localTimezone));

        } catch (AwesomeNotificationException e) {
            e.printStackTrace();
        }
    }

    @Test
    public void shiftToTimeZone() throws ParseException {
        TimeZone shiftedTimeZone = TimeZone.getTimeZone("GMT+08:00");

        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US);
        simpleDateFormat.setTimeZone(shiftedTimeZone);
        Date dateShifted = simpleDateFormat.parse("2000-01-01 08:00:00");

        assertEquals("Time zone was not correctly shifted",
                dateShifted, DateUtils.shiftToTimeZone(dateMillennialBug, shiftedTimeZone));
    }

    @Test
    public void getLocalDate() throws AwesomeNotificationException {
        String realLocalTimeZoneId = DateUtils.localTimeZone.toString();

        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US);
        simpleDateFormat.setTimeZone(DateUtils.localTimeZone);
        String now = simpleDateFormat.format(new Date());

        assertEquals("Local date printed was not equal to local", now, DateUtils.getLocalDate(realLocalTimeZoneId));
        assertEquals("Local date printed without timezone was equal to local", now, DateUtils.getLocalDate(null));
    }

    @Test
    public void getUTCDate() {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US);
        simpleDateFormat.setTimeZone(DateUtils.utcTimeZone);
        String now = simpleDateFormat.format(new Date());

        assertEquals("The date printed as UTC is different from current UTC date", now, DateUtils.getUTCDate());
    }

    @Test
    public void getUTCDateTime() {
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeZone(DateUtils.utcTimeZone);
        calendar.set(Calendar.MILLISECOND, 0);
        Date utcDate =  calendar.getTime();

        assertEquals("The UTC date is different from current UTC date", utcDate, DateUtils.getUTCDateTime());
    }

    @Test
    public void getLocalDateTime() throws AwesomeNotificationException {
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeZone(DateUtils.localTimeZone);
        calendar.set(Calendar.MILLISECOND, 0);

        Date utcDate =  calendar.getTime();
        Date returned = DateUtils.getLocalDateTime(DateUtils.localTimeZone.toString());

        assertEquals("", utcDate.toString(), returned.toString());
    }

    @Test
    public void getTimeZone() throws AwesomeNotificationException {

        assertEquals("UTC", DateUtils.getTimeZone("UTC").getID());

        assertThrows(AwesomeNotificationException.class,
                () -> { DateUtils.getTimeZone("+08:00"); });

        assertThrows(AwesomeNotificationException.class,
                () -> { DateUtils.getTimeZone("AAA"); });

        assertThrows(AwesomeNotificationException.class,
                () -> { DateUtils.getTimeZone(""); });

        assertEquals("GMT-04:00", DateUtils.getTimeZone("GMT-04:00").getID());
        assertEquals("America/Sao_Paulo", DateUtils.getTimeZone("America/Sao_Paulo").getID());
    }
}