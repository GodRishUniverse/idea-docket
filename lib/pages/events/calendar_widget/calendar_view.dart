import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalenderWidgetForEvents extends StatefulWidget {
  final List<Event> events;
  const CalenderWidgetForEvents({
    super.key,
    required this.events,
  });

  @override
  State<CalenderWidgetForEvents> createState() =>
      _CalenderWidgetForEventsState();
}

class _CalenderWidgetForEventsState extends State<CalenderWidgetForEvents> {
  int colourBlindnessIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteUsed,
      appBar: AppBar(
        backgroundColor: darkBackground,
        foregroundColor: orangeUsed,
        elevation: 5.0,
        title: Text(
          "Calendar View for Events",
          style: TextStyle(
            color: colorBlindness(
              orangeUsed,
              returnColorBlindNessTypeFromIndex(
                colourBlindnessIndex,
              ),
            ),
            fontFamily: "GilroyBold",
            fontSize: 19,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorBlindness(
            whiteUsed,
            returnColorBlindNessTypeFromIndex(
              colourBlindnessIndex,
            ),
          ),
        ),
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SfCalendar(
            headerHeight: 60,
            headerStyle: CalendarHeaderStyle(
              textStyle: const TextStyle(
                fontFamily: "GilroyBold",
                fontSize: 22,
              ),
              backgroundColor: colorBlindness(
                whiteUsed,
                returnColorBlindNessTypeFromIndex(
                  colourBlindnessIndex,
                ),
              ),
            ),
            backgroundColor: colorBlindness(
              whiteUsed,
              returnColorBlindNessTypeFromIndex(
                colourBlindnessIndex,
              ),
            ),
            todayHighlightColor: colorBlindness(
              orangeUsed,
              returnColorBlindNessTypeFromIndex(
                colourBlindnessIndex,
              ),
            ),
            cellBorderColor: null,
            initialSelectedDate: DateTime.now(),
            view: CalendarView.day,
            allowedViews: const <CalendarView>[
              CalendarView.day,
              CalendarView.week,
              CalendarView.month,
              CalendarView.timelineDay,
            ],
            firstDayOfWeek: 1,
            dataSource: EventDataSource(widget.events),
            appointmentTextStyle: const TextStyle(
              color: greyUsed,
              fontFamily: 'Gilroy',
            ),
            monthViewSettings: MonthViewSettings(
              numberOfWeeksInView: 6,
              showAgenda: true,
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              agendaStyle: AgendaStyle(
                backgroundColor: colorBlindness(
                  whiteUsed,
                  returnColorBlindNessTypeFromIndex(
                    colourBlindnessIndex,
                  ),
                ),
                appointmentTextStyle: const TextStyle(
                  color: blackUsed,
                ),
              ),
              monthCellStyle: const MonthCellStyle(
                textStyle: TextStyle(
                  fontFamily: 'Gilroy',
                  color: blackUsed,
                ),
                leadingDatesTextStyle: TextStyle(
                  fontFamily: 'Gilroy',
                  color: greyUsedOpacityLowered,
                ),
                trailingDatesTextStyle: TextStyle(
                  fontFamily: 'Gilroy',
                  color: greyUsedOpacityLowered,
                ),
              ),
            ),
            viewHeaderStyle: ViewHeaderStyle(
              dayTextStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: blackUsed,
              ),
              dateTextStyle: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: colorBlindness(
                  orangeUsed,
                  returnColorBlindNessTypeFromIndex(
                    colourBlindnessIndex,
                  ),
                ),
              ),
            ),
            timeSlotViewSettings: TimeSlotViewSettings(
              timeTextStyle: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 16,
                color: colorBlindness(
                  greyUsed,
                  returnColorBlindNessTypeFromIndex(
                    colourBlindnessIndex,
                  ),
                ),
              ),
              timelineAppointmentHeight: 60,
              timeIntervalHeight: 60,
              timeIntervalWidth: 60,
            ),
            onTap: (CalendarTapDetails details) {
              if (details.targetElement == CalendarElement.appointment) {
                final Event appointment = details.appointments!.first;
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog.adaptive(
                      backgroundColor: colorBlindness(
                        appointment.color,
                        returnColorBlindNessTypeFromIndex(
                          colourBlindnessIndex,
                        ),
                      ),
                      title: Text(appointment.title),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date: ${DateFormat.yMMMMd().format(appointment.date.toDate())}",
                            style: TextStyle(
                              color: blackUsed.withOpacity(0.9),
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            'From ${DateFormat.jm().format(appointment.dateWithStartTime.toDate())} to ${DateFormat.jm().format(appointment.dateWithEndTime.toDate())}',
                            style: TextStyle(
                              color: blackUsed.withOpacity(0.9),
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            'Description: ${appointment.description}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> source) {
    appointments = source;
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  String? getNotes(int index) {
    return appointments![index].description;
  }

  @override
  DateTime getStartTime(int index) {
    return (appointments![index].dateWithStartTime).toDate();
  }

  @override
  DateTime getEndTime(int index) {
    return (appointments![index].dateWithEndTime).toDate();
  }

  @override
  Color getColor(int index) {
    return appointments![index].color;
  }
}
