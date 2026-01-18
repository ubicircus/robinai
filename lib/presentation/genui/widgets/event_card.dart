import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class EventCard extends StatefulWidget {
  final String title;
  final String startTime; // ISO 8601 format or parseable date string
  final String? endTime; // ISO 8601 format or parseable date string
  final String? location;
  final List<String>? attendees;
  final String? description;
  final String? eventId; // Unique ID for this event instance
  final Function(String eventId, String status, String? error)? onStatusChange;

  const EventCard({
    super.key,
    required this.title,
    required this.startTime,
    this.endTime,
    this.location,
    this.attendees,
    this.description,
    this.eventId,
    this.onStatusChange,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  // Static map to persist event status across widget recreations (for history)
  static final Map<String, String> _eventStatusCache = {};
  static final Map<String, String?> _eventErrorCache = {};
  
  String _status = 'pending'; // pending, granted, denied, created, failed
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // Restore status from cache if available
    if (widget.eventId != null && _eventStatusCache.containsKey(widget.eventId)) {
      _status = _eventStatusCache[widget.eventId]!;
      _errorMessage = _eventErrorCache[widget.eventId];
    }
  }
  
  void _updateStatus(String status, [String? error]) {
    setState(() {
      _status = status;
      _errorMessage = error;
    });
    // Cache the status for persistence
    if (widget.eventId != null) {
      _eventStatusCache[widget.eventId!] = status;
      _eventErrorCache[widget.eventId!] = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: _getStatusColor(),
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event,
                    color: _getStatusColor(),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                  ),
                  if (_status == 'denied' || _status == 'failed')
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.access_time, _formatDateTime(widget.startTime)),
              if (widget.endTime != null)
                _buildInfoRow(
                    Icons.access_time_filled, _formatDateTime(widget.endTime!)),
              if (widget.location != null)
                _buildInfoRow(Icons.location_on, widget.location!),
              if (widget.attendees != null && widget.attendees!.isNotEmpty) ...[
                _buildInfoRow(
                    Icons.people,
                    widget.attendees!.join(', '),
                ),
                if (Platform.isIOS)
                  Padding(
                    padding: const EdgeInsets.only(left: 24, top: 4, bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Attendees shown for reference only on iOS. Add attendees manually in the calendar app.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              if (widget.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              _buildActionButton(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_status == 'created') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            Text(
              'Event added to calendar',
              style: TextStyle(color: Colors.green, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_status == 'denied' || _status == 'failed') {
      final isPermanentlyDenied = _errorMessage?.contains('permanently denied') ?? false;
      
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _retryAddToCalendar,
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          if (isPermanentlyDenied) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await openAppSettings();
                    },
                    icon: Icon(Icons.settings, size: 18),
                    label: Text('Open Settings'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }

    String buttonText;
    IconData buttonIcon;
    
    if (_status == 'requesting') {
      buttonText = 'Adding...';
      buttonIcon = Icons.hourglass_empty;
    } else {
      buttonText = 'Add to Calendar';
      buttonIcon = Icons.calendar_today;
    }
    
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _status == 'requesting' ? null : _addToCalendar,
            icon: Icon(buttonIcon, size: 18),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              disabledBackgroundColor: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_status) {
      case 'created':
        return Colors.green;
      case 'denied':
      case 'failed':
        return Colors.orange;
      case 'granted':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final dateFormat = DateFormat('MMM d, yyyy');
      final timeFormat = DateFormat('h:mm a');
      return '${dateFormat.format(dateTime)} at ${timeFormat.format(dateTime)}';
    } catch (e) {
      return dateTimeStr; // Return original if parsing fails
    }
  }
  
  String? _optionalString(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Attendee? _buildAttendee(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final bracketMatch = RegExp(r'<([^>]+@[^>]+)>').firstMatch(trimmed);
    if (bracketMatch != null) {
      final email = bracketMatch.group(1);
      if (email == null || email.isEmpty) return null;
      final name = trimmed.replaceAll(bracketMatch.group(0) ?? '', '').trim();
      return Attendee(
        name: name.isEmpty ? email : name,
        emailAddress: email,
        role: AttendeeRole.Required,
      );
    }

    if (!trimmed.contains('@')) return null;
    return Attendee(
      name: trimmed,
      emailAddress: trimmed,
      role: AttendeeRole.Required,
    );
  }

  Future<void> _addToCalendar() async {
    debugPrint('EventCard: _addToCalendar called, current status: $_status');
    
    if (!mounted) return;
    
    _updateStatus('requesting', null);

    try {
      debugPrint('EventCard: Parsing dates...');
      // Parse dates
      final startDate = DateTime.parse(widget.startTime);
      final endDate = widget.endTime != null
          ? DateTime.parse(widget.endTime!)
          : startDate.add(const Duration(hours: 1));

      debugPrint('EventCard: Initializing device calendar plugin...');
      // Initialize device calendar plugin
      final deviceCalendarPlugin = DeviceCalendarPlugin();
      
      // Request permissions through device_calendar (it uses EventKit directly)
      debugPrint('EventCard: Requesting calendar permissions through device_calendar...');
      final hasPermissionsResult = await deviceCalendarPlugin.hasPermissions();
      final hasPermissions = hasPermissionsResult.data ?? false;
      debugPrint('EventCard: hasPermissions = $hasPermissions');
      
      if (!hasPermissions) {
        debugPrint('EventCard: No permissions, requesting...');
        final requestResult = await deviceCalendarPlugin.requestPermissions();
        final granted = requestResult.data ?? false;
        debugPrint('EventCard: requestPermissions returned: $granted');
        
        if (!granted) {
          debugPrint('EventCard: Permission request was denied');
          _updateStatus('denied', 'Calendar permission was denied. Please enable it in Settings.');
          widget.onStatusChange?.call(
            widget.eventId ?? '',
            'denied',
            'Calendar permission denied',
          );
          return;
        }
      }

      debugPrint('EventCard: Permission granted, retrieving calendars...');
      
      // Get default calendar
      final calendarsResult = await deviceCalendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data == null || calendarsResult.data!.isEmpty) {
        debugPrint('EventCard: Failed to retrieve calendars');
        _updateStatus('failed', 'Failed to access calendar. Please check your calendar permissions.');
        widget.onStatusChange?.call(
          widget.eventId ?? '',
          'failed',
          'Failed to retrieve calendars',
        );
        return;
      }
      
      // Use the first available calendar (or default calendar)
      final calendar = calendarsResult.data!.firstWhere(
        (cal) => cal.isDefault ?? false,
        orElse: () => calendarsResult.data!.first,
      );
      
      debugPrint('EventCard: Using calendar: ${calendar.name}, ID: ${calendar.id}');
      
      // Validate calendar ID
      if (calendar.id == null || calendar.id!.isEmpty) {
        debugPrint('EventCard: Calendar ID is null or empty');
        _updateStatus('failed', 'Invalid calendar selected.');
        widget.onStatusChange?.call(
          widget.eventId ?? '',
          'failed',
          'Invalid calendar ID',
        );
        return;
      }
      
      // Create event directly (like Claude does)
      // Only include optional fields if they have actual values
      // EventKit crashes if null values are passed for optional string fields
      final startTz = tz.TZDateTime.from(startDate, tz.UTC);
      final endTz = tz.TZDateTime.from(endDate, tz.UTC);
      
      // EventKit on iOS does not allow programmatically setting attendees.
      // Skip attendees on iOS to avoid PlatformException(500).
      final bool allowAttendees = !Platform.isIOS;
      if (!allowAttendees && widget.attendees != null && widget.attendees!.isNotEmpty) {
        debugPrint('EventCard: Skipping attendees on iOS (not supported by EventKit)');
      }

      // Build attendees list only when allowed and when we have valid emails.
      List<Attendee>? attendeesList;
      if (allowAttendees && widget.attendees != null && widget.attendees!.isNotEmpty) {
        final validAttendees = widget.attendees!
            .map(_buildAttendee)
            .whereType<Attendee>()
            .toList();
        if (validAttendees.isNotEmpty) {
          attendeesList = validAttendees;
        }
      }
      
      // Create event with required fields.
      // For optional fields, omit them when empty to avoid NSNull on iOS.
      final event = Event(
        calendar.id!,
        title: widget.title,
        start: startTz,
        end: endTz,
        description: _optionalString(widget.description),
        location: _optionalString(widget.location),
        attendees: attendeesList, // null is fine for attendees list
      );
      
      debugPrint('EventCard: Created event object: title=${event.title}, description=${event.description ?? "null"}, location=${event.location ?? "null"}, attendees=${event.attendees?.length ?? 0}');
      
      final createEventResult = await deviceCalendarPlugin.createOrUpdateEvent(event);
      
      if (createEventResult == null) {
        debugPrint('EventCard: createOrUpdateEvent returned null');
        _updateStatus('failed', 'Failed to add event to calendar.');
        widget.onStatusChange?.call(
          widget.eventId ?? '',
          'failed',
          'createOrUpdateEvent returned null',
        );
        return;
      }
      
      debugPrint('EventCard: createOrUpdateEvent returned: isSuccess=${createEventResult.isSuccess}, data=${createEventResult.data}');
      debugPrint('EventCard: Widget mounted: $mounted');

      if (!mounted) {
        debugPrint('EventCard: Widget no longer mounted, skipping state update');
        return;
      }

      if (createEventResult.isSuccess && createEventResult.data != null) {
        // Success - event was added directly to calendar
        debugPrint('EventCard: Event added successfully with ID: ${createEventResult.data}');
        _updateStatus('created', null);
        widget.onStatusChange?.call(
          widget.eventId ?? '',
          'created',
          null,
        );
      } else {
        // Failed to add event
        final errors = createEventResult.errors;
        final errorMsg = errors.isNotEmpty
            ? errors.first.errorMessage
            : 'Failed to add event to calendar.';
        debugPrint('EventCard: Event addition failed: $errorMsg');
        _updateStatus('failed', errorMsg);
        widget.onStatusChange?.call(
          widget.eventId ?? '',
          'failed',
          errorMsg,
        );
      }
    } catch (e, stackTrace) {
      // Handle different types of errors
      debugPrint('EventCard: Exception caught: $e');
      debugPrint('EventCard: Stack trace: $stackTrace');
      
      final errorStr = e.toString();
      String status;
      String errorMsg;

      if (errorStr.contains('permission') || errorStr.contains('Permission')) {
        status = 'denied';
        errorMsg = 'Calendar permission is required. Please enable it in your device settings.';
      } else if (errorStr.contains('MissingPluginException')) {
        status = 'failed';
        errorMsg = 'Calendar plugin not available. Please restart the app.';
      } else {
        status = 'failed';
        errorMsg = 'Error: ${e.toString()}';
      }

      if (mounted) {
        _updateStatus(status, errorMsg);
        widget.onStatusChange?.call(
          widget.eventId ?? '',
          status,
          errorMsg,
        );
      }
    }
  }

  Future<void> _retryAddToCalendar() async {
    _updateStatus('pending', null);
    await _addToCalendar();
  }
}
