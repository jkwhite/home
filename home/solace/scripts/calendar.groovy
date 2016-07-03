import org.jdesktop.swingx.JXMonthView;
import java.util.Calendar;
import java.util.Date;


cal = { year=null, month=null ->
    if(year==null) {
        if(month==null) {
            new JXMonthView()
        }
        else {
            def c = Calendar.instance; c[c.MONTH] = month; c[c.DATE] = 1
            new JXMonthView(firstDisplayedDate:c.time.time)
        }
    }
    else {
        if(month==null) {
            (0..11).collect { def c = Calendar.instance; c[c.MONTH] = it; c[c.DATE] = 1; new JXMonthView(firstDisplayedDate:c.time.time) }.table(3)
        }
        else {
            def c = Calendar.instance; c[c.MONTH] = month; c[c.YEAR] = year; c[c.DATE] = 1
            new JXMonthView(firstDisplayedDate:c.time.time)
        }
    }
}
