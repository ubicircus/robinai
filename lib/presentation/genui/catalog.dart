import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:uuid/uuid.dart';
import 'widgets/info_card.dart';
import 'widgets/status_badge.dart';
import 'widgets/event_card.dart';
import '../services/calendar_event_service.dart';

final robinCatalog = Catalog([
  ...CoreCatalogItems.asCatalog().items,
  CatalogItem(
    name: 'InfoCard',
    dataSchema: Schema.object(
      properties: {
        'title': Schema.string(description: 'The title of the card'),
        'content': Schema.string(description: 'The main body text of the card'),
        'icon': Schema.string(
          description: 'An optional icon name (info, warning, check, error)',
          enumValues: ['info', 'warning', 'check', 'error'],
        ),
      },
      required: ['title', 'content'],
    ),
    widgetBuilder: (itemContext) {
      final properties = itemContext.data as Map<String, dynamic>;
      return InfoCard(
        title: properties['title'] ?? 'No Title',
        content: properties['content'] ?? 'No Content',
        icon: properties['icon'],
      );
    },
  ),
  CatalogItem(
    name: 'StatusBadge',
    dataSchema: Schema.object(
      properties: {
        'label': Schema.string(description: 'The text label on the badge'),
        'status': Schema.string(
          description: 'The status type (success, warning, error, info)',
          enumValues: ['success', 'warning', 'error', 'info'],
        ),
      },
      required: ['label', 'status'],
    ),
    widgetBuilder: (itemContext) {
      final properties = itemContext.data as Map<String, dynamic>;
      return StatusBadge(
        label: properties['label'] ?? 'Unknown',
        status: properties['status'] ?? 'info',
      );
    },
  ),
  CatalogItem(
    name: 'EventCard',
    dataSchema: Schema.object(
      properties: {
        'title': Schema.string(description: 'The title of the calendar event'),
        'startTime': Schema.string(
          description: 'Start time in ISO 8601 format (e.g., "2026-01-20T10:00:00")',
        ),
        'endTime': Schema.string(
          description: 'End time in ISO 8601 format (e.g., "2026-01-20T11:00:00")',
        ),
        'location': Schema.string(description: 'Location of the event'),
        'attendees': Schema.string(
          description: 'Comma-separated list of attendee names or emails, or JSON array as string',
        ),
        'description': Schema.string(description: 'Description or notes for the event'),
      },
      required: ['title', 'startTime'],
    ),
    widgetBuilder: (itemContext) {
      final properties = itemContext.data as Map<String, dynamic>;
      final eventId = const Uuid().v4();
      
      return EventCard(
        title: properties['title'] ?? 'Untitled Event',
        startTime: properties['startTime'] ?? DateTime.now().toIso8601String(),
        endTime: properties['endTime'],
        location: properties['location'],
        attendees: properties['attendees'] != null
            ? List<String>.from(properties['attendees'])
            : null,
        description: properties['description'],
        eventId: eventId,
        onStatusChange: (eventId, status, error) {
          // Notify the calendar event service
          CalendarEventService.instance.notifyStatusChange(
            eventId: eventId,
            status: status,
            error: error,
            eventTitle: properties['title'] ?? 'Untitled Event',
          );
        },
      );
    },
  ),
], catalogId: 'a2ui.org:standard_catalog_0_8_0');
